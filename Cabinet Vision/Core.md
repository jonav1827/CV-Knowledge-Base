# Core & Fundamentals

The base CV license everyone has, plus the fundamentals that apply before getting into any
specific module — navigation, general concepts, file/job structure, preferences, terminology.
These two were originally split into separate files but folded into one: the Core license *is* the
foundation, so there's no real line between "fundamentals" and "Core" content.

See `Modules.md` for the full Core feature list Hexagon documents. This file is for the real
operational knowledge on top of that: how it's actually used, gotchas, workflow, and anecdotes.

**Priority** — on Ironwood's intended first-license list, and the base everything else builds on.

---

## The Level Hierarchy (THE fundamental concept)

Everything else in Cabinet Vision sits on top of this. If one thing in this whole Knowledge Base
has to be understood first, it's this.

CV organizes every property — construction, materials, hardware, sizing, everything — into nested
levels, in this exact order, top to bottom:

**System → Job → Room → Wall → Wall Face → Assembly → Case / Interior / Face → Part → Operation**

(Documentation elsewhere sometimes simplifies this down to System → Job → Room → Assembly →
Part → Operation, but the real chain CV follows is the fuller one above — see **The Object Tree**
below, which is the literal, concrete representation of this exact hierarchy, not a separate or
looser version of it.)

**How setup works:** System level is where the master defaults live — this is where you set up
your standard Parts, Materials, Construction methods, and everything else you want to be true by
default. When you start a new Job, CV copies the System-level settings into that Job as its
starting point.

**How inheritance/lookup works:** When CV needs to know how to build something, it doesn't start
at the top and work down — it starts at the *lowest* level (Operation, then Part, and so on up
through Case/Interior/Face, Assembly, Wall Face, Wall, Room, Job, System) and works its way *up*,
stopping the moment it finds an instruction. Whatever level has the most specific, lowest override
wins. Nothing higher up even gets consulted once a match is found.

**How overrides work:** A change made at any level only affects that level and whatever's below it
that hasn't been overridden itself — it never reaches sideways (to a sibling) or upward (to the
level above). Concretely: change a Room's Door style, and every Assembly in that Room picks it
up — *except* an Assembly that already had its own Door style set individually at the Assembly
level. That one keeps its own override; the Room-level change simply never gets consulted for it,
because CV already found what it needed at the Assembly level first.

**Mechanically, what an override actually is (corrected):** an override is *not* an existing
parameter's value flipping from Equation to Static. It's an entirely separate parameter, newly
inserted into the Object Tree at the branch where the override happens — sitting directly in the
path between the object doing the lookup and wherever the real information actually lives.

Worked example — `TOEH` (toe height): a cabinet's toe height is normally defined once, up in the
construction method / standards, not on the cabinet itself. So when a cabinet needs to know its toe
height, it climbs the tree, finds `TOEH` defined up at the standard, and uses that. Override the toe
height on that one cabinet, and CV places a brand-new `TOEH` parameter directly on the cabinet's own
branch — somewhere it didn't exist before. Now when the cabinet looks up `TOEH`, it finds this
override sitting right there *before* it ever has to climb as far as the standard, stops (first
match wins, per the lookup rule above), and uses the override's value instead. "Clearing" an
override means deleting that inserted parameter outright — with it gone, the lookup has nothing to
stop it at that branch anymore, and it continues climbing to the real value.

This is also what CV's `Visible with user override` Visibility value (`Reference/CV System
Parameters.pdf`, and see `Parameters.md`) actually means: that specific parameter only exists on a
branch — is only "visible" there at all — when it's been overridden. Its presence on the tree *is*
the override.

**An override defaults to Static, but doesn't have to stay that way.** A user-created override can
usually be made "intelligent" with an Equation instead of a fixed value. And there's no fundamental
difference between a user-created override and a **UCS-created** override (see `Parameters.md`) —
both are the same inserted-parameter mechanism described above; the only real difference is *what*
put it there, which is exactly what the person-icon vs. 3-lines-icon distinction in the Object Tree
is showing you.

**UCS-created overrides come with a real trap, though: you cannot simply delete them.** A UCS is
code that runs on every rebuild. If a UCS is what's placing an override parameter on the tree, and
you delete that parameter, the deletion itself triggers a rebuild — which re-runs the UCS code —
which immediately reapplies the exact override you just deleted. The only way to actually remove a
UCS-driven override is to go edit or disable the UCS itself, not the parameter it's placing. This
is part of why UCS is considered advanced territory reserved for highly skilled technicians: a
well-written UCS can massively extend CV and tailor it to a company's exact standards, but a poorly
written one can cause real, hard-to-diagnose problems precisely because you can't just delete your
way out of what it's doing.

This is also framed as a **Global vs. Local** distinction: System-level changes are Global — they
reach every future Job (not retroactively, unless deliberately imported into an existing Job).
Room-level changes are Local — contained to that Room only. This containment is what makes it
possible to run an Oak kitchen, a Cherry dining room, a laminate laundry room, and melamine garage
cabinets all in the same Job without them bleeding into each other: each Room's overrides isolate
its own Material/Construction/Hardware/Counter Top choices from every other Room.

### Jon's notes

**The real danger isn't confusion, it's accidental overrides.** Not understanding the hierarchy
shows up as several different mistakes, but the big one is a user doing *more work than actually
required* — and in the process, unknowingly creating an override. If that override isn't caught
during output review, it makes it to production as-is. This happens constantly — not a
beginner-only mistake, it catches experienced users too.

**Worked example — a Walnut-to-White-Oak revision:** Say a Job is set up with Walnut doors at the
Job level, so every Room inherits Walnut by default. A revision comes in changing the whole job to
White Oak. There are two ways to make that change:

1. Change it once at the Job level. Every Room inherits White Oak, and keeps inheriting whatever
   the Job level says going forward.
2. Change it individually in each Room. This *looks* identical right now — every Room shows White
   Oak either way — but it's created an override in every single Room. Those Rooms are now
   disconnected from the Job level for that property and will never inherit a Job-level change to
   it again unless someone manually catches it or clears the override.

The trap: if the job later reverts back to Walnut at the Job level, option 1's rooms follow
automatically. Option 2's rooms don't move — they're stuck on White Oak until someone manually
fixes each one. Across a whole job this kind of override might be obvious, but buried in one
property of one Room inside a large job, it's very easily missed.

**An even subtler version of the same trap:** overriding a property, then manually changing that
override's value *back* to match the default. The values now match, so it looks correct at a
glance — but the override parameter itself was never cleared. It's still technically overriding the
default with the default, which means it's still silently disconnected from inheritance and will
diverge again the next time the Job-level value legitimately changes.

**Checking for overrides:** there's no single universal method — different override types get
checked in different ways depending on which level they live at, behavior can be inconsistent, and
known system bugs can actually hide certain overrides from view. Nearly any override can be found
if you know to look for it, but nothing prompts you to look — that judgment has to come from
knowing the hierarchy well enough to suspect where one might exist.

**Clearing an override:** also depends on where it lives — the Room Overrides tab, the Section
Editor UI's own overrides, a Part's Overrides tab, or in some cases the override *only* exists on
the Object Tree. See **The Object Tree** below.

---

## The Object Tree (fundamental #2)

Jon's second fundamental, alongside the Level Hierarchy above — and not a separate or looser
concept from it. The Object Tree **is** the exact hierarchy above, made literal and inspectable:
System → Job → Room → Wall → Wall Face → Assembly → Case/Interior/Face → Part → Operation, all the
way down, with every property along the way parametrized. Important: parameters themselves are
**not** part of that branch structure — they don't occupy their own level the way Room or Part do.
A parameter is a characteristic *of* whatever branch it lives on, not a child branch in its own
right (see `Parameters.md`). Overrides that don't show up in a Room's
Overrides tab, a Part's Overrides tab, or the Section Editor UI can still be found here, which
makes it the closest thing to a universal place to check — with one correction: *most*, not all,
parameters live visibly on the tree. Some are hidden — still real, still referenceable (in a
formula/UCS, for instance), just not something you can see or click on directly in the tree view.
Cabinet Vision's own system-parameter reference (saved in `Reference/CV System Parameters.pdf`)
documents a `Visibility` property on every parameter — values seen include `Always`, `Never`,
`Non-Visible`, `Visible with user override`, `User Added`, and `User Activated` — which plausibly
relates to this. Worth being cautious here, though: Jon has found a lot of the documentation
around Visibility unreliable in practice, and doesn't actually rely on checking it — in real work,
finding a hidden parameter is a matter of knowing to look through the tree directly, not consulting
its documented Visibility value. See `Parameters.md` for the distinction between Visibility and
Style (Standard/Attribute/Note), which is the property that actually governs day-to-day work with
a parameter.

### Jon's notes

**Structure:** a literal expandable tree, same shape as a file explorer. The text string at the
top of the view is a breadcrumb showing exactly where you currently are in the tree (e.g.
`Room 1.WALL.Front Face.ASM.Interior`). Worked example, one Assembly deep (a "Standard 2DR 1DWR
Floating Cabinet"), showing how the hierarchy above plays out concretely:

- **Case** — the physical case parts: Finished Left End, Finished Right End, Unfinished Back,
  Nailer(s), Top, Deck
- **Interior** — Case Opening(s), Drawer Stretcher, Adjustable Shelf
- **Face** — Face Opening, Drawer Opening, Mid Rail, and a Door Opening that nests further into a
  Door Object (Door Pull, Hinges, Door Slab, and boring operations like cup holes/anchor holes,
  Hinge Plates)

Every node has a short internal code in parentheses (LF, RF, UB, NA, TO, DE, CO, DS, AS, FO,
DOR_OPEN, DOR, PULL, HNG, S_DSLAB, etc.) — worth capturing in the Glossary later if these codes
come up as their own point of confusion.

**Navigation:** no search or filter — you have to already know how to navigate it and where to
look for what you're after. Not something you can casually browse to find an answer; it requires
already knowing roughly where the thing you're looking for should live.

**How much people actually work in it:** the average CV user does very little, if any, direct work
inside the Object Tree. It's primarily an inspection/reference tool, not a place normal day-to-day
work happens.

**The real risk:** editing directly in the Object Tree affects the job directly and immediately —
it's not a sandbox or a preview. Unless you know exactly what you're editing and why, it's easy to
cause complications this way.

### Parameters & icons

Select any node in the tree and a panel below it lists every parameter relevant to that branch, in
the form `NAME = value [Type]` — observed types so far are Static (a fixed value), String (a text
value), and Equation (calculated/formula-driven). This panel is the actual mechanism for checking
what's set where, referenced above.

Each parameter can carry one of three states, shown by an icon directly to its left:

- **No icon** — a standard parameter, nothing overriding or controlling it.
- **A small "3 lines" icon** — the parameter is being controlled by a UCS (User Created Standard).
- **A small person icon** — the parameter has been modified directly by a user. This *is* an
  override, made visible.

The nuance worth remembering: **a UCS can itself be what creates and controls an override
parameter** — in that case the parameter displays the 3-lines icon, not the person icon, even
though it's functionally still an override. So the same parameter (e.g. `TOEH`, toe height) could
show up with *either* icon depending on how the override was actually put there — set by hand
(person icon) or driven by a UCS (3-lines icon). The icon tells you the *mechanism* behind an
override, not just whether one exists.

Parameters got big enough to warrant their own file — see `Parameters.md` for parameter types,
the three parameter styles (Standard/Attribute/Note) and how they differ, Static vs. Equation
values, parametric equations, Object Intelligence, and the 9 basic parameters every beginner
should know.

---

## File Menu & Preferences (quick reference)

- **Batch Jobs** — bundles multiple Jobs or ORD files into one combined cut list, usable across
  S2M CENTER, Bid Center, or Report Center at once.
- **Job Recovery** — lists recoverable `.BAK` (created on every successful Open), `.ASV`
  (AutoSave), and `.TMP` files, letting you restore a Job from a prior state.
- **Measurements are always stored internally as inches**, no matter what unit or precision you
  display. Changing the display unit/precision only changes what's shown, never what's stored —
  worth remembering before assuming a rounding quirk is a bug.
- **Undo/Redo stack size** (General tab) — how many actions can be undone. Set too high and it can
  noticeably slow the system; recommended around 5.
- **Auto-Save interval** (General tab) — how often CV auto-saves in the background, directly
  feeding the `.ASV` files Job Recovery restores from above. Too short an interval (e.g. 1 minute)
  can actually slow things down or contribute to crashes on large jobs; recommended 10–20 minutes.
  If CV crashes, the next launch checks for a matching `.ASV` file and offers to restore from it —
  but only up to whatever point that file was last written, so anything after that is still lost.
- The **Geometry, Layout, Detail, Format, and Tools** Preferences tabs are mostly long lists of
  granular CNC/output checkboxes (ARD file output options, banding-in-cutlist toggles, etc.) —
  reference material to pull up when configuring a specific output, not something worth memorizing
  as core knowledge.

---

## Layers

The single most important, non-obvious fact about Layers: **they control what you can *see*, never
what actually exists in the Job.** Turning a Layer off just hides that category of object from a
particular view — the objects themselves are untouched. Turn off Upper Cabinets in a Floor Plan
View's Layer settings, and the upper cabinets are still fully there in the job data; they simply
don't render in that view. This is the same mental model as a layer toggle in any drawing/CAD
software — it's presentation, not data.

**Layer Schedules** are named, reusable bundles of Layer settings — create, edit, copy, rename, or
remove them like presets. The same job, same exact view, can look completely different depending
on which Layer Schedule is applied: full-detail cabinets vs. outline-only cabinets, dimensions shown
vs. hidden, object name labels on vs. off — all without a single object in the job actually changing.

**Confirmed, and this reframes a lot: the Layer Schedule tree is not a separate system from the
Level Hierarchy — it's the same parent/child inheritance pattern, applied to layers.** Selecting a
parent folder like "Layout (General)" shows its own full layer list, and its child views (Floor
Plan View, Elevation View, etc.) inherit from it the same way any child inherits from its parent
elsewhere in CV — unless a child sets its own override for that layer, in which case the child's
value wins. A child can also carry layer categories the parent doesn't have at all (Dimensions,
Annotations, Shop Annotations, CAD are missing from Layout (General)'s own list, most likely
because it's a deliberately generalized level — those are more view-specific concerns that get
introduced further down, not overrides of something the parent already defines). This is the same
principle as a Part having more parameters than a Room, just expressed through Layers instead of
the object-property parameters covered earlier.

**Critical clarification, straight from Jon: every branch in this tree is a genuinely separate,
standalone view — nothing about a screen is actually shared between a parent and its child.**
Nesting in the tree is purely about *inheritance* (a child starts out picking up its parent's
settings, and can override them) — it says nothing about how the two views relate on screen. A
child is not a sub-region of its parent's view, and a parent's screen doesn't contain its child's
content. Confirmed with a concrete example: **Splash View** sits nested under Elevation View in
the tree, but it isn't "the splash portion of a normal Elevation View" — it's the layer schedule
for the dedicated **Splash** tool's own separate screen (the same "Splash" tool that sits in the
Room Level sidebar alongside Walls, Objects, Auto Fill, Molding, Grain Match, Cross Section, and
CAD, each of which opens its own distinct screen). Its position under Elevation View exists only so
it inherits Elevation View's settings by default — reaching that screen at all requires activating
its own dedicated tool, not navigating "into" Elevation View. Don't read tree position as screen
containment anywhere in this hierarchy.

**Why the nesting lands where it does, now confirmed:** Room Level's top tab bar — **Plan**,
**Elevation**, **3D**, alongside Reports/Drawings/S2M CENTER — is what maps directly onto Layout
(General)'s own top-level children (Floor Plan View ↔ Plan tab, Elevation View ↔ Elevation tab,
Layout Perspective View ↔ 3D tab). Each of those tabs exposes its *own* set of sidebar tools, and
that set isn't fixed — **Splash** and **Grain Match** only exist in the sidebar while the
**Elevation** tab is active; they're absent entirely while in **Plan**. Conversely, **Tops (F4)**
(the tool behind Counter Tops View) only exists while in **Plan**. A tool that exists in *both* tabs
— **Molding** and **Cross Section** both do — opens a genuinely different dedicated screen
depending on which tab you launched it from, which is exactly why Plan Molding View and Elev
Molding View are two separate tree nodes instead of one, and why Vertical/Horizontal Cross Section
View (reachable from Plan) are distinct from End/Wall Face Cross Section View (reachable from
Elevation). **So a child view's position under a specific parent isn't arbitrary — it reflects
which top-level tab's sidebar is the only place that tool/screen can actually be reached from,** on
top of (not instead of) the inheritance relationship already established above.

**Important caveat, straight from Jon: this is how the Layer hierarchy is *supposed* to work, and
sometimes it does — but it's noticeably less reliable than the real Level Hierarchy/parameter
system.** The clean override mechanism documented earlier (an override is its own deletable
parameter, and clearing it lets inheritance resume) doesn't have a reliable equivalent here — there
is no dependable way to "clear" a layer override back to inheriting from its parent. Practically,
that means there's no reliable way to see what's actually overridden at a child view versus what's
still genuinely inheriting. A real failure mode this produces: a child view can end up with nearly
every layer individually set, to the point that changing the parent's settings no longer changes
*anything* about that child — it's effectively fully disconnected, and nothing in the UI makes that
obvious.

**Confirmed by direct example:** comparing Layout (General) to its child Floor Plan View, at least
one layer's color differs between parent and child — a real, live override. In the layer list
itself, that overridden entry looks exactly the same as every genuinely-inherited entry sitting
right next to it — no icon, no marker, nothing distinguishing "this is overridden" from "this is
inherited." That's the concrete version of the caveat above, not a separate observation from it.
(The specific colors involved aren't meaningful here — Jon's test schedule is actively being
modified for these walkthroughs, so only the mechanism is being logged, never the values currently
shown.)

**Practical guidance:** it's still best to adjust layers top-down (set the general/parent level
first, same instinct as everywhere else in CV) — but don't assume that's sufficient the way it
would be for regular parameters. Setting the parent has to be followed up by actually checking that
child views are picking up the intended settings, not just trusted to cascade correctly.

**Four properties are controlled per individual Layer within a Schedule:**
1. **Light bulb** — visibility in the Viewing area (lit/yellow = on, grey = off).
2. **Pencil** — visibility in the Drawing area (same on/off convention as the light bulb, separate
   toggle).
3. **Colored square** — the Layer's color.
4. **Line icon** — opens the Line Type Selector: a line *style* (solid, dashed, dotted, and
   dash-dot variants) plus a *weight*, independently configurable. The 16 weight options run in
   1/4-point steps from 1/4 Pt up through 4 Pt, then 4 1/2, 5, 6, and 8 Pt.

**Changes don't take effect until you click OK** on the editing dialog, and sometimes require a
rebuild on top of that before they show up. Cancel discards everything unsaved — nothing commits
until OK is actually clicked. Rebuild predictability: it seems mostly tied to color/line-style
changes specifically, but Jon's found it inconsistent enough that the safest assumption is just to
expect a rebuild might be needed regardless of what changed.

### The bold layers — filter/config sub-dialogs

Bold entries (Molding, Hardware, Annotations, Dimensions, Shop Annotations) open their own dialog
instead of just exposing the four basic properties:

- **Molding Filters** — checkboxes to filter which molding sub-types the Molding layer actually
  applies to (Applied, Base Board, Casing, Ceiling, Chair Rail, Crown, Light Rail, Scribe) —
  confirmed: **Applied** here just means whether Applied Molding (molding placed directly onto a
  surface like a door, rather than being part of the case construction) shows in that view. No extra
  special-case setting beyond the checkboxes — confirmed asymmetric with Hardware Filters below, not
  an oversight on the observation. Worth flagging generally: the `DOOR_AM` attribute referenced
  earlier in the Object Tree parameter examples turned out to be something **Jon built himself** (a
  custom attribute to make adding applied moldings to doors easier), not a stock CV parameter —
  custom and native parameters can sit side-by-side in these lists looking identical, with no visual
  distinction between them.
- **Hardware Filters** — same idea for hardware sub-types (Casters, Connectors, Drawer Guides,
  Finger Pull, Hinge Plates, Hinges, Leg Levelers, Legs, Pulls, Rods, Sliding Door Rails, Sliding
  Door Rollers, Wire Baskets), plus a separate color setting for **Unmatched Connectors** —
  genuinely unresolved what this refers to, even to Jon. Open item.
- **Primary Operations** — another bold layer with its own sub-dialog, just discovered: a color-only
  picker for **Unmatched Operations**, structurally identical to Hardware's Unmatched Connectors
  (no checklist here, just the color grid). Jon believes both function the same way, but what
  "unmatched" actually means in either case is unresolved — he's tried to deliberately trigger the
  condition and hasn't been able to reproduce it. Both flagged as open, minor-priority items.
- **Annotations** — Show Wall Labels, Show Object Names, Show Object Numbers, Stagger Object
  Names/Numbers, a label-format choice (`#1 Object` vs. `Object (#1)`), Font, and **Show Object
  Drawers** with its own **Offset/Increment** pair. Correcting an earlier guess: Offset/Increment
  here has nothing to do with numbering — it only exists in Floor Plan Views specifically, and it
  controls a line drawn at the face of a cabinet for each drawer on that cabinet: Offset is the
  distance from the cabinet's face to the first line, Increment is the distance between each
  subsequent line after that. This "show a line per stacked item" treatment is drawer-specific, not
  a broader pattern — there's no equivalent for doors or other object types. Reason: drawers are
  stacked vertically, so **looking straight down from above — Plan View's actual vantage point —
  every drawer in the stack occupies the same footprint and is otherwise indistinguishable from just
  one drawer.** That's specifically why this setting exists in Plan View and not Elevation View —
  Elevation looks at the cabinet from the front/side, where the stacked drawer fronts are already
  visible and countable without any extra indicator.
- **Shop Annotations** — a separate annotation set aimed at the shop floor rather than the
  customer: more production-relevant detail without having to spell everything out elsewhere on the
  drawing. Specific fields:
  - **Architectural Hinges** — draws `<`/`>` notation on the face of doors to show hinge side: `<`
    = left-hinged, `>` = right-hinged. **Reverse Architectural Lines** flips that convention (`<`
    becomes right-hinged, `>` becomes left-hinged).
  - **Frameless Door Outline** vs. **Frameless Opening Outline** — the Door Outline traces the door
    itself (which typically overlays the case parts visually); the Opening Outline traces the case
    parts that actually form the openings *behind* the doors. The Opening Outline only draws when a
    cabinet has more than one opening — a cabinet with no shelves/partitions (a single open cavity)
    won't get this outline at all.
  - **Frame Overlay** dropdown — partially resolved. The other option, **Frame Openings**, displays
    each opening's height/width, functioning similarly to how dimensions display on frameless
    cabinets. Jon's own note: he's not sure why these are two separate settings, since they appear
    to do essentially the same thing. What "Frame Overlay" itself (the option he actually keeps it
    locked to) specifically does differently is still unresolved — open item narrowed, not closed.
  - **Roll Out Outline** — draws an outline of roll-out drawer boxes inside the cabinet.
  - **Shelves: Single Line vs. Outline** — controls how a shelf is drawn: a single line, or a full
    outline that more accurately represents the shelf's actual thickness. Same underlying idea as
    the Door Swings Annotation-vs-Outline choice below — a simplified line vs. a
    thickness-accurate outline.
  - **The "Dimensions" checkbox group** — additional values displayed directly on the elevation
    without having to manually dimension them: **Opening Width** (width of every opening),
    **Opening Height** (height of every opening — not the space between adjustable shelves),
    **Doors and Drawers Sizes** (height/width of every door/drawer front), **Opening Height for
    Adjustable Shelves** (the height between adjustable shelves specifically), **Stiles** (width of
    every stile), **Rails** (width of every rail).
  - **Closet Rods center-top clearance** — believed (not fully confirmed) to show the distance
    between the closet rod's center and the top of the hanging section's opening.

**General principle worth generalizing from that Annotations example:** a bold layer's sub-dialog
isn't necessarily identical across every view — the same dialog (e.g. Annotations) can be virtually
the same everywhere, and still have specific fields that only appear in one particular view. The
Offset/Increment pair above is the clearest example: present on Floor Plan View itself and on two of
its children, Counter Tops View and Plan Molding View — but absent on a third child, Vertical Cross
Section View. **Resolved:** this settles the earlier open question — Show Object Drawers/Offset/
Increment is *not* a whole-branch trait of Floor Plan View. It's specific to top-down/plan-type
views, tying back to the reasoning already established elsewhere in this section (stacked drawers
are only visually indistinguishable from a directly-overhead vantage point) — a Cross Section view
isn't looking straight down, so the field has no reason to exist there. This is a level deeper than
the earlier per-scene-independence point (which was about the same *setting* holding different
*values* per scene) — this is about the available *fields themselves* differing by scene, not just
their values.

**Confirmed: the Annotations sub-dialog isn't even always the same *kind* of dialog.** Vertical
Cross Section View's Annotations dialog has essentially nothing in common with the checkbox-based
one on Floor Plan View/Counter Tops View/Plan Molding View (Show Wall Labels, Show Object Names,
etc.) — instead it's a label-style picker (a choice of label shape, e.g. arrow/box/ball, plus a
label offset and font). Confirmed as expected, not an inconsistency: a Cross Section view is
annotating a different kind of thing (dimension/callout-style labels) than a plan-type view (object
names and numbers), so the two "Annotations" dialogs solve genuinely different problems despite
sharing a name. Don't assume a bold layer's sub-dialog is drawn from one fixed schema just because
the label ("Annotations") is the same everywhere.

**A third Annotations variant, confirmed on Elevation View:** shares the Show Object Names/Show
Object Numbers/Stagger/label-format/Font fields with the plan-type schema, but swaps out Show Wall
Labels and Show Object Drawers for fields specific to an elevation's own concerns — **Show End
Types**, with a sub-option **Show Unfinished Ends**. Show End Types prints a single letter on each
assembly identifying its finished-end type: `F` = Finished, `A` = Applied Finished End, `D` =
Applied Door, `P` = Panelized, `E` = Extended, `S` = Skinned. Filler and No End carry no letter at
all — Show Unfinished Ends controls whether an end with no real finish type still gets some marker
rather than being left blank. So there are now (at least) three distinct Annotations schemas
confirmed across three different view types — plan-type, Cross Section, and Elevation — each
tailored to what that view actually needs to communicate.

**A fourth Annotations variant, confirmed on Assembly Face Section View:** shares Show End Types/
Show Unfinished Ends with the Elevation schema, but swaps Show Object Names/Numbers for **Show
Door/Drawer Numbers** — a labeling concept specific to working inside one assembly rather than a
whole room. Confirmed what it actually labels: not simple sequential numbering, but the
**split-section codes** generated by how that assembly's face has been divided (via the Section
Face screen's Horizontal Split/Vertical Split/Multi Split tools) — e.g. a face split into a top
door and two lower doors gets labeled `1A`, `1B-L`, `1B-R`. This ties directly back to the
tree-navigation rule established earlier: Assembly Face Section View is the Layers node for that
same dedicated **Section Face** screen, not a generic elevation-style view of the assembly — which
is exactly why it's one of only two Assembly (General) children that actually carry Shop
Annotations and Annotations at all, unlike the plain Ortho views (Assembly Case Section View,
the Layers node for the paired **Section Interior** screen, is the other one).

**Section-family Dimensions dialogs share a structural quirk, confirmed across both:** neither
Assembly Face Section View's nor Assembly Case Section View's Dimensions dialog has a Vertical Line
Increment field — both only offer Horizontal Line Offset/Increment plus a single Vertical Line
Offset. Confirmed as a real, intentional difference tied to being a Section-type dialog, not
something unique to Face Section specifically.

**Resolved — "Show fixed shelves dimensions":** greyed out (and easy to keep missing, since it
looks like every other disabled checkbox) on Assembly Face Section View's own Dimensions dialog
specifically because that setting doesn't apply there at all — it's really an **Assembly Case
Section View** setting, sitting in the shared Section-family dialog, and confirmed checkable/active
there. Confirmed what it does, demonstrated on the **Section Interior** screen (Assembly level,
Section ribbon group): with a Fixed Shelf selected, it displays the opening-height dimensions
immediately **above and below that fixed shelf** — e.g. one number for the space from the shelf up
to whatever's above it, another from the shelf down to whatever's below.

**Same pattern confirmed again in Shop Annotations:** Assembly Case Section View greys out
**Architectural Hinges** (and its Reverse Architectural Lines sub-option) — hinge-side notation is
a door/face concept, and Case Section View is showing the case/interior only, not the face/doors.
General lesson worth keeping in mind across this whole dialog system: a shared dialog can carry a
setting that's permanently greyed out on one specific view because it genuinely belongs to a
*different* view sharing that same dialog, not because it's conditionally locked behind another
checkbox the way Door Swings is.

**Another naming quirk, confirmed at the Part level:** the tree node **Ortho Face** (a child of
Parts (General)) opens a Dimensions dialog titled "Dimensions [Part Ortho Front]" — a genuinely
different name, not just the bracketed schedule/view label covered by the earlier title-bar
caution. Confirmed as CV's own inconsistent internal naming, not a sign of two different screens —
same screen, the dialog just doesn't always use the tree's own name for itself. Worth remembering
as a broader caution: a dialog's title isn't guaranteed to match the tree node name that opened it.

**What the Cross Section label/offset actually control, now confirmed:** creating a *static* Cross
Section (Room Level sidebar, Cross Section tool) and sending it to Drawings pops a dialog with a
**Drawing Name** field (defaulting to the literal text "LABEL") and a **Show This Cross Section in
Plan View** checkbox. This dialog is static-only — a Live cross section sent to Drawings doesn't
prompt for this at all, consistent with the Static-vs-Live distinction already established
elsewhere in this file.
- The **Drawing Name** text is exactly what shows up as the label text in the drawing — leave it
  "LABEL" and that's literally what prints; rename it and that name is what appears instead.
- That label appears **once at each end of the cross section's cut line** — not once per drawing,
  not tied to Plan View despite what the checkbox implies.
- **Show This Cross Section in Plan View**, when checked, places a marker for this cross section on
  the room's separate top-down Plan View drawing — a distinct, additional placement from the two
  end-of-cut-line labels described above, not a description of where those two labels themselves
  are shown.
- The **Label offset** field (seen in the Vertical Cross Section View Annotations dialog covered
  above) controls how far each of those two end labels sits from the actual cut line — a larger
  offset pushes the label text further away from the line it's marking.

**Important gotcha, confirmed: these labels are CAD, not live layer-driven objects.** CV places
these cross-section end labels as actual CAD entities in the scene — meaning they're directly
editable once placed, but they do **not** update automatically when the underlying label/offset
settings change. If a job already has cross sections placed with a given label/offset, then partway
through the job that setting gets changed, every label already placed stays exactly as it was —
only newly-created labels reflect the new setting. This is a real staleness trap distinct from the
Static-vs-Live drawing staleness covered elsewhere: even a *Live* cross section can carry stale CAD
labels that silently stop matching current settings, with nothing in the UI flagging the mismatch.

**Confirmed: a child view can carry substantially more layer categories than its own parent.**
Vertical Cross Section View's own layer list is noticeably longer than Floor Plan View's — it
introduces multiple categories (Exposed Parts, Internal Parts, Frame Parts, Doors And Drawer
Fronts, Drawer Box, Toe Parts, Objects, Operations, Intelli-Joints, Leica, among others) that don't
exist on Floor Plan View at all. Concrete example of the general rule noted earlier: a child can
introduce entirely new layer categories the parent never had, the same way a Part can carry more
parameters than a Room.

**A second confirmed example, on a direct child of Layout (General) this time:** Layout Perspective
View's layer list includes **Floor** and **Ceiling** categories that don't exist on Floor Plan View
or Elevation View. Confirmed why: Layout Perspective View is a full 3D view of the whole room, so
floor and ceiling surfaces are actually visible in it and need their own visibility control —
unlike the flatter 2D-style views, where those surfaces either aren't shown or aren't the point of
the view.

**General Perspective-view rule, confirmed at all three levels:** no Perspective view — Room,
Assembly, or Part — carries Dimensions or CAD at all. Confirmed directly on Assembly Perspective
View (whose category list otherwise matches the Ortho views' broad list, minus those two), extended
to Layout Perspective View, and now confirmed a third time on Parts (General)'s own **Perspective
View** (Hardware, Parts, Operations, Primary Operations, Intelli-Joints only — again, no Dimensions
or CAD, matching Ortho Face/Edge/End minus those two categories). Reasoning: Dimensions and CAD are
inherently 2D/technical-drawing concepts, and a 3D pictorial view isn't where precise dimension
lines or CAD annotations get added — this holds regardless of which level the Perspective view
belongs to.

**CAM (the last child under Parts (General)) carries the exact same narrow category list as
Perspective View** (Hardware, Parts, Operations, Primary Operations, Intelli-Joints — no Dimensions
or CAD), for a different reason than the Perspective rule above: CAM is the Layers node for the
machining/toolpath-generation screen, not a drafting view, so dimension lines and CAD annotations
simply aren't relevant there either. Another instance of the same underlying principle — a branch's
available settings are shaped by what that branch is actually for — arrived at from a completely
different direction than the Perspective-view case just above it.

**The four flat Sheet nodes (Assembly Sheet, Wall Elevations, Part Sheet, Plan Sheet), confirmed:**
these sit outside the Layout/Assemblies/Parts (General) tree structure entirely and are tied to
CV's Reporting/shop-drawing sheet system rather than being live scenes. Confirmed specifically for
**Assembly Sheet**: it's the layer schedule that governs an assembly-level shop drawing sheet when
a Report/Template auto-generates one — a fundamentally different kind of node from everything
covered above, output-oriented rather than a screen a user navigates to directly. Its own category
list matches the broad Assembly-level schema (including Shop Annotations, Annotations in the
Show-Door/Drawer-Numbers variant, and Dimensions), and its Dimensions dialog has **Show fixed
shelves dimensions** actually checkable here (not greyed the way it is on Assembly Face Section
View) — confirmed why: Assembly Sheet's output covers case/interior details too, where fixed
shelves are relevant, unlike a face-only section view.

**Wall Elevations, confirmed as Assembly Sheet's Room/Wall-level counterpart:** used specifically
when CV auto-generates a wall elevation drawing sheet via a Report/Template, the same relationship
Assembly Sheet has to an assembly sheet. Its own category list and Annotations schema both match
**Elevation View** exactly (Show Object Names/Numbers/Stagger/label-format plus Show End Types/Show
Unfinished Ends) rather than Assembly Sheet's Show-Door/Drawer-Numbers variant — each output Sheet
node mirrors the schema of whatever live-view level it corresponds to (Assembly-level content for
Assembly Sheet, Room/Elevation-level content for Wall Elevations). Its Dimensions dialog also has
the full four offset/increment fields (no missing Vertical Line Increment) and no "Show fixed
shelves dimensions" field at all — consistent with being Elevation-type rather than
Assembly-Section-type.

**Part Sheet, confirmed swap vs. the plain Part Ortho views:** carries **Annotations** (which
Ortho Face/Edge/End lack) but drops **Hardware** (which those Ortho views do have). Confirmed
intentional: a part-level print sheet cares about labeling/annotating the part, not toggling
hardware visibility on or off — another instance of the branch-carries-only-what-it-needs
principle, this time trading one category for another rather than just adding or dropping.

**Plan Sheet, confirmed as the third and final match in the Sheet-mirrors-live-view pattern:** its
Annotations schema matches **Floor Plan View** exactly (Show Wall Labels plus Show Object
Drawers/Offset/Increment). That completes the pattern across all three checked Sheet nodes:
Assembly Sheet mirrors Assembly Face Section View, Wall Elevations mirrors Elevation View, and Plan
Sheet mirrors Floor Plan View. One real difference from Floor Plan View, though, confirmed and
explained: Plan Sheet's own layer list includes **Floor** and **Ceiling** (categories Floor Plan
View itself lacks — only Layout Perspective View had them among Layout (General)'s children).
Reasoning: the printed output needs to represent all room surfaces, unlike the live Floor Plan View
screen, which doesn't need floor/ceiling visibility control the same way a 2D working view is used.
Also notably absent from Plan Sheet's Dimensions dialog: **Show Object Depth** — consistent with
that field being tied to Elevation-type schemas specifically; a straight-down plan view has no need
for a depth-indicating tick the way an elevation does.

**Confirmed: views can be purpose-built narrow, not just purpose-built broad.** Layout (General)
being "deliberately generalized" (noted above) is one end of this spectrum; Plan Molding View is
the opposite end — a view built around a single layer category matching its own name/task, with the
rest of its layer list left essentially unused for that view's purpose. Same underlying principle
either direction: a scene's layer configuration is shaped by what that scene is actually *for*, not
some fixed default every view shares.

**Multi-level nesting, confirmed:** the Layer Schedule tree isn't limited to a single parent/child
step — it chains multiple levels deep just like the Level Hierarchy does. Confirmed example:
Layout (General) → Floor Plan View → Counter Tops View (with Plan Molding View, Vertical Cross
Section View, and Horizontal Cross Section View as further children/siblings under Floor Plan
View). Counter Tops View is a grandchild of Layout (General), not a direct child of it.

**Confirmed: sibling views (not just parent/child pairs) can have different layer categories from
each other.** Horizontal Cross Section View's layer list has no Annotations entry at all — it isn't
just missing the Show Object Drawers field the way Vertical Cross Section View is, it doesn't carry
an Annotations bold layer in any form, checkbox-based or label-style-picker. Confirmed as expected:
Horizontal Cross Section View, in Plan View, displays exactly like an ordinary Plan View — it just
additionally lets you see inside cabinets. It has no cut-line-end labels to manage because it isn't
built around the same vertical-cut-line concept Vertical Cross Section View uses.

**Resolved — what actually determines the Annotations schema: not the branch, and not literally
"horizontal vs. vertical," but whether the view introduces a real cut line at all.** End Cross
Section View (nested under **Elevation View**, not Floor Plan View) uses the exact same
label-shape-picker schema as Vertical Cross Section View (under Floor Plan View) — proving branch
position isn't what decides this.

Corrected mechanism, straight from Jon: CV's "Cross Section" views actually split into two
different kinds, and it's *that* split — not cut orientation — that determines whether Annotations
exists:
- **See-through versions of an existing parent view** — **Horizontal Cross Section View**
  reproduces Floor Plan View's exact vantage point, just with the added ability to see inside
  cabinets. **Wall Face Cross Section View** reproduces Elevation View's exact vantage point the
  same way (plus one extra capability standard Elevation View doesn't have: showing the *ends* of
  cabinets on perpendicular walls). Neither of these introduces a genuinely new cutting line
  distinct from the parent view it's simulating — there's nothing new to label, so there's no
  Annotations layer at all.
- **Views built around an actual new cut line** — Vertical Cross Section View and End Cross
  Section View slice through the model along a real cut line that doesn't correspond to any
  existing parent view's vantage point, producing two real endpoints worth labeling — hence the
  label-shape-picker schema.

So the real dividing line is "does this view simulate an existing parent view with extra
see-through detail" vs. "does this view create a genuinely new cut," not the horizontal/vertical
framing first guessed at. Plan-type and Elevation-type views get their own object-naming schemas
for the separate reason that neither is built around a cut line in the first place.

**The general rule underneath all of this, stated directly by Jon:** each branch only provides the
layer settings that actually apply to it. Every specific example above — Show Object Drawers only
on top-down/plan-type views, Vertical Cross Section View's label-style Annotations, Horizontal
Cross Section View having no Annotations at all, a child carrying categories its parent lacks — is
really just this one principle showing up differently depending on which branch you're looking at.
Don't treat any one example as the special case; expect *every* branch's available settings to be
shaped by what that branch is actually for.

**Extends into the Assemblies (General) branch too, confirmed:** Assembly Ortho Face introduces
Dimensions and CAD (absent from its parent Assemblies (General), same pattern as Room-level
branches introducing view-specific bold layers further down) but has no Annotations or Shop
Annotations at all. Confirmed this isn't an Assembly-level-wide rule, though — it depends on the
specific child view, not a blanket "Assembly-level never gets Annotations." Also confirmed: Dimension
Styles follow the same per-level naming convention already noted (`Layout` for Room-level views,
`Assembly` for Assembly-level views).

**Caution — dialog title bars are not Style names.** A bold layer's sub-dialog title can show extra
context (e.g. a Dimensions dialog titled "Dimensions [Layout Counter Tops]" when opened from
Counter Tops View) — that bracketed text is just CV labeling which schedule/view the dialog belongs
to, not the name of whatever Style is actually selected inside it. Don't confuse the two; always
check the actual Style field, not the title bar.

**Structure:** Layer Schedules are organized by view area — e.g. under "Layout (General)," Floor
Plan View has its own set of editable layers (Molding, Hardware, Primary Operations, Annotations,
Dimensions, and more depending on the view). Same idea repeats at the Assembly and Part levels too.

**Where the Layer Schedule selector actually lives:** at Room Level, in the Ribbonbar's Main Tab
View group — a dropdown showing the active schedule by name (e.g. "F1 Standard"), right next to the
Room selector. The Room Level sidebar itself has its own separate set of tools, not Layer-related
but worth having as a map: **Walls (F2)**, **Objects (F3)**, **Floors**, **Ceilings**, **Tops
(F4)**, **Molding (F5)**, **Auto Fill (F6)**, **Cross Section**, and **CAD (F7)**.

**Resolving the CAD question:** CAD does not show up as its own category inside `Default.dat`
(confirmed — only Layers and Dimensions live there). It shows up in two unrelated places instead:
this Room Level sidebar tool (F7), and as one of the named presets inside Dimension Styles (see
below). Two different "CAD" references, neither of them a settings category of its own.

**This is where confusion actually comes from, and it's the important part:** every scene (view
type) has its *own independent* set of layer settings. Most customization options are universal —
available in every scene — but some scenes have more options than others, and critically, **each
option is set per scene, independently.** The same conceptual setting can hold a completely
different value in one scene than in another, and CV just shows whichever one matches the scene
you're currently looking at. Example: cabinet outlines could be set to black in Elevation View and
green in Plan View — both settings exist at the same time, nothing is overwriting the other, and
what actually displays depends entirely on which view you're in. The mistake this causes: change
something in one scene, then go look at a different scene and assume the change "didn't work" or
"got undone" — when really, that other scene simply has its own separate setting that was never
touched.

**The layer list itself is fixed** — Walls, Molding, Hardware, and the rest are CV's built-in
categories per view type, and can't be added to. "Setting up layers" always means configuring how
the existing categories behave (on/off, color, line style, and the deeper filters on bold ones),
never creating new categories from scratch.

**Why multiple Layer Schedules exist at all:** the whole point is being able to present the same
job differently depending on who's looking at it — a schedule for client-facing plan views, a
different one for shop drawings, another for checking one specific detail like toe kicks. Jon's own
practice, though, is to use a **single** schedule and instead vary presentation by configuring the
*outputs* (what gets sent to Drawings, sheets, reports) rather than switching schedules. His stated
reasoning: multiple schedules create two real risks — picking the wrong one for the task at hand,
and different users on the same team ending up on different schedules for the same kind of work.
One schedule guarantees consistency. He's clear this is a preference, not a claim that multiple
schedules are wrong — plenty of legitimate reasons to keep several around; it's just not how he
personally works.

**Confirmed: schedules within one `Default.dat` are fully independent — no shared settings between
them at all.** The practical use case for keeping several: capturing different scenes with
different schedules specifically as *Static* drawings, since Static freezes that schedule's exact
look at the moment it was sent. A *Live* drawing behaves differently — it typically keeps updating
based on whatever schedule is *currently* active, not necessarily the one that was active when the
scene was first sent. Worth remembering alongside the earlier point that Job files always render
using whichever schedule is active on the machine that opens them.

**Critical fact that makes the consistency risk above much bigger than it sounds: Layers are not
shared system-wide — they live locally, per machine.** With 5 engineers on 5 workstations, each
one's Layer Schedules can be completely different from the other four's, even if everyone believes
they're "using the same setup." This isn't just a matter of a user *choosing* a different schedule
on purpose — it's architectural. Unlike System-level settings that get copied down into every new
Job (see the Level Hierarchy above), Layer Schedules don't propagate across a network install on
their own. Achieving real team-wide consistency means deliberately getting the same schedule onto
every machine, not just agreeing on a schedule name.

**Confirmed consequence: the exact same Job file renders completely differently depending on which
machine opens it.** Regardless of what Layer Schedule was active when a Job was originally drawn,
opening that Job on a different machine displays it using *that machine's own* default Layer
Schedule — the Job doesn't carry its drawing-time schedule along with it. Same underlying data,
different presentation, purely a function of whose `Default.dat` happens to be active locally.

**Resolved: CV's Packages import/export feature does not cover Layers.** Layers — along with
several other settings — actually live in a local file called `Default.dat`, stored per machine, not
in anything Packages can move around. The practical fix for team consistency: distribute one
`Default.dat` file to everyone and have each person overwrite their own local copy with it, rather
than trying to rebuild the same Layer Schedule by hand on every workstation.

**Where to actually find it:** a minor but real pain point on its own — plenty of people struggle
just to locate this file. Path (CV 2025):
`C:\ProgramData\Hexagon\CABINET VISION\CV 2025\Default.dat`. `ProgramData` is a hidden folder by
default, which is likely why it trips people up.

**CV's own Backup Utility can include `Default.dat` — this is a capability question, not a
"what's the factory default" question.** The Backup Utility has an Include list and an Ignore list,
and `Default.dat` is one of the items that can sit in either — along with `DefaultCLST.dat`, All
Graphics, Assigned Material Textures, Core Data, Posts, System Parameters, xCRM Data, `CVData.accdb`,
and the Report Database. Whether it's actually included depends on how a given install has this
configured (Jon's own company's current setup has it in Ignore, but that's a configuration choice,
not confirmed to be CV's out-of-the-box default) — the point that matters: it's a real option
either way, so it's worth deliberately checking and setting rather than assuming.

**A schedule becomes the automatic default** the same way any other setting does — set it via
"Set As System Defaults" (see the quick-reference above) and it loads automatically on every future
job, rather than needing to be selected manually each time.

**There's no universal starting point for setting layers up.** What a Job's layers should look like
depends entirely on what that specific CV user needs to see while working, and how they want their
own drawings to look — no one-size-fits-all recipe to follow, and no "correct" schedule to copy
from as a starting template.

**Sending a view to the Drawings page** has its own separate, long list of presentation-specific
toggles (under Edit → Advanced on a Layer Schedule) — things like forcing all lines to black for
non-color printing, including/excluding wall hatching, cleaning up overlapped or intersecting
lines, hiding concealed lines, simplified door/drawer symbols, curve tessellation detail, and
hatching for case/interior parts. Reference material to pull up when actually preparing a drawing
for print or client presentation, not something to memorize up front.

**Correction: this dialog is not Drawings-output-only.** At least Assembly Outlines Only applies to
the live interactive view and carries through into Drawings — confirmed, not a separate
print-time-only layer of settings the way "reference material" originally made it sound.

**Resolved — the real answer was hiding in the bulb/pencil icons the whole time.** Every regular
Layer gets *two separate* visibility toggles — light bulb for the **Viewing area** (the live view),
pencil for the **Drawing area** — specifically because CV is built to let a layer's live-view
visibility diverge from its Drawings-output visibility. That's the actual general rule: **Layers
are explicitly designed with independent live-vs-Drawings control built in (bulb vs. pencil)**,
while at least some Advanced-dialog settings (Assembly Outlines Only, confirmed) are a single
unified toggle with no such split — they apply the same way to both contexts. So it's not that
"everything shows up both places" or "nothing does" — it depends on whether a given setting is one
of the two-icon, independently-splittable kind, or the single-toggle, unified kind.

**The Advanced dialog is opened per-view** (via the "Advanced" button on a Layer Schedule's main
window, for whichever view node is currently selected in the tree) — its settings apply to that
specific view, not globally across the whole schedule. Specific fields, beyond the general list
above:

- **Door Swings** dropdown is locked (greyed out) until **Assembly Outlines Only** is checked —
  it's only meaningful once outline-only mode is active. **Show Simple Doors** and **Show Simple
  Drawer Box**, despite appearing right next to it, are *not* tied to that toggle at all — they're
  locked or unlocked based on which specific view/scene is selected (not available in every view).
  Confirmed: it's specifically about how door swings display in **Plan Views**, with three options —
  **None** (no swing indicator at all), **Annotation** (a single line showing swing direction, the
  same simplified-line-vs-real-geometry idea as the drawer Offset/Increment lines), and **Outline**
  (the same idea as Annotation, but drawing the door's actual outline/thickness instead of a single
  line — mirroring the Shop Annotations Shelves setting's Single-Line-vs-Outline choice).
- **Force Drawing to Black**, when left unchecked, sends the view to Drawings with all of that
  view's Layer color settings intact — i.e. it's specifically an override that flattens everything
  to black for non-color printing, not a default-on behavior; the colored version is what you get
  without it.
- **Top Outlines Only** is a different concept from Assembly Outlines Only, despite the similar
  name — it's specifically about **countertops**. In a view looking down where a countertop is
  present, the countertop by default visually hides everything beneath it (cases, etc.). Checking
  Top Outlines Only lets you see through the countertop while still showing its own outline, so you
  can see both what's under it and where the countertop itself actually sits.
- **Background color** swatches set the live-view background color (not a Drawings-output/print
  setting).
- **Show Axis Indicator** toggles a small icon showing the orientation of the X/Y/Z axes.
- **Show Sections Outline** is specific to Section views — it draws a visible dividing line between
  each section.
- **Template** (in the "To Drawings" area, paired with a named-scene picker and a Change button)
  selects which **Drawing Scene** template this view sends to when producing Drawings. Drawing
  Scene is one of CV's template types (see Templates under Producing Drawings, later in this file);
  full depth on how scenes and Drawings interact is deferred to that section.

**"Outline only" is not the same thing as Render Mode — two separate systems that interact.**
Assembly Outlines Only (a Layer setting) draws literally just the shape/outline of an assembly.
**Render Mode** (Room Level Ribbonbar, View group) is a completely different, independent setting
controlling how the 3D geometry itself is shaded, with three options:
- **Wireframe** — everything becomes transparent, all edges outlined. This is the one place the two
  systems visibly interact: wireframe line appearance can/will look different depending on the
  active Layer settings — **confirmed by direct example**: a Hardware layer set to red actually
  rendered red in Wireframe mode.
- **Fill** — applies the Room's finish/color to objects, making them appear solid. Cannot see
  through parts.
- **Texture** — applies each Material's full mapped texture (grain, grain direction, color, etc.) to
  every part. Cannot see through parts.

**Confirmed boundary on that interaction:** Layer-assigned colors only carry visible weight in
Wireframe. In the same example, once switched to Fill or Texture mode, that same red Hardware layer
no longer showed as red — Fill and Texture render surfaces by the Room's finish or the Material's
actual texture instead, and a layer's own color setting doesn't override that for solid-rendered
parts. Layer color is a Wireframe-specific effect, not something that follows through to the more
realistic render modes.

---

## Dimensions

Stored in `Default.dat` right alongside Layers (see above), but it's really two separate
sub-systems under one name: **named dimension-line definitions** (what gets dimensioned, and
where) and **Dimension Styles** (how a dimension line actually looks once it's drawn).

**Named dimension-line definitions:** inside a Layer Schedule's bold "Dimensions" entry for a given
view (e.g. "Dimensions [Layout Plan View]"), there's a whole list of named lines — like "Wall
Length" — that can be created, edited, copied, renamed, removed, and reordered, the same way Layer
Schedules themselves can. Each one has:
- A **Type** — which edge/side it measures (Wall, Wall End, Island Counter Top, or a side like
  Left/Top/Right/Bottom, depending on context).
- A checklist of **Objects** that trigger a dimension mark on that line — Wall Ends, Assembly Ends,
  Assembly Centers, Door Ends, Door Centers, Counter Tops, Sink Centers, Window Ends/Centers,
  Appliance Ends/Centers, and more, each independently toggled.
- **Force Dimension Line** — confirmed, and confirmed *why* by CV's own docs: normally, if none of a
  line's configured Objects actually exist in a given design (e.g. a line configured to show Counter
  Top Surface/Bottom on a job with no counter tops), CV just won't draw that dimension line at all.
  Force Dimension Line overrides that — it still draws the line for whatever *does* exist among the
  configured objects (e.g. Wall Ends, which are almost always present) even when others on that same
  line aren't. This is why Jon uses it mainly on wall length/height lines specifically — Wall Ends
  are close to guaranteed to exist, so forcing ensures at least that gets dimensioned regardless of
  what else is or isn't in the job.
- **Stack Dimensions** — genuinely unresolved. Jon has never been able to figure out what this does,
  and it isn't explained anywhere in CV's own help documentation either (checked). Open item — worth
  testing directly in CV rather than guessing.

**Confirmed: deleting or editing a named dimension line a Job depends on is safe.** The Job keeps
functioning normally — that specific dimension line just stops displaying. No breakage, no error,
just a quietly missing dimension on whatever view relied on it.

The per-view Dimensions dialog (e.g. "Dimensions [Layout Plan View]") is also where the two
sub-systems connect: it has its own **Style** dropdown — that's exactly where you pick which
Dimension Style (see below) gets applied to that view's automatic dimension lines. The dialog also
holds settings that apply across the whole view rather than one named line (Horizontal/Vertical
Line Offset and Increment, Tail Dimensions) — plus a **Show Object Depth** checkbox, confirmed on
both Elevation View and Assembly Sheet (not Elevation-View-exclusive): draws a small tick in the
top-right corner of each assembly showing that assembly's depth. When several adjacent assemblies
all share the same depth, the tick only appears on the **farthest-right** one of that group, not on
every one of them.

A second, independent place a Style gets chosen: when manually dimensioning an object directly
with the **CAD** tool (Room Level sidebar, F7), you can select a Style right there for that specific
dimension — not locked to whatever the view's own Dimensions dialog has set as default.

**Dimension Styles** are a separate named-preset list — create/edit/copy/rename/remove like any
other preset list in CV. **Correction:** `CAD`, `Layout`, `Assembly`, and `Part` are examples seen
in Jon's own setup, and the `Style 1:1`/`1:2`/`1:4`/etc. names are **not native CV presets** —
they're custom dimension styles Jon's own company built and named after scale ratios for their own
purposes. Don't treat that naming pattern as something CV ships with by default. Editing a Style
exposes real formatting control, grouped into:
- **General** — Line (on/off), **Fixed Scale** — confirmed: when on, the dimension's text/arrows
  stay a constant size regardless of the scene's zoom/scale, rather than scaling along with it.
- **Lines and Arrows** — Line Width; **Ticks Height** — confirmed: the length of the perpendicular
  tick mark drawn at each end of a dimension; **Arrow/Mark Size** — confirmed: a separate setting,
  the scale of whichever arrow/mark style is actually in use (arrow types vary — Architectural Tick
  is one option among several); **Lines Extension** — confirmed: how far the extension lines
  overshoot past the dimension line itself; **Tail Offset** — confirmed, and more specific than the
  name suggests: this only matters when a dimension is "tailed" — tailed means the tick/extension
  line runs all the way to the object being dimensioned instead of stopping at the dimension line,
  and Tail Offset is the small gap held between that tail and the object's actual face. Jon notes
  tailed dimensions aren't commonly used — even though they draw a distinct line straight to the
  object, having many of them active at once tends to create overlapping, confusing clutter; Left/
  Right Arrow style (e.g. Architectural Tick), Center Mark.
  - **Where this shows up as its own per-view control:** the Part-level Dimensions dialog (e.g.
    Ortho Face) has an **Extended Tails** checkbox nested under **Tail Dimensions** — confirmed
    purpose: Parts carry a lot of small, densely-packed details worth dimensioning (notches, route
    widths, etc.), and dimension lines for those can get genuinely hard to read at that scale.
    Extended Tails lets the tail actually reach all the way to the specific small detail it's
    dimensioning, rather than stopping short, specifically to cut through that clutter and make it
    clearer which line is dimensioning which feature.
- **Text** — Alignment, Vertical/Horizontal Placement, Offset, Clearance, **Frame** — confirmed:
  draws a box around the dimension text, Font, Bold, Height.
- **Fit** — **Hide Text** / **Hide Arrow** — confirmed, and simpler than "Fit" implies: these are
  unconditional toggles that hide the element outright regardless of available space, not automatic
  overflow/collision handling.

**This is where "CAD" actually shows up in the Dimensions system** — not as a settings category of
its own, but as one specific Dimension Style, presumably tuned for precise/technical dimensioning
versus the more presentation-oriented Layout/Assembly/Part styles.

**Naming note:** the "F1 Standard" schedule name and "F1 Cabinets" showing as the licensed product
name in the statusbar aren't a coincidence — company/product-specific naming carries through into
schedule names.

---

## Producing Drawings

Two distinct ways to actually get from scenes in CV to a finished drawing:

1. **Manual — send scenes to Drawings, then place and print.** A scene can be sent as either
   **Live** or **Static**. Live stays linked and updates automatically as the job changes; Static is
   a frozen snapshot that won't reflect later changes — Static is *not recommended* for exactly that
   reason. Once sent, scenes still need to be manually placed on pages/title blocks before printing.
2. **Templates (found in the Reports tab)** — pre-configured title blocks that automatically place
   scenes for you, skipping the manual placement step entirely. A template can either be sent to
   Drawings the same way a manual scene can, or printed straight to PDF, bypassing Drawings
   altogether.

**The actual mechanics of "sending to Drawings," confirmed:** right-clicking a scene (in Plan,
Elevation, 3D, etc.) surfaces the real menu commands — **To Drawing** and **To Live-Drawing** —
confirmed as the literal names behind the Static/Live distinction above (To Drawing = Static, To
Live-Drawing = Live).

**Drawings is a genuine top-level destination, not a hidden sub-screen.** At Room Level, it sits as
its own tab alongside Plan, Elevation, 3D, Reports, and S2M CENTER — a real page you navigate to,
with its own Ribbonbar (Paper Sizes, Drawings Library, Measure Tools) and its own sidebar:
- **Available Scenes** — the job-wide pool of every scene that's been sent to Drawings (via To
  Drawing/To Live-Drawing), regardless of whether it's actually been placed on any sheet yet.
- **Scenes on Current Sheet** — specifically what's placed on the sheet currently being viewed
  (Sheets are navigable — Sheet 1, Sheet 2, etc. — with a New Sheet control, so a job can hold
  multiple sheets/pages).
- **Confirmed: "Paper" showing in Scenes on Current Sheet on a blank sheet is just the sheet/page
  itself** — a placeholder entry, not an actual sent scene. Also confirmed: the **title block is
  not accounted for anywhere in that scene list** — it's tied to the sheet/paper itself, separate
  from the scene-tracking mechanism entirely.

**Confirmed: multiple scenes can share one sheet.** Placing several scenes on the same sheet is
supported, but they all scale together as a group — the more scenes crammed onto one page, the
smaller each individual scene (and everything inside it) renders. Not a free "add unlimited detail"
mechanic; it's a real trade-off between scene count and legibility per scene.

**Confirmed: the Drawings/CAD page uses one plain, shared Layers/Dimensions setup — not the
per-view independence documented throughout the Layers section above.** There's no separate layer
schedule per sheet or per scene-on-a-sheet the way Floor Plan View and Elevation View each have
their own; it's the same ordinary Layers/Dimensions system used everywhere, just applied at the
page level. This is exactly where the earlier bulb/pencil distinction pays off directly: the
**pencil** (Drawing area visibility) is specifically what governs what actually shows up here on
the Drawings page — reinforcing that the bulb/pencil split exists precisely so live-view visibility
and Drawings-output visibility can diverge on purpose.

**The Drawings Library, confirmed, and Jon has real hands-on experience with it:** this is where
CAD symbols and — critically — **custom Templates themselves get created and edited**. It's the
actual authoring environment behind the Templates system referenced earlier in this section, not
just a passive pull-from library.

**Still genuinely unused/open: "Save Drawing Scenes to a Separate File"** (the x2D CAD module
feature). Jon has never had a reason to use this one — still an open question whether it's just
another name for Static or a distinct file-export mechanic.

**When manual beats Templates:** some shops are particular enough about how their drawings look
that a Template genuinely can't reproduce it — in that case, they build their own drawings manually
instead. Templates handle the standard/repeatable case; manual placement is the fallback for a shop
standard specific enough to not fit the template system.

**Resolved — staleness is the whole story, confirmed, and it's more total than "the cabinets
changed" suggests.** A Static scene freezes *everything* about that scene, not just the geometry —
including the Layers used to draw it. If the Layer Schedule changes after a scene was sent as
Static (different colors, visibility, anything), that static drawing will never pick up the change,
even though the live view updates immediately. Only Live captures downstream changes of any kind,
cosmetic or structural — Static isn't "mostly current, minus recent edits," it's genuinely frozen in
every respect.

---

## Multi-Window Mode (split views)

*(Seen in Jon's CV 2025 screenshots; Jon says he under-uses it.)* CV can show several views at once
instead of one, each with its own **live** content.

**Turning it on:** Main tab → **View** group → **Window Mode** dropdown, which offers **Normal Window**,
**Split Horizontal** and **Split Vertical**. Choose a split, then split again to get more panes. (A
three-pane layout was shown, so a pane can itself be split.)

**How the panes work:**
- **Each pane has its own tab strip.** At Layout (room) level: Plan, Elevation, 3D, Reports, Drawings (and
  S2M CENTER on the first pane). At Assembly level: Section, Face, Plan, End, 3D, Reports. Every pane can
  show a different view, so you can watch Plan, 3D and a report at once.
- Each pane has a **maximize button** in its top-right corner.
- The **ribbon and sidebar change** depending on which pane is active. In two of the screenshots the ribbon's
  View group showed **View Mode, Window Mode and Set Columns** and the sidebar showed **Order Entry, Bid
  Center, Report Center, Plan & Elevation Sheet, Assembly Sheet and Part Sheet** (at assembly level: Order
  Entry, Bid Center, Report Center, Assembly Sheet, Part Sheet). In the other two the ribbon showed Zoom,
  Render Mode, Window Mode, Job/Room and Modifications tools and the sidebar showed the drawing tools (Walls,
  Objects, Floors, Ceilings, Tops, Molding, Auto Fill, Cross Section, CAD). *(Which pane was active in each
  shot wasn't recorded. Presumably the first set goes with a Reports pane.)*
- **Set Columns** (ribbon) **shows or hides columns** in the report (Jon).
- **CV remembers your split layout globally** (Jon): your last layout stays as your setting across jobs,
  not per job.

**The live report depends on the level you're working at:**
- **At the room (Layout) level,** the Reports pane is a table of **assemblies**: Item, Part No., Width,
  Height, Depth, Catalog, Door Style, Hinge, Finish, Qty, Type and Description.
- **At the assembly level,** it is a table of **parts**: Qty, Name, Width, Length, Thick and **Material**
  (for example "Finished Left End, 3/4 Prism SF237 Charcoal", "Exterior Banding, Prism SF237 Charcoal EB",
  a drawer guide, hinges, and so on). This is the quickest place to **read the material each part is
  actually using** and compare it against the material schedule (see `Materials & Schedules.md`).
- The report updates as you change the job, so a change in a drawing pane shows in the report at once.
  *(Shown live in the screenshots; the exact refresh behavior wasn't tested.)*

## Automatic CAD Text

Jon's own framing: an "insanely valuable tool" for streamlining drawings, and one he says is easy to
mix up the name of (Automatic CAD Text / CAD Automatic Text). Whenever text is added through the
CAD tool anywhere in CV, it can hold **Text Variables** — placeholders written as `{ }` — that
auto-fill from data already in the Job, instead of being hand-typed. A huge library of these exists
(job/customer/ship-to/user/room/assembly/wall/part-level fields, material schedules, construction
methods, dates, and more — see `Reference/` for the full official variable list), and critically,
**any System or User Parameter can be referenced this way too**, not just the pre-built variables —
`{cab.cabnote1}` pulls a custom parameter named `CabNote1` off the current cabinet exactly like the
built-in ones. Confirmed: referencing a parameter through a tag simply returns that parameter's
current value directly — there's no separate "value vs. parameter" distinction to worry about.

**Title Blocks are built with this directly.** Editing one happens in ordinary CAD (F7) mode — the
full CAD ribbon (Text, Dimensions, Leaders, Lines, Hatch, etc.) — with the raw `{tag}` text visible
and editable as CAD text objects. A real title block is typically a mix of **static text** (a
company's boilerplate/legal text, address) **and** Automatic Text tags (job number, customer name,
dates, page count). Confirmed concretely: the "Pg X of Y" on a title block is literally
`{draw.no}` of `{draw.total}`.

**Correction — "Live"/"Static" isn't an official CV toggle for title blocks the way it is for
scenes; it's descriptive, and Automatic Text is what actually earns the label.** A title block
named "Live Title Block" (Jon's own naming, not a CV-imposed category) is "Live" specifically
*because* it's built with Automatic CAD Text — that CAD content genuinely updates in real time as
the underlying data changes. A title block built with zero Automatic Text (pure static CAD) would
correctly be called "Static," since nothing in it is actually driving updates. Worth generalizing:
Automatic CAD Text is the real mechanism that makes *any* piece of CAD content behave "live," not
something exclusive to scenes sent via To Live-Drawing.

**Corrected: Automatic Text *can* climb up the tree, much like a formula's colon-climbing — the
earlier "no climbing at all" claim was wrong.** A tag placed on a cabinet can genuinely read data
from the Wall it sits on, or the Room it's inside of, by climbing up that cabinet's own ancestor
chain — the PDF's nested category menus (Cabinet → Wall Face → Wall → Room → Job) are literally
showing that upward-climbing capability at work, not a fixed menu that reorganizes by sheet type.
**Final, settled answer: it cannot look back down the tree at all, under any circumstances** — an
initial guess that a very direct/explicit path might reach downward was floated and then
retracted. Climbing with Automatic Text is strictly one-directional (up only), unlike a formula
reference, which can also read down into a named child via period-addressing.

**What's still true, though:** a tag still needs *some* valid anchoring context to climb from in
the first place. A `{cab.something}` tag placed somewhere that isn't actually inside an assembly
still won't resolve — there's no cabinet to climb from at all. A `{wall.x}` tag still won't resolve
in Plan View; it has to sit directly on the relevant wall to have a wall to climb from. **You can
place any tag anywhere — CV won't stop you — but it still needs a real anchor in the right kind of
location to have anything to climb up toward.** Knowing *where* a tag needs to live remains the
real skill, just for a more specific reason than "it can't climb at all."

**The empty-vs-invisible behavior is a normal, low-stakes mechanic, not a real gotcha — with one
real exception.** An unpopulated variable shows the literal variable name while in CAD (editing)
mode, but is invisible in Normal View — a genuinely useful way to have a note that only appears
when a UCS or condition actually populates it. The real gotcha is different: **a typo in a tag
produces no visible sign of failure at all — it just silently shows nothing, indistinguishable from
a tag that correctly resolved to empty.** Jon's own practice specifically guards against this: when
referencing his own custom parameters via Automatic Text, he makes sure the parameter always
resolves to *something* — even a literal "None/N/A" — rather than ever being legitimately blank, so
a blank field on a drawing reliably means "something's wrong" rather than being ambiguous with
"correctly empty."

**Worked example of real leverage, straight from Jon:** a custom floating-shelf parameter
continuously measures the distance to whatever object sits below it. Rather than manually drawing
(and re-drawing, every time something changes) a dimension line to show that gap, he places an
Automatic Text tag referencing that parameter directly on CAD saved with the shelf assembly. Since
the parameter keeps recalculating and the tag just displays its current value, the measurement
shown on the drawing is always current with zero manual maintenance — a direct extension of Object
Intelligence (`Parameters.md`) into the drawing itself, not just the model.

**Deferred/not pursued:** the three text-format modifiers (`u:`/`l:` force first-character
case, `n:` parenthesizes negative numbers) — Jon has never had a reason to use them. The
Modular-Catalog-only `{option#ID.label}`/`{option#ID.value}` variables are confirmed **safe to
skip** — not part of how Ironwood works with catalogs.

**Title blocks aren't kept per client.** Most of Jon's drawings are produced inside a client's own
system, where their title block already exists, so he doesn't maintain separate title blocks for
separate companies.

**Second worked example — an appliance object that labels itself on elevations.** The appliance
carries custom parameters for its type, manufacturer, model number, and whether it's panel ready,
plus the built-in width (`DX`). CAD saved inside the appliance references them as tags (e.g.
`{CAB.DX}" {CAB.APP_MANU} {CAB.APP_TYPE}`, then model and panel-ready on their own lines), so the
elevation shows a complete, correct callout with no hand-typing. Same principle as the floating
shelf: the data lives on the object as parameters, and the drawing text just reads it. Jon notes
this is one of *many* such uses.

**How Live vs. Static actually gets decided: it's the output path, not the Template.** Layers is
where a Template is assigned to each view for printing/sending to Drawings. The same Template
behaves differently depending on how it's sent:
- **Sent as a Live Drawing:** Automatic CAD Text updates along with the rest of the drawing.
- **Sent as a Static drawing:** nothing updates, Automatic Text included. It's a frozen image.
- **Printed straight to PDF:** Jon's preferred method, using a well-designed Template that captures
  most of each scene's elevation information. It has real drawbacks (details still to be
  captured).

**Jon's standing recommendation:** if a company can't build a Template it trusts to carry the
drawing on its own, always recommend Live Drawings. Static should almost never be used, only once a
job is ready to push into production, and even then Jon has reservations.
