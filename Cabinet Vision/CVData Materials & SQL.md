# CVData Materials and SQL

How Cabinet Vision stores every material type in the CVData database, column by column, mapped to the
Material Properties window, and what that means for creating many materials by script instead of one at
a time in the Material Manager. For what each property does in CV itself, see `Materials & Schedules.md`.

**Provenance.** This was built from one brand-new material of every type made in the CV 2025 New
Material wizard (nothing cloned or edited), read straight from CVData, plus the CV 2025 help and its
CVData table dictionary. Counter Top was not in that batch, so its section was read from existing
production rows. Everything here is what CV itself wrote; anything not directly observed is marked
**[inferred]** or **[unverified]**.

**Why this file exists.** The goal is to identify a standard for a set of materials, settle their
defaults, and then generate a script that creates all of them without opening the Material Manager. That
only works if the storage rules below are followed exactly.

---

## Part 1: The storage pattern every material follows

A material is spread over several tables:

| Layer of storage | Table | Always present? |
|---|---|---|
| The material itself | `Material` | Yes |
| Its group in the Material Manager | `MaterialMenuTreeItem` | Yes |
| Its type-specific properties | `MaterialExtra<Type>Info` | Yes, except Molding Set |
| Its appearance or 3D model | `Layer` | Yes, except Composite and Molding Set |
| Its 3D geometry meshes | `Shape` | Only for model-bearing types |

A complete ordinary material is therefore four tables: `Material`, `MaterialMenuTreeItem`,
`MaterialExtra<Type>Info` and `Layer`. Panel Stock, Board Stock, Laminate and Composite add
`MaterialExtraCNCInfo`, and the sheet types add `MaterialExtraSizeInfo` (Board Stock uses
`MaterialExtraBoardInfo` instead). Composite and Molding Set break the pattern and are covered in
their own sections.

### The two Layer patterns

This is the most important structural split in the schema.

**Pattern A: flat materials** (sheet goods, lumber, banding, counter tops, molding, plain
miscellaneous). CV writes one `Layer` row per visible face, only to carry finish and texture. There is no
geometry.

```
Layer[Face]  parent=0   ShapeID=0
Layer[Back]  parent=0   ShapeID=0      (left out on Laminate, Banding and Molding, which are Face only)
Layer[Edge]  parent=0   ShapeID=0
Layer[End]   parent=0   ShapeID=0
```

**Pattern B: model materials** (all the hardware). CV writes a root work plane, then one `Layer` child for
each physical piece of the part, each pointing at a `Shape` row that holds a 3D mesh.

```
Layer[Plane]      parent=0        name="Primary Work Plane"   ShapeID=0
  Layer[Geometry] parent=<plane>  name="_HGBASE"              ShapeID=<a mesh>
  Layer[Geometry] parent=<plane>  name="_HGARM"               ShapeID=<a mesh>
```

**A material supports the Model button in CV if and only if it uses Pattern B.** It supports the Profile
button only if it is Molding or Molding Set.

---

## Part 2: The shared tables

### 2.1 `Material`: the base row (21 columns)

Every material has one. The Material Properties window shows most of these in the Material group at the
top of the General tab.

| Column | CV property | What it does |
|---|---|---|
| `ID` | ID | Read-only in CV; assigned by SQL. |
| `Name` | Name | The name on cut lists and in material schedules. Never use a `"` character: the help warns it breaks job optimization. Write `1/2in Melamine`, not `1/2" Melamine`. |
| `Description` | Description | Free text. |
| `MaterialTypeID` | Type | Read-only in CV. Foreign key to `refMaterialType`. Decides which Extra-Info table applies and which buttons are enabled. |
| `UnitOfIssueID` | Unit of Issue | Foreign key to `refUnitOfIssue`. The unit you buy in; drives costing. |
| `DefaultMaterialVendorMapID` | Default Vendor | Foreign key to `MaterialVendorMap`, or 0 for None. **If set, CV disables Default Cost, Default Markup and Default Tax Rate and takes them from the vendor.** |
| `DefaultCost` | Default Cost | What you pay. Disabled when a vendor is set. |
| `SellPrice` | Sell Price | What you charge. |
| `DefaultMarkup` | Default Markup | A percent, normally for freight or overhead. Further markups are set in the Bid Center. |
| `SalesTax` | Sales Tax | Whether *you* pay tax when buying it. Not what you charge the customer. |
| `DefaultTaxRate` | Default Tax Rate | The percent you pay. |
| `Waste` | Waste | A waste percent. |
| `Estimate` | Estimate | Whether the material is sent to the Bid Center and included in the "% of Material Cost" bid method. |
| `LoadModel` | Load Model | Whether the 3D model is loaded into jobs (so heavy models can be switched off). The row only shows in the window for model-bearing types, **but the column is written as 1 on every material, including Panel Stock, so it is not a usable sign of model support.** |
| `NcInventory` | S2M Material | Whether the material appears in S2M CENTER's own Material Catalog. **Not an output gate** (see 5.4). |
| `ParentID` | none | The alias parent. 0 for a normal material; set on alias rows (alternate sizes or lengths of the same product). |
| `Deleted` | none | Soft delete. CV renames the row `{d}<name>(n)` and sets this. Rows are never physically removed. |
| `System` | none | 1 = a system material shipped by Hexagon. These show red in the Select Material dialog. Do not edit them. |
| `ContributorID` | none | The source of the record (a catalog import, and so on). 0 for locally created. |
| `rGUID` | none | A globally unique ID for sync and conflict handling. **The only column in the whole material schema with no default: you must supply it.** |
| `LastUpdate` | none | Sync timestamp. |

**Defaults CV wrote on every new material:** `DefaultCost = 0`, `SellPrice = 0`, `DefaultMarkup = 0`,
`SalesTax = 0`, `DefaultTaxRate = 0`, `Waste = 0`, `Estimate = 1`, `LoadModel = 1`, `NcInventory = 0`,
`ParentID = 0`, `Deleted = 0`, `System = 0`, `ContributorID = 0`, `DefaultMaterialVendorMapID = 0`.
`UnitOfIssueID` is the only base-row field CV varies by type (see each type below).

### 2.2 `MaterialMenuTreeItem`: which group the material is in (6 columns)

| Column | Meaning |
|---|---|
| `MenuTreeID` | Foreign key to `MaterialMenuTree`: the group. |
| `MaterialID` | Foreign key to `Material`. |
| `MenuID` | **Must be `1`.** The column defaults to 0, and a material with `MenuID = 0` is silently invisible in the Material Manager even though its row is in the right group. |

### 2.3 `Layer`: appearance and 3D model (23 columns)

| Column | CV property | What it does |
|---|---|---|
| `LayerTypeID` | none | Foreign key to `refLayerType`: 1 Face, 2 Back, 3 Edge, 4 End, 5 Geometry, 6 Plane. |
| `Name` | Layer group header | `Face`, `Back`, `Edge` or `End` on flat materials. On models, the CV part name, such as `_HGBASE`, `_PLGRIP`, `_DGAMEM` or `Primary Work Plane`. |
| `ParentID` | none | 0 for a root layer. On models, the Geometry rows point at their work plane; this builds the Model Editor's sidebar tree. |
| `FinishID` | Finish | The color locked to this layer. **0 = Automatic**, meaning it inherits the finish from the job, room, assembly or part. A non-zero value locks the color to the material. |
| `FinishTypeID` | Finish Type | Foreign key to the finish type. **It must be 1, not 0,** on normal materials. |
| `TextureID` | Texture | The pattern. **1 = the blank (no-pattern) texture.** |
| `TextureMapID` | none | Texture mapping mode. 0 on everything CV created. |
| `ShapeID` | none | Foreign key to `Shape`. 0 on flat layers. On Geometry layers, the 3D mesh. On a Molding material's Face layer, **this is where the profile shape lives**. |
| `XPosition`, `YPosition`, `ZPosition` | Model Editor placement | **Formula strings, not numbers** (see 5.2). Empty on flat layers. |
| `XDimension`, `YDimension`, `ZDimension` | Model Editor size | Formula strings, the same as position. |
| `XRotation`, `YRotation`, `ZRotation` | Model Editor rotation | Degrees, or a formula. |

**The texture rule for CNC:** if Face and Back carry the same texture (or none), you are telling S2M the
material is two-sided and parts may be flipped. If the textures differ, S2M may not flip parts on that
material, and it tells the operator which named texture must face up on the nest.

### 2.4 `Shape`: the 3D meshes

| Column | Meaning |
|---|---|
| `ShapeTypeID` | 1 = 2D Operation, 2 = 2D Profile, 3 = 3D Model. All hardware geometry is type 3. |
| `Shape` | XML of the form `<Shape size="X Y Z"><IndexedFaceSet coordIndex="…" …>`: a vertex-indexed mesh. |

CV generates these itself when you create a hardware material, so they are not practical to author by
hand.

---

## Part 3: The 24 material types

Each section gives the type's own table, each column mapped to its window property, and its Layer
structure. Values marked "default" are what CV wrote for a new material of that type. All dimensions are
stored in **millimeters** (see 5.1); the inch equivalent is given where it is clean.

### [1] Panel Stock

Sheet goods. **Unit of Issue:** 5 (Sheet). **Tables:** `MaterialExtraSizeInfo`, `MaterialExtraCNCInfo`
and four flat layers.

`MaterialExtraSizeInfo` (Size group):

| Column | CV property | Default | Notes |
|---|---|---|---|
| `Width` | Width | 1219.2 (48 in) | Sheet width. |
| `Length` | Length | 2438.4 (96 in) | Sheet length. |
| `Thickness` | Thickness | 19.05 (3/4 in) | **The most important property of any material.** The whole cut list depends on it. |

`MaterialExtraCNCInfo`: see 3.CNC. **Layers:** Face, Back, Edge, End (Pattern A). CV gave Face and Back
`FinishID = 0` (Automatic) but gave Edge and End a fixed finish and texture, so the panel takes its color
from the job while the cut edges are pre-colored. **Models:** No. **Profile:** No.

### [2] Board Stock

Dimensional lumber and solid stock. **Unit of Issue:** 3 (SQ FT). **Tables:** `MaterialExtraBoardInfo`,
`MaterialExtraCNCInfo`, four flat layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Thickness` | Thickness | 12.7 (1/2 in) | The **finished** thickness; drives the cut list. |
| `RoughThickness` | Rough Thickness | 19.05 (3/4 in) | The **purchased** thickness, used for board-foot or board-meter calculations. **Only used when Unit of Issue is BD FT or BD M.** |

The help notes that naming a material `4/4 Oak` with a Thickness of 3/4 is cosmetic: the `4/4` in the
name has no effect. Rough Thickness is the field that drives material requirements. **Layers:** Face,
Back, Edge, End, all with a fixed finish and no textures. **Models:** No. **Profile:** No. `Optimize`
defaults to 1, though the help says it would be unusual to send board stock parts to the nester.

### [3] Laminate

**Unit of Issue:** 5 (Sheet). **Tables:** `MaterialExtraLaminateInfo`, `MaterialExtraSizeInfo`,
`MaterialExtraCNCInfo`, one flat layer.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Oversize` | Oversize | 12.7 (1/2 in) | The laminate is cut oversize by this amount so it can be trimmed flush after pressing. A 12 x 29 1/4 part with 1 in of oversize needs a 14 x 31 1/4 blank. |

`MaterialExtraSizeInfo` default: 1219.2 x 2438.4 x 1.5875 (48 x 96 x 1/16 in). **Layers:** Face only.
**Models:** No. **Profile:** No.

### [4] Banding

**Unit of Issue:** 2 (Per FT). **Tables:** `MaterialExtraBandingInfo` and one flat layer. **No CNC info
and no Size info.**

| Column | CV property | Default | What it does |
|---|---|---|---|
| `LengthTrim` | Length Trim | 12.7 (1/2 in) | Extra banding length per piece to cover feed-in and end-trim waste on the edgebander. |
| `Thickness` | Thickness | 0.5 (half a millimeter; the reference document also called it "about 1 mm") | The band thickness. |
| `NCBandingTag` | none | NULL | The banding code used on S2M labels and in the Import Cutlist banding flag. Lower-case letters are defined by S2M; upper-case letters come from the design package. |

**Banding has a thickness but no width.** The width is always the thickness of the part it is applied
to. The help's advice is to put the physical width in the name (for example "7/8 wide") for reference
only. Solid stock can legitimately be defined as banding when you need solid wood edges. **Layers:**
Face only. **Models:** No. **Profile:** No.

### [5] Hinge

**Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraHingeInfo` plus model layers (Pattern B).

| Column | CV property | Default | What it does |
|---|---|---|---|
| `HingeTypeID` | Type | 1 (Concealed) | Foreign key to `refHingeType`: 1 Concealed, 2 Exposed, 3 Double Door. |
| `SideOverlay` | Horizontal Overlay | 25.4 (1 in) | How much the door overlays the face frame at the top and bottom. **Face-frame cabinets only.** |
| `VerticalOverlay` | Vertical Overlay | 25.4 | The overlay at the left and right. Face-frame only. |
| `DoorEdgeToHinge` | Door End to Hinge | 37 | Distance from the door's top or bottom **end** to the hinge center. Sets the graphic reference point. |
| `Inset` | Inset | 0 | 0 puts the door proud of the frame by its own thickness. Positive values pull the door back into the frame or case; **negative values move it out.** |
| `MaxHingeSpacing` | Maximum Spacing | 609.6 (24 in) | Once hinges would be farther apart than this, CV adds another hinge to the door. |
| `OpeningAngle` | Opening Angle | 125 | Degrees. Used by the open-door animation. |
| `DoorEdgeToRefPt` | Door Edge To Reference Point | 20 | Distance from the door's **side** edge to the hinge center. Shifts the 3D model when placed. |
| `RollOutClearance` | Roll Out Clearance | 0 | If a roll-out lands at the same height as a hinge, CV spaces it by this amount. |

**Layers:** `Primary Work Plane`, then `_HGBASE` (the cup or base, 37 x 47 x 15 mm) and `_HGARM` (the arm,
15.2 x 16.9 x 62 mm). **The arm's position and rotation are driven by the door-open angle:** its X is
`DOPEN>0|-15.25mm*COS(DOPEN)|1|-15.25mm` and its Y rotation is `DOPEN` itself. That is how the hinge
animates when you open a door. **Models:** Yes. **Profile:** No. It also has an Operations tab
(system-generated boring).

### [6] Drawer Guide

The most property-rich hardware type, because it sizes the drawer box. **Unit of Issue:** 11 (Pair).
**Cost warning from the help: enter half the price of a pair**, because cost is per guide. **Tables:**
`MaterialExtraGuideInfo`, `MaterialExtraClearanceInfo` and model layers.

`MaterialExtraGuideInfo` (Guide group):

| Column | CV property | Default | What it does |
|---|---|---|---|
| `GuideTypeID` | Type | 1 (Side Mount) | Foreign key to `refGuideType`: 1 Side Mount, 2 Bottom Mount, 3 Top Mount, 4 System. **"Mount" is how it attaches to the cabinet, not the drawer**; a Blum Tandem is a Side Mount in CV. |
| `Height` | Height | 25.4 | Guide height. |
| `Depth` | Length | 400 | Guide length (the column is `Depth`, the window label is Length). |
| `Extension` | Extension | 457.2 (18 in) | The graphic limit of how far the box opens in the open-drawer animation. |
| `ScrewCenterRefTop` | Screw Center Reference to Top | 0 | If true, mounting bores reference the **top** of the drawer box; if false, the **bottom** (per the reference). **Jon confirmed in CV: false = the bottom of the guide.** |
| `ScrewCenterToBoxBottom` | Screw Center To Box Reference | 0 | Bore position from that reference. Helps set drawer box height when aligning to system boring. |
| `GuideHoleOffset` | none | 32 | Distance from the assembly face to the first hole. This is the graphic reference point. |
| `BackNotchLength` | Back Notch Length | 0 | A notch cut in the drawer back to clear the guide. |
| `BackNotchHeight` | Back Notch Height | 0 | |
| `BackNotchOffset` | Back Notch Offset | 0 | The horizontal position of the notch. |

`MaterialExtraClearanceInfo` (Clearance group). **This table is what actually sizes the drawer box:**

| Column | CV property | Default | What it does |
|---|---|---|---|
| `SideClearance` | Side Clearance | 8.5 (about 11/32 in) | Effectively the guide's thickness. **Doubled and subtracted from the opening width to give the drawer box width.** The help suggests 17/32 in instead of 1/2 in if you want play. |
| `MinBelowBox` | Minimum Below Box | 0.79375 (1/32 in) | The gap between the bottom of the box side (or the box bottom, whichever is lower) and whatever is beneath. |
| `MinAboveBox` | Minimum Above Box | 12.5 | The gap between the top of the box and whatever is above. With the drawer construction method, **this sets the drawer box height.** |

**Layers:** `Primary Work Plane`, then `_DGAMEM` (the cabinet member) and `_DGBMEM` (the box member). Both
positions use `_MIRROR` so one model serves left and right, and both size from `_M:DEPTH`, so changing
the Length property resizes the graphic. **Models:** Yes. **Profile:** No. Operations tab: yes.

### [7] Pull

**Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraPullInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `PullTypeID` | Type | 1 (Knob) | Foreign key to `refPullType`: 1 Knob, 2 Pull, 3 Cup. |
| `HorizontalInset` | Horizontal Inset | 38.1 (1 1/2 in) | Horizontal position of the pull's reference point on the door or drawer front. |
| `VerticalInset` | Vertical Inset | 50.8 (2 in) | Vertical position. |

**Layers:** `Primary Work Plane`, then `_PLSHAFT` (12.6 x 12.6 x 16.8 mm) and `_PLGRIP`
(38.1 x 38.1 x 8.4 mm), stacked: the grip sits at Z 17.018, just above the shaft's height of 16.764.
**Models:** Yes. **Profile:** No. Operations tab: yes.

### [8] Miscellaneous

The catch-all for pegs, accessories and anything without a dedicated type. **Unit of Issue:** 1 (Each).
**Tables:** `MaterialExtraMiscellaneousInfo`, plus four flat layers **or** model layers depending on one
flag.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Thickness` | Thickness | 19.05 | The material thickness. |
| `HasModel` | Model | 0 | **The switch.** Set true and CV lets you build a 3D model in the Model Editor and turns on the Load Model row in the Material group. |

This is the only type where model support is a per-material choice, not a property of the type.
**Layers:** Face, Back, Edge, End when `HasModel = 0`; Plane and Geometry layers are added when
`HasModel = 1`. **Models:** conditional. **Profile:** No.

### [9] Counter Top

Not part of the wizard batch; read from existing production rows. **Unit of Issue:** 1 (Each).
**Tables:** `MaterialExtraCounterTopInfo`, `MaterialExtraSizeInfo` and four flat layers.

| Column | CV property | What it does | Status |
|---|---|---|---|
| `CostPerButtJoint` | Cost Per Butt Joint | A charge per butt joint. | [inferred] |
| `CostPerMiterJoint` | Cost Per Miter Joint | A charge per mitered joint. | [inferred] |
| `CostPerCutout` | Cost Per Cutout | A charge per sink or cooktop cutout. | [inferred] |
| `CostPerEndCap` | Cost Per End Cap | A charge per end cap. | [inferred] |
| `CostPerEndSplash` | Cost Per End Splash | A charge per end splash. | [inferred] |
| `ScribeTrim` | Scribe Trim | An extra length allowance for scribing to a wall. | [inferred] |

The labels are inferred from the column names because this type has no help page. All six were 0 on
every production row. The size info carries the top's dimensions, for example 406.4 x 2438.4 x 19.05
(16 in deep, 8 ft, 3/4 in). **Models:** No. **Profile:** No.

### [10] Molding

**Scoping note from the help:** this type is for **bought molding sold by SKU** (for example, Crown 123
in Oak, 10 ft, is SKU C123OAK10). **Molding you make yourself should be defined in the Molding Manager
with a plain Board Stock material assigned.** **Unit of Issue:** 2 (Per FT). **Tables:**
`MaterialExtraMoldingInfo` and one flat layer.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `ProfileTypeID` | Type | 1 (Crown) | Foreign key to `refProfileType`: Crown, Top Edging, Light Rail, Scribe, Base Board, Chair Rail, Casing, Applied, Ceiling, Bead, Outside Edge, Inside Edge, Raised Panel, Door Route, Finger Pull, Door Applied (numbered 1 to 16 in that order). |
| `Length` | Length | 2438.4 (8 ft) | The stick length you buy. |
| `CostPerJoint` | Cost Per Joint | 0 | What you charge per joint. |
| `MiterTrim` | Miter Trim | 0 | Length compensation at each miter. |

CV optimizes molding use across the lengths available in a job, so the help strongly recommends setting
up **aliases** for every length you stock. **Layers:** Face only. **This layer's `ShapeID` is where the
profile lives**; it is 0 until you use the Profile button to import a shape from the Molding Manager.
**Models:** No. **Profile:** Yes (Import, then Profile, pulls a shape from the Molding Manager library).

### [11] Wire Basket

**Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraBasketInfo` plus model layers (the most complex
model CV built: seven layers).

| Column | CV property | Default | What it does |
|---|---|---|---|
| `BasketTypeID` | Type | 1 (Side Mount) | Foreign key to `refBasketType`: 1 Side Mount, 2 Bottom Mount, 3 Top Mount, 4 No Mount. |
| `Depth` | Depth | 355.6 (14 in) | |
| `Width` | Width | 457.2 (18 in) | |
| `Height` | Height | 152.4 (6 in) | |
| `FirstHoleOffset` | First Hole Offset | 32 | Distance from the face to the first bore. |

**Layers:** `Primary Work Plane`, then a nested second plane `_WBFARWP` (mirrored 180 degrees at
`_M:WIDTH`), plus `_WBSM` (the basket, sized entirely from `_M:DEPTH`, `_M:DZ` and `_M:WIDTH`) and two
mount members per side. It is the clearest example of a model that resizes itself from its own property
values. **Models:** Yes. **Profile:** No. Operations tab: yes.

### [12] Rod

Closet rod. **Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraRodInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Length` | Length | 914.4 (36 in) | The rod length. |

**Layers:** `Primary Work Plane`, then `_HRROD` (22 mm diameter) and a far work plane `_HRFARWP`. The rod's
Z dimension is `_OPENINGDX>0|_OPENINGDX|1|914.4mm`: **it spans the actual opening width when placed and
falls back to 36 in when there is no opening.** **Models:** Yes. **Profile:** No. Operations tab: yes.

### [13] Sliding Door Rail

**Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraSlidingDoorRailInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Length` | Length | 914.4 (36 in) | The rail length. |

**Layers:** `Primary Work Plane`, then `_RARAIL`, a 19.05 x 19.05 mm section whose length is
`_OPENINGDX` with the same fallback as the rod. **Models:** Yes. **Profile:** No. Operations tab: yes.

### [14] Hinge Plate

The mounting plate a concealed hinge clips onto. **Unit of Issue:** 1 (Each). **Tables:**
`MaterialExtraHingePlateInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `HingePlateTypeID` | Type | 2 (Frame) | Foreign key to `refHingePlateType`: 1 Panel, 2 Frame, 3 Inline. |
| `PlateHoleOffset` | Plate Hole Offset | 37 | Distance from the front of the case to the center of the primary mounting holes. Shifts the graphic; the holes should sit at the graphic reference point. |

**Layers:** `Primary Work Plane`, then `_HPFRAME` (56.8 x 50 x 10 mm). **Models:** Yes. **Profile:** No.
Operations tab: yes.

### [15] Sliding Door Roller

**Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraSlidingDoorRollerInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `RollerTypeID` | Type | 1 (Roller) | Foreign key to `refSlidingDoorRollerType`: 1 Roller, 2 Slot. |
| `DoorEdgeInset` | Door Edge Inset | 50.8 (2 in) | Mounting plate position from the door edge. |
| `DoorEndInset` | Door End Inset | 76.2 (3 in) | Mounting plate position from the door end. |
| `MountOnBack` | Mount On Back | 1 | Whether the roller mounts to the back of the door. |
| `DoorDadoRefID` | Slot Reference | 1 (Center) | Foreign key to `refSlidingDoorDadoRef`: 1 Center, 2 Back, 3 Front. |
| `DoorDadoOffset` | Slot Offset | 0 | Offset from that reference. |

**Layers:** `Primary Work Plane`, then `_ROROLLER`. Its position and rotation branch on
`_M:MNTPLTONBACK`, so the same model re-orients itself depending on the Mount On Back setting.
**Models:** Yes. **Profile:** No. Operations tab: yes.

### [16] Leg

**Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraLegInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Height` | Height | 101.6 (4 in) | **Used to determine the assembly's elevation** when the leg is applied, not just a graphic. |

**Layers:** `Primary Work Plane`, then `_LGBF`, a 76.2 x 76.2 mm footprint whose height is driven by
`_M:HEIGHT`. **Models:** Yes. **Profile:** No.

### [17] Leg Leveler

**Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraLegLevelerInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Height` | Height | 101.6 | The same role as Leg: sets the assembly elevation. |

**Layers:** `Primary Work Plane`, then `_LLAF` (the adjustable foot) and `_LLMP` (the mounting post). The
foot's Z position is `:Y>0|:Y-_M:HEIGHT+25.4mm|1|25.4mm`, so it repositions relative to the assembly it
is under. **Models:** Yes. **Profile:** No.

### [18] Caster

**Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraCasterInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Height` | Height | 101.6 | Sets the assembly elevation. |

**Layers:** `Primary Work Plane`, then `_CSAXLE`, `_CSPIVOT`, `_CSBASE` and `_CSWHEEL`. **Every position
and dimension is a multiple of `_M:HEIGHT`** (for example the wheel dimension is
`_M:HEIGHT * 0.856153`), so changing the Height property scales the whole caster proportionally. It is
the best example in the schema of a fully parametric model. **Models:** Yes. **Profile:** No.

### [19] Composite

A material built by stacking other materials (for example laminate over a substrate). **Unit of Issue:**
1 (Each). **Tables:** `MaterialExtraCompositeInfo`, `MaterialExtraSizeInfo`, `MaterialExtraCNCInfo` and
`MaterialCompositeMap`. **There are no Layer rows at all:** appearance comes from the member materials.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `PreAssembled` | Pre-Assembled | 0 | Whether the composite is assembled **before** cutting and machining. If false, each member material is cut and machined separately. |

`MaterialExtraSizeInfo` is present but **read-only in CV**: Width, Length and Thickness are calculated
from the member materials. CV wrote 1219.2 x 2438.4 x 19.05 as a starting point.

`MaterialCompositeMap` holds the stack, one row per member:

| Column | What it does |
|---|---|
| `CompositeMaterialID` | The composite itself. |
| `MaterialID` | The member material. |
| `StackOrder` | The position in the stack, from 0 up. |
| `FaceUp` | Which way the member faces. |
| `Oversize` | A per-member oversize; production rows use 25.4 (1 in) on the laminate layer and 0 on the substrate. |

**Models:** No. **Profile:** No. **Aliases:** not supported.

### [20] Molding Set

**The one type with no Extra-Info table and no Layer rows.** CV wrote only the `Material` row and the
group entry. A molding set has no geometry of its own; it is purely an arrangement of other moldings.
**Unit of Issue:** 1 (Each). **Table:** `MaterialMoldingSetMap`.

| Column | What it does |
|---|---|
| `MoldingSetMaterialID` | The set. |
| `MaterialID` | A member Molding material. |
| `XPosition`, `YPosition` | Where that molding sits in the stacked assembly. |
| `Rotation` | Its rotation. |
| `Mirror` | Whether it is mirrored. |

**Models:** No. **Profile:** Yes, but the shapes themselves cannot be edited there. The Profile tab opens
and lets you import several existing moldings into the set and position, rotate and mirror each one.
Editing a profile shape happens on the Molding material or in the Molding Manager (confirmed in the
window). **Aliases:** not supported.

### [21] Connector

Knock-down fasteners such as Lamello, Cabineo, Rafix and Lockdowel. **Unit of Issue:** 1 (Each).
**Tables:** `MaterialExtraConnectorInfo` plus model layers (plus `MaterialParameter` rows on most
production connectors).

| Column | CV property | Default | What it does |
|---|---|---|---|
| `ConnectorTypeID` | Type | 1 (Rafix) | Foreign key to `refConnectorType` (21 values, listed in Part 4). |

Type selection has real machining consequences (from the help):
- **Clamex P-10, P-14, P Medius 14-10, Tenso P-10 and P-14** need a 4 1/2-axis machine with Lamello's
  Clamex saw.
- **FastenLink** needs a shaped tool in the S2M Tool Catalog.
- **"Connector"** (value 6) is the generic one. It ships with **no model** so you can build a custom
  connector in the Model Editor.

**Layers:** `Primary Work Plane`, then `_CNRFCAM` (the cam, 22 x 14 x 21 mm) and `_CNRFBOLT` (the bolt,
5 x 5 x 12.7 mm), plus a secondary work plane `_CNALTWP` rotated -90 degrees, so the connector's two
halves land on perpendicular faces. **Models:** Yes. **Profile:** No. **Aliases:** not supported.

### [22] Shadowline Channel

**Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraShadowlineChannelInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Length` | Length | 914.4 (36 in) | The channel length. |

A lookup `refShadowlineChannel` exists (1 L-Channel, 2 C-Channel, 3 J-Channel), but **the Info table has
no type column**, so CV wrote only the length. Where that selection is stored, if it is exposed at all,
is **[unverified]**. **Layers:** `Primary Work Plane`, then `_SHRAIL`, a 38.1 x 63.5 mm section whose
length is `_OPENINGDX` with a 36 in fallback. **Models:** Yes. **Profile:** No.

### [23] Finger Pull

An integrated pull rail, used instead of hardware pulls. **Unit of Issue:** 1 (Each). **Tables:**
`MaterialExtraFingerPullInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Length` | Length | 762 (30 in) | The rail length. |
| `EdgeTrim` | Edge Trim | 19.05 (3/4 in) | The amount removed from the door edge where the finger pull is applied, per the help's Finger Pull page. (The reference document this file was built from guessed it was an end allowance on the rail; the help says otherwise.) |

The help lists three finger pull types (C-Rail, Flat-Rail, U-Rail), but `refFingerPullType` contains only
**1 = C-Rail** and the Info table has no type column, so the other two appear to be undelivered in this
build. **Layers:** `Primary Work Plane`, then `_FPRAIL`, a 19.05 x 19.05 mm section whose length is
`_EDGLEN>0|_EDGLEN|1|712mm`, so it spans the edge it is applied to. **Models:** Yes. **Profile:** No.

### [24] Shadowline Bracket

**Unit of Issue:** 1 (Each). **Tables:** `MaterialExtraShadowlineBracketInfo` plus model layers.

| Column | CV property | Default | What it does |
|---|---|---|---|
| `BracketHoleOffset` | **Inset** (the label in Material Properties; confirmed on Jon's material, shown as 1 15/32 = 37 mm) | 37 | Distance from the case front to the bracket's mounting hole center, mirroring `PlateHoleOffset` on hinge plates **[the "case front" meaning is still inferred; the preview shows it measured to the top hole]**. Operations tab fields: hole Diameter 3/16, Depth 15/32, Spacing 1 1/4 (not yet mapped to columns). |

**Layers:** `Primary Work Plane`, then `_SHMB` (25.4 x 42.667 x 25.4 mm). **Models:** Yes. **Profile:** No.

### 3.CNC: `MaterialExtraCNCInfo` (shared by Panel Stock, Board Stock, Laminate and Composite)

| Column | CV property | Default | What it does |
|---|---|---|---|
| `Optimize` | Optimize | 1 | **Whether the material is sent to the Optimizer/Nester at all.** Together with a valid sheet size, this decides S2M output. Materials that should not reach S2M have `Optimize = 0`. |
| `GrainDependent` | Grain Dependent | 1 | Whether parts may be rotated on the sheet. On means the grain runs one way and parts cannot be turned. |
| `DropWidth` | Drop Width | 0 | The minimum width for a remnant to count as a reusable offcut rather than scrap. |
| `DropLength` | Drop Length | 0 | The same for length. |
| `FeedRatePercent` | Feed Rate Percent | 100 | Percent of the tool's optimum feed rate for this material. |
| `SpindleSpeedPercent` | Spindle Speed Percent | 100 | Percent of optimum spindle RPM. |
| `MinimizeFaceChip` | Minimize Face Chip | 1 | Tells S2M's automatic tool selection to prefer a **down-shear** bit. |
| `MinimizeBackChip` | Minimize Back Chip | 1 | Prefer an **up-shear** bit. **With both on, S2M selects a compression bit.** |
| `ClimbCut` | Climb Cut | 0 | Cut this material climb rather than conventional. |
| `MaxDepthPerPass` | Maximum Depth Per Pass | 0 | Depth limit per pass. CV uses the smaller of the material's and the tool's value. |

---

## Part 4: Lookup tables

```
refMaterialType     1 Panel Stock · 2 Board Stock · 3 Laminate · 4 Banding · 5 Hinge · 6 Drawer Guide ·
                    7 Pull · 8 Miscellaneous · 9 Counter Top · 10 Molding · 11 Wire Basket · 12 Rod ·
                    13 Sliding Door Rail · 14 Hinge Plate · 15 Sliding Door Roller · 16 Leg ·
                    17 Leg Leveler · 18 Caster · 19 Composite · 20 Molding Set · 21 Connector ·
                    22 Shadowline Channel · 23 Finger Pull · 24 Shadowline Bracket

refUnitOfIssue      1 Each · 2 Per FT · 3 SQ FT · 4 BD FT · 5 Sheet · 6 Per M · 7 SQ M · 8 BD M ·
                    9 Cubic M · 10 Cubic FT · 11 Pair

refLayerType        1 Face · 2 Back · 3 Edge · 4 End · 5 Geometry · 6 Plane
refShapeType        1 2D Operation · 2 2D Profile · 3 3D Model
refWorkPlaneType    1 Face · 2 Back · 3 Left · 4 Right · 5 Top · 6 Bottom
refUnitOfMeasure    1 Inches · 2 Millimeters · 3 Meters · 4 Feet

refProfileType      1 Crown · 2 Top Edging · 3 Light Rail · 4 Scribe · 5 Base Board · 6 Chair Rail ·
                    7 Casing · 8 Applied · 9 Ceiling · 10 Bead · 11 Outside Edge · 12 Inside Edge ·
                    13 Raised Panel · 14 Door Route · 15 Finger Pull · 16 Door Applied

refHingeType        1 Concealed · 2 Exposed · 3 Double Door
refHingePlateType   1 Panel · 2 Frame · 3 Inline
refGuideType        1 Side Mount · 2 Bottom Mount · 3 Top Mount · 4 System
refPullType         1 Knob · 2 Pull · 3 Cup
refBasketType       1 Side Mount · 2 Bottom Mount · 3 Top Mount · 4 No Mount
refFingerPullType   1 C-Rail          (the help lists Flat-Rail and U-Rail; not in this build)
refShadowlineChannel 1 L-Channel · 2 C-Channel · 3 J-Channel   (not referenced by the Info table)
refSlidingDoorRollerType  1 Roller · 2 Slot
refSlidingDoorDadoRef     1 Center · 2 Back · 3 Front

refConnectorType    1 Rafix · 2 Clamex P-10 · 3 Clamex P-15 · 4 Clamex P Medius 15/10 · 5 Tenso P-14 ·
                    6 Connector (generic, no model) · 7 Lockdowel · 8 FastenLink · 9 Clamex P Medius 14-10 ·
                    10 Clamex P-14 · 11 Cabineo 8 · 12 Cabineo 12 · 13 Divario P-18 · 14 Tenso P-10 ·
                    15 Peanut 1 · 16 Peanut 2 · 17 Clamex S-20 · 18 Cabineo X · 19 Lockdowel Spring Pin ·
                    20 Lockdowel H-Clip · 21 Lockdowel Channel Lock
```

---

## Part 5: Conventions and gotchas

### 5.1 Units are millimeters, always

Every dimension in CVData is stored in **millimeters**, whatever CV displays.

| Imperial | Stored |
|---|---|
| 1/32 in | 0.79375 |
| 1/16 in | 1.5875 |
| 1/2 in | 12.7 |
| 5/8 in | 15.875 |
| 3/4 in | 19.05 |
| 13/16 in | 20.6375 |
| 1 in | 25.4 |
| 4 ft | 1219.2 |
| 8 ft | 2438.4 |

Floating-point noise is normal and harmless: CV wrote `37.00000000036` for a 37 mm offset and
`0.50000000076` for a half-millimeter banding thickness.

### 5.2 Layer positions are formula strings, not numbers

The nine position, dimension and rotation columns on `Layer` are `nvarchar(max)` and hold CV expressions.
Tokens seen:

| Token | Meaning |
|---|---|
| `_M:HEIGHT`, `_M:DEPTH`, `_M:WIDTH` | This material's own property values, from its Extra-Info table |
| `_M:SC`, `_M:MH1P`, `_M:MNTPLTONBACK`, `_M:MNTPLTPOSTOP` | Other derived material properties |
| `:DX`, `:DY`, `:DZ` | The material's own bounding dimensions |
| `::DZ` | The **parent** assembly's dimension (a double colon is one level up) |
| `DOPEN` | The door or drawer open angle; drives the open-door animation |
| `_MIRROR` | True on the mirrored instance, so one model serves left and right |
| `_OPENINGDX` | The width of the opening the part is placed into |
| `_EDGLEN` | The length of the edge the part is applied to |

**Conditionals use the legacy UCS chain syntax** `test|value|test|value`, where a bare `1` is the
always-true else branch:

```
_OPENINGDX>0|_OPENINGDX|1|914.4mm
    if the opening width is known, span it; otherwise default to 36 in

_MIRROR & DOPEN|_M:MH1P+DOPEN|_MIRROR|_M:MH1P|DOPEN|-_M:MH1P-DOPEN|1|-_M:MH1P
    a four-branch chain: mirrored and open, mirrored, open, else
```

The Primary Work Plane is always positioned at `(:DX/2, :DY/2, :DZ)`: centered in X and Y, at the top in Z.
These are the same expressions used in UCS:M, so the rules in `UCS.md` (tree paths with `:`, `_M:` reads)
apply.

### 5.3 `MenuID` must be 1

`MaterialMenuTreeItem.MenuID` defaults to 0, and a material with `MenuID = 0` is **silently invisible** in
the Material Manager even with a correct group. Hand-written inserts that leave the column out produce
materials that exist in SQL and cannot be found in CV.

### 5.4 "S2M Material" is not an output gate

`Material.NcInventory`, shown as **S2M Material**, only controls whether the material appears in **S2M
CENTER's own Material Catalog** (Utilities, Material Catalog, populated through "Show Materials from CV").
It is used for S2M-side per-material overrides, for adding a material by hand to a job's Material List,
and for stand-alone work such as Import Cutlist.

What decides whether parts actually output to S2M is `MaterialExtraCNCInfo.Optimize` plus a valid sheet
size. Many panel materials output correctly with `NcInventory = 0`. Leave it false unless you want the
material listed in S2M's catalog.

### 5.5 Board Stock vs Panel Stock

`MaterialTypeID` decides which size table CV reads. Board Stock reads `MaterialExtraBoardInfo`; Panel
Stock reads `MaterialExtraSizeInfo`. **Getting this wrong produces "missing board info" in jobs even when
the size rows exist.** MDF and engineered sheets are Panel Stock at every thickness; only solid species
belong in Board Stock.

### 5.6 Deleting

CV never physically deletes a material. It renames the row `{d}<name>(n)`, sets `Deleted = 1` and drops
the `MaterialMenuTreeItem`.

---

## Part 6: Creating materials by SQL

### 6.1 The schema will not protect you

Across all 30 material-keyed tables there is **exactly one** NOT NULL column without a default:
`Material.rGUID`. Everything else is defaulted, so SQL will accept a material of any type with almost no
values supplied, and the result can be structurally valid but wrong in CV. The database cannot tell you
whether a material is correct.

### 6.2 Clone, do not author

Because of 6.1, the reliable pattern is to **copy a known-good CV-authored row of the same type** and
change only what differs, rather than composing an INSERT from the column list. The best source is a clean,
unedited material of the same type created by CV's own New Material wizard. Material IDs differ from
system to system, so look the source row up by name each time and never hard-code an ID.

### 6.3 What is and is not proven

| | Status |
|---|---|
| Panel Stock, Board Stock | Creation by SQL is **proven** and in production use (the four-table rule, millimeter units, the rough-thickness snap). |
| Banding, Laminate, Counter Top, Molding, Composite, flat Miscellaneous | Structurally simple and clonable, but **not yet verified end to end in CV.** |
| All the model-bearing hardware types | Clonable, but they need a `Shape` row of 3D mesh XML, which is not practical to author. CV's wizard generates it and supplies a sensible default model, so **creating these in CV is faster than by SQL.** |
| Molding Set | No geometry to build; only member rows in `MaterialMoldingSetMap`. |

Some existing materials have no Extra-Info row of their type (for example banding without
`MaterialExtraBandingInfo`). Whether that row is truly optional or those materials are quietly broken is
**[unverified]**.

### 6.4 Insert order

1. `Material`: supply `rGUID` (a fresh GUID), `Name`, `MaterialTypeID` and `UnitOfIssueID`.
2. `MaterialExtra<Type>Info`: one row, with `MaterialID` and the type's properties.
3. `MaterialExtraCNCInfo`, `MaterialExtraSizeInfo` or `MaterialExtraBoardInfo` where the type uses them.
4. `Layer`: the flat set or the model tree.
5. `MaterialMenuTreeItem`: **with `MenuID = 1`.**

`OUTPUT INSERTED` and `SCOPE_IDENTITY()` are unreliable on these tables because of triggers. Insert one
row at a time and get the new ID with `SELECT ID FROM Material WHERE Name = @name`.

### 6.5 Pre-flight checklist (run before any creation script)

The schema in this file is a written description, so confirm it against the live database first. Every
query below is read-only. If any result differs from what this file says, stop and compare before
writing anything.

1. **Confirm the CV version** (CV 2025 is what this file was built from). A different version can add or
   rename columns.
2. **Confirm the columns.** The material tables should match Parts 2 and 3.
   ```sql
   SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_NAME IN ('Material','MaterialMenuTreeItem','Layer','Shape',
                        'MaterialCompositeMap','MaterialMoldingSetMap')
      OR TABLE_NAME LIKE 'MaterialExtra%'
   ORDER BY TABLE_NAME, ORDINAL_POSITION;
   ```
3. **Confirm the no-default rule.** This file says `Material.rGUID` is the only NOT NULL column with no
   default. Identity columns are excluded here because SQL fills them in.
   ```sql
   SELECT TABLE_NAME, COLUMN_NAME
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE IS_NULLABLE = 'NO' AND COLUMN_DEFAULT IS NULL
     AND COLUMNPROPERTY(OBJECT_ID(TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 0
     AND (TABLE_NAME IN ('Material','MaterialMenuTreeItem','Layer','Shape',
                         'MaterialCompositeMap','MaterialMoldingSetMap')
          OR TABLE_NAME LIKE 'MaterialExtra%');
   ```
   Expect `Material.rGUID`. Any other NOT NULL column with no default is a value the script must supply.
4. **Confirm the lookup tables** in Part 4 still hold the same IDs and names (`refMaterialType`,
   `refUnitOfIssue`, `refLayerType`, `refShapeType`, `refWorkPlaneType`, `refUnitOfMeasure`,
   `refProfileType`, `refHingeType`, `refHingePlateType`, `refGuideType`, `refPullType`,
   `refBasketType`, `refFingerPullType`, `refShadowlineChannel`, `refSlidingDoorRollerType`,
   `refSlidingDoorDadoRef`, `refConnectorType`).
   ```sql
   SELECT * FROM refMaterialType ORDER BY ID;   -- repeat for each lookup table
   ```
5. **Confirm the triggers** that make `OUTPUT INSERTED` and `SCOPE_IDENTITY()` unreliable, so the
   one-row-at-a-time rule is still needed.
   ```sql
   SELECT t.name AS TriggerName, OBJECT_NAME(t.parent_id) AS TableName
   FROM sys.triggers t
   WHERE OBJECT_NAME(t.parent_id) IN ('Material','Layer','Shape','MaterialMenuTreeItem')
      OR OBJECT_NAME(t.parent_id) LIKE 'MaterialExtra%';
   ```
6. **Find the clone source for each type.** Look up a clean, unedited, wizard-created material of that
   type by name, and never reuse an ID from another system.
   ```sql
   SELECT ID, Name, MaterialTypeID FROM Material
   WHERE MaterialTypeID = @TypeID AND Deleted = 0 AND System = 0;
   ```
7. **Find the target group.** Look up the `MenuTreeID` of the group the new materials should land in
   (`SELECT * FROM MaterialMenuTree`), and remember `MenuID` must be 1.
8. **Do one dry run before the batch.** Create a single material of one type with the script, then in
   the Material Manager check that it appears in the right group, opens in Properties, shows the
   type's fields with the right values, and has the right buttons enabled (Model only on model
   types). Compare its rows column by column against the wizard-made source. Delete it in CV, not in
   SQL, so CV's own soft-delete runs.
9. **Protect the data.** Take a backup, or run the dry run inside a transaction that you roll back
   first, before any batch insert. (This is standard practice, not something from the reference.)

Only after all nine checks pass should the batch script run.
