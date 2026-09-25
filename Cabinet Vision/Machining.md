# xMachining

x-module (largest, many +additions). See `Modules.md` for the full feature list Hexagon documents for this
module — this file is for the real operational knowledge on top of that: how it's actually used, gotchas,
workflow, and anecdotes.

**Priority** — on Ironwood's intended first-license list.

**Status:** the sections below are a first pass built from Hexagon's own S2M CENTER help (see
`S2M Handoff.md` for how that material was obtained), not yet checked against a real S2M install — Ironwood
doesn't hold a CV/S2M license yet (see `Modules.md`'s Status section). Treat everything here as reference
until it's confirmed hands-on, the same way `Core.md` and `Materials & Schedules.md` started before being
checked against Jon's own CV.

---

## What S2M CENTER is

S2M CENTER is Cabinet Vision's CNC output application — the software that takes the parts and materials
from a CV job and turns them into Optimizer/Nester patterns, tool selections, and NC code (G-code or a
machine-specific file format) for a shop's saws, routers, point-to-points, drill & dowel machines, and
other CNC equipment. It is reached from a CV job (the CV help's Getting Started topic lists "S2M CENTER" as
one of the fundamentals) and can also run output through **ALPHACAM** (Intelli-CAM) for shops with that
level of license — see the **xMachining** module features in `Modules.md` for what each license tier adds.

A few connected but separate reference files back this one:
- `Materials & Schedules.md` — the CNC section of a material's Properties (Optimize, Grain Dependent, Feed
  and Spindle percent, chip-minimize options, Climb Cut, Maximum Depth Per Pass) and how those settings
  work together with a **tool's** own settings. The full **Automatic Tool Selection Logic** (which tool
  S2M picks for a Part Outline, Hole, Dado, or Route operation) is written up there, since it grew out of
  documenting the material CNC fields.
- `CVData Materials & SQL.md` — the CVData database schema, scoped to material tables. `S2M Tid-Bits.txt`
  in `Reference/S2M Help/` has the **full** database schema (every table, not just materials) if that scope
  is ever needed.
- **`../04 Machining/`** (`Processes.md`, `Products.md`, `Notes.md`) — general, non-CV tooling knowledge:
  feeds-and-speeds formulas and worked examples, chip-load and surface-speed tables, and a full
  upcut/downcut/compression bit comparison (CV's S2M CENTER calls the same three bit types up-shear,
  down-shear and compression — see the Tool Catalog section below). Gathered from web sources, not yet
  checked against Ironwood's own tooling; see `Unverified Knowledge.md` items T1-T4.

## The S2M CENTER workflow

**1. Parts and Materials view** (the default opening view). Every part in the job's cutlist is listed, with
an icon showing whether it will be sent to the Optimizer (a brown sheet icon), to CNC (a yellow router
icon), both, or neither. A **red icon** flags a part that won't be optimized — commonly because it's wider
than the material's sheet size. Hovering any icon shows why. Parts, quantities, sizes and materials can all
be edited directly in this list, and a **Selection Copy** drag-handle can copy one cell's value down or up
into several others at once (fields that are unique or auto-populated block this).

If **Machine Sets** exist, a **Sel** column shows, per part, which machine set(s) it will output to (`|..`
manual only, `|.|` manual and a named set, and so on) — a quick way to audit routing before running output.

**Right-click a part** for Copy, Edit, Delete, **OK to Optimize**, **OK to Output CNC** (these two only
show when *Show Parts Not Set for Optimization or Output* is on in Preferences), and **Save to Library**
(saves the part to the Part Library for reuse in future jobs).

**2. Edit.** Three part-level editors: **Edit Shape** (the Shape Editor's CAD-style tools), **Edge Band**,
and **Edit Operations**.

**3. Filter Parts.** A powerful include/exclude tool with four filter modes — **New Filter** (ignores
anything currently selected), **Add to Selected Items** (builds on a manual selection without losing it),
**Filter on Previous Selection** (narrows an existing filter, e.g. select three cabinets, then filter those
down to one material), and **Remove Selected Items**. Five tabs: **Assemblies** (include/exclude by job,
room or cabinet), **Materials**, **Parts**, **Other** (Part Shape, Part Face — none/single/double-sided
machining —, Horizontal/Vertical Boring, Route/Drill-Dowel/Cut-to-Size/Other Operations, each with, without
or only, plus Optimize/CNC tagging and per-machine output status), and **Saved** (manage saved filters).
Filters can also be attached to a Machine Set (see below).

**4. Optimize** runs the Optimizer (for a Saw) or Nester (for a Router). A **Run Number** is generated from
the PSNC database's `RunCounter`, divided by the shop's configured Run Number Range with the remainder
added to the range's minimum — this lets a shop split run numbers across multiple users (e.g. Jeff 0-99,
Sally 100-199). The results screen reports, per material, sheet count and Used/Offcut/Waste percentages,
plus any **tool selection Warnings** (a selected tool may not be ideal, but the job still runs) or **Errors**
(an operation has no available tool — a new tool is needed). If no Primary Machine is set (only a
Secondary/Point-to-Point), the **Output CNC Operations** button appears instead and skips straight to
generating that machine's NC Link output.

**5. Patterns view.** Cut Patterns show the optimized/nested sheets (click the stack image); with multiple
Primary Machines (Machine Sets) a selector switches between them. **Show Tool Path** overlays the toolpath
on the sheet, color-coded: **red = default/centerline**, **cyan = left compensation**, **magenta = right
compensation**. **Machining Simulation** sends the selected pattern to the Machine Simulator (Intelli-CAM
links only, via ALPHACAM). Right-click a pattern for **Optimize** (re-optimize just that material), **Print**,
**Properties** (a per-material override of the optimize/nest settings — doesn't affect other materials in
the same PNC file), **Add Blank Sheet**, and **Remove Blank Sheets**.

**6. Reports.** Printable output about the run, organized into **Report Groups** (a named collection of
reports you print together with one click — **Print Reports In Group**). S2M ships with sample groups and
many predefined reports (part labels for several Avery label sizes, material summaries, nest/saw cut lists
in several formats, part/program lists grouped by cabinet/material/part/program, an outline-tools list, and
more — the full list is in `S2M Sidebar.txt`). Reports can be exported to PDF, Excel, Word, RTF,
XHTML/CSS, CSV, XML, several image formats, and more. **The Report Editor** (opened via **Edit Report**)
edits a report's layout; a system report must be **copied** first, since system reports can't be edited
directly.

**Reading part labels and program lists:** every label indicates whether its part's CNC program runs in a
"normal" or "mirror" machining zone, and whether the part has a second program (in the opposite zone). The
**program file name itself** also encodes which face it machines: **F** = front program (from the
finished/face side), **B** = back program (from the unfinished/back side) — e.g. `r01f0001` vs `r01b0001`.

**7. NC Code & Labels** is the actual output step: an Output Data window listing every active Machine
Set's NC output, plus **+Label** job output, **Label Images** for a saw's or router's own labeling system,
**CV Paperless Traveller** upload (work order name, path, and — its own detail — a "Scan Parts" QR code
built from `{WorkOrder}_{Part.ID}`), and **Save Job State** (writes a `.snc` snapshot of the job at its
"Ready for Output" state, reopenable later). The generated **`CncRun.txt`** file lists, per part: program
name, part name, width, length, material thickness, material name, cabinet number, quantity, grain
(0/1), program face (F/B), **material face-dependent (0/1)** — the same one-sided/two-sided flag discussed
under Materials — machine tag code and machine name.

## The Machine Catalog

Machines are set up in the **Machine Catalog**, reached from the Main tab. There are **8 machine types**:

| Type | Purpose |
|---|---|
| **Saw** | An NC panel saw, used with the Optimizer. |
| **Sheet Router** | A nested-based CNC router (Intelli-CAM). |
| **P2P** | A Point-to-Point machining center (Intelli-CAM). |
| **Part Router** | A router used as a secondary/parts machine. |
| **Drill and Dowel** | A CNC drill-and-dowel inserter. |
| **Chop Saw** | An automated chop saw system. |
| **Other** | Anything that doesn't fit the above — at the time of the help's writing, only the Hoffmann/RazorGage haunching system needed this. |
| **Machine Set** | Groups several of the above together (see below). |
| **Material Handling** | An automated material-handling/storage system (Flexstore, Intellistore, Storemaster, Winstore, and similar — each has its own parameter set, largely out of scope until Ironwood has one). |

Every normal (non-set) machine has a **Manufacturer**, an **NC Link** (the output format/post for that
brand and model), a short **Tag** (identifies which barcode on a label belongs to which machine — useful
when the same part goes to two machines with either the same or different barcodes), **Output Metric**,
**Output Summary** (whether a `CncRun.txt` is generated), **Available**, and an **Output Directory**
(local path or UNC).

### Machine Sets and Workflow

A **Machine Set** groups machines together for an automated, multi-machine shop, or simply to route certain
materials, part types or operations to specific machines using the same Filtering system described above. A
set can have **only one Primary Machine**, but any number of the others. Once a Primary Machine is in the
set, a **`--BAND PARTS--`** marker becomes available in the machine order — machines *after* it are
compensated for edgebanding thickness, machines before it are not.

**How operations move through the set — pass-through vs. stop.** By default a machine **consumes** any
operation it can perform: once done, that operation isn't offered to the next machine in the set. Enabling
**Operations Pass Through** on a machine instead lets *every* operation continue on to the next machine —
useful when a shop wants to send the same programs to more than one candidate machine (for example two
identical Point-to-Points) and let the floor decide which one actually runs them. The set's UI shows this
per machine with two icons: a **pass-through** icon (operations remain available downstream) and a **stop**
icon (operations are consumed here). Getting this wrong is a real pitfall: if a Nest/Saw is accidentally set
to pass-through, *every* operation — not just the ones meant for a downstream machine — passes along to the
next stage.

**Workflow reporting.** Each machine's Tag combines into a **workflow string** describing the chain a part
actually moved through (e.g. `SAW-DND-P2P`, or `SAW-(PP1/PP2)-(DD1/DD2)` where parentheses mean "either
machine in the group could do it"). This is available in +Label and in reports from the PSNC database, and
is a genuinely useful audit trail on an automated line.

**A "safety net" pattern from the help:** add a Point-to-Point set to **Full Outline** and pass-through as
the *first* machine after the saw/nest. Every operation still reaches the primary machine as normal, but if
a part is damaged later, a fresh blank can be roughed to size and rerun through that first P2P's barcode to
completely re-mill it.

### Setting up a Sheet Saw

Key concepts from the Saw's Setup tab (the machine-brand-specific parameter lists — Altendorf, Holzma, SCMI,
Selco, PIOS, and dozens more — are in `S2M Ribbonbar.txt` and are skipped here until a specific saw is
chosen):
- **Rip Cut Kerf / Cross Cut Kerf:** the blade widths, used to compute cut spacing.
- **Booking:** Max Height (material thickness the saw accepts), and Min/Max Sheets per Book (stack).
- **Optimization quality:** Fastest through Best trades computer time for yield. **Booking Priority**
  slides between favoring Yield (fewer books) and Labor (more books, i.e. fewer cycles per book).
- **Max Phases (Turns):** most older saws max out at 3.
- **Z-Cuts** (the "third phase" cut on a strip) and **T-Cuts** (cuts to break a sheet apart before ripping
  or cross-cutting) can both be eliminated — allowing them improves yield at the cost of time on the saw.
- **First Cut Priority** (Rip, Cross/Y Cut, or Either), **Strip Sort**, **Parts in Strip Sort**, and
  **Offcuts First/Last** control the pattern's cut order.
- **Part Size Tolerance** absorbs small unit-conversion size differences from the design software so parts
  that should be "the same size" are actually treated as such.
- **Restrictions** (min/max strip and Z-cut dimensions, max sheet size), **Speed** (rip/head cut and
  retract speeds in in/sec), **Times** (panel load, pattern setup, phase-turn times, booking overhead, an
  hourly saw cost, an overmake penalty), and **Trim** (dust-cut allowance) round out the saw's profile.

### Setting up a Sheet Router (nesting)

- **6th Face nesting:** machines a part's back-side (secondary/Face 6) operations before flipping the sheet
  and cutting the primary face and outlines. Programs get a suffix — **N** (no 6th-face program), **A**
  (the back-side program, run before Z), **Z** (the main program) — so the operator knows the sequence.
- **Common Line Cutting** tightly packs parts so one outline pass cuts two parts at once, improving yield
  and tool life, but only one side of that shared cut gets a clean edge (the other sees some blowout) — the
  help recommends it only for non-essential parts on less-than-premium material, and it always outputs an
  uncompensated centerline path, so **tool size in the Tool Catalog must be accurate**. **Common Line
  Maximum Retrace** lets the path travel alongside an already-cut edge to cut down on rapid moves; **Common
  Line Retrace by Small Parts** extends the automatic small-part retrace avoidance to small (not just very
  small) parts.
- **Pocket Waste** can rout out large open waste areas of a nest (not valid offcuts) to reduce chip load and
  clear debris, controlled by a minimum area/dimension and an optional **Skin Thickness** if vacuum
  clamping needs a thin waste layer left for hold-down.
- **Scrap Cuts** similarly break up leftover scrap into smaller, easier-to-dispose-of pieces, with its own
  tool, ordering (before or after part outlines), and min/max size limits.
- **Small Parts handling** — the mechanism behind Modules.md's "Intelligent Small Part Handling (Tabs,
  Onionskins, Return Onionskins)" feature:
  - A part counts as **Small** or **Very Small** by area or by a minimum dimension (whichever is more
    restrictive); Very Small parts get extra handling since they're more prone to shifting once freed.
  - **Lead Types** control how the tool enters/exits a cut: **None** (a straight plunge, least favored, no
    cutter compensation), **Sloped** (the most common — required for G41/G42 compensation, since the
    machine applies compensation during the lead-in), **Tab** (a short under-depth bridge left during the
    first pass, removed on a second pass), **Onion Skin** (the whole outline is cut just short of full
    depth, leaving a thin skin that anchors the part until a second pass frees it), and **Return Onion
    Skin** (like Onion Skin, but *every* part gets its first pass before *any* part gets its second/
    liberating pass — safer for a batch of small parts on one sheet).
  - **Nest Boundaries** can keep small/very-small parts away from the sheet edge, a named corner, or (for
    Very Small parts specifically) the sheet's interior — handy alongside Perimeter Nesting.
- **Grain Matching:** by default S2M orients grain exactly as the design software passed it, including any
  gap between grouped cabinets (e.g. an upper over a base). **Close Grain Match Gaps Larger Than** lets a
  gap above a threshold be closed to the standard nest gap instead — a gap smaller than the kerf is always
  ignored, and the help suggests 0 or 2x kerf as typical values. This directly affects the **additional cut
  passes some saw links generate for doors under drawers** — the Kerf value (rip and cross) determines the
  gap size used, so adjusting kerf can remove unwanted extra passes.
- **6th Face / label sort order, +Label image settings, and label-applicator machine parameters** exist
  but are out of scope until +Label is in use.

### Setting up a Part Router / P2P

- **Combine Face and Back:** defines a machine that can machine both the part's face and back
  *simultaneously*. Enabling it splits the Output tab into **Primary** and **Back Face** sub-tabs (each with
  its own settings) and adds a single-character **Face Up / Back Up Indicator** (defaults `+`/`-`) to the
  output file name so the operator can tell orientation from the file name alone. A Multi-Drill setup can
  likewise be defined separately per face.
- **Offset by 1/2 EDX/EDY:** important when a part has been oversized (EDX/EDY) and the router routs the
  full outline — compensates so the oversize amount isn't lost.
- **Match Programs:** identical parts get a single shared ("grouped", marked with a `g` in the program name)
  program instead of one program each.
- **Zone Sizes / Alternate Zones:** a multi-zone P2P can be told to alternate which zone receives
  consecutive same-zone parts, so the machine can work one zone while the next part loads into the other —
  a real throughput gain on a multi-zone machine.

## The Tool Catalog

The Tool Catalog defines every tool available for CNC output, and — critically for **Intelli-CAM** output —
**every field on a tool must have a valid value**. There are **11 tool types**:

1. **Vertical Drill** — boring part faces/backs.
2. **Horizontal Drill** — boring into part edges; always output as a secondary operation.
3. **Flat Router** — standard straight router bits; the workhorse type.
4. **Ball Router** — 3D routing/carving, and slots or flutes with rounded bottoms/inside corners.
5. **Bull Nose Router** — decorative bottom-edge cutting.
6. **Tool Set** — links several tools to perform one operation (the help's example: raised-panel MDF door
   detail — a preliminary flat-router pass, then a shaped bit, to reduce wear on the shaped bit).
7. **Dovetail Tool Set** — defines a dovetail tool plus its male and female toolpath movements.
8. **Saw** — typically for grooving; common on P2Ps, and as an aggregate on most CNC routers.
9. **5-Axis Saw** — typically for cutting miters on parts.
10. **V Router Bit** — a conical bit for 2½-axis miters.
11. **Shaped Router** — custom shaped router bit profiles.

**General tool properties, all tools:**
- **Machine:** assign to a specific machine, **Any** (available everywhere), **Unavailable**, or
  **Multiple** (a chosen subset).
- **Name:** for reference only — may appear as a comment next to the tool change in some posts.
- **Tool Number:** matches the tool in S2M to the physical tool position/number on the machine
  (critical for everything except a gang-drill drill, where it's ignored).
- **Height Offset ID:** usually the tool number (or +100) — the controller's preset for tip-to-spoilboard
  distance; set by the operator at the machine, ignored by some posts.
- **Tool ID:** S2M's own unique ID — callable from CV, e.g. a UCS setting the `ToolID` parameter to force a
  specific tool onto an operation.
- **Diameter/Kerf:** matches tools to operations, and for a dado decides whether it cuts single-pass,
  rectangle, or pocket (see the Automatic Tool Selection Logic in `Materials & Schedules.md`). Normally
  matches the real tool, but can deliberately be set smaller to force a particular dado behavior.
- **Minimum Work Depth / Work Depth:** together set the optimum material-thickness range for a tool — the
  help's example uses a 9.5mm compression bit for 16-19mm stock and a 12mm bit above 20mm, each with its own
  Min/Max Work Depth window.

**The three CNC output path types** (a combination of a Tool Catalog setting — Centerline vs. Offset Path —
and a Machine Catalog setting — Tool Center vs. Tool Radius):
1. **Centerline – Tool Center, no G41/G42:** the outline path is offset outward from the part by the tool
   radius, and the tool's center follows it exactly. If a bit is sharpened smaller, **the new size has to be
   re-entered in the Tool Catalog and the program re-output**, or the part cuts oversize.
2. **Centerline – Tool Center, with G41/G42:** the same path, but the control looks up **tool
   compensation** from its own register. Re-sharpen the same 1/4" bit down to a .23 radius, and instead of
   going back into S2M, the operator enters .02 (the difference) at the control and the machine offsets the
   path itself — useful for swapping bits on the fly without re-outputting from S2M.
3. **Offset – Tool Radius:** the path follows the part's exact outline, and the **control** must apply the
   tool-radius offset (a 1/2" bit needs a .25 offset entered at the machine; re-sharpened to .23, the
   control's comp value is updated to match).

Which of the three a given machine uses is a shop/post decision, and it's the reason tool comp exists at
all: a router bit gets smaller every time it's sharpened, and something — S2M, or the machine control — has
to account for that so parts keep cutting to the correct size.

### Automatic Tool Selection Logic

This is the logic behind a material's **Minimize Face Chip / Minimize Back Chip** settings (see
`Materials & Schedules.md`) and a tool's own **Down Shear / Up Shear** flags — confirmed in Hexagon's S2M
CENTER help (`Reference/S2M Help/S2M Ribbonbar.txt`, "Enhanced Tool Selection Logic for CNC Output"),
organized by operation type. Each search below only considers tools with **Allow Auto Select** on.

- **Part Outline** (the one tool set as the job's Outline Tool): search flat routers with Outline = True, in
  this order — (1) an Up/Down Shear bit that matches the sheet's requirements (i.e. the material's Minimize
  Face/Back Chip flags), (2) a Compression bit, (3) a Down Shear bit, (4) an Up Shear bit, (5) an
  "Expansion" bit (both shear flags False). No match is an error.
- **Vertical Hole:** an exact-size vertical drill bit first (checking gang-drill-head fit); if none, a flat
  router at exact size in the order Down Shear, Compression, Up Shear, Expansion (bores the hole in one
  drop); if still none, a smaller-diameter flat router in the same order (routs a pocket to size).
- **Horizontal Hole:** an exact size-and-direction horizontal drill bit, or an error.
- **Dado:** prefers a **saw** over a router when the dado reaches a part edge; searches saws for a size and
  direction match (swapping direction or dropping to a smaller kerf with multiple passes as needed) before
  falling back to a router, which **always selects Down Shear** for a single-pass dado, or one of
  Up/Down-shear-match, Down Shear, Compression, Expansion, Up Shear (in that order) for a multi-pass route
  when no router matches the full width.
- **Cutout / Pocket Route:** searches flat routers for a size and shear match first; the fallback order
  differs by whether it's a **Cutout** (Compression, Down Shear, Up Shear, Expansion) or a **Pocket**
  (Down Shear, Compression, Expansion, Up Shear).

Two patterns worth remembering: **Compression is consistently the tool chosen when both Minimize Face Chip
and Minimize Back Chip are on** (it appears early in every list except Cutout, where it's still ahead of
plain Up/Down Shear alone), and **an "Expansion" bit is a tool with both shear flags False** — the fallback
of last resort before Up Shear alone in most lists. The help's own reference charts (#1 to #6) referenced
alongside this logic are diagrams, which did not survive the PDF-to-text conversion.

### How feed and speed are applied on output

From the help's Tools table reference — the same wording appears in both the CV help and the S2M help
(`Reference/S2M Help/S2M Tid-Bits.txt`); the exact math is still inferred, see `Unverified Knowledge.md`
item M13a. A tool stores its own **feed rate at a 1/4 in deep cut** and **at a 3/4 in deep cut**, plus a
**descent rate** and a **spindle speed (RPM)**. Both sources say these are "used to dynamically output
varying feed rates based on depth of cut and percentage value entered into Material Catalog." So the output
feed rate for a cut depends on the **depth of that cut** (presumably worked out between the tool's 1/4 in
and 3/4 in values) and is then **adjusted by the material's Feed Rate Percent**. Spindle speed comes from
the tool and is scaled by the material's Spindle Speed Percent. A **post processor** turns the result into
G-code and handles units (the help's example: a MultiCAM post expects inches per minute but outputs inches
per second). An RPM of 0 on a tool usually causes a G-code error, and some machines ignore the RPM value and
use a preset speed for the tool. *(Inferred, not stated: the calculation order, and that feed is
interpolated between the two depths.)*

## Preferences (CV help topic reference; from `S2M Intro.txt`)

Seven tabs, relevant highlights:
- **General:** Run Number format (3-digit numeric 000-999, Alpha-Numeric R00-RZZ for up to 1296 outputs, or
  Standard R00-R99) and the Run Number Range described under the workflow section above; which ALPHACAM
  module the S2M CENTER Ultimate uses; and up to 10 label-position choices for real-time labeling.
- **Tool Warnings:** toggles which warnings show during optimization.
- **Geometry:** ten options, notably **Close Grain Match Gaps Larger Than** (see Sheet Router above) and
  **Pre-Mill Edgebanding**. The latter compensates for an edgebander with a pre-mill station — with **Max**,
  the value is the largest amount the bander will trim off the banded edge; with **Fixed**, it's an exact
  amount. This actually **resizes the part** for banded edges. **Pre-banded** edges are only the part's
  Left/Right/Top/Bottom while still rectangular; **pre-milled** edges can be any of those plus any other
  edge that could physically feed into a banding machine (an edge next to a radius is excluded, since a
  single strip of banding would need to span it and the adjacent part, and an end-trimmer could cut into the
  radius).
- **CNC:** **Allow Invalid Pre-Assigned Tools to be Substituted** — a fail-safe: if an operation was
  explicitly assigned a `ToolID` (say, to force certain work onto a specific machine) and that tool turns
  out to be invalid for the operation on the *current* machine, this option lets Automatic Tool Selection
  step in instead of the operation simply failing.
- **Miter Options:** whether S2M creates miter operations at all, and which tool machines them (a V-Bit
  tool, if its angle matches). 2½-axis miters are allowed on a normal nest but **not on 6th-face nesting**
  (flipping the sheet could damage the miter); 4/5-axis miters need a properly configured multi-axis tool
  and a post that supports multi-axis movement.
- **Ordering:** "By Cabinet" restricts a sheet to one cabinet's parts (lets assembly start the moment that
  cabinet is fully cut); **Minimize 6th Face Patterns** forces 6th-face work onto as few sheets as possible,
  at some cost to yield; and the processing order of operation types on a nest/part can be reordered
  directly.
- **Reports:** default reports for Secondary Part Sheets and Pattern Printouts, and whether Saw
  Optimization reports Offcuts and Grain-Match Gap Cuts.
- **Measurement Units:** S2M stores every measurement as a double-precision number **in inches internally**,
  regardless of the display unit — a value entered as 56mm is stored as `2.20472440944881"`. What's chosen
  here (units + precision) only changes the *display*, not the stored value, which is worth remembering if
  a size looks like it's been rounded somewhere it shouldn't have.

## DXF and third-party CAD import

Parts can be brought in from another CAD package as DXF (or, via a dedicated importer, Blum Dynaplan BXF,
KAB-NX, KCDw, Pattern Systems, S2M Part List, or SmartLister). An **Edit DXF Layer Scheme** defines how a
package's layer names map to S2M's operation types:
- **12 layer roles** (Part, Outline, Vertical/Horizontal/Left/Right/Front/Back Bore, Route, Dado, Pocket,
  Edge Miter).
- **8 keyword characters** embedded in a layer name (Tool Number, Operation Depth, Operation Width, Offset
  Left/Right, Tool Inside/Outside, Secondary Face — the last lets one DXF carry machining for both faces of
  a part).
- **3 miscellaneous settings** (the decimal separator character, the "part is face up" character — the
  default assumption is face **down**, and whether CAD geometry already encodes true thickness as depth).

**Known limitations, straight from the help:** one DXF per part (a part with both front and back
programs needs both sets of operations in the single file, not split across two); no mirrored parts (S2M
will rotate 90° or flip a part, but won't accept mirrored geometry); an operation's size is read as its
**bounding box** (so a centerline-output dado's raw geometry is smaller than the real dado — it grows by the
tool diameter during processing); and only **Arc, Circle, Line, LWPOLYLINE, POLYLINE, SEQEND, VERTEX**
entities are read — anything else is skipped with a warning.

---

## Jon's notes

_No hands-on notes yet — Ironwood doesn't hold an S2M license. This section is where real practice, gotchas
and anecdotes go once there's a live install to test the material above against._
