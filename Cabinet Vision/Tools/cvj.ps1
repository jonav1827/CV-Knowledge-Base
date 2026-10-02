# cvj.ps1 - read-only reader for Cabinet Vision job files (.cvj)
#
# Load it:   . "<repo>\Cabinet Vision\Tools\cvj.ps1"
# Use it:    $job = Open-Cvj 'C:\path\job.cvj'
#            Get-CvjStreams $job
#            $bytes = Get-CvjStream $job 'Contents'
#            Get-CvjTree $bytes | Format-CvjTree
#            Export-CvjDump $job 'C:\path\job.dump.txt'
#
# Every file open is read-only and shared, so Cabinet Vision is never blocked.
# Nothing in this file writes to a .cvj. The only function that writes anything is
# Export-CvjDump, and it writes a plain text file that must not end in .cvj.
#
# The format this reads is described in "Cabinet Vision/CVJ File Format.md".
# Written for Windows PowerShell 5.1. Keep this file plain ASCII.

$script:CvjEnd   = [uint32]4294967290     # sector numbers at or above this are end/free markers
$script:CvjLatin = [System.Text.Encoding]::GetEncoding(28591)
$script:CvjInv   = [System.Globalization.CultureInfo]::InvariantCulture

# ---------------------------------------------------------------- container

function Read-CvjChain {
    # Follow a sector chain in the main FAT and return its bytes.
    param($Bytes, $Fat, [int]$SectorSize, [uint32]$Start, [int64]$MaxBytes)
    $ms = New-Object System.IO.MemoryStream
    $s = $Start; $guard = 0
    while ($s -lt $script:CvjEnd -and $ms.Length -lt $MaxBytes -and $guard -lt 4000000) {
        $ms.Write($Bytes, ([int64]$s + 1) * $SectorSize, $SectorSize)
        $s = $Fat[[int]$s]; $guard++
    }
    return ,$ms.ToArray()
}

function Open-Cvj {
    # Read a .cvj into memory and parse the compound-file directory.
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { throw "File not found: $Path" }
    $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try {
        $b = New-Object byte[] $fs.Length
        $off = 0
        while ($off -lt $b.Length) { $r = $fs.Read($b, $off, $b.Length - $off); if ($r -le 0) { break }; $off += $r }
    } finally { $fs.Close() }
    if ($b.Length -lt 512 -or $b[0] -ne 0xD0 -or $b[1] -ne 0xCF -or $b[2] -ne 0x11 -or $b[3] -ne 0xE0) { throw "Not a compound file: $Path" }

    $ss      = 1 -shl [BitConverter]::ToUInt16($b, 0x1E)
    $mss     = 1 -shl [BitConverter]::ToUInt16($b, 0x20)
    $numFat  = [BitConverter]::ToUInt32($b, 0x2C)
    $dirStart = [BitConverter]::ToUInt32($b, 0x30)
    $cutoff  = [BitConverter]::ToUInt32($b, 0x38)
    $miniFatStart = [BitConverter]::ToUInt32($b, 0x3C)
    $difat   = [BitConverter]::ToUInt32($b, 0x44)

    # FAT sector list: 109 in the header, the rest through the DIFAT chain.
    $fatSectors = New-Object System.Collections.Generic.List[uint32]
    for ($i = 0; $i -lt 109 -and $fatSectors.Count -lt $numFat; $i++) { $fatSectors.Add([BitConverter]::ToUInt32($b, 0x4C + 4 * $i)) }
    $guard = 0
    while ($difat -lt $script:CvjEnd -and $fatSectors.Count -lt $numFat -and $guard -lt 100000) {
        $o = ([int64]$difat + 1) * $ss
        for ($i = 0; $i -lt ($ss / 4 - 1) -and $fatSectors.Count -lt $numFat; $i++) { $fatSectors.Add([BitConverter]::ToUInt32($b, $o + 4 * $i)) }
        $difat = [BitConverter]::ToUInt32($b, $o + $ss - 4); $guard++
    }
    $fat = New-Object System.Collections.Generic.List[uint32]
    foreach ($s in $fatSectors) { $o = ([int64]$s + 1) * $ss; for ($j = 0; $j -lt $ss / 4; $j++) { $fat.Add([BitConverter]::ToUInt32($b, $o + 4 * $j)) } }

    $dir = Read-CvjChain $b $fat $ss $dirStart 100000000
    $entries = New-Object System.Collections.Generic.List[object]
    for ($e = 0; $e + 128 -le $dir.Length; $e += 128) {
        $nl = [BitConverter]::ToUInt16($dir, $e + 0x40)
        if ($nl -lt 2 -or $nl -gt 64) { continue }
        $entries.Add([pscustomobject]@{
            Name  = [System.Text.Encoding]::Unicode.GetString($dir, $e, $nl - 2)
            Type  = [int]$dir[$e + 0x42]            # 1 storage, 2 stream, 5 root
            Start = [BitConverter]::ToUInt32($dir, $e + 0x74)
            Size  = [BitConverter]::ToUInt32($dir, $e + 0x78)
        })
    }
    $root = $entries | Where-Object { $_.Type -eq 5 } | Select-Object -First 1
    $mini = Read-CvjChain $b $fat $ss $root.Start $root.Size
    $miniFat = Read-CvjChain $b $fat $ss $miniFatStart 100000000

    return [pscustomobject]@{
        Path = $Path; Bytes = $b; SectorSize = $ss; MiniSectorSize = $mss; MiniCutoff = $cutoff
        Fat = $fat; Entries = $entries; Mini = $mini; MiniFat = $miniFat
    }
}

function Get-CvjStreams {
    # Name and size of every stream in the job.
    param([Parameter(Mandatory = $true)]$Job)
    $Job.Entries | Where-Object { $_.Type -eq 2 } | Select-Object Name, Size
}

function Get-CvjStream {
    # The bytes of one stream.
    param([Parameter(Mandatory = $true)]$Job, [Parameter(Mandatory = $true)][string]$Name)
    $e = $Job.Entries | Where-Object { $_.Type -eq 2 -and $_.Name -eq $Name } | Select-Object -First 1
    if ($null -eq $e) { throw "No stream named '$Name'" }
    if ($e.Size -ge $Job.MiniCutoff) {
        $x = Read-CvjChain $Job.Bytes $Job.Fat $Job.SectorSize $e.Start $e.Size
    } else {
        $ms = New-Object System.IO.MemoryStream
        $s = $e.Start; $guard = 0
        while ($s -lt $script:CvjEnd -and $ms.Length -lt $e.Size -and $guard -lt 1000000) {
            $ms.Write($Job.Mini, [int64]$s * $Job.MiniSectorSize, $Job.MiniSectorSize)
            $s = [BitConverter]::ToUInt32($Job.MiniFat, [int]$s * 4); $guard++
        }
        $x = $ms.ToArray()
    }
    $out = New-Object byte[] $e.Size
    [Array]::Copy($x, $out, [Math]::Min($x.Length, [int]$e.Size))
    return ,$out
}

# ---------------------------------------------------------------- low-level helpers

function Format-CvjHex {
    # Hex and text view of a byte range.
    param([Parameter(Mandatory = $true)][byte[]]$Bytes, [int]$From = 0, [int]$Length = 256, [int]$Width = 32)
    $last = [Math]::Min($From + $Length, $Bytes.Length)
    for ($i = $From; $i -lt $last; $i += $Width) {
        $seg = $Bytes[$i..([Math]::Min($i + $Width - 1, $last - 1))]
        $hex = ($seg | ForEach-Object { $_.ToString('X2') }) -join ' '
        $asc = -join ($seg | ForEach-Object { if ($_ -ge 32 -and $_ -le 126) { [char]$_ } else { '.' } })
        '{0:X6}  {1}  {2}' -f $i, $hex.PadRight(3 * $Width - 1), $asc
    }
}

function Read-CvjString {
    # Read one text field (FF FE FF, length, UTF-16 text) at $Pos.Value and advance it.
    # Returns $null if there is no text field at that position.
    param([byte[]]$Bytes, [ref]$Pos)
    $q = $Pos.Value
    if ($q + 4 -gt $Bytes.Length -or $Bytes[$q] -ne 0xFF -or $Bytes[$q + 1] -ne 0xFE -or $Bytes[$q + 2] -ne 0xFF) { return $null }
    $len = [int]$Bytes[$q + 3]; $q += 4
    if ($len -eq 255) { $len = [int][BitConverter]::ToUInt16($Bytes, $q); $q += 2 }
    if ($q + 2 * $len -gt $Bytes.Length) { return $null }
    $s = [System.Text.Encoding]::Unicode.GetString($Bytes, $q, 2 * $len)
    $Pos.Value = $q + 2 * $len
    return ,$s
}

function Format-CvjNumber {
    param([double]$Value)
    return ([Math]::Round($Value, 6)).ToString('0.######', $script:CvjInv)
}

function Get-CvjClasses {
    # Every object type defined in a stream, with the offset where it is first used.
    param([Parameter(Mandatory = $true)][byte[]]$Bytes)
    $t = $script:CvjLatin.GetString($Bytes)
    foreach ($m in ([regex]'\xFF\xFF([\s\S]{2})([\x02-\x3F])\x00(C[VX][A-Za-z0-9_]{0,61})').Matches($t)) {
        if ($m.Groups[3].Value.Length -ne [int][char]$m.Groups[2].Value) { continue }
        [pscustomobject]@{ Offset = $m.Index; Name = $m.Groups[3].Value; Schema = [BitConverter]::ToUInt16($Bytes, $m.Index + 2) }
    }
}

# ---------------------------------------------------------------- named objects and parameters

function Get-CvjRecords {
    # Walk a stream and return every named object and every parameter, in file order.
    # Objects:    Kind='Object', Id, Name, Desc, ObjKind, ParamCount
    # Parameters: Kind='Param',  Name, Desc, Type, Value, Flags, Formulas, ListText
    param([Parameter(Mandatory = $true)][byte[]]$Bytes)
    $d = $Bytes
    $t = $script:CvjLatin.GetString($d)
    $out = New-Object System.Collections.Generic.List[object]
    $prevEnd = 0
    foreach ($m in ([regex]'\x01\xCF[\s\S]{4}\xFF\xFE\xFF').Matches($t)) {
        if ($m.Index -lt $prevEnd) { continue }
        $id = [BitConverter]::ToInt32($d, $m.Index + 2)
        $pos = $m.Index + 6
        $name = Read-CvjString $d ([ref]$pos); if ($null -eq $name) { continue }
        $desc = Read-CvjString $d ([ref]$pos); if ($null -eq $desc) { continue }
        if ($name -match '[\x00-\x1F]' -or $desc -match '[\x00-\x08\x0E-\x1F]') { continue }
        $q = $pos + 4
        $isParam = ($q + 30 -lt $d.Length -and $d[$q] -eq 0x01 -and $d[$q + 1] -eq 0xE9 -and $d[$q + 8] -eq 0x04 -and $d[$q + 9] -eq 0xE9 -and $d[$q + 18] -eq 0x02 -and $d[$q + 19] -eq 0xCF)
        if ($isParam) {
            $eqCount = [BitConverter]::ToUInt16($d, $q + 10)
            $flags   = [BitConverter]::ToUInt16($d, $q + 12)
            $type    = [BitConverter]::ToInt32($d, $q + 20)
            $v = $q + 24
            switch ($type) {
                4 { $val = [BitConverter]::ToInt32($d, $v); $v += 4 }
                5 { $val = [bool][BitConverter]::ToInt32($d, $v); $v += 4 }
                8 { $pp = $v; $val = Read-CvjString $d ([ref]$pp); $v = $pp }
                default { $val = [BitConverter]::ToDouble($d, $v); $v += 8 }
            }
            $formulas = New-Object System.Collections.Generic.List[string]
            for ($k = 0; $k -lt $eqCount -and $v + 4 -lt $d.Length; $k++) {
                if ($d[$v] -eq 0xFF -and $d[$v + 1] -eq 0xFF) { $v += 6 + [BitConverter]::ToUInt16($d, $v + 4) } else { $v += 2 }
                if ($d[$v + 1] -ne 0xE9) { break }
                $v += 2; $pp = $v
                $cond = Read-CvjString $d ([ref]$pp)
                $expr = Read-CvjString $d ([ref]$pp)
                if ($null -eq $expr) { break }
                $formulas.Add("$cond|$expr")
                $v = $pp + 1
            }
            $pp = $v; $list = Read-CvjString $d ([ref]$pp)
            if ($null -ne $list) { $v = $pp + 2 }
            $out.Add([pscustomobject]@{ Kind = 'Param'; Offset = $m.Index; End = $v; Id = $id; Name = $name; Desc = $desc; Type = $type; Value = $val; Flags = $flags; Formulas = $formulas; ListText = $list })
            $prevEnd = $v
        } else {
            $objKind = -1; $paramCount = -1; $end = $pos
            if ($pos + 16 -le $d.Length -and $d[$pos + 4] -eq 0x01 -and $d[$pos + 5] -eq 0xE9) {
                $objKind = [int][BitConverter]::ToUInt16($d, $pos + 6)
                if ($d[$pos + 12] -eq 0x01 -and $d[$pos + 13] -eq 0xE9) { $paramCount = [int][BitConverter]::ToUInt16($d, $pos + 14); $end = $pos + 16 }
            }
            $out.Add([pscustomobject]@{ Kind = 'Object'; Offset = $m.Index; End = $end; Id = $id; Name = $name; Desc = $desc; ObjKind = $objKind; ParamCount = $paramCount })
            $prevEnd = $end
        }
    }
    return ,$out
}

function Format-CvjValue {
    # One parameter as text: name = value, with its type, flags, formulas and list.
    param($Param)
    $typeName = switch ($Param.Type) { 1 { 'meas' } 2 { 'angle' } 4 { 'int' } 5 { 'bool' } 6 { 'dec' } 8 { 'text' } default { "type$($Param.Type)" } }
    if ($Param.Value -is [double]) { $v = Format-CvjNumber $Param.Value } elseif ($Param.Type -eq 8) { $v = "'$($Param.Value)'" } else { $v = "$($Param.Value)" }
    $s = "$($Param.Name) = $v [$typeName] flags=0x$('{0:X4}' -f $Param.Flags)"
    if ($Param.Desc) { $s += " desc='$($Param.Desc)'" }
    foreach ($f in $Param.Formulas) { $s += " formula=<$f>" }
    if ($Param.ListText) { $s += " list='$($Param.ListText)'" }
    return $s
}

function Get-CvjTree {
    # Objects of a stream with their parameters attached and a Depth taken from the
    # child count each object stores after its last parameter. Meant for 'Contents'.
    param([Parameter(Mandatory = $true)][byte[]]$Bytes)
    $recs = Get-CvjRecords $Bytes
    $t = $script:CvjLatin.GetString($Bytes)
    $objs = New-Object System.Collections.Generic.List[object]
    for ($i = 0; $i -lt $recs.Count; $i++) {
        $x = $recs[$i]
        if ($x.Kind -ne 'Object') { continue }
        if ($x.Name -eq '' -and $x.Desc -eq '') { continue }       # unnamed helper objects (part outlines)
        $params = New-Object System.Collections.Generic.List[object]
        $j = $i + 1
        while ($j -lt $recs.Count -and $recs[$j].Kind -eq 'Param') { $params.Add($recs[$j]); $j++ }
        $lastEnd = $recs[$j - 1].End
        $k = $j
        while ($k -lt $recs.Count -and ($recs[$k].Kind -eq 'Param' -or ($recs[$k].Name -eq '' -and $recs[$k].Desc -eq ''))) { $k++ }
        if ($k -lt $recs.Count) { $next = $recs[$k].Offset } else { $next = $Bytes.Length }
        # Trailer: ... 02 E9, uint16 banding-packet count, the packets, uint16 child count.
        # A banding packet is: type tag, 01 E9, uint32, 01 E9, uint16, four doubles.
        $kids = 0; $bands = New-Object System.Collections.Generic.List[string]
        $segLen = [Math]::Min(600, $next - $lastEnd)
        $seg = $t.Substring($lastEnd, $segLen)
        foreach ($m2 in ([regex]'\x02\xE9').Matches($seg)) {
            $q = $lastEnd + $m2.Index + 2
            if ($q + 4 -gt $Bytes.Length) { continue }
            $nb = [int][BitConverter]::ToUInt16($Bytes, $q); $q += 2
            if ($nb -gt 16) { continue }
            $ok = $true; $found = New-Object System.Collections.Generic.List[string]
            for ($bi = 0; $bi -lt $nb; $bi++) {
                if ($q + 50 -gt $Bytes.Length) { $ok = $false; break }
                if ($Bytes[$q] -eq 0xFF -and $Bytes[$q + 1] -eq 0xFF) { $q += 6 + [BitConverter]::ToUInt16($Bytes, $q + 4) } else { $q += 2 }
                if ($Bytes[$q] -ne 0x01 -or $Bytes[$q + 1] -ne 0xE9 -or $Bytes[$q + 6] -ne 0x01 -or $Bytes[$q + 7] -ne 0xE9) { $ok = $false; break }
                $v = 0..3 | ForEach-Object { Format-CvjNumber ([BitConverter]::ToDouble($Bytes, $q + 10 + 8 * $_)) }
                $found.Add("$([BitConverter]::ToUInt32($Bytes, $q + 2)) $([BitConverter]::ToUInt16($Bytes, $q + 8)) $($v -join ' ')")
                $q += 42
            }
            if (-not $ok -or $q + 2 -gt $Bytes.Length) { continue }
            $kids = [int][BitConverter]::ToUInt16($Bytes, $q); $bands = $found      # the last valid match wins
        }
        $objs.Add([pscustomobject]@{ Offset = $x.Offset; Id = $x.Id; Name = $x.Name; Desc = $x.Desc; ObjKind = $x.ObjKind; DeclaredParams = $x.ParamCount; Params = $params; Children = $kids; BandPackets = $bands; Depth = 0 })
    }
    $stack = New-Object System.Collections.Generic.Stack[int]
    foreach ($o in $objs) {
        while ($stack.Count -gt 0 -and $stack.Peek() -le 0) { [void]$stack.Pop() }
        $o.Depth = $stack.Count
        if ($stack.Count -gt 0) { $c = $stack.Pop(); $stack.Push($c - 1) }
        if ($o.Children -gt 0) { $stack.Push([int]$o.Children) }
    }
    return ,$objs
}

function Format-CvjTree {
    # Indented text for the output of Get-CvjTree. -WithParams adds one line per parameter.
    param([Parameter(ValueFromPipeline = $true)]$Tree, [switch]$WithParams)
    process {
        foreach ($o in $Tree) {
            $pad = '  ' * $o.Depth
            "$pad[$($o.Name) | $($o.Desc) | id=$($o.Id) | kind=$($o.ObjKind) | params=$($o.Params.Count) | children=$($o.Children)]"
            if ($WithParams) {
                foreach ($p in $o.Params) { "$pad    $(Format-CvjValue $p)" }
                foreach ($bp in $o.BandPackets) { "$pad    banding packet: $bp" }
            }
        }
    }
}

# ---------------------------------------------------------------- numbered settings

function Get-CvjSettingRuns {
    # Find every list of numbered settings in a stream (construction schedules and
    # connections store their values this way). Each run has Offset, Declared, Owner
    # (the nearest named object before it) and Settings (Number, Option, Flags, Type, Value).
    param([Parameter(Mandatory = $true)][byte[]]$Bytes)
    $d = $Bytes
    $recs = Get-CvjRecords $d
    $owners = @($recs | Where-Object { $_.Kind -eq 'Object' -and $_.Name -ne '' })
    $o = 0
    while ($o -lt $d.Length - 30) {
        $hit = $false
        if ($d[$o] -eq 0x02 -and $d[$o + 1] -eq 0xE9) {
            $count = [BitConverter]::ToUInt32($d, $o + 2)
            $first = [BitConverter]::ToUInt16($d, $o + 6)
            # A run must hold at least 3 settings; shorter matches are too easy to hit by accident.
            if ($count -ge 3 -and $count -le 20000 -and $first -ge 1 -and $first -le 100 -and [BitConverter]::ToUInt16($d, $o + 10) -lt 0x400) {
                $q = $o + 6; $prev = 0; $ok = $true
                $list = New-Object System.Collections.Generic.List[object]
                for ($n = 0; $n -lt $count; $n++) {
                    if ($q + 14 -gt $d.Length) { $ok = $false; break }
                    $num = [BitConverter]::ToUInt16($d, $q); $opt = [BitConverter]::ToUInt16($d, $q + 2)
                    $fl = [BitConverter]::ToUInt16($d, $q + 4); $ty = [BitConverter]::ToInt32($d, $q + 6)
                    if ($num -le $prev -or $fl -ge 0x400 -or $ty -lt 0 -or $ty -gt 20) { $ok = $false; break }
                    if ($ty -eq 4 -or $ty -eq 5) { $val = [BitConverter]::ToInt32($d, $q + 10); $q += 14 }
                    elseif ($ty -eq 8) { $pp = $q + 10; $val = Read-CvjString $d ([ref]$pp); if ($null -eq $val) { $ok = $false; break }; $q = $pp }
                    else { if ($q + 18 -gt $d.Length) { $ok = $false; break }; $val = [BitConverter]::ToDouble($d, $q + 10); $q += 18 }
                    $list.Add([pscustomobject]@{ Number = [int]$num; Option = [int]$opt; Flags = [int]$fl; Type = $ty; Value = $val })
                    $prev = $num
                }
                if ($ok -and $list.Count -eq $count) {
                    $owner = ''
                    foreach ($w in $owners) { if ($w.Offset -lt $o) { $owner = $w.Name } else { break } }
                    [pscustomobject]@{ Offset = $o; End = $q; Declared = [int]$count; Owner = $owner; Settings = $list }
                    $o = $q; $hit = $true
                }
            }
        }
        if (-not $hit) { $o++ }
    }
}

# ---------------------------------------------------------------- text dump for comparing jobs

function Get-CvjHash {
    param([byte[]]$Bytes)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return (($sha.ComputeHash($Bytes) | ForEach-Object { $_.ToString('x2') }) -join '').Substring(0, 16) } finally { $sha.Dispose() }
}

function Get-CvjDumpLines {
    # The whole job as text lines. Offsets are left out so that two dumps compare cleanly.
    param([Parameter(Mandatory = $true)]$Job)
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('# STREAMS')
    $streams = @{}
    foreach ($s in (Get-CvjStreams $Job | Sort-Object Name)) {
        $bytes = Get-CvjStream $Job $s.Name
        $streams[$s.Name] = $bytes
        $lines.Add("stream $($s.Name) size=$($s.Size) sha256=$(Get-CvjHash $bytes)")
    }
    foreach ($name in ($streams.Keys | Sort-Object)) {
        $bytes = $streams[$name]
        if ($bytes.Length -gt 2000000) { continue }                 # scenes are mostly image data
        $lines.Add(''); $lines.Add("# STREAM $name")
        foreach ($c in (Get-CvjClasses $bytes)) { $lines.Add("class $($c.Name)") }
        if ($name -eq 'Contents') {
            foreach ($l in (Get-CvjTree $bytes | Format-CvjTree -WithParams)) { $lines.Add($l) }
        } else {
            foreach ($r in (Get-CvjRecords $bytes)) {
                if ($r.Kind -eq 'Object') { if ($r.Name -ne '' -or $r.Desc -ne '') { $lines.Add("[$($r.Name) | $($r.Desc) | id=$($r.Id) | kind=$($r.ObjKind)]") } }
                else { $lines.Add("    $(Format-CvjValue $r)") }
            }
        }
        $ri = 0
        foreach ($run in (Get-CvjSettingRuns $bytes)) {
            $ri++
            $lines.Add("settings run $ri owner='$($run.Owner)' count=$($run.Declared)")
            foreach ($st in $run.Settings) {
                if ($st.Value -is [double]) { $v = Format-CvjNumber $st.Value } else { $v = "$($st.Value)" }
                $lines.Add("    run $ri setting $($st.Number) option=$($st.Option) flags=0x$('{0:X2}' -f $st.Flags) type=$($st.Type) value=$v")
            }
        }
    }
    return ,$lines
}

function Compare-CvjDump {
    # Compare two dump files stream by stream, as sets of lines. Order is ignored, because
    # Cabinet Vision writes some rows (material schedule parts) in a different order on every save.
    # The Header stream is skipped: its cache is re-encrypted on every save.
    param([Parameter(Mandatory = $true)][string]$Before, [Parameter(Mandatory = $true)][string]$After, [int]$MaxLines = 60)
    $sections = {
        param($path)
        $h = @{}; $cur = 'STREAMS'; $h[$cur] = New-Object System.Collections.Generic.List[string]
        foreach ($l in [System.IO.File]::ReadAllLines($path)) {
            if ($l.StartsWith('# STREAM ')) { $cur = $l.Substring(9); $h[$cur] = New-Object System.Collections.Generic.List[string] }
            elseif ($l -ne '' -and -not $l.StartsWith('# ')) { $h[$cur].Add($l) }
        }
        return $h
    }
    $a = & $sections $Before; $b = & $sections $After
    foreach ($name in (@($a.Keys) + @($b.Keys) | Sort-Object -Unique)) {
        if ($name -eq 'Header') { continue }
        if ($a.ContainsKey($name)) { $la = $a[$name] } else { $la = New-Object System.Collections.Generic.List[string] }
        if ($b.ContainsKey($name)) { $lb = $b[$name] } else { $lb = New-Object System.Collections.Generic.List[string] }
        if ($name -eq 'STREAMS') { $la = @($la | Where-Object { $_ -notmatch '^stream Header ' }); $lb = @($lb | Where-Object { $_ -notmatch '^stream Header ' }) }
        $sa = New-Object 'System.Collections.Generic.HashSet[string]'; foreach ($l in $la) { [void]$sa.Add($l) }
        $sb = New-Object 'System.Collections.Generic.HashSet[string]'; foreach ($l in $lb) { [void]$sb.Add($l) }
        $removed = @($la | Where-Object { -not $sb.Contains($_) })
        $added = @($lb | Where-Object { -not $sa.Contains($_) })
        if ($removed.Count -eq 0 -and $added.Count -eq 0) { continue }
        "== $name : $($removed.Count) lines only before, $($added.Count) lines only after"
        foreach ($l in ($removed | Select-Object -First $MaxLines)) { "  - $l" }
        if ($removed.Count -gt $MaxLines) { "  - ... $($removed.Count - $MaxLines) more" }
        foreach ($l in ($added | Select-Object -First $MaxLines)) { "  + $l" }
        if ($added.Count -gt $MaxLines) { "  + ... $($added.Count - $MaxLines) more" }
    }
}

function Export-CvjDump {
    # Write the text dump of a job to a file. Refuses to write over a .cvj.
    param([Parameter(Mandatory = $true)]$Job, [Parameter(Mandatory = $true)][string]$OutFile)
    if ([System.IO.Path]::GetExtension($OutFile) -eq '.cvj') { throw 'Refusing to write a .cvj file.' }
    if ([System.IO.Path]::GetFullPath($OutFile) -eq [System.IO.Path]::GetFullPath($Job.Path)) { throw 'Refusing to write over the job file.' }
    $lines = Get-CvjDumpLines $Job
    [System.IO.File]::WriteAllLines($OutFile, $lines, (New-Object System.Text.UTF8Encoding($false)))
    "Wrote $($lines.Count) lines to $OutFile"
}
