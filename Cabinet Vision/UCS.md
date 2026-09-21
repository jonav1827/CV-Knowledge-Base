# User Created Standards (UCS)

Code that runs on every rebuild and can read, compute, create, change, or delete parameters and
parts. Two authoring languages exist: **UCS:M** (the legacy proprietary macro language — almost
entirely `If-Then` and `While-Do`) and **UCS:JS** (JavaScript, introduced in CV 2024; our CV 25.2 has
both, plus JS Libraries). JS gives far more control. See `Parameters.md` for the parameter concepts
this builds on.

Source docs are in `Reference/` (System Parameters, and the CV help sections on User Created
Standards / JavaScript UCS / Functions / Assembly / Shape). Grep the system-parameter reference for
any parameter before guessing at it.

The UCS:M sections cover the legacy language and everything learned building Ironwood's door/drawer-front, V-groove, pull, filler and hinge UCSs on CV 25.2; UCS:JS follows, then the translation between them. Specific configured values (profile dimensions, peg material IDs, tolerances) are deliberately left out; only the mechanisms are kept.

## The hierarchy and the look-UP model

Levels, top to bottom: System → Job → Room → Wall → Wall Face → Assembly / Molding / Countertop /
Splash → Part Groups (Case / Interior / Face) → Part → Operation.

Parameters are **pulled, not pushed**: a child climbs its ancestor chain until it finds the
parameter, and the nearest ancestor wins. That is exactly how Standards and Overrides work. A
Standard lives at the Job level (Construction Method); an Override placed lower (Room, Assembly)
is found first and short-circuits the lookup. Worked example: Toe Kick Height is Standard #238 =
4"; a Room override changes every cabinet in the room; an Assembly override changes only that
cabinet. Most, not all, parameters propagate; some are local to their level.

## Reading parameters — the access prefixes

- **System parameters:** by name (`TOEH`, `_3DHDIR`, `_AI`). Many start with `_`.
- **Material parameters:** prefix `_M:` on a part that uses the material (`_M:DZ` = banding
  thickness).
- **Standards:** `_CV:nnn` returns the Standard's **value**; `_CB:nnn` returns its **button
  selection**. `nnn` is the Standard number (Toe Kick: `_CV:238`). The override for the same
  quantity is a separate parameter (`TOEH`).
- **Tree navigation:** `:` scans UP and stops at the first match; stacking `::` skips nearer
  matches to reach a higher ancestor. The colon count is relative to the object the UCS acts on,
  not an absolute address (a Part needs one more than an Assembly to reach the same ancestor).
  `.` goes down a level, `@n` disambiguates same-named siblings. Key words: `Cab`, `Case`,
  `Interior`, `Face`, `DE` (deck), and part internal names. Example paths: `Case.DE.DY`, `:DY`.
- **Choice lists compare the STORED value, not the display label.** A label like "To Be
  Determined" may store `TBD`. Verify the stored value before writing a condition against it; a
  wrong one silently never fires.
- **Override parameters ("Visible with user override")** read directly with `:` and compare
  against their default even when un-overridden (`:PREF == 1` is simply false at default 0). No
  null guard needed.

### Reading the parameter reference
- **System params:** *Type* = whether writable (System Defined Query Only = read-only; System
  and/or User Definable = writable). *Applies To* = native hierarchy level (can often be used
  elsewhere too). *Values* in parentheses = the data type. *Visibility* = whether it shows in the
  Object Tree (Visible with user override / Never / Always).
- **Material params:** *Applies To* = material *types* (Banding, Hinge, Board Stock, Drawer Guide…),
  not hierarchy levels.

## Creating a parameter — five required choices

1. **Name** — short; it's what shows in the Object Tree.
2. **Type** — Measurement, Integer, Degrees, Decimal, Text, etc.
3. **Value** — literal or equation.
4. **Style** — Standard (Object Tree only), Attribute (sidebar), Note (Notes tab only; the tab
   doesn't exist until at least one Note-style parameter does).
5. **Description** — only conditional field: optional for Standard, required for Attribute/Note.

**Persistence:** a parameter must be styled (or be a plain untyped `NAME = value`) to survive a
rebuild. A bare typed declaration with no style is rebuilt each regeneration and reads back null
next time, which breaks any "has this been set?" check. `NAME := value` is a per-regeneration
working variable only.

## UCS:M (legacy) essentials

- The first line must be a `;` comment; it becomes the UCS description.
- **Every UCS:M script must open with `For Each <TYPE1> | <TYPE2> <ObjectType>`** — the iterator *is*
  the apply-condition. Without it the UCS binds to nothing and silently does nothing. No `end for`
  needed; the whole script is the loop body. (UCS:JS is the opposite: apply-conditions live in a
  dialog, outside the code.)
- **`if … then … end if` is multi-line only.** `then` ends the line, the body sits on its own lines,
  `end if` on its own line. A single-line form doesn't parse and silently rolls back the whole UCS.
- Equations: `IF <condition> THEN <equation>`; conditions evaluate top-down and the first truthy one
  wins. Condition `1` = always.
- Create objects with `Dim NAME as New <ObjectType>`; attach operations to a part via
  `NewObj.Owner = Owner`. A manually added Part needs `UCSMOD = 1` for a UCS to modify it.
- `this` stands in for the For Each object; inline variables use `{}`.
- **Operators:** `+ - * / % ^` (power), `! < > <= >= == != & |`. `==` is required in Object Tree
  IFs. `&` binds tighter than `|` (confirmed live), so `A | B & C` reads as `A | (B & C)`.
- **`== null` tests existence**, distinct from 0 — but CV sometimes conflates null and 0. If
  behavior looks off at that boundary, that is the suspect.
- **Referencing a null parameter in an equation breaks it:** the assignment silently fails rather
  than returning 0. The only safe use of a possibly-null parameter is an explicit `== null` check.
- **Never combine `|` with `else`.** With `if A | B then … else …`, the `else` misfires because only
  one OR-ed condition is true at a time. Put the bad/exclusion case first as an `&` conjunction and
  let `else` be the catch-all.
- **`=` vs `:=`:** `=` stores a formula evaluated later (at render); `:=` computes now and stores the
  value. Don't `delete` a temp that a `=` formula still references — it goes null before the formula
  runs and the parameter silently fails. Only delete temps whose every consumer used `:=`.
- **Merging same-result cases:** when a new case yields a value another case already assigns, OR it
  into the existing condition rather than duplicating the block. When a later block re-asserts the
  same value for the same part, the last write wins.
- **Diagnostic technique:** drop `TESTn = n` plain-assignment markers down the branches; which ones
  appear and survive shows which path ran and what persisted.
- **Test-cabinet gate:** a bare `CLAUDE_TEST`-style read (climbs the tree) with `exit` if null,
  placed right after `For Each` and outside any `if NAME` block, sandboxes a UCS to a flagged cabinet.

## Persistence, seeding and idempotency (UCS:M)

- A stored flag of `0` reads back as null (null/0 conflation). If you store a flag instead of the
  default, use nonzero values.
- **Rebuild-persistence problems are much more common on parts than on assemblies.** Assemblies
  usually hold their parameters across a rebuild; a bare unstyled parameter on a part gets wiped.
  If a tracker parameter keeps vanishing, check whether it lives on a part, then style it or move
  the state up to the assembly. A Note-style (`<style> = 2`) flag sometimes survives on parts that
  auto-wipe everything else.
- Some objects delete and rebuild their parameters every time the object itself rebuilds. On those,
  even a null-check-seeded value keeps snapping back to its default.
- **Seeded default vs hardcoded:** an assignment inside `if X == null then` is a seeded default (set
  once, the user can change it). A bare top-level assignment is hardcoded (re-asserted every rebuild;
  the only way to change it is to edit the code).
- **Wipe-slate pattern:** for a value that must recompute fresh every rebuild, `delete` it at the top
  before rebuilding it. Seed-once (`== null`) is for persistent, user-editable values;
  delete-first is for derived values. The wrong choice is a silent bug: seed-once on a derived value
  goes stale, and no-wipe on an accumulator multiplies across rebuilds.
- **Idempotency law:** UCSs re-run on every rebuild, so they must be safe to re-run. `:=`, seed-once
  and delete-on-cleanup survive re-running; accumulation (`+=`, `X := X + 1`, string append)
  compounds each rebuild. Parts made with `dim` are rebuilt fresh each cycle; parameters persist.
- **`:=` does not work on text-type parameters.** Text always uses `=`. And a `<text>` tag makes the
  right-hand side expect a quoted literal, so never tag an assignment whose value comes from another
  parameter (the un-evaluated parameter name gets stored instead).
- `QTY = 0` deletes the object. `Adjust Add (X)` / `Adjust Mult (X)` are long forms of `+=` / `*=`.
- **Discriminate on a field you don't write.** A UCS that reads a field to decide something and also
  writes that field drifts, because rebuild 2 reads what rebuild 1 changed. Branch on a stable field
  the UCS never touches (e.g. read a hinge's material schedule `_M:SCHEDID`, write its material).

## Type and style tags (UCS:M)

Suffix a parameter name with a tag to set its type, style or description inline:
- **Types:** `<crncy>`, `<meas>` (default; converts imperial/metric), `<deg>`, `<int>`, `<bool>`,
  `<dec>`, `<text>`.
- **`<style>`:** `0` = Value (Standard), `1` = Attribute, `2` = Note.
- **`<desc>`:** the prompt text (needed for Attribute/Note).

```
if U_DWStrip == null then
    U_DWStrip<bool>  = 0
    U_DWStrip<style> = 1
    U_DWStrip<desc>  = 'Add Dishwasher Strip'
end if
```
Text parameters build strings from other parameters: `NAME = w{DX}h{DY}d{DZ}`.

A Standard-style parameter needs only name, type and value; omit `<style>`/`<desc>`.

## Text limits (UCS:M)

- **String literal limit (UCS:M only, untested in JS):** the quoted literal, opening quote + content +
  closing quote, must be 255 characters or less, so content is at most 253. Total line length is
  irrelevant. Violating it makes CV throw an error on apply and the UCS doesn't work.
- The limit is lexical: CV checks it on the literal as typed in the script, not on the value the
  script produces when it runs. A value built at run time through `{}` substitution can be any length.
- **Chunking workaround (how it works):** to build a choice list longer than 253 characters, split
  its entries across several `<text>` parameters, each with a typed literal of 253 characters or
  fewer, then reference them with `{}` inside one short final literal. `{}` is expanded at the moment
  of assignment, so the stored list is already the full text and nothing keeps pointing at the
  pieces. That is why the pieces can be deleted straight afterward. Rules:
  - Each piece holds whole entries and does not end with ` | `; type the separator in the final
    literal between the `{}` references.
  - `{}` only sees parameters on the current part, so the pieces must be created on the same part as
    the list.
  - Build the pieces inside the null check and delete them right after, so no scratch parameters stay
    on the object.
```
if WIDGET_CHOICE == null then
    W_STR1<text> = '01 - Option A = A | 02 - Option B = B | 03 - Option C = C'
    W_STR2<text> = '04 - Option D = D | 05 - Option E = E'
    WIDGET_CHOICE<text> = '<lst>Default = Default | None/Not Applicable = N/A | {W_STR1} | {W_STR2} | Update Selections = U'
    delete W_STR1
    delete W_STR2
end if
    WIDGET_CHOICE<style> = 1
    WIDGET_CHOICE<desc> = '01 - Widget Type'
```
  When the list also has an `Update Selections` delete-gate, put that gate above this block as shown
  under Choice lists; the pieces are rebuilt each time the list is recreated.
- A 288-character *condition* line works; the limit is on quoted literals only.
- **System Parameter value strings have a hard cap of 1011 characters, and overflow is destructive:**
  it deletes the data for that parameter AND every parameter below it in the list. Treat 1000 as the
  working limit; when a list approaches it, split it into two System Parameters before it grows. The
  253 limit does not apply to a string entered directly in the System Parameters window, only once it
  becomes a typed literal in a UCS, so chunking is a UCS-only workaround.
- Extended characters such as `°` (CP1252) round-trip fine through System Parameters and UCS string
  comparisons.

## Choice lists (UCS:M)

- A `<text>` parameter whose value starts with `<lst>` renders as a dropdown of `Desc = Value` pairs
  separated by ` | `. (Undocumented in the help; equivalent to JS `CreateChoiceList`.) `<lst>` is not
  an entry, only the marker.
- **The default selection is the first entry after `<lst>`**, regardless of where the display sorts
  it.
- **CV alphabetizes the dropdown by the description**, lexicographically, so `IE #10` sorts before
  `IE #2`. Force order with sequential prefixes (`01 - `, `02 - `, …).
- **Prefix convention:** real choices run `01+` with no gaps, even when the underlying names skip
  numbers (the prefix never mirrors the entity's own number). `None/Not Applicable` gets `00` so it
  sorts first. `Default` and `Update Selections` get no number, so they sort to the bottom while
  `Default` is still the default. Letter-named lists (e.g. panel profiles) can go bare; number-named
  lists need prefixes.
- **The right side of each pair is a hard contract.** It is what downstream code reads; editing
  prefixes or descriptions must never touch it.
- **Labels are client-facing** and must set the right expectation, not just describe the algorithm
  (e.g. label a non-aligned V-groove mode `(Random)` because that tells a client the grooves may not
  line up).
- Text values must be quoted when referenced: `if X == 'U'` works, `if X == U` doesn't. Numeric
  types compare bare.
- **An `<int>` choice list must use `0` for None, never the text `'None'`**, or `if X != 0` is true
  when None is picked and phantom sub-attributes appear.
- **Update path.** The seed-once null check freezes the list at creation, so later edits to the list
  never propagate. Add an `Update Selections = U` entry and a delete-gate BEFORE the null check:

```
    if DOR_IE == 'U' then
        delete DOR_IE
    end if
if DOR_IE == null then
    DOR_IE<text> = '<lst>Default = Default | None/Not Applicable = N/A | {IE_STRING1} | Update Selections = U'
end if
    DOR_IE<style> = 1
    DOR_IE<desc> = 'Inside Edge Profile'
```
  Order is load-bearing: delete-gate, then create, then enforce style/desc. The sentinel must match
  the type (`U` for text, an out-of-band number like `-1` for integers). Picking it resets the user's
  selection to the default. Every UCS-created choice list needs some update path.
- **Room/System-Parameter lists don't use the sentinel.** They are defined in the System Parameters
  window and refreshed into existing jobs with **Update Job → Parameters** (see System parameters
  below).
- **Two values in one text choice.** A single readable choice can drive two independent results, and
  the text is also what prints on drawings. Write one `if` block per complete choice string, and have
  each block set both values together:
```
if :WIDGET_STYLE == 'Round (90°)' then
    WIDGET_MATID := 1001
    WIDGET_ROT := 90
end if
if :WIDGET_STYLE == 'Round (45°)' then
    WIDGET_MATID := 1001
    WIDGET_ROT := -45
end if
if :WIDGET_STYLE == 'Square (90°)' then
    WIDGET_MATID := 1002
    WIDGET_ROT := 90
end if
```
  Store the readable text in the room parameter and translate it to the number or ID the geometry
  needs in the UCS (the numbers never sit in the list). Extended characters like `°` compare fine.
- **Lookup for data CV doesn't store.** When a value the geometry needs isn't exposed anywhere (for
  example a profile's dimensions, or how tall a bored hole pattern is), store it yourself: one block per
  choice, keyed on the stored value, that sets the numbers. Seed a default first so an unlisted
  choice degrades safely, and merge choices that share the same numbers into one condition with
  `|`. The numbers are only as right as their upkeep, so when a result is off, check the lookup
  values first.
- **Variants of one item** (for example an inside and an outside version): give each variant its own
  list entry and carry the variant label in both the display and the stored value, so the UCS can
  branch on it.
- **Pass-through / override final parameter** (hand-rolling the Standard→Override pull):
```
if DOR_IE == 'Default' then
    IE = :DOOR_IE
else
    IE = DOR_IE
end if
```
  The gate compares against the value tied to the list's Default entry, which is not always the text
  `'Default'` (an integer list may use `0`). The final parameter is deliberately hardcoded and
  Standard-style. Use `:` on every up-tree reference as best practice. Parameter names are custom to
  the domain; the local-attribute → room-parameter → final-parameter structure is what's reusable.
- **Attribute numbering:** CV alphabetizes the sidebar by `<desc>`. Put unconditional attributes
  first (`01`, `02`, …) and conditional ones after so a hidden conditional never leaves a gap. A
  sub-attribute takes its parent's number plus `.#` (`06` → `06.4`). Keep the same number for the
  same kind of attribute across parts.
- **Override parameters (Jon's own convention).** Every override of one of his own parameters is
  named `OVR_` followed by the name of the parameter it targets, so an override for `PARAM1` is
  `OVR_PARAM1`. This shows at a glance which override targets which parameter, and because the Object
  Tree is alphabetized, every override sits together in one place. Give the override's `<desc>` an
  `OVR - ` prefix with no number (digits sort before letters, so it sinks to the bottom of the
  sidebar). For a Boolean OFF-switch, put it on the user-accessible part and enforce it with one
  added condition at the place the feature is created (`if :PARAM1 != 0 & :OVR_PARAM1 != 1 then`),
  reading it up-tree.
  This is separate from CV's own built-in system overrides (such as `TOEH`), which override the
  construction schedule; his `OVR_` layer overrides his own parameters.

## Execution model and ordering

- The whole UCS runs top-down on every rebuild for every matched object. Unconditional assignments at
  the top reset state, blocks lower down override, and when several blocks match the last one wins.
- **A failed assignment keeps the previous value** (the target silently keeps what it had if the
  right-hand side can't evaluate). **An `if` condition referencing a nonexistent parameter is skipped
  harmlessly**, treated as not true. Only assignments have the can't-evaluate problem.
- **Seed-to-0 pattern:** unconditionally seed, at the very top, the values that parts consume, so
  every failure mode degrades to a safe zero. Don't seed routing parameters that are guaranteed to
  exist.
- **Exit conditions are the main performance lever.** CV walks the body block by block: at each
  top-level gate it evaluates the condition, and a failure skips that block's entire body, nested
  `if`s included. Start every UCS with the cheapest early-exit outer gate (`CONSTID` is ideal, since
  it resolves near the top of an assembly's definition) and wrap each concern in its own top-level
  gate. A well-gated monolith is as efficient as a split; **splitting is a maintainability decision,
  not a performance one.** If you split, divide where a block's gate changes, never by line count.
- **Don't add `exit` at the end of each `NAME` block.** The payoff is negligible.
- **Lineup order.** UCSs run top-down by Ordinal, and a UCS that produces parameters another
  consumes must sit above it. **Pre-build UCSs run first as a group, then post-build UCSs run
  top-down as a group; each UCS runs once per build.** So order only matters within the same build
  phase. Confirmed with a probe UCS that logged its firing order.
- **Pre-build vs post-build:** pre-build alters native system parameters; post-build (Pre-Build
  unchecked) alters parts and can `dim` objects and operations. A pre-build UCS will not dim anything.
- **Two UCSs writing the same parameter on the same part fight silently** (last writer wins, no
  error). When a parameter's final value contradicts a UCS that plainly sets it, stop reading that UCS
  and grep for other writers. One owner per parameter; namespaced prefixes (`DOR_*`, `_VG_*`, `OVR_*`)
  keep UCSs in their own lanes.
- **Assembly/parts two-pass architecture:** an assembly UCS writes attributes and neighbor intelligence
  onto the cabinet; a parts UCS reads them via `:CAB.*` to build and position parts. The assembly pass
  must precede the parts pass. Standard skeleton: header → `For Each` → test gates → exit-and-cleanup
  (`if CONSTID != <id> then delete <every param this UCS created>; exit`, which self-heals when a
  cabinet is reclassified) → defaults → attributes → size intelligence → conditional intelligence →
  naming.
- **Test gates:** a bare parameter placed manually on one job (e.g. `CLAUDE_TEST`) sandboxes a UCS to
  that job; the UCS just reads whether it exists. A gate for another author's test environment
  stops your UCS confounding their readings.

## UCS structure (UCS:M)

How one UCS is laid out so each part is handled once and every block runs only where it applies:

```
;Controls Widget Part Intelligence
For Each FRONT | PANEL | STILE part

    if TEST_FLAG == null then
        exit
    end if

if NAME == 'FRONT' | NAME == 'PANEL' then ;If Part Is A Front Or A Panel

    ;;SEED VALUES OTHER PARTS READ
    WIDGET_OFFSET := 0


    ;;ATTRIBUTES AND LOOKUPS
    ;(seed-once attributes, pass-through, lookup blocks that set WIDGET_OFFSET)


    if NAME == 'FRONT' then ;If Part Is A Front
        ;(logic only fronts need, nested in the shared block)
    end if

end if


if NAME == 'STILE' then ;If Part Is A Stile
    ;(this part never passes the gate above, so it gets its own sibling block)
    ;(reads what the block above computed, e.g. :WIDGET_OFFSET)
end if
```

- **The header lists every part type the file touches**, and only those. A part type that isn't listed
  is never visited, so its gate logic never runs. Drop a type from the list when nothing gates on it.
- **One visit per part.** Give each part group one top-level `if NAME` block. Don't re-open the same
  part later in the file.
- **Nest sub-part logic inside its parent's block** when they share a gate (for example the attributes
  for a front, a drawer front and a panel live inside one shared block, and hardware placed on a
  frame part sits inside the block that computes that frame's thickness).
- **Parts that never pass the main gate get a sibling block** after it, not inside it.
- **Producers above consumers.** Compute a value before any block that reads it (a lookup sets a
  dimension before the part that uses it is placed). Across separate UCSs the same rule is the lineup
  order, see Execution model and ordering. A UCS reads its children's values up-tree with `:`.
- **Don't add `exit` at the end of each `NAME` block**; the saving is negligible.
- **Clear shared scratch with one gate at the end of the group.** When sibling option blocks share
  scratch parameters, don't put a `delete` in each block's `else`: a later block's `else` wipes what an
  earlier sibling just set. Use a single conjunction gate instead:

```
if OPTION_A == 0 & OPTION_B == 0 & OPTION_C == 0 then
    delete SCRATCH1
    delete SCRATCH2
end if
```
- **Deselect cleanups keep the sidebar honest.** In each option's `else`, delete the children it
  created, so returning a dropdown to None clears its sub-attributes. Delete anything that exists only
  under a condition when that condition goes false; `delete` on a missing parameter does nothing.
- **Split assembly and parts work** into two passes when parts need values decided at the assembly
  level (see the two-pass architecture under Execution model and ordering).

## Equations, geometry and positioning

- **CV equations are algebra:** parameters are the variables, prefixes pick the scope (`:DZ` parent's,
  bare `DZ` own). A UCS declares relationships and CV re-solves them each rebuild. Derive equations
  from the joint's geometry, not by fitting sample numbers, and a relational equation aligns for every
  profile and thickness. For positioning equations, get the relationship in words from the person who
  knows the geometry rather than inferring it from a drawing.
- **`=` stores the live equation; `:=` collapses it to a constant when evaluated.** A live `=`
  resolves a chained reference (A defined by B, defined by C) in one pass, while a `:=` snapshot
  captures only one hop and settles one rebuild at a time. Any value that inherits from a neighbor that
  itself inherits should use `=`.
- **`=` and `:=` with tree paths:** a down-tree reference computed with `:=` stops short; down-tree
  references generally need live `=`. But a `=` variable reading a plain PART parameter
  (`PABSY`, `DX`, …) freezes at the point of capture, exactly like `:=` (proven with a per-hinge
  test). Reading an OPERATION value down-tree into a variable does need `=`, since `:=` returns 0.
- **When `delete` is safe:** a parameter *is* its value, so any equation in this UCS or a later one
  that references it breaks once it's deleted, regardless of `=` vs `:=`. Delete only transient state
  you re-derive each rebuild, parameters whose existence conditions aren't met, or things whose every
  consumer has already fully evaluated. `delete` on a nonexistent parameter is a no-op.
- **Don't create a parameter for a single-use intermediate**; inline it. Cache only a computed value
  used more than once, and only when re-inlining it would multiply boundary crossings. Don't cache a
  bare reference.
- **Query system parameters directly** (`if LEND == 13`); don't snapshot to an intermediate. The only
  legit reasons are reuse of something expensive, or a `{}` substitution where inlining would nest
  braces.
- **Boolean-multiply trick:** a comparison like `(NAME == 'DLS')` evaluates to 1 or 0, so
  `A*(cond1) + B*(cond2)` selects between values inside one equation. It only works when exactly two
  options matter; with more, fall back to blocks.
- **Origin awareness is everything.** Positions and rotations are relative to the object's own origin,
  and each object's origin can sit on a different side per axis. Every origin is parent-relative and
  resets per level. Cross-frame comparisons must sum the chain of parent offsets to a common frame,
  or use length-only comparisons, which are frame-free. Positional findings hold only for the
  conditions of that equation.
- **Frame toolbox:** `X/Y/Z` are parent-relative; `XX/YY/ZZ` are assembly-only absolute wall-frame
  positions (null on anything inside the assembly, which silently makes conditions never fire, and
  needed because the cabinet editor re-centers the assembly at the origin); `PABSX/Y/Z` and
  `PABSAX/AY/AZ` are part-level absolute position/rotation relative to the cabinet.
- **Assembly-level queries from a part:** `LEND`/`REND` and similar live on the assembly. A bare read in
  an assignment climbs and resolves, but a `{}` substitution does not, so use `:CAB.LEND`.
- **Position adjust:** use `+=` / `-=` with a plain precomputed operand; `Y := Y + (…)` (reading and
  writing the same axis in one statement) faults. A delta measured off live `PABSY` self-zeroes on
  rebuild, so it doesn't drift; a fixed delta like `+= 2` would move every rebuild. `PABSY` does not
  track `Y +=` moves, so mirror each move into a running "current Y" variable.
- **Reference a freshly dimmed part with `this.X`**; a bare `X` won't resolve reliably because X
  didn't exist before this build pass.

## Reading other objects and the tree

- **Sibling addressing:** `:` = parent, `:.NAME@{i}` = sibling by index (parent's child), bare `NAME` =
  sibling, `this` = the For Each object, `.` = child. Same-named siblings are indexed with `@{i}` and
  walked with `while :.NAME@{i}.DX != null do` (**null-check, not `> 0`**: hardware like hinges has
  `DX = 0`, so a `> 0` test ends the loop at zero items).
- **Find your own index by matching position** (`:.HNG@{i}.Y == Y`), not `.ID`, which comes back 0
  through a sibling path. Find neighbors by position, never by index, since indices shuffle when
  items are added or removed.
- **You can READ a child or sibling parameter through a path, but you cannot ASSIGN through one**
  (`this.HNG@{n}.MATID := X` is an invalid operand). To write per instance, iterate the instances
  themselves and assign on self.
- **`{}` braces** glue a value into a name or path (`HNG@{i}`); in a comparison or arithmetic use the
  bare name. Inline `{}` evaluates only against parameters that exist on the current part, so a
  value from another part has to be handed down into a same-part carrier parameter first.
- **Delete-then-redetect pattern** for adjacency: delete all adjacency parameters at rebuild start, so
  "the parameter exists" means "the neighbor exists" (`LASM == null` = no left neighbor). Naming every
  assembly `ASM` gives the loops one stable handle, which is what makes the adjacent-assembly
  parameters (`LASM/RASM/TASM/BASM`) populate.
- **Conditions and sibling parts:** down-tree paths in a condition (`:.S_DSLAB.DX`) were observed to
  silently never fire, while sibling ASSEMBLIES read fine in conditions. The boundary is unsettled
  (build timing or part vs assembly). Prefer an up-tree discriminator for any gate; down-tree paths
  are reliable inside live `=` equations. `_SLAB` (0/1, Door or Drawer Front, up-tree) is the
  purpose-built slab discriminator.
- **Gate door-type-specific work by the consuming part's `NAME`**, not at the container.
- **Door tags as filters.** A door carries descriptive tags (for example a material tag such as
  `MAT:Veneer` or a manufacturer tag) in the `_DOOR_TAG` string parameter. A UCS reads it and matches
  with wildcards (`*MAT:Wood*`) to decide which parts to make or buy, or which override applies. Read
  it with a bare `_DOOR_TAG` from the parent front (a `:` climb was the earlier bug). Names,
  descriptions and tags can all serve as filters, not just `NAME`. Tags live on the door in the catalog,
  so after changing one, run Update Job → Doors on existing jobs.
- **Connection-applied children (line bores) don't exist at UCS:M time.** The connection that applies
  `LFVBORE`/`LRVBORE` fires after a UCS:M runs, so they can't be read from UCS:M, and referencing one
  doesn't return null but invalidates the whole expression and wipes the parameter that was applying
  to that part. In UCS:JS they are only visible at a late enough ordinal. A fixed shelf (`FS`) is not
  connection-applied. A line bore's `DY` overstates its extent; the real span is `(REPT − 1) * SPCNG`
  up from its `PABSY`.
- **Dependent-tolerance lesson:** a tolerance hand-mirrored from a construction condition (e.g. line
  bore hole count) is only as right as its upkeep. Check, in order, that the construction condition is
  set, the hinge height is right, the applied pattern matches the condition, and the mirrored numbers
  match.

## The nine basic parameters in code, and creating objects with dim

**The nine basics.** Every object carries X, Y, Z (position), DX, DY, DZ (size) and AX, AY, AZ
(rotation); what each means is in `Parameters.md`. In code:
- **UCS:M:** a bare name (`DX`) is the object the UCS is running on, `:DX` climbs to the parent,
  `CHILD.DX` reads a child. Write with `:=` (`X := 5`).
- **UCS:JS:** they are properties of `_this` (`_this.DX`) and readable with `GetParameterValue`.
- **Position is measured from the parent's reference point to the object's own origin.**
- **Rotation pivots about the object's origin.** The origin stays where X/Y/Z put it and the body
  swings around it, so after a rotation the origin sits on a different corner of the visible outline.
  That is why origins turn up on different sides (a rail's at its top, one stile's on its outside
  edge and the other's on its inside). Work out which corner the origin is on, for the orientation in
  question, before writing a position equation. CV's own UCS introduction gives the rotation order as
  X, then Y, then Z, with the axes not moving with the part.

**Making an object.**
- `dim NAME as new <type>` (`part`, `pull`, `line`, `hole`, …) creates it. The nine basics are the
  minimum you set on it, each with `NAME.PROPERTY := value`.
- **Material and thickness come from the material schedule.** Most parts have a default material
  assigned in the material schedules, so a dim'd part looks there for its material, and `DZ` follows
  that material's thickness (which can still be overridden). Set `MATID` only to force a different
  material. *(Material schedules are not yet covered in this Knowledge Base.)*
- Re-`dim`ing the same object name creates a new distinct part each time; UCS-created objects are
  recreated fresh each rebuild rather than stacking.
- Only a few material types can display 3D models, so a peg may have to be a `pull`. Model placement
  is set in the Material Manager relative to the dimmed parent's origin; the model carries its own
  size, so the dimmed object gets a placeholder dimension.
- **`line` as a machining route:** `TOOLID` selects the tool, `DZ` is the cut depth, `_FACEWP := 1`,
  `_RCUT` picks the path (0 center-line, 1 inside cut, 2 outside cut, 3 outside door route).
- `_FACEWP`: 1 = face, 2 = back. `_SPECIAL` (special-order flag): 1 Accessory, 2 Blum LEGRABOX,
  3 Docking Drawer. `DO` = drawer box interior (and `DO.DZ` is its height), `BBK` = drawer box back.
- Switching a `DWR` between false front and real drawer makes CV treat it as a new part and wipe the
  other mode's parameters, so crossover cleanup is unnecessary.
- **`_HINSET`/`_VINSET`:** how much of a panel sits inside the tongue of the stiles (or rails). The
  visible panel is `[_HINSET, DX − _HINSET]`.
- `_HGRAIN := 1` (hidden parameter) runs grain horizontally on door panel parts only.
- **Hinges:** `HNG` (the cup) is a Part (class 10), not a `Hinge` object type, and lives on the door;
  `S_HNGPLT` (the plate) lives on the door opening. CV numbers them bottom-up. Material is written with
  `MATID := <id>` on self and read back through `_M:MATID` (bare `MATID` reads 0).
- A manually added part needs `UCSMOD = 1`; operations attach with `NewObj.Owner = Owner`.

## Loops (while-do)

**What a loop is.** A block of code that repeats for as long as a condition stays true. It has three
parts, and a loop with any of them missing either never runs or never stops:
1. **Start:** a counter is given a starting value.
2. **Test:** the condition is checked *before every pass*. If it is false the first time, the body runs
   zero times.
3. **Step:** something inside the body changes the counter, otherwise the test never becomes false.

```
i<int> := 0
while {i} < COUNT do
    ;(body: runs once for each value of i)
    i<int> += 1
end while
delete i
```

**Why the counter is reset and deleted.** The whole UCS runs again on every rebuild. Seed the counter
fresh each time with `:=`, and `delete` it afterward so no scratch value is left on the object.

**Braces.** `{}` is an inline evaluation. The bare `i` is the counter parameter itself (the thing being
created, tested and stepped, as in `i<int> += 1`). `{i}` evaluates the counter *at that moment in the
loop* and inserts its current value where a name or value is being built, so on pass 3 the path
`ITEM@{i}` becomes `ITEM@3`. This is why `{i}` is required inside names and paths. The V-groove loop
also used `{i}` in the loop test and in arithmetic, and the hinge work used the bare `i` in
comparisons; both have been seen working.

**Example 1: create N objects, centered across a width.** The count comes from the width and a
spacing, the start position centers the array, and each pass places one object:

```
COUNT<int> := TRUNC(DX / :WIDGET_SPACING)
START := (DX - (:WIDGET_SPACING * (COUNT - 1))) / 2

i<int> := 0
while {i} < COUNT do
    dim MARK as new part
        MARK.X := START + (:WIDGET_SPACING * {i})
        MARK.Y := 0
        MARK.Z := 0
        MARK.DX := 1
        MARK.DY := DY
        MARK.DZ := .75
        MARK.AX := 0
        MARK.AY := 0
        MARK.AZ := 0
    i<int> += 1
end while
delete i
```
- `TRUNC` drops the fraction, so a partial slot is not made.
- The array's span is `spacing * (COUNT - 1)`, which is why the start position is half of what is
  left over.
- `i` starts at 0, so pass `i` places the object `i` spacings from the start.
- The nine basics are all set here. `DZ` is shown as a literal, but it would normally follow the
  material schedule's thickness.

Trace for `DX = 20` and `:WIDGET_SPACING = 6`, so `COUNT = TRUNC(20 / 6) = 3` and
`START = (20 - 6 * 2) / 2 = 4`:

| Pass | `i` at the test | `i < COUNT`? | Action | `i` after |
|---|---|---|---|---|
| 1 | 0 | 0 < 3, true | object at X = 4 | 1 |
| 2 | 1 | 1 < 3, true | object at X = 10 | 2 |
| 3 | 2 | 2 < 3, true | object at X = 16 | 3 |
| end | 3 | 3 < 3, false | loop stops; `delete i` | (deleted) |

The three objects span X = 4 to 16 inside a width of 20, leaving 4 on each side.

**Example 2: walk N existing siblings.** Visit each same-named neighbor to count them and find this
object's own position among them. The list ends when the next index does not exist, so the test is a
**null check**, not `> 0` (hardware such as hinges has `DX = 0`, so `> 0` would stop before the first
one):

```
COUNT<int> := 0
MYPOS<int> := 0

i<int> := 1
while :.ITEM@{i}.DX != null do
    COUNT += 1
    if :.ITEM@{i}.Y == Y then
        MYPOS := i
    end if
    i<int> += 1
end while
delete i
```
- `:.ITEM@{i}` means "up to the parent, then down to its i-th child named ITEM", which is a
  sibling of the object the UCS is running on. `{i}` is required here because it builds the path.
- Find your own place by matching a real position (`Y == Y`), not `.ID`, which does not come back
  through a sibling path.
- Indices start at 1, and `i` ends one past the last item, so the count is `i - 1` if it is not
  tracked separately. CV numbers same-named hardware bottom-up.

Trace for three siblings `ITEM@1`, `ITEM@2`, `ITEM@3` at `Y` = 10, 20 and 30, running on the one at
`Y = 20`:

| Pass | `i` | `:.ITEM@i.DX` exists? | `COUNT` after | `Y` match? | `MYPOS` after | `i` after |
|---|---|---|---|---|---|---|
| 1 | 1 | yes | 1 | 10 ≠ 20, no | 0 | 2 |
| 2 | 2 | yes | 2 | 20 = 20, yes | 2 | 3 |
| 3 | 3 | yes | 3 | 30 ≠ 20, no | 2 | 4 |
| end | 4 | no (null), so the test is false | 3 | | 2 | loop stops; `delete i` |

The result is `COUNT = 3` and `MYPOS = 2`; `i` ended at 4, which is one past the last item.
- You can read a sibling's value through the path but you cannot assign through it; each object must
  set its own values.

## One value, several jobs

A recurring way to cut code: let a single parameter do more than one job, so no translation table or
extra flag is needed.

- **A choice value that is also an ID.** Name library parts after the material ID they use, and make
  that ID the stored value of the choice list. The same value then picks the part *and* builds its
  library path, with no name-to-ID lookup: `PART.LIBPART = 'Library\Accessories\{MATID}'`.
- **A numeric room value that is also the on/off switch.** Let `0` mean "none" and any other value
  mean "on", and use the value itself as the setting (the hardware ID, or a spacing). Then one
  condition, `if :WIDGET != 0 then`, both enables the feature and supplies its value. If the room
  parameter doesn't exist, the condition is null and skips harmlessly.
- **A comparison as a number.** `(NAME == 'LEFT')` is 1 or 0, so it can be a multiplier that selects
  between two values inside one equation (see the boolean-multiply trick under Equations).
- **A model already placed in its material vs a scaled library part.** A model set up inside its
  material is already centered, so placing it is just `X := DX/2`. A library part that scales to fit
  needs size math (`DX/2 + width/2`) and a rounded size. Where a model's origin sits is set in the
  Material Manager relative to the object you dim it on, so the equations only have to match it.
- **Anchor to the stable object.** Dim accessories on the opening, not the door, because the door
  moves with side adjustments and would de-center the accessory.

## Formatting standard (UCS:M)

- **Three comment tiers:** `;;;MAJOR SECTION;;;` (all caps, column 0, preceded by 4 blank lines);
  `;;GROUP HEADER` (all caps, indented to its nesting level, preceded by 3 blank lines); and an
  inline gate description after `if`/`else` (one `;`, Title Case, phrased as the condition being
  tested). Comment the gates, not the assignments, and give `else` a description of the inverse.
- Indentation follows block depth (one tab per level); nested blocks sit between blank lines; one
  blank line between sibling blocks; the first line is still the single-`;` UCS description.
- Attribute creation: put the `<style>`/`<desc>` lines after the `end if` (so they're re-enforced every
  run), indented one tab to group with the create block.
- Deliver snippets at base level (the CV editor adds the destination depth on paste); full files keep
  true depth.

## UCS:JS essentials

### Globals
- **`_this`** — the object the UCS runs on (a `CVAsmManaged`); primary handle for parameters and
  tree walking.
- **`_cab`** — owning cabinet/assembly context (seen in examples; exact meaning unconfirmed).
- **`_cvSystem`** — `Alert`, `CopyToClipboard`, `CreateObject('cvShape')`.
- **`_cvMath`** — `Degrees`, `Radians`, `Imperial`, `Metric`, `isEQ/isGT/isGTE/isLT/isLTE`,
  `isZero`, `Epsilon()` (1.19e-04).
- **`_cvString`** — `FieldString`, `isEQ`, `isEQN`, `isEQWC` (wildcards `*` `?`).
- **Libraries:** a CV Lib named "Math" is called as `_math` (lowercase, underscore-prefixed).

### Gotchas
- **No `For Each`.** Use "Add Apply Conditions" in the UCS window (wildcards allowed; filter scope
  with the OBJECT parameter). Apply conditions are not code.
- **Float comparisons must use `_cvMath.isEQ/isGT/…`** — raw `==`/`>` break on IEEE floats.
- `GetChildren()` returns a .NET `List`, not a JS array.
- The Shape API needs an **xShaping license**; `GetShape()` / `CreateObject('cvShape')` return null
  without it. Always null-check.
- Public Variables can't be defined in code; add them manually through the sidebar.
- The UCS description is the first comment line. Order column = processing priority; there are
  Enabled and Pre-Build flags. UCS:M can be converted to UCS:JS (a hidden :M backup is kept);
  Restore reverts to :M and loses the :JS.
- There is no top-level `return`; restructure `exit` as `if/else`.

### `CVAsmManaged` (`_this`)
- **Properties:** NAME, DESC, COMMENT, CLASS, TYPE, X/Y/Z, **DX** width, **DY** height/length,
  **DZ** depth/thickness, AX/AY/AZ, QTY, VISIBLE, BAND, REPT, SPCNG, and a few more. (The source
  PDF's property table is column-shifted in extraction; DX/DY/DZ, X/Y/Z, AX/AY/AZ, NAME/DESC are
  confirmed, verify the rest against the PDF.)
- **Methods:** `GetParameterValue(name)` (null if absent), `SetParameter(name, value, [type])`,
  `SetParameter(name, equation, [condition], [type])`, `HasParameter`, `RemoveParameter`,
  `ModifyParameter(name, PARMOD_DESC | PARMOD_TYPE | PARMOD_STYLE, value)`,
  `CreateChoiceList(name, 'Desc=val|Desc=val', type)`, `SetChoiceValue`, `Evaluate`,
  `EvaluateCondition`, `FormatText('WIDTH{DX}')`, tree walking (`GetChildren`, `GetFirstChild`,
  `GetNextSibling`, `GetParent`, `FindAssembly`, `SetParent`), `CreateChild(OBJ_type, name, [desc])`
  (returns the child), `SetMaterial`, `ReplacePart`, `QueryID`, and shape calls
  (`GetShape`, `IsShaped`, `SetShape`).
- **`CVShapeManaged`** (xShaping): `AddLine`, `AddArcRad`, `AddArc3Pt`, `Boolean('add'|'sub', …)`,
  `Check`, `GetSideType/SetSideType`, `Parse(xml)`, `Reset`, `ToXML`. Edge indices are 0-based.

### Constants
- **`VAL_*` types:** 1 MEASUREMENT, 2 DEGREES, 3 RADIANS, 4 INTEGER, 5 BOOL, 6 DECIMAL, 7 PARTID,
  8 TEXT, 9 CURRENCY.
- **`PARSTYLE_*`:** DEFAULT (1) = Standard, ATTRIBUTE (2), NOTE (3).
- **`PARMOD_*`:** DESC, TYPE, STYLE.
- **`OBJ_*` (CreateChild):** ASSEMBLY, OPENING, PART, DOOR, DRWFRONT, MOLDING, NGACSRY, HARDWARE,
  PULL, GUIDE, HINGE, HINGEPLATE, OPERATION, HOLE, DADO, LINEBORE, BLINDDADO, DOVETAIL, IJOINT,
  CONNECTION, ROUTE, LINE, ARC, and more. Also `ASM_CLASS_*`, `ASM_TYPE_*`, `ASM_END_*`, `ID_*`,
  `AXIS_*`.

### Validated in CV 25.2 (confirmed working, not just from docs)
- `GetParameterValue('X') === null` cleanly distinguishes "doesn't exist."
- `SetParameter('N', 'text', VAL_TEXT)` creates a text parameter; `ModifyParameter` sets style and
  description; `RemoveParameter` removes.
- **`GetParameterValue` honors the `:` path prefix** (`':PARAM'`, `'::PARAM'`, `'.child.PARAM'`,
  `'NAME@2.PARAM'`) and returns null, not 0, when a `:`-path parameter doesn't exist. This makes it
  the cleanest way to port UCS:M tree-path lookups.
- A `GetParent()`-based gate also works. Not yet proven whether a bare-name `GetParameterValue`
  resolves up the tree or reads only the immediate parent.

### Pattern: value inside the null check, style + description outside
```js
if (_this.GetParameterValue('MYPARM') === null) {
    _this.SetParameter('MYPARM', 'seed value', VAL_TEXT);          // value: seeded ONCE
}
_this.ModifyParameter('MYPARM', PARMOD_STYLE, PARSTYLE_ATTRIBUTE); // enforced every run
_this.ModifyParameter('MYPARM', PARMOD_DESC, 'Sidebar description'); // enforced every run
```
The value is set only at creation so users can override it freely; style and description are
re-asserted every rebuild so they can't drift. The two extra calls are the protection mechanism,
not overhead — don't "optimize" them into the null check.

### Writing to the Room or Job from a UCS:JS
Target a child (an Assembly), climb `GetParent()` to get a reference to the ancestor, and call
`SetParameter` / `ModifyParameter` / `RemoveParameter` on **that reference**, not `_this`. Room and
Job can't be targeted directly through Apply Conditions (a Room target ran with no error and created
nothing). Confirmed in CV 25.2, including a Note-style parameter spawning the Room's Notes tab.

Real ancestor chain above a cabinet: `_this` (cabinet) → Front Face (Wall Face, Class 10) → WALL
(Class 10) → Room (**Class 0**, Type 1) → Job (**Class 0**, Type 0, top; its `GetParent()` is null).
`Class === 0` marks the non-assembly levels. Don't hardcode hop counts; climb to the top:

```js
var room = null, job = _this, node = _this.GetParent();
while (node !== null) { room = job; job = node; node = node.GetParent(); }
// job = Job (topmost), room = the node directly below it (Room)
if (room !== null) {
    if (room.GetParameterValue('ROOM_NOTE') === null)
        room.SetParameter('ROOM_NOTE', 'text', VAL_TEXT);
    room.ModifyParameter('ROOM_NOTE', PARMOD_STYLE, PARSTYLE_NOTE);
    room.ModifyParameter('ROOM_NOTE', PARMOD_DESC, 'Description');
}
```
Open optimization: run per Assembly, this writes to the Room once per cabinet (idempotent but
redundant). A run-once or first-one-wins guard is still to be worked out.

## UCS:M ↔ UCS:JS translation

**Identical:** `+ - * /`, `%`, `< > <= >=`, `!`, `=`, `+= -= *= /=`.

**False friends (same symbol, different meaning):**

| Symbol | UCS:M | JavaScript | Use in UCS:JS |
|---|---|---|---|
| `^` | power | bitwise XOR | `**` or `Math.pow` |
| `&` | logical AND | bitwise AND | `&&` |
| `\|` | logical OR | bitwise OR | `\|\|` |
| `==` | equivalence | loose equality | `===` |
| `!=` | inequality | loose inequality | `!==` |

**Other translations:**
- `:=` → JS `=` for variables; for a parameter, `SetParameter`.
- `Delete PARAM` → `RemoveParameter`. `PARAM == null` → `GetParameterValue(...) === null`.
- Math: `ABS/SQRT/ROUND/TRUNC/EXP/LOG/LOG10` → the same names under `Math.`. `SQR(x)` is *square*, so
  `x*x`. **Trig is in degrees in UCS:M but radians in JS** — convert with `_cvMath`. `RPREC` has no
  JS equivalent.
- Units: `Imp(x)` → `_cvMath.Imperial(x)`; `300mm` → `_cvMath.Metric(300)`; `12in` →
  `_cvMath.Imperial(12)`.
- Strings: joins via `FormatText('w{DX}h{DY}')` or `'w' + dx`; compares via `_cvString.isEQ/isEQN/
  isEQWC`.
- Objects: `Dim X as New Part` → `CreateChild(OBJ_PART, 'X')`; `<type>` → the `VAL_*` argument;
  `<style>` / `<desc>` → `ModifyParameter`.
- Control flow: `;` → `//`; `If…Then…End If` → `if (c) {}`; `While…Do` → `while (c) {}`; `Exit` →
  restructure with if/else; `For Each` → Apply Conditions dialog.

## Job and room parameter behavior

- **Style decides where a parameter lives and whether touching it triggers a rebuild.** All three
  styles are still just parameters, and Update Job → Parameters treats them the same way. The
  differences:
  - **Standard** parameters live in the Object Tree and nowhere else.
  - **Attribute** parameters live in the Object Tree and also show on the sidebar (which ones show
    depends on the object currently selected). Changing one triggers a rebuild of its parent and of
    every child of that parent.
  - **Note** parameters live in the Object Tree and on the **Notes** tab of the Properties windows
    (job, room, assembly). Changing one does not trigger a rebuild; the change only takes effect once
    a rebuild is triggered some other way.

  So use Attributes for what must update live and keep the sidebar clean, and Notes for the bulk of
  up-front choices made once at the start of a drawing.
- **Catalog changes need a manual job Update; UCS edits do not.** A job snapshots Materials,
  Construction, Doors, Intelli-Joints, Connections and Parameters when it is created. A UCS edit takes
  hold on the next rebuild with no update. If something "stopped working after a system change," run
  Update on the job first: a stale snapshot (e.g. old door tags) looks like a broken UCS.
- **A parameter's value is what prints on drawings**, so room choices are best stored as readable
  text and translated to numbers by a UCS, rather than storing raw numbers or material IDs.
- **UCS:JS can write wall, room and job parameters (through a part); UCS:M cannot write upward at
  all.** In JS the write happens through the part the apply condition targets, so that part must
  already exist in the room. This is why legacy room parameters have to come from System Parameters.

## System parameters (job, room and cabinet-class parameters)

**What the term means.** Strictly, "system parameters" are the parameters that are native to Cabinet
Vision and exist by default (`TOEH`, `LEND`, and roughly 660 others, documented in the reference PDF).
The **System Parameters window** is one place where you can add your own custom parameters to that
system; it is one of several ways custom parameters get created (a UCS is another). So "system
parameter" can mean a built-in one or a custom one defined in that window, and this file says which.

**What a custom system parameter is.** A parameter definition stored at the system level that CV
copies onto every job, room or cabinet it applies to, so the parameter exists before any UCS runs. Each
one is created with six fields: **Prompt** (the sidebar or Notes label, including its `01 - `
numbering), **Parameter** (the name a UCS reads), **Type** (text, integer, measurement, Boolean…),
**Value** (a literal or a `<lst>` choice list), **Class** and **Style**. There is no separate
description field; the Prompt is the description (it appears as "Description" when the parameter
is shown on a job or room). Where to open the windows is in the table below.

**Class decides where the parameter lives**, and follows the CV hierarchy. The choices are Job, Room,
Cabinets, Base Cabinet, Upper Cabinet, Tall Cabinet, Vanity, Closets, Closet Standard, Closet Shelf,
Closet Panel, Closet Base and Closet Upper.
- A **Job** parameter is one per job, sits at the top of the Object Tree, and affects every room
  below it.
- A **Room** parameter is one per room and affects only the room it sits in. If the same name exists
  at both levels, the room's value wins (nearest ancestor wins).
- A **cabinet or closet class** parameter is added to every cabinet of that class when it is placed,
  so each one carries its own copy that can be overridden per cabinet.

**Style decides its behavior.** Attribute shows on the sidebar and rebuilds when changed; Note shows on
the Notes tab and does not rebuild when changed; Standard shows only in the Object Tree (see Job and
room parameter behavior).

**Where to find each window.** Where you can see each kind of parameter differs:
- **Job parameters** are never viewable in the Object Tree; use the Job Properties window.
- **Room parameters** are viewable in the Object Tree, on the Room node at the top of the tree (the
  parameter pane below the tree shows them when it is selected), and in the Room Properties window.
- **Cabinet and closet class parameters** live on the assemblies they apply to, so they are always
  viewable in the tree, on each assembly.

The windows:

| Window | What it edits | Path |
|---|---|---|
| **System Parameters** | The template that new jobs copy. Only reachable with no job open (the Utilities tab inside an open job has no Parameters button). | Start screen → **Utilities** tab → **Parameters** button |
| **Job Properties → Parameters** | The live parameters on the current job | Inside an open job: **Main** tab → **Job** button → **Parameters** tab |
| **Room Properties → Parameters** | The live parameters on the current room | Inside an open job: **Main** tab → **Room** button → **Parameters** tab |
| **Parameter Edit** | One parameter's definition | From either Properties → Parameters tab, select a row and press **Edit** (**Add** creates a new one, **Delete** removes it) |
| **User Created Standards** | The UCS editor | **Utilities** tab → **User Created Standards** button (next to Parameters on the start screen; also on the Utilities tab inside an open job) |
| **Update Job** | Pulls changes from the system databases into the open job. Its dialog offers Materials, Construction, Doors, Intelli-Joints, Connections and Parameters | Inside an open job: **Utilities** tab → **Update Job** button, then tick the items to update (**Parameters** is the one that refreshes system parameters) |
| **Assembly Properties → Parameters** | The parameters on one cabinet (closets are identical) | Select the cabinet in a Plan or Elevation view → right-click → **Properties** → **Parameters** tab |
| **Object Tree parameter pane** | The parameters on any object in the tree, not just cabinets | Toggle the sidebar to the Object Tree with the two-arrow button at the bottom left, select a node, and read the pane below the tree |
| **Assembly editor** | The same Object Tree and pane, scoped to one cabinet | Open the cabinet for editing with right-click → **Edit** or by double-clicking it (title bar shows `[Assembly]`), then use the same bottom-left toggle |

Notes on each:
- **System Parameters window.** A grid with the columns **Prompt**, **Parameter**, **Type** and
  **Value**, and a **Delete** / **Delete All** button at the bottom. Rows carry a small icon at the
  left; the Job-class rows use a different icon from the room-level ones. **Class** and **Style** are
  further columns to the right of Value (scroll right). To add a parameter, type it into the blank row
  at the bottom of the grid. Because it opens from the start screen, it is global, not tied to one
  job.
- **Update dialog.** "This action will update the selected items in this job with the latest changes
  made to the databases." It shows a checklist of **Materials**, **Construction** and **Doors** (each
  expandable), **Intelli-Joints**, **Connections** and **Parameters**, with OK and Cancel. Below the
  list is a **Remove deleted system parameters** checkbox (greyed out until Parameters is ticked, as
  far as the screenshot shows). It controls whether a parameter you deleted from the System
  Parameters window is also removed from the job; without it, the job keeps the old parameter.
- **Job Properties and Room Properties.** Each is a dialog with a left-hand column of object tabs (Job
  or Room, then **Cabinet**, **Closet**, **Counter Top**, **Molding**) and a **Parameters** tab beside
  Information, Comment and Schedule (Job) or General, Finishes, Layout, Overrides and Notes (Room).
  The **Cabinet** and **Closet** tabs hold the default settings that new cabinets and closets in that
  job or room start with. The live copy of a class parameter on an existing cabinet is seen by
  selecting that cabinet, then reading the sidebar or the Object Tree. The Parameters list shows **Parameter**, **Value**, **Type** and
  **Description**, where Description is the parameter's Prompt. Rows created from a system parameter
  show a list icon. A **person icon** on a row means a user changed that value from its default.
- **Parameter Edit** has **Type**, **Style** (Standard, Attribute or Note), **Name**, **Description**
  (the Prompt), a **Value** or **Equation** choice (Value with a **Choices** button, or an equation
  list of IF / THEN rows with a **Test** button) and a read-only **UCS** field. The same dialog is used
  to author a parameter directly on a job or room, not only to edit a system-defined one.
  Equations are what make assemblies and parts parametric (Object Intelligence). **Once a UCS is
  actively targeting a parameter, that parameter cannot be modified at all outside the UCS**: the
  UCS hardcodes everything about it. This is what makes a UCS so powerful, and also what makes it
  destructive when it is wrong. Only an *unconditional* write locks a parameter: one the UCS writes
  every rebuild. A seed-once value (created inside an `== null` check) is not being actively targeted
  after creation, so the user can still edit it.
- **Assembly Properties.** The right-click menu on a cabinet (Copy, Delete, Move Label, Save, Edit,
  Section, Edit Shape, Combine, Split, Detach Toe, Rehinge, Finish End, Lock Width, Replace,
  **Properties**, …) opens a dialog with tabs General, Comment, Finishes, Legs, Overrides and
  **Parameters**. The Parameters tab lists every parameter on that cabinet (native, class-defined and
  UCS-created together) with the same **Parameter / Value / Type / Description** columns and
  **Add / Delete / Edit** buttons as the job and room dialogs. The **Type** column reads Value, String
  or Equation. Selecting a cabinet also fills the sidebar with its Attribute-style parameters (under
  the Attributes heading, below the built-in Clearance, End Position, Center Position, Dimensions and
  Position groups).
- **Object Tree parameter pane.** The two-arrow button at the bottom left of the sidebar switches the
  sidebar between the home view and the Object Tree. The tree shows the whole path down from the room
  (Room → Wall → Front Face → cabinet), and the path of the selected object is printed above it in
  the form `Room.WALL@2.Front Face.ASM@2`, the same `@n` addressing a UCS uses. Below the tree, a pane
  lists every parameter on the selected object as `NAME = value [Static]`, `[Equation]` or `[String]`,
  with **new**, **edit** and **delete** icons on its toolbar. The value shown is always the computed
  result, and the tag tells you how it is stored (tested and confirmed):
  - `[Static]`: the result of an equation that was resolved when it ran, which is what `:=` produces.
  - `[Equation]`: the equation itself is stored and re-evaluated, which is what `=` produces. The
    pane still shows the computed value, not the formula text.
  - `[String]`: any text parameter.

  This gives an at-a-glance way to check whether a UCS assigned a value with `:=` or `=`. Double-clicking a row (or **edit**)
  opens the same Parameter Edit dialog. This pane works on any object in the tree, so it is the way
  to inspect and edit part-, operation- and assembly-level parameters, and the place to read what a
  UCS has written. The Parameter Edit dialog's Description box is greyed out for Standard-style
  parameters (only Attribute and Note need one). Its read-only **UCS** field names exactly which UCS
  is actively targeting or controlling that parameter, whether the parameter is native or custom
  (for example a parameter controlled by the Public Variables list shows "> Public Variables"). An
  empty field means no UCS is controlling it. Check this field first when a parameter won't accept an
  edit.
- **Assembly editor.** Opening a cabinet for editing switches the title bar to `[Assembly]` and shows
  the ribbon's Section tools and the Section, Face, Plan, End, 3D and Reports tabs. The bottom-left
  toggle gives the same tree-plus-pane view, with the tree starting at the cabinet, so you can inspect
  its parts and operations from the cabinet down.
- **Naming example.** An Attribute in the sidebar named `OVR - Override Cabinet Size Control` sits
  after the numbered attributes, matching the `OVR - ` description convention.
- **On screen while working.** Attribute-style job and room parameters also show in the sidebar under
  **Job Parameters** and **Room Parameters** and can be changed there; Note-style ones do not appear
  in the sidebar (they are on the Notes tab).

**How they reach jobs.** A new job is seeded with the current system parameters when it is created. To
bring later changes into an existing job, run **Update Job → Parameters**. That adds any missing
parameters to the job, room and existing cabinets, and it also refreshes changed definitions (lists,
prompts, defaults) while keeping what the user already selected. (Do not confuse this with a UCS
`delete` before `create`, which is what refreshes a UCS-created parameter; see the `Update Selections`
sentinel under Choice lists.) A job created before a parameter existed simply reads that parameter as
null until updated.

**How a UCS uses them.**
- Read a job or room parameter from a part or assembly with `:PARAM` (the `:` climbs until it finds
  the nearest match). Reading a missing one is null, so conditions skip harmlessly, but an assignment
  that uses it as its source silently keeps its old value. Guard with `== null` or seed a default.
- The usual structure is local attribute → room parameter → final parameter (the pass-through under
  Choice lists), so a part follows the room unless the user picks something different on that part.
- A choice list's comparison is against its stored value, not the label: confirm the stored value
  before writing the condition.
- **UCS:M can only read them.** UCS:JS can also write job, room and wall parameters, but only by
  climbing from a part that already exists in the room.
- Naming groups related parameters by area with a shared prefix (for example `JOB_*`, `ROOM_*`,
  `EXT_*`, `INT_*`, `DOOR_*`, `ACC_*`); the numeric prefix on each Prompt sorts them in the sidebar.
- When a parameter is renamed, every UCS and every Automatic CAD Text tag that reads the old name must
  be updated, and only the live name should be referenced.
- The text you store is also what prints on drawings, through Automatic CAD Text tags. See Automatic
  CAD Text in `Core.md` for how tags read any parameter, and its practice of making sure a parameter
  always resolves to something (such as "N/A") so a blank on a drawing means something is wrong.

## Where UCSs live

All UCSs live in one CVData table, `UCS`. `Code` holds the script, `CodeBackup` the hidden UCS:M backup
from Convert-to-JS, `Ordinal` the execution order, `Disabled` the enabled flag, `PreBuild` the phase
flag, `MacroType` (0 = UCS:M, 1 = UCS:JS), `UCSLibrary` the JS-library flag and `ApplyCondition` the
apply conditions. `ID` is a stable identity, distinct from the lineup position (`Ordinal`); `rGUID`
survives export/import. Child tables keyed by `UCSID` hold public variables, parameters and the
assembly-class/type/construction/door maps. Older UCS sets that predate the current rebuild are kept
only because old jobs reference them, and they exit by `CONSTID` on new work.

## Feature designs worked out

- **V-grooves:** three modes: slabs aligned across a contiguous coplanar run of cabinets, 5-piece panels
  centered per panel (random), and 5-piece panels aligned within one cabinet. Architecture: a
  cabinet-level run-detection UCS (ordered first) → the face computes shared spacing and alignment → each
  part owns its phase, gated by `NAME`. Run detection uses live-`=` propagation of left/right run ends
  across adjacent cabinets, which resolves in one pass.
- **Pulls:** pull side is opposite the hinge (`HNG`: 1 left-hinged, 2 right-hinged, 3 top-hinged, 4
  bottom-hinged); cabinet class sets ergonomics (base/vanity → top of door, upper → bottom, tall → a
  three-case dispatch). Centering uses the door's rail and stile flats.
- **Fillers / finished ends** (CONSTID 177): four coordinated UCSs partitioned by width, connection and
  scope (standard assembly, ¾-wide assembly, sub-assemblies, parts). The parameter contract flows one
  way: the assembly UCSs decide, the sub and parts UCSs read `:CAB.*`. The two assembly UCSs are ~70%
  identical and are candidates to merge into one width-branched UCS.
- **Hinge collision avoidance:** move a hinge (cup and plate together, in Y) out of the way of an
  adjustable or fixed shelf, centering it in the adjacent opening; adjustable-shelf clearance keys off
  the line-bore hole count, fixed shelves use a flat clearance. The version that worked was the
  smallest one, working from shelf positions rather than the connection-applied bores.
- **Roadmap:** convert pullout accessories from one scaled library part to discrete-size models chosen
  from a size ladder, which needs a per-line width catalog.

## Debugging and troubleshooting

1. **UCS not running at all:** the code broke silently somewhere, or the UCS is simply disabled. Check
   Enabled first.
2. **UCS runs but ignores one part:** that part type is missing from the `For Each … part` line.
3. **`dim` does nothing:** the UCS is set to Pre-Build.
4. **A parameter's final value contradicts a UCS that plainly sets it:** another UCS is writing it later
   in the order.
5. **Consumer reads null on a value another UCS sets:** check lineup order and build phase first.
6. **Stopped working after a system change:** run Update on the job (see above).
- **Probes:** drop temporary `DBG_X := <expr>` parameters, or `COMMENT = 'text {PARAM}'` on a part
  (displayable in a CAD table), and read them off the Object Tree before theorizing. A `:=` probe that
  fails to appear proves its right-hand side was null. Delete probes afterward.
- **Simplifying means removing, never swapping in unverified syntax.** Folding a guard into one
  `& … & (… | …)` line with parentheses evaluated false for every hinge and silently no-op'd. Keep
  conditions single-operator or nested; don't introduce parentheses as part of a cleanup.
- **Debugging a constant miss in a relational equation:** audit the inputs (any lookup values feeding
  it) before rewriting the equation. A wrong input can pass for a geometry error for several rounds.
- A `For Each` type-order error (`HNG | AS` erroring while `AS | HNG` ran clean) was seen once and never
  explained; treat it as a one-off, not a rule.

### General principles
- **A fault anywhere silently rolls back the WHOLE UCS.** Extra scaffolding is usually the bug.
- Write the smallest thing that could work; add a flag/guard/temp only on proven need.
- On any break: strip to the known-good core and bisect — add one piece, rebuild — never add another
  layer.
- Query parameters directly rather than snapshotting them into variables, and adjust position with
  `+=` / `-=` and a precomputed operand.
- If a block passes ~20 lines or 3+ temps, the minimal version almost always wins.
- Before inventing a constant or tolerance, scan the already-mapped room/interior parameters
  (`INT_*` choice lists, hidden `_*` overrides) — the value is usually already held somewhere.
  Example: the hinge tolerance's line-bore reach is `INT_LBORE` (holes per shelf) × 32 mm, not a
  magic number.
