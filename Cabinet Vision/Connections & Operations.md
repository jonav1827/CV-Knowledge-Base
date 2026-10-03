# Connections and Operations

How Cabinet Vision stores joinery (dados, bores, connectors, dovetails, mortise & tenon) and the
machining operations they produce. This is the vocabulary a UCS draws on when it adds a joint or a
toolpath (see `UCS.md`), and the data S2M turns into tool selection (see `Machining.md`).

Everything below is the built-in CV model and its built-in standard definitions. The actual
**named connections a shop builds** (specific dado depths, their RTA-connector recipes) are that
shop's construction knowledge and are not recorded here.

---

## 1. A Connection is a named joint that bundles standard values

`Connection` holds one row per named joint: `Name`, `Description`, `ConnectionTypeID`, `System`
(1 = Hexagon built-in), `ShowInList` (whether it appears in the construction pick list).

The eight connection types (`refConnectionType`):

| ID | Type | What it makes |
|---|---|---|
| 1 | Set | A group of other connections applied together (see 1.2). |
| 2 | Dado | A dado / groove / rabbet; blind or through. |
| 3 | AssemblyBoring | Dowel and face bores (construction boring). |
| 4 | IJoint | An Intelli-Joint — a cam-and-dowel / RTA connector drilling recipe (see 3). |
| 5 | Connector | A connector hardware joint (e.g. Lamello, Cabineo). |
| 6 | Dovetail | Through or blind dovetails. |
| 7 | Line Boring | A row of shelf-pin / system holes. |
| 8 | Mortise & Tennon | Frame joinery. (CV's spelling is "Tennon".) |

### 1.1 Where a connection's values live — `ConnectionStandardMap`

A connection does not store its depth, diameter, spacing and so on as columns. It stores them the
same way case standards work: one `ConnectionStandardMap` row per value, keyed to a standard
definition.

| Column | Meaning |
|---|---|
| `ConnectionID` | The connection this value belongs to. |
| `ConnectionStandardID` | Which standard (→ `refConnectionStandard`, see 2). |
| `Value` | The value, as text (a formula or a literal). |
| `Choice` | For list-type standards, the chosen option. |
| `ParameterTypeID` | The value's type (see parameter type codes in `CVJ File Format.md` §3). |
| `UnitOfMeasureID` | Unit for the value. |
| `Visited` | Whether this standard has been set for this connection. |

### 1.2 A Set bundles connections — `ConnectionSetMap`

A type-1 **Set** connection applies several connections at once. `ConnectionSetMap` lists its
members (`ConnectionID` = the set, `MemberID` → the member `Connection`). This is how one choice in
construction can place, say, a dado plus a line bore plus screw holes together.

## 2. `refConnectionStandard` — every tunable parameter, by type

This is the built-in catalog of what each connection type can set — 104 standards. The naming
convention is `CONSTD_<area><Thing>`, and each standard belongs to one `ConnectionTypeID`. Grouped:

- **Dado (type 2):** `DadoDepth`, `DadoType` (blind Y/N), `QualifyDado`, `TenonWidth`,
  `PocketWidth`, `SppressS2MExtend`, `FrontNotchLength`, `RearNotch` + `RearNotchLength`,
  `WidthAdjustment`, `LengthAdjustment`, `DepthAdjustment`.
- **AssemblyBoring (type 3):** horizontal (dowel) and vertical (face) `…Diam` / `…Depth`,
  `EdgePosition`, `MiterPosition`, `FixedHead` + `HeadNumber` + `HeadBitMask`, `Fixed1stHole`,
  `RearGap` / `FrontGap`, `HolePlacement`, front & rear `Qty` / `Position` / `Spacing`,
  `MidPlacement`, `BalancedPos` + `BalanceSpace`, `BoreMidIgnore32` (restrict mid holes to 32 mm
  increments).
- **IJoint (type 4):** `IJointID` (→ an `IJoint` recipe), `EdgePosition`, `MiterPosition`,
  `SingleJoint`, fixed-head set, placement, front & rear `Qty` / `Position` / `Spacing`, gaps,
  `MidPlacement`, `BalancedPos` + `BalanceSpace`.
- **Connector (type 5):** `ConnectID` (→ a connector), same geometry set as IJoint.
- **Dovetail (type 6):** `FrontPos`, `RearPos`, `MaxSpacing`, `Tool`, `Type` (0 through / 1 blind),
  `AdjustPart`, `AdjustReference`.
- **Line Boring (type 7):** `SideClearance`, `RequiredHoles`, `HoleQuantity`, `HoleDiameter`,
  `HoleDepth`, `FrontPos`, `RearPos`, `HoleSpacing`, `MaxLineSpacing`, `Placement`, `BalancedPos` +
  `BalanceSpace`, `SpanSpace`.
- **Mortise & Tennon (type 8):** `TennonDepth`, `PocketWidth`, `SppressS2MExtend`, top / bottom /
  front / rear `ShoulderWidth`, mortise `Width` / `Length` / `Depth` `Adjustment`.

Value types follow the standard parameter type codes (Measurement 1, Boolean 0/5, Integer 4,
Decimal 6, Text 8, ShapeID/GUID 11) documented in `CVJ File Format.md` §3.

### 2.1 Which standards are pick lists — `refConnectionChoiceType`

Maps a standard to a choice list and a `SpecialTypeID`: 2 = pick a Connector, 7 = pick an IJoint,
9 = pick a Dovetail tool, 4 = a bit-mask text value. This drives the dropdowns in the connection
editor (e.g. the `ConnectID` standard offers the list of connectors; `IJointID` offers the IJoints).

## 3. Operations — the toolpaths a connection produces

### 3.1 `Operation` + `OperationParameter`

An `Operation` is one machining operation placed on a part:

| Column | Meaning |
|---|---|
| `LayerID` | Which part layer (→ `refLayerType`: 1 Face, 2 Back, 3 Edge, 4 End, 5 Geometry, 6 Plane). |
| `WorkPlaneTypeID` | Which face the op is on (→ `refWorkPlaneType`: 1 Face, 2 Back, 3 Left, 4 Right, 5 Top, 6 Bottom). |
| `OperationTypeID` | The kind of op (→ `refOperationType`, see below). |
| `XPosition` / `YPosition` / `ZPosition`, `Width` / `Length` / `Depth`, `Repeat` / `Spacing` | **Formula strings**, not numbers — e.g. `DX/2`, `::DZ`, a literal like `12`. |
| `ShapeID` | The op's shape (→ `Shape`). |
| `ToolID` | The tool. |

`refOperationType` (20): 1 Hole · 2 Dado · 3 Line Bore · 4 Hole Master · 5 Dado Master ·
6 Line Bore Master · 7 Route · 8 Line · 9 Arc · 10/11 Clamex (+ Master) · 12/13 FastenLink (+ Master)
· 14 Intelli-Joint · 15 AlphaCAM · 16/17 Dovetail Master/Slave · 18 Reverse Dado ·
19 Reverse Dado Master · 20 Blind Reverse Dado Master. "Master" ops drive the primary part of a
two-part joint; the matching op on the secondary part is the slave.

`OperationParameter` adds extras per op (`Name`, `ParameterTypeID`, `ParamValue`), e.g. a workplane
override, a bit normal/diameter, a transparency.

### 3.2 `IJoint` + `IJointOperation` — RTA connector recipes

An `IJoint` (cam-and-dowel, Lamello, Blum-style connector) owns a set of named `IJointOperation`
rows, each a hole or dado with formula geometry:

| Column | Meaning |
|---|---|
| `Name` | The feature (`Housing`, `Cam Hole`, `Peg Hole`, `Stud Hole`, `Anchor`, `Bolt`, `ConnBolt`, `Dado`). |
| `Master` | Whether this feature is bored in the primary part. |
| `XPosition` / `YPosition`, `Width`, `Spacing`, `Depth`, `Quantity` | Formula strings. |
| `ToolID` | The tool. |

Formula idioms seen in connection/operation formulas:

- `Imp(n)` wraps a literal entered in the imperial unit (so the recipe reads naturally in inches/mm
  regardless of the job's display unit).
- Part dimension variables `DX`, `DY` (and `DZ`) — e.g. `DY/2` to centre a bore, `DY - (2 * 1)` to
  inset from both edges.

## Reference

- Writing joints and ops from a script: `UCS.md` (`dim … as new connection` / dado / route / line /
  arc use this vocabulary).
- How S2M turns an op + tool into output: `Machining.md` (tool catalog, automatic tool selection).
- Shapes referenced by ops and connectors: `CVData Materials & SQL.md` §2.4.
- Parameter type codes and formula notation: `CVJ File Format.md` §3.
