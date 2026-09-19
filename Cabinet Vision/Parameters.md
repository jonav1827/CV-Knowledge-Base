# Parameters

Parameters are what hold all the information within Cabinet Vision. Every parameter is a
variable, and those variables get used in equations throughout CV — this is the layer underneath
everything covered in `Core.md`'s Level Hierarchy and Object Tree sections. Understanding
parameters well is what makes the rest of CV click.

**Important distinction: parameters are not branches/children in the Object Tree.** They don't
occupy a level the way Room, Assembly, Case, or Part do. A parameter is a *characteristic* of
whatever branch it belongs to — it describes that branch, it isn't a child node hanging off it.
This is why parameters show up in the panel *below* the tree for whatever branch is currently
selected (see `Core.md`), rather than as further entries inside the tree itself.

**Priority** — foundational to xShaping and to Object Intelligence generally, both on Ironwood's
first-license list.

---

## Parameter Types

The *type* of a parameter is what kind of value it holds:

- Measurement
- Degrees
- Boolean
- Integer
- Text
- Decimal
- Currency

## Parameter Styles

The *style* of a parameter is about where it lives and how a user interacts with it — three
styles:

- **Standard** — lives only in the Object Tree. No UI prompt; nothing to interact with outside of
  going and finding it directly.
- **Attribute** — lives in the Object Tree *and* has a prompt on the UI sidebar, so a user can
  interact with it easily without hunting through the tree.
- **Note** — also lives in the Object Tree with a user-facing prompt, but that prompt sits in a
  dedicated Notes tab instead of the sidebar.

Style is independent of Type (below) — any of the 7 types can be any of these 3 styles, no
restricted combinations. When creating a custom parameter, the user sets both its Type and its
Style directly.

Style is also a **different concept from Visibility**, which is a separate property documented in
Hexagon's system-parameter reference (`Always`, `Never`, `Non-Visible`, `Visible with user
override`, `User Added`, `User Activated`) governing whether a parameter shows up in the Object
Tree at all. Worth flagging: Jon has found a lot of that Visibility documentation unreliable in
practice, and doesn't actually check a parameter's Visibility value day to day — he just looks
through the tree directly for what he needs. Treat Visibility as a documented-but-not-load-bearing
property; Style (Standard/Attribute/Note) is the one that actually matters for how you work with a
parameter.

**The rebuild difference between Attribute and Note is critical:** changing an **Attribute**
triggers an *immediate* rebuild of whatever branch it lives on — a Room attribute rebuilds the
whole Room, a Cabinet attribute rebuilds that Cabinet, and so on, following the same Level
Hierarchy described in `Core.md`. Changing a **Note**, by contrast, does *not* trigger a rebuild —
the change sits there and won't actually show up until the next time that branch rebuilds for some
other reason. Easy to assume the two behave the same since they look and feel similar; they don't.

Worth being honest about the actual stakes here: the rebuild delay itself is frustrating to work
around, but Jon hasn't personally seen it cause an issue that made it all the way into production —
unlike the Level Hierarchy override trap in `Core.md`, which does. Real, but a lower-severity
gotcha than that one.

## Static vs. Equation — how a parameter gets its value

This is the `[Static]` / `[Equation]` tag seen next to every parameter in the Object Tree panel
(see `Core.md`):

- **Static** — the parameter simply holds a fixed value.
- **Equation** — the parameter's value is computed by an actual formula. Can be as simple as
  `A + B = X`, or it can reference *other* parameters to help determine its own value — a
  **parametric equation**.

## Parametric Equations & Object Intelligence

When an equation references other parameters, an object becomes tied directly to those other
variables and adjusts automatically as they change. This is called **Object Intelligence**, and
it's one of the most useful things a Cabinet Vision technician can understand — it's the mechanism
that makes CV's automation and customization actually work, rather than everything being manually
re-entered by hand every time something changes upstream.

**Worked example — a user-added Right Finished End:** say you have a 42"H upper cabinet and you
manually add your own right finished end to it. `CAB` here is *not* a universal keyword for "the
parent" — it's just the specific name used to reference this particular cabinet assembly in this
example (see **Addressing/path syntax** below for how references actually work in general). You
*could* assign that finished end static width/length/position values — but if the cabinet itself
later changes size, those static numbers won't follow along. Instead, drive the finished end's own
parameters from the cabinet's:

- `CAB.DZ` → assigned to the finished end's **width (DX)**
- `CAB.DY` → assigned to the finished end's **length (DY)**
- `CAB.DX` → assigned to the finished end's **X position** (left/right)

With that in place: if the cabinet gets deeper, the finished end automatically gets wider. If the
cabinet gets taller, the finished end automatically gets longer. If the cabinet gets wider, the
finished end's position updates so it stays put on the right side of it. Nothing has to be
re-entered by hand — this is Object Intelligence in practice.

**Addressing/path syntax:** three ways to reference another parameter's value from a formula, and
they can be combined:

- **Direct/absolute path** — write out the actual object name(s), like `CAB.DZ`: go to the node
  named `CAB`, read its `DZ`. This is what the worked example above actually uses — `CAB` there
  isn't a keyword, it's the real name of that specific cabinet, which happened to sit one level up
  from the part the formula was written on.
- **Colon (`:`) — climb *up* the tree**, searching for a parameter matching the given name. Colon
  count is fundamentally about *disambiguation*, not a literal level-count, though the two often
  coincide: CV keeps climbing and scanning upward until it finds a match. If the parameter name
  you're referencing only exists on *one* branch anywhere above your current position, a single
  colon is enough no matter how many actual levels away it is — there's only one branch it can
  possibly resolve to. If the *same* parameter name exists on multiple branches above you, each
  additional colon lets you skip past a nearer, unwanted match to reach the specific farther one
  you actually want. In the worked example, `:DZ` and `CAB.DZ` produce the same result only because
  `CAB` happens to be the nearest (and here, only) branch up with a `DZ` — not because "one colon"
  always means "one level."
- **Period (`.`) — read *down* the tree**, into a named child.

**Colon and period can be combined in the same reference** — e.g. climbing up some number of
branches to a shared ancestor, then reading back down into a different descendant branch (reaching
a "cousin" node rather than a straight-line ancestor).

**Worked example — a down-path, using the Object Tree screenshot in `Core.md`:** starting at the
cabinet (`CAB`) and reading down to the Door Slab, four branches deep — Face, then the door
opening, then the door object itself, then the slab:

`CAB.Face.DOR_OPEN.DOR.S_DSLAB`

Door Slab isn't a direct child of the cabinet — it's nested inside the Face branch specifically
(not Case or Interior), inside the door opening, inside the door object. Each period steps down one
named child at a time, same mechanic as the up-path's colon, just in the other direction.

## Custom Parameters

CV also lets a user create their own parameters for further customization, on top of the built-in
ones. More advanced territory — but it becomes much easier to work with once the basics of
parameters and the Object Tree are solid.

Jon has created dozens of custom parameters used in many different ways over time — real examples
are intentionally being deferred for now as intermediate-level material, once the fundamentals
above are fully locked in.

## UCS (User Created Standards) — flagged for its own future deep-dive

UCS keeps surfacing as we build this out (see the override mechanism and icon system in `Core.md`)
and clearly deserves full treatment of its own eventually — CV's help documentation gives it a
whole section (User Created Standards, JavaScript UCS, JavaScript Functions/Object
Model/Libraries), and Jon's called it one of the most advanced things in CV. What's confirmed so
far, purely from context established elsewhere: a UCS is code that runs on *every* rebuild and can
create, change, or delete parameters and parts, and can assign Static values, single Equations, or
even multiple conditional equations. Because it re-runs every rebuild, anything it places on the
tree can't just be deleted — deleting it triggers the rebuild that recreates it, so fixing a
UCS-driven problem means editing the UCS itself. A well-written one can massively extend CV and
tailor it to a company's standards; a poorly written one can cause real, hard-to-diagnose problems
for exactly the same reason. Full syntax, structure, and gotchas now live in `UCS.md`.

## The 9 Basic Parameters

The essentials every beginner should know right away — these are the ones that showed up directly
in the Object Tree examples in `Core.md` (e.g. the Wall-level parameter panel). Per CV's own help
documentation (Intelligence Workshop → The Basics), practically every object in CV carries these
nine — a room, a cabinet, a part are all "objects" in this sense — though most objects carry more
than just these nine on top. Together they define an object's position, size, and rotation, and can
be reached three ways: through the Object Tree, through that object's Properties, or by writing a
User Created Standard.

**Positional — X, Y, Z:** record an object's position *relative to its parent's Reference Point*
(see below) — e.g. a Part's position is relative to its Assembly, an Assembly's is relative to its
Wall. Sign convention: positive `X` moves right of the parent's reference point, negative moves
left; positive `Y` moves up, negative down; positive `Z` moves forward (toward the face), negative
moves back.

**Sizing — DX, DY, DZ:** the "D" stands for Dimension. What each one measures depends on the
object:
- On an **Assembly**: `DX` = width, `DY` = height, `DZ` = depth.
- On a **Part**: `DX` = width *across the grain*, `DY` = length *with the grain*, `DZ` = thickness
  (measured from the Part's Back toward its Face). Since a Part's thickness is normally determined
  by its Material rather than hand-entered, `DZ` is rarely something you'd write a formula for on a
  Part specifically.

**Rotational — AX, AY, AZ:** rotate an object around each axis. Rarely written into a formula once
a Part is correctly placed in an Assembly (it doesn't usually need to keep changing), but
understanding rotation still matters because rotating a Part moves where its Reference Point ends
up. Quick mental model for each axis: `AX` rotates the way a gymnast swings around a horizontal
bar (like rolling a pencil pointed to the right); `AY` rotates the way a tetherball's rope swings
around its pole (pencil pointed up); `AZ` rotates the way an airplane's propeller spins as you face
it (pencil pointed at you). Sign convention: facing the Reference Point, positive rotates
counter-clockwise, negative rotates clockwise.

## Reference Point & Normal Orientation

The concept underneath X/Y/Z position values: every Assembly or Part has an imaginary **Reference
Point** sitting at its left-bottom-back corner. An Assembly is positioned on a Wall relative to the
Wall's reference point; a Part is positioned in an Assembly relative to the Assembly's reference
point — the same parent/child relationship the Level Hierarchy in `Core.md` already describes,
just applied to physical position instead of property inheritance.

Every Part CV adds to an Assembly starts out in **Normal Orientation** (its default, unrotated
state): length running up/down, width running left/right, thickness running back-to-front, face
toward the viewer, top up — reference point at the left-bottom-back corner. One rule worth
remembering: the reference point always sits on the *back* side of whatever material a Part is
made from, never the face side.
