# S2M CENTER: Handoff

Written 2026-09-25, logging how the S2M reference material arrived and what came of it. The real content
lives in `Machining.md` (S2M CENTER is Cabinet Vision's CNC output application, and lives under the
**xMachining** module — see `Modules.md`). Read this file first if picking the S2M work back up.

## Where the reference material came from

Jon downloaded and printed Hexagon's S2M CENTER help **one heading at a time** (the online help system
doesn't offer a single export), producing four PDFs that together make up the whole help file:

- `S2M Intro.pdf` — What's New changelogs by version, plus the **Preferences** reference (all 7 tabs) near
  the end.
- `S2M Ribbonbar.pdf` — by far the largest (365 pages): the Main Tab reference. Parts/Materials view,
  Machine Catalog (all 8 machine types, Machine Sets and Workflow), Tool Catalog, the full **Automatic Tool
  Selection Logic**, DXF import, and a very large per-machine-brand NC Links catalog (Holzma, SCMI, Selco,
  PIOS, and dozens more).
- `S2M Sidebar.pdf` — the Optimizing/Nesting sidebar, Filter Parts, the Optimize run, Reports and Report
  Groups, NC Code & Labels output, and the `CncRun.txt` file format.
- `S2M Tid-Bits.pdf` — turned out to be the **full `CVData.mdf` database schema reference** (230 pages,
  every table in the database CV and S2M share), plus a short install-support-folder listing at the end.

All four were copied into `Reference/S2M Help/` alongside the CV help, and a `.txt` was extracted from each
with `pdftotext -layout` so they're greppable, matching how `Reference/Help/CABINET VISION 2025 Help.txt`
was handled.

## What came out of it

Two items on `Unverified Knowledge.md` got resolved:

- **M1 (S2M one-sided/two-sided texture rule):** confirmed directly in Hexagon's own S2M help this time,
  not just inferred from the CV help — `S2M Intro.txt`'s "Print" topic has a worked example ("Particle
  Board side down/up"). Jon still hasn't seen this on a real printout, so the item stays open with that as
  the remaining test.
- **M13 (Automatic Tool Selection Logic):** fully resolved. The complete operation-by-operation logic
  (Part Outline, Vertical/Horizontal Hole, Dado, Cutout/Pocket Route) was found in `S2M Ribbonbar.txt` and
  written into `Materials & Schedules.md`'s CNC section.

`M13a` (the feed/speed depth-of-cut interpolation math) is still open — the S2M help repeats the CV help's
exact wording, so no new detail, just a second source saying the same thing.

## Then: building Machining.md

Jon asked to also "learn everything you can from those help files and start building out the .md" — the
stub at `Machining.md` (xMachining module, "no entries yet"). That file now has a first real pass:
S2M CENTER's workflow (Parts view through output), the Machine Catalog (types, Machine Sets/Workflow,
per-machine-type setup concepts), the Tool Catalog (11 tool types, general tool properties, the three CNC
output path types), the Preferences reference, and DXF/third-party CAD import.

**Important caveat carried into that file, and worth repeating here:** Ironwood doesn't hold a CV license
yet (per `Modules.md`'s Status section), so **none of this has been used hands-on** — it's a straight
distillation of Hexagon's documentation, the same way `Core.md` and `Materials & Schedules.md` started
before Jon checked them against his own install. Treat everything in `Machining.md` as reference until
Jon has S2M CENTER in front of him to confirm it.

## Merged with a parallel session's tooling research (2026-09-25)

While this work was in progress, Jon pushed a separate session's research from another machine:
`04 Machining/Processes.md`, `Products.md` and `Notes.md` — general (non-CV) feeds-and-speeds formulas and
an upcut/downcut/compression bit comparison, gathered from web sources (`Unverified Knowledge.md` items
T1-T4). That work had explicitly flagged that the S2M help wasn't in the repo yet and that "face chip =
downcut, back chip = upcut" was an unconfirmed inference (its `Notes.md`). The two sessions turned out to
answer each other:
- The S2M help confirms CV's own UI literally uses **"Up Shear"** and **"Down Shear"** as tool properties,
  narrowing T3 (the terminology mapping is solid; only the live tool-selection behavior is still untested).
- `04 Machining/Notes.md` was updated to point at the now-present S2M help and the Automatic Tool Selection
  Logic in `Materials & Schedules.md`.
- `Machining.md` and `Materials & Schedules.md` were both cross-linked to `04 Machining/` for the fuller,
  properly sourced feeds/speeds and bit-type material, rather than duplicating it.

## What's still in the source material, not yet mined

- **The full per-machine-brand NC Links catalog** in `S2M Ribbonbar.txt` (roughly lines 2495–6780): dozens
  of machine-specific output parameter lists (PIOS, SCMI, Selco XML, Holzma, and more). Left alone for now
  — only worth mining once Ironwood or a client actually has one of these machines.
- **The full `CVData.mdf` schema** in `S2M Tid-Bits.txt` (all 230 pages/8500+ lines) — a much bigger
  reference than what `CVData Materials & SQL.md` currently covers (which is scoped to material tables
  only). A future project if deeper SQL/database work is ever needed beyond materials.
- **Part-P2P / Specialized (Drill & Dowel, Chop Saw) output tab details** past the general concepts already
  captured, the **+Label** app, the **Report Editor**, and ALPHACAM-specific integration points.
- The help's reference **charts (#1–#6)** for the Automatic Tool Selection Logic are diagrams that did not
  survive PDF-to-text conversion — open the source PDF directly if one is ever needed.
