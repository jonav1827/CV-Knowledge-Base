# CVJ File Format

What is inside a Cabinet Vision job file (`.cvj`) and how it is stored. Built by reading a CV 2025
job byte by byte with `Tools/cvj.ps1`; nothing here comes from Hexagon documentation. A job file is a
copy of the job itself plus a copy of every CVData object the job uses (material schedules,
materials, construction schedules, connections, door styles), so reading one shows how those
database objects relate without opening the database.

**What counts as verified here.** An entry is in this file only if it was confirmed one of three
ways: by the file's own counts (for example, every object stores how many parameters it has, and the
decoded parameters matched on every object), by matching the CVData tables described in
`CVData Materials & SQL.md`, or by Jon in Cabinet Vision. Anything still being worked out is kept
out of this file until it is confirmed. Entries that have only been seen in one job are marked
**[one job]**.

**Not covered.** Example values from any real job. This file records what each field is, not what a
shop set it to.

---

## 1. The container

A `.cvj` is a Microsoft compound file (the same container as a pre-2007 `.doc`): a small file system
of named streams. There are no sub-folders inside it.

| Stream | What it holds |
|---|---|
| `Contents` | The job: job defaults, rooms, walls, cabinets, parts, connections. |
| `Materials` | Every material schedule the job uses, the materials they point to, plus finishes, finish types, textures and moulding profiles. |
| `Construction` | The construction schedules the job uses, their conditions, and the connections. |
| `Doors` | Door settings, door styles and the door association table. |
| `Catalogs` | The catalogs the job references. |
| `Lights` | Light schedules for rendering. |
| `Header` | A ZIP archive holding one encrypted file, `Cache.xml`. Not readable. |
| `DrawManager` | The list of drawing scenes and sheets. |
| `Scene<ID>` | One stream per drawing scene, named with the scene's ID. The title block scene holds its logo as an uncompressed bitmap, which can make it by far the largest stream in the file. |
| `Sheet<ID>` | One stream per drawing sheet. |
| `Version` | Three numbers: the CV year, a release number and a build number. |
| `Shapes`, `Materials.map`, `Construction.map` | Small streams; purpose not yet confirmed. |

**Practical point:** a large title block image is stored uncompressed in every job made from that
title block. **[one job]**

### What an empty job contains

Comparing a job with nothing drawn against the same job with a wall and cabinets shows what a job
carries by default and what is added on demand. **[one pair of jobs]**

| Carried by every job, even empty | Added only when something uses it |
|---|---|
| The job object with its defaults and ID pointers | Walls, cabinets, parts |
| One room, with the room-level prompts | A second drawing scene. A bare wall does not create it; it appears once assemblies are placed. |
| Every material schedule the job defaults point to, with their materials, finishes and textures | A material schedule that only an assembly points to, with its materials and textures |
| The construction schedules the job defaults point to (case, drawer, roll-out, top) | A construction schedule that only an assembly points to |
| Door settings and the default door style | **Connections.** An empty job stores none. Each connection is copied in when a part first uses it. |
| Catalogs, light schedules, the title block scene, the sheet | |

So a job file never holds the whole database, only the rows this job needs. A connection or
schedule that no part in the job uses will not be found in the file even though the job's
construction schedule refers to it by ID.

**Where the defaults come from.** No job starts empty. Certain properties are stored as System
Defaults; they come in already selected when a new job is created, and the user can override them
from there. The job-level parameters and room prompts in a newly created job are those defaults.

### What a save changes by itself

Cabinet Vision keeps the previous version of the job as `<name>.bak` beside the `.cvj` when it
saves. Comparing the two after a save with no changes shows what saving alone alters.
**[one pair of files]**

| Stream | Effect of a no-change save |
|---|---|
| `Contents` | None. Any difference here is a real change to the job. |
| `Header` | Rewritten completely; the cache is re-encrypted on every save. |
| `Materials` | Same content, but the part rows inside each schedule are written in a different order. Compare it as a set of rows, not position by position. |
| `Construction` | A counter on the construction shape goes up by one, and shape coordinates can drift in the last decimal place. |
| `Doors` | One field in each door association row changes. |
| The rest | None. |

## 2. How objects are written

Everything inside a stream is written the same way.

| Element | How it is stored |
|---|---|
| Object type, first use | `FF FF`, a 2-byte schema number, a 2-byte name length, then the type name in ASCII (`CVCabinet`, `CVParameter`, `CVMatPart` and so on). |
| Object type, later uses | A 2-byte reference with the high bit set. |
| Version tag | Two bytes in front of most blocks of fields: a version number and a marker byte (`E9` or `CF`). |
| Text | `FF FE FF`, a 1-byte length (or `FF` and a 2-byte length), then UTF-16 text. |
| Numbers | Little-endian. Lengths are 8-byte floating point. |
| Named object | `01 CF`, a 4-byte ID, a text name, a text description. |

**Units.** Lengths in the job file are in inches in an imperial job **[one job]**. CVData stores the
same values in millimetres (see `CVData Materials & SQL.md` 5.1), so a 35 mm bore reads as 1.378
in the job file.

**IDs.** Objects copied from CVData keep their CVData `ID`. Objects created in the job (cabinets,
door parts, scenes) take IDs from one counter shared by the whole job.

## 3. Parameters

A parameter is stored as: name, description, a formula count, flags, a type, the value, any
formulas, and the choice list for a prompt.

| Type code | Kind | Stored as |
|---|---|---|
| 1 | Measurement | 8-byte number |
| 2 | Angle, in degrees | 8-byte number |
| 4 | Integer | 4-byte number |
| 5 | Yes/No | 4-byte number |
| 6 | Decimal | 8-byte number |
| 8 | Text | Text |

- **Description** is the prompt text shown to the user. It is empty on system parameters.
- **Formulas.** A parameter can carry one or more formulas, each a condition and an expression. A
  leading `:` in an expression reads the parent's value, the same as in UCS (see `UCS.md`).
- **Choice list.** A prompt with a list stores it as one text value: `<lst>` followed by
  `label = value` pairs separated by ` | `.
- **Flags** are a 16-bit set. The individual bits are not yet confirmed.

Every object stores its parameter count, and the count matched the decoded parameters on every
object in the test job. That check is what confirms the record layout.

The type codes were checked against the System Parameters reference in the CV 2025 help
(`Reference/Help`): of the parameter names in the test job that the help documents, the ones the
help calls Measurement were stored as type 1, Degrees as 2, Integer or Database ID as 4, Boolean as
5 and Decimal or Percentage as 6, with a handful of exceptions (cabinet-level rotations are stored
as type 1). The help does not document the `_MS…`, `_CS…` and `_DP…` pointer parameters at all.

## 4. The job tree (`Contents`)

Each object stores how many children it has, which gives the real parent/child tree:

```
Job
  Room
    Wall
      Wall face
        Cabinet (or other assembly)
          Case        -> parts, each with its connections
          Interior    -> case opening
          Face        -> face opening, drawer openings, door openings, rails
            Drawer opening -> drawer box (-> front, box parts), guides
            Door opening   -> door (-> hinges, door parts), hinge plates
```

| Level | What it stores |
|---|---|
| Job | The job defaults: standard heights and depths, and one ID pointer for each material schedule, construction schedule, door setting, finish and profile the job uses (section 5). |
| Room | The room-level prompts. |
| Wall | Position (`X`, `Y`, `Z`), length (`DX`), height (`DY`), thickness (`DZ`), rotation, vault height and position, and the angle from the previous wall. Height and thickness start from the job's wall height and wall thickness defaults. Adding a wall adds exactly three objects: the wall, its front face and its back face. The back face stores its own position (offset by the wall's length and thickness) and a 180 degree rotation; the front face stores nothing until something is placed on it. |
| Cabinet | Size, position, end types, cabinet number, and every cabinet-level prompt with its current answer. Any job default can be overridden here with a parameter of the same name. |
| Part | `PID` (part ID), position (`X`, `Y`, `Z`), size (`DX`, `DY`, `DZ`), rotation (`AX`, `AY`, `AZ`) and edge offsets. A banded part also has `BAND`, a text value with one banding tag letter per edge (`N` for none), and a banding record after its parameters holding the band thickness and the banded lengths. |
| Connection | A child of the part it is cut into. Stores which edge (`_EDGWP`), its size and position, and `_CONNID`, the ID of the connection in the `Construction` stream. |

**A cabinet with no UCS acting on it** is three sections, Case, Interior and Face, and a short list
of system parameters: size, position, rotation, end types (`LEND`, `REND`), what is beside it
(`LADJ`, `RADJ`), cabinet number, construction style and label position. Everything beyond that on
a cabinet in a working shop's job (prompts, extra sub-assemblies, flags) was put there by that
shop's UCSs. Comparing the same cabinet with the shop's UCSs on and off is the quickest way to see
what they add. **[one pair of jobs]**

**Room prompts are UCS-made too.** With the UCSs off, a room stores only its room number.

**Not every part you see in Cabinet Vision is in the job file.** Cabinet Vision rebuilds an assembly
from its construction method and material schedules (see "Understanding an Override" in the CV
help), so parts it can regenerate do not have to be saved. In the test job, the Object Tree showed a
default base cabinet with a back, two finished ends and four face frame parts as well as its sub
ends, top and deck; the job file held only the sub ends, top and deck, and the names of the other
parts did not occur anywhere in the file. Viewing the assembly and saving again did not add them.
Which parts are saved and which are left to the rebuild is not yet pinned down. **[one job]**

**A change to a rebuilt part is saved as a parameter on the assembly.** Changing the back of that
cabinet added one parameter to the cabinet, `BKTYPE` (the back type), and nothing else; the back
still was not saved as a part. So for parts the rebuild creates, the job file records the
instruction that steers the rebuild, not the result. **[one job]**

A parameter with no formula is what the Object Tree labels `[Static]`.

**Part outlines.** Door parts, drawer fronts and drawer box parts also store their outline as line
segments with numbered corner points. Each segment can carry its own parameters; on door parts these
include an edge profile ID. A drawer box back stores its guide notches in this outline. **[one job]**

## 5. ID pointers

The job tree does not repeat schedule or material data. It points to it by ID:

| Parameter family | Points to |
|---|---|
| `_MS…` | A material schedule in the `Materials` stream |
| `_CS…` | A construction schedule in the `Construction` stream |
| `_DP…` | A door setting in the `Doors` stream |
| `_INTF`, `_EXTF` | A finish |
| `_…PRF` | A moulding profile |
| `_CONNID` (on a connection) | A connection |

Every pointer in the test job resolved to an object with that ID in the matching stream, except one
profile that was referenced and not stored.

## 6. Materials stream

Written in this order: material schedules, materials, finishes, finish types, textures, profiles.
Each is a copy of CVData rows. The table and column names below come from the CVData schema
reference in `Reference/S2M Help/S2M Tid-Bits.txt`.

| In the job file | CVData table | Fields carried |
|---|---|---|
| Material schedule | `Schedule` | ID, name, description |
| Part row in a schedule | `ScheduleMap` | Schedule, part, material |
| The part named on that row | `Part` | ID, short name, description |
| Schedule-level parameters | `ScheduleParameter`; door schedules also `ScheduleExtraDoorInfo` | Cost per door, cost per area, minimum cost, banding and laminate flags |
| Material | `Material` plus its `MaterialExtra…Info` table | See below |
| Material face | `Layer` | Finish, finish type, texture |
| Parameters on a model layer | `LayerParameter` | Name, type, value |
| Mesh | `Shape` | Size and geometry |
| Finish | `Finish` | ID, name, description, colour |
| Finish type | `FinishType` | Ambient, diffuse, specular and emissive factors, shininess, transparency, shader |
| Texture | `Texture` | ID, name, image path, world width and height |
| Profile | `Profile` | ID, name, shape ID |

**Material schedule.** A name, and one row per part type. Each row holds the part code and
description, the **material ID** for that part, and a copy of the material's appearance: four finish
IDs, four finish type IDs and four texture IDs, in the order Face, Back, Edge, End.

**Material.** The CVData `Material` row with its type-specific properties stored as short-named
parameters. They are the same properties as the `MaterialExtra…Info` columns:

| Group | Parameters | CVData columns |
|---|---|---|
| Size | `DX`, `DY`, `DZ` | Width, Length, Thickness |
| Board stock | `RT` | RoughThickness |
| Banding | `TRIM` | LengthTrim |
| CNC | `CNCOPT`, `CNCGD`, `CNCDW`, `CNCDL`, `CNCFRP`, `CNCSSP`, `CNCMFC`, `CNCMBC`, `CNCCC`, `CNCMDPP` | Optimize, GrainDependent, DropWidth, DropLength, FeedRatePercent, SpindleSpeedPercent, MinimizeFaceChip, MinimizeBackChip, ClimbCut, MaxDepthPerPass |
| Drawer guide | `GT`, `HEIGHT`, `DEPTH`, `EXT`, `MH1P`, `SCREF`, `SCTBB`, `BKNLEN`, `BKNHGT`, `BKNOFF` | Type, Height, Length, Extension, first hole offset, ScrewCenterRefTop, ScrewCenterToBoxBottom, BackNotchLength, BackNotchHeight, BackNotchOffset |
| Guide clearance | `SC`, `MBB`, `MAB` | SideClearance, MinBelowBox, MinAboveBox |

The other hardware types follow the same pattern. `Materials & Schedules.md` lists the parameter
names for each type.

**Faces.** Each material stores its `Layer` rows. Flat materials have Face, Back, Edge and End, each
with a finish ID, a finish type ID and a texture ID. Finish 0 is Automatic and texture 1 is the
blank texture, the same as in CVData.

**Hardware.** Model materials store their work plane, their members with 3D meshes, and their
machining operations. Each operation is a named object (cup hole, anchor hole, mount hole) with a
position, a diameter in `DX`, a depth in `DZ`, the face it is cut from in `_FACEWP`, and a `TOOLID`.

**Finishes, finish types, textures, profiles.** A finish stores a colour. A texture stores an image
file name and the size it covers; the image itself is not in the job file. A profile stores its
overall size and its outline as line and arc segments.

## 7. Construction stream

The stream is a copy of the construction tables in CVData. The table and column names below come
from the CVData schema reference in `Reference/S2M Help/S2M Tid-Bits.txt`.

| In the job file | CVData table |
|---|---|
| A construction schedule (ID, name, description) | `Construction` |
| Its list of numbered settings | `ConstructionStandardMap`, one row per setting |
| Its conditions | `ConstructionCondition` |
| Its `_DBID` parameter | `ConstructionParameter` |
| A shape used by a schedule | `ConstructionShape` |
| A connection (ID, name, description) | `Connection` |
| A connection's numbered settings | `ConnectionStandardMap` |
| A connection's member connections | `ConnectionSetMap` |

**Schedules are numbered settings.** A construction schedule has no named fields in the job file.
It is a list of records, and each record is one `ConstructionStandardMap` row:

| Field in the record | Column | Meaning |
|---|---|---|
| Setting number | `StandardID` | Which question in the construction wizard. Points to `refCaseStandard`, `refDrawerStandard` or `refTopStandard`, depending on the kind of schedule. |
| Option | `Choice` | The option button selected for that question. |
| Value type | `ParameterTypeID` | The kind of value (measurement, integer, text and so on). |
| Value | `Value` | Any value entered for that question. |

The names of the questions are not in the job file. They are the `Name` and `Description` columns
of the `ref…Standard` lookup tables.

Case, drawer, roll-out and top schedules each use their own numbering, because each points to its
own lookup table.

**Conditions.** A schedule stores each condition as a name, a test written as a formula, and a case
type number (`ConstructionCondition.TypeID`, pointing to `refCaseType`). The built-in case types
(base, upper, tall, vanity and their corner variants) take the low numbers; a shop's own conditions
are numbered after them.

**Conditional values.** A setting that differs for one case type or condition is stored as an extra
record whose number is `(case type number - 1) x 2000 + the setting number`. The record with the
plain setting number holds the default. This packs `ConstructionStandardMap.TypeID` and `StandardID`
into one number. In the test job the shop's first condition was case type 11, which fits ten
built-in case types numbered 1 to 10. **[one job]**

**Connections per joint.** A block of settings in a case schedule each hold a connection ID, with -1
for none. That is how a schedule assigns a connection to each joint, and it can be overridden per
condition like any other setting.

**Connections.** Each connection stores its ID, name and its own short list of numbered settings
(depth and so on). A connection can instead list other connections as its members. A job file
stores only some of the connections its schedules refer to. **[one job]**

Every settings list declares how many records it holds, and the decoded count matched on every list
in the test job. That check is what confirms the record layout.

## 8. Doors stream

- **Door settings:** one per door slot in the job, each pointing to a door style by ID.
- **Door style:** a `Door` row. The design is stored as XML: a reference door size, each panel, and
  each stile and rail with its width, position and extra length. After the XML come the four
  banding tags (`BandTop`, `BandBottom`, `BandLeft`, `BandRight`), each a single letter such as
  `N` for none or `D` for door.
- **Door association table:** `DoorAssociationSize` and `DoorAssociationSizeMap` rows. A door style
  can hand over to an associated door style by size: the table holds the size breakpoints and, for
  each cell of the size grid, the ID of the door style to use.

The same single-letter banding tags appear as the text values of some construction settings.

## 9. Reading a job file

`Tools/cvj.ps1` reads all of the above. It opens the file read-only and shared, so it is safe to use
while Cabinet Vision has the job open, and it has no code that writes a `.cvj`.

| Function | Use |
|---|---|
| `Open-Cvj` | Load a job file. |
| `Get-CvjStreams`, `Get-CvjStream` | List the streams; get one stream's bytes. |
| `Get-CvjTree`, `Format-CvjTree` | The job tree from `Contents`, with or without parameters. |
| `Get-CvjRecords` | Every named object and parameter in any stream. |
| `Get-CvjSettingRuns` | Every numbered-settings list in a stream. |
| `Get-CvjClasses` | The object types a stream uses. |
| `Format-CvjHex` | A hex view of any byte range. |
| `Export-CvjDump` | The whole job as a text file, for comparing two versions of a job line by line. |

**Finding what a setting does.** Save the job, change one thing in Cabinet Vision, save it under a
new name, dump both and compare. The lines that differ are where that setting is stored.
