# xReporting

x-module. See `Modules.md` for the full feature list Hexagon documents for this module — this
file is for the real operational knowledge on top of that: how it's actually used, gotchas,
workflow, and anecdotes.

**Priority** — on Ironwood's intended first-license list.

---

## The one thing that explains reports

Report SQL does **not** run against CVData. When a report runs, Cabinet Vision builds a fresh
in-memory **Microsoft Access / Jet database**, copies the job's data into intermediate tables there,
and every query in the report runs against **that** dataset in **Jet (Access) SQL** — not T-SQL.

- General, Catalog and Bid reports use `report.accdb`.
- NC reports (Saw, Nest, Part) use `psnc-xx.accdb`, with a different set of intermediate tables.

This is why report queries look the way they do: `IIF(...)`, `STR(...)`, `TRIM(...)`,
`Count/Sum/Max`, `WITH … AS (…)`, `[Bracketed Names With Spaces]`, and `SELECT TOP 10000 …` on
nearly every query. A query that is valid T-SQL can still fail in a report, and vice-versa — the
dialect is Access. The table names a report uses (`Parts`, `Cuts`, `PanelLayout`, `SawCuts`,
`MoldingStickCount`, `Job Info`) are the **report dataset's** tables, not CVData tables.

## How a report is stored

A report is a banded template plus a set of SQL queries. The pieces (CVData tables):

| Table | What it holds |
|---|---|
| `Report` | One row per report: `Tag` (6-char code, e.g. `CLSC01`, `DL0001`, `SAW005`), `Name`, `ReportTypeID`, `ReportTemplateID`, `System` (1 = Hexagon built-in), `PartGraphics`, `Settings` (XML), `Script`. |
| `ReportTemplate` | `Template` XML — the banded visual layout (header / detail / footer bands, fields, graphics). |
| `ReportQuery` | Named queries that make up the report's dataset. See below. |
| `ReportSource` | One row per **band / section** of the report. `SQL` is the final `SELECT` that feeds that band; a report with 8 sources has 8 bands / sub-reports. Also sort and concat settings. |
| `ReportVariable` | Report-level variables (`Name` / `Value` / `Type`), e.g. `ReportName`. |
| `ReportSourceExtraData` | Per-source filter hooks — how a source is scoped to one cabinet / room / top (see below). |
| `ReportGroup` + `ReportList` | The print-menu tree: `ReportList` places a report into a `ReportGroup` folder. `refReportGroupType` = CV / CV Bid / S2M. |
| `ReportRelation` | Primary/foreign joins between sources. Often empty — joins are written inline in the SQL instead. |

`refReportType`: 1 General · 2 Catalog Editor · 3 Bid · 4 NC General · 5 NC Saw · 6 NC Nest ·
7 NC Part. Type decides which `.accdb` and which intermediate tables are available.

### `ReportQuery` — building the dataset

Two kinds, set by the `Import` flag:

- **`Import = True`**: pull a base table straight from CVData into the report dataset. `Table` names
  the CVData table and `Source` is `[CVData]`; `Fields` lists the columns. Example: a query named
  `CxMaterial` importing `Material` (ID, MaterialTypeID, Name, Description, UnitOfIssueID), or
  `CxUnitOfIssue` importing `refUnitOfIssue`. These are the seed tables.
- **`Import = False`**: a derived query (a view) written in Jet SQL. It can reference other queries,
  so the queries form a dependency chain, and CTEs (`WITH … AS`) are allowed. A `ReportSource` then
  selects from the top of that chain.

### Two conventions to copy when you write report SQL

1. **Dual query storage.** CV keeps two copies of each query in the one `SQL` field: the live,
   normalized query first, then the designer's original inside a comment:
   ```
   SELECT TOP 10000 … (normalized: functions upper-cased, = spaced, TOP added)
   /*** Original Query ***
   SELECT … (exactly what was typed)
   ***/
   ```
   The live query at the top is what runs; the comment is the fuller version of what was entered.
   Edit the live query; keep the comment in step.
2. **`{field}` token substitution.** Tokens like `{Part ID}`, `{Width String}`, `{Material ID}`,
   `{field}` are replaced at render time with the **current detail row's** values. This is CV's
   correlated-subquery / mail-merge mechanism: a per-row count or lookup is written as one query with
   `{…}` tokens in its `WHERE`/`HAVING`, and CV re-runs it substituting each row.

### Scoping a report to a cabinet, room or top — `ReportSourceExtraData`

A source names the column CV filters on when the report is run for a single object:
`FilterByCabinetIDField`, `FilterByRoomIDField`, `FilterByTopIDField`, `FilterByAccountIDField`
(e.g. `Parts.[Cabinet ID]`). `CabinetQtySQL` is a per-cabinet quantity breakdown query (uses the
`{field}` tokens). NC reports have the parallel `ReportSourceExtraNCData` with
`FilterByRunCounter/Pattern/Run/Part` fields.

## Worked structure of three built-in reports

**Standard Cut List** (`CLSC01`, General) — the baseline. Imports `CxMaterial` and `CxUnitOfIssue`;
its main `Parts` source groups parts by material (`INNER JOIN CxMaterial`, `CxUnitOfIssue`),
`WHERE BuyOut = 0`, `COUNT(Part ID) AS Qty`, ordered material → width DESC → length DESC. A second
source builds the job-title line. Scoped by `Parts.[Cabinet ID]` / `Parts.[Top ID]`.

**Material Summary** (`MTOT01`, General) — multi-source aggregation. Seven sources, each a
`SUM … GROUP BY` over cost and waste for one material class (sheet parts via a `PartsCTE`, plus
molding stick/lineal costs by unit of issue, molding, variable molding, job info). Shows how one
report fans out into many independent `SELECT`s, one per band.

**Saw Cut List - Simple** (`SAW005`, NC Saw) — runs against `psnc-xx.accdb`. A chain of named
queries build on each other: `FaceDependence` → `PatternReps` → `CutSizes` → `SheetCount` →
`SawPartRunData` → `SawCuts` (a large `DISTINCT` join across `Cuts`, `PanelLayout`, `Parts`, `Jobs`,
`Materials`, `Assemblies`, `Rooms`, `Patterns`, `PartRunData`, `CutSizes`) → `RunJobs` → `PartList`.
The NC intermediate tables (`PanelLayout`, `SawCuts`, `Cuts`, `Patterns`, `PartRunData`, `RunInfo`)
are the nesting/optimizing output, not CVData tables.

## Gotchas

- **Write Access SQL, test in the report.** The dialect is Jet, not T-SQL. `IIF` not `CASE`, `&`/`+`
  for string concat, `[Name With Spaces]` not `"Name"`, `STR()` / `TRIM()`, Access date functions.
- **`TOP 10000`** is CV's normalizer capping result size; keep it unless you mean to change it.
- **Tag codes are the stable handle.** The 6-character `Tag` (not the display `Name`) identifies a
  report; several reports can share a `Name` (there are ten "Banding Cut List" rows).
- **`System = 1` reports are Hexagon's.** They are reset on update; copy to a new report before
  editing so your version survives a CV upgrade.

## Reference

- Serialization and units shared with the job file: `CVJ File Format.md`.
- The intermediate `Parts`/`Cuts`/`PanelLayout` tables come out of the S2M optimizing run:
  `Machining.md`, `S2M Handoff.md`.
- Material/cost columns the summaries read: `CVData Materials & SQL.md`.
