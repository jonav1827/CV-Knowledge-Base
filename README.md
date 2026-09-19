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
  thin because they're not in active use.
- **Parameters.md** — foundational to Object Intelligence and xShaping: parameter types, the three
  parameter styles (Standard/Attribute/Note), Static vs. Equation values, parametric equations, and
  the 9 basic parameters every beginner should know. Big enough a topic to earn its own file rather
  than living inside Core.md.
- **UCS.md** — User Created Standards: the look-UP resolution model, parameter access prefixes,
  UCS:M (legacy) and UCS:JS (JavaScript) syntax, validated patterns, and hard-won gotchas.
- **Notes.md** — anecdotes/gotchas that span multiple modules rather than belonging to one.
- **Reference/** — downloaded source material (the Hexagon module-features PDF, help docs, etc.).

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
