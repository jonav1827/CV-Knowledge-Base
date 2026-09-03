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

This is also framed as a **Global vs. Local** distinction: System-level changes are Global — they
reach every future Job (not retroactively, unless deliberately imported into an existing Job).
Room-level changes are Local — contained to that Room only. This containment is what makes it
possible to run an Oak kitchen, a Cherry dining room, a laminate laundry room, and melamine garage
cabinets all in the same Job without them bleeding into each other: each Room's overrides isolate
its own Material/Construction/Hardware/Counter Top choices from every other Room.

**Mechanically, what an override *is*:** an override is its own unique parameter that exists on
the Object Tree only while it's active. "Clearing" an override, through whatever UI is offered for
it, just removes that parameter. You can also clear one manually by finding it directly on the
Object Tree and deleting the parameter yourself — same effect either way.

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
way down, with every property along the way parametrized. Overrides that don't show up in a Room's
Overrides tab, a Part's Overrides tab, or the Section Editor UI can still be found here, which
makes it the closest thing to a universal place to check — with one correction: *most*, not all,
parameters live visibly on the tree. Some are hidden — still real, still referenceable (in a
formula/UCS, for instance), just not something you can see or click on directly in the tree view.
Cabinet Vision's own system-parameter reference (saved in `Reference/CV System Parameters.pdf`)
documents a `Visibility` property on every parameter — values seen include `Always`, `Never`,
`Non-Visible`, `Visible with user override`, `User Added`, and `User Activated` — which is almost
certainly the mechanism behind this: a `Never`/`Non-Visible` parameter is exactly the kind that's
real and usable but won't appear in the tree itself.

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

A full reference list of CV's system parameters is coming next — Jon has it, and it may already
exist in the help documentation too, worth cross-checking once both are in hand.
