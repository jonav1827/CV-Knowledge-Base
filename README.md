# Ironwood Shopworks Knowledge Base

A structured record of Jon's knowledge (and knowledge gathered from others — manufacturers,
industry sources, downloaded reference material) across every stage of a cabinetry/woodworking
job, kept current over time. The goal: Claude acts as an encyclopedia and troubleshooting partner
against this material — capturing it here means it's retrievable on demand instead of living only
in Jon's head.

## Structure

One folder per production stage:

- `01 Bidding`
- `02 Design & Drafting`
- `03 Engineering`
- `04 Machining`
- `05 Production & Custom`
- `06 Finishing`
- `07 Install`

Each stage folder holds three files:

- **Processes.md** — step-by-step how-tos: how things actually get done, the right way, and why.
- **Products.md** — specific hardware, materials, machines, or software relevant to that stage —
  what's good, what's not, when to use what.
- **Notes.md** — anecdotes, lessons learned, and the "why" behind the processes; things worth
  remembering that don't fit a clean how-to.

Plus a `Reference/` subfolder (created as needed) for downloaded source material — PDFs, spec
sheets, manuals — that the three files above can cite back to, so distilled knowledge and raw
source documents don't get tangled together.

## Unverified Knowledge.md

A running checklist of everything in the Knowledge Base that isn't yet confirmed in Jon's CV, with how to
test each item. Check it when picking what to verify next, tick items off when they're tested, and add new
ones as they come up.

## Glossary.md

A single, cross-cutting file at the top level (not filed under any one stage) mapping every
alternate shop term to one canonical entry — cabinetry/woodworking terminology varies a lot shop to
shop, and an unfamiliar term mid-training can stall understanding until it "clicks" in person.
Catching those synonyms here means that click can happen from a lookup instead.

## Cabinet Vision/

Cabinet Vision gets its own top-level folder rather than living under one production stage — it's
too central to the business (the long-term core asset per the positioning doc) and touches too
many stages at once (Design & Drafting, Engineering, Machining) to file under just one. Organized
by CV's own licensing structure rather than the generic Processes/Products/Notes split:

- **Modules.md** — factual reference index of Cabinet Vision's licensing hierarchy (Core, the
  x-modules, and their +-additions), sourced from Hexagon's own documentation in `Reference/`.
  What exists, not what Ironwood knows about it — a searchable distillation of the source PDF, kept
  even though the PDF itself is also in `Reference/`, since grepping a Markdown file beats
  re-reading a PDF every time the licensing structure needs to be checked.
- One file per module — `Core.md` doubles as the CV fundamentals file (navigation, general
  concepts, file/job structure, preferences, terminology — there's no real line between "Core" and
  "fundamentals," so they aren't split), plus `Cabinets.md`, `Closets.md`, `2D CAD.md`,
  `Bidding.md`, `Countertops.md`, `CRM.md`, `Optimizer.md`, `Rendering.md`, `Reporting.md`,
  `Shaping.md`, `Machining.md` — every module gets a file so nothing's missing, even ones that stay
  thin because they're not in active use. **`Machining.md`** now has real content: S2M CENTER's
  workflow, Machine Catalog, Tool Catalog and Preferences, built from Hexagon's S2M help — see
  **S2M Handoff.md** for how that material was obtained and what's still unmined in it. None of it
  is hands-on confirmed yet (Ironwood has no CV/S2M license), same caveat as the other module files
  before Jon checks them against a real install.
- **Parameters.md** — foundational to Object Intelligence and xShaping: parameter types, the three
  parameter styles (Standard/Attribute/Note), Static vs. Equation values, parametric equations, and
  the 9 basic parameters every beginner should know. Big enough a topic to earn its own file rather
  than living inside Core.md.
- **Materials & Schedules.md** — how CV assigns materials, profiles, hardware and layers through
  schedules (material catalog vs schedule, part roles, priority, the kinds of schedule), built up
  topic by topic.
- **CVData Materials & SQL.md** — how CV stores every material type in the CVData database (tables,
  columns, defaults, lookup tables, gotchas) and how to create many materials by script.
- **Materials Handoff.md** — where the Materials work stands: what's covered, open items, and the plan
  for the next session. Read it first when resuming.
- **Walkthrough - Create a Panel Stock Material.md** — draft step-by-step walk-through (wizard screens
  still unchecked against Jon's CV).
- **Setup Packages.md** — how CV transfers custom objects (materials, schedules, doors, UCSs, catalogs and more)
  between installations with a Setup Package: what can go in one, export, import and overwrite options.
- **UCS.md** — User Created Standards: the look-UP resolution model, parameter access prefixes,
  UCS:M (legacy) and UCS:JS (JavaScript) syntax, validated patterns, and hard-won gotchas.
- **Notes.md** — anecdotes/gotchas that span multiple modules rather than belonging to one.
- **Reference/** — downloaded source material (the Hexagon module-features PDF, help docs, etc.).

## Hardware/

Manufacturer hardware (drawer runners, hinges, lift systems and so on) gets its own top-level folder because
the same product shows up in Engineering, Machining and Install. It has one subfolder per manufacturer, then
one per product line. Each product line folder holds the write-up and its source catalog together, so there's
no separate `Reference/` folder here.

- **Blum/**
  - **TANDEM/**
    - `TANDEM Runners.md`: the TANDEM concealed runner family (563H, 563F, 563. and 554H). Covers the H vs F
      difference, lengths and part numbers, drawer box deductions, shared parts, the lateral stabilizer, and
      where "heavy duty" fits.
    - Source: `TANDEM plus BLUMOTION Catalog (2025).pdf`.
  - **MOVENTO/**
    - `MOVENTO Runners.md`: the MOVENTO premium and heavy-duty runners (763H, 763., 769. and the 769R
      waste/recycle set). Covers MOVENTO vs TANDEM drawer box differences, lengths and part numbers.
    - Source: `MOVENTO Catalog (2026).pdf`.
  - **AVENTOS/**
    - `AVENTOS top Lift Systems.md`: the AVENTOS top family (HF, HS, HL and HK top, HK-S, HK-XS). Covers which
      lift for which door, power-factor sizing, part numbers, crown clearance formulas, face frame brackets,
      inset methods and SERVO-DRIVE.
    - `AVENTOS HKi Lift.md`: the lift-up mechanism milled into the cabinet side. Covers fully vs
      semi-integrated, power-factor sizing, part numbers and planning notes.
    - Sources: `AVENTOS top Catalog (2026).pdf`, `AVENTOS HKi Catalog (2024).pdf`.
  - **Hinges/**
    - `Concealed Hinges.md`: the full concealed hinge program (CLIP top BLUMOTION, CLIP top, CLIP, angled
      hinges, and COMPACT for face frames). Covers the overlay formula, part number patterns, each hinge's
      opening angle, max door thickness and fixed distance, mounting plates, face frame adapter plates,
      soft-close add-ons, TIP-ON and tools.
    - Source: `Concealed Hinges Catalog (2025).pdf`.

## Other cross-cutting topics

Not everything cross-cutting needs its own top-level folder like Cabinet Vision did — that's
reserved for things central enough to the business to earn it. A smaller cross-cutting topic can
just be filed under its most relevant stage and cross-referenced from the others. Claude can search
across the whole Knowledge Base regardless of which folder something lives in, so the folder a note
sits in is mainly for human browsability, not a retrieval boundary.

## Format

Plain Markdown throughout, matching the rest of this repo. No fixed schema — write entries as
whatever level of structure fits the content (a heading and a paragraph is fine; a table is fine
if the content calls for it).
