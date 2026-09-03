# Cabinet Vision — Licensing Modules

Reference index of Cabinet Vision's module/licensing structure, sourced from
`Reference/2021 Hexagon CV Module Features.pdf` (dated 2021 — confirm with Jon whether this still
matches the current lineup before treating it as current). This file is the factual "what exists"
skeleton; real operational knowledge (what Ironwood actually uses, how, and why) belongs in the
per-module files it points to, not here.

## Structure

- **:Core** — the base license everyone has.
- **x-modules** — licensed add-ons that expand Core (x2D CAD, xBidding, xCountertops, xCRM,
  xOptimizer, xRendering, xReporting, xShaping, xMachining).
- **+-additions** — smaller bolt-ons that require a specific x-module already licensed.
- **\*Industry Solutions** — Core-compatible add-ons for a specific industry (\*Cabinets, \*Closets).

---

## :Core — Industry Solutions (base license)

- **Views** — Order Entry; Floor Plan, Elevations, 3D, & Assembly; Elevation Cross Sections; Save
  3D Camera Views; Room Walk Throughs; Lighting & Textures; Simple Renders
- **Rooms** — Straight, Angled, Curved, Cathedral, Vaulted, & Peninsula Walls; Shape Walls from
  Elevation View; Define Ceilings & Floors; Import & Export Rooms
- **Parts & Materials** — Typical Hardware Specification; Import 3D Models for Materials; Create
  Material Aliases and Kits; Create Composite Materials; Custom & Predefined Connector Materials;
  Custom Profiles; Custom Molding and Molding Set Materials; Add Intelligence to Parts; Change
  Material, Dimensions, & Shapes of Parts; Parametric Part Shaping (Simple Constraints)
- **2D CAD & Drawings** — Static Drawing Scenes; Create & Save Titleblocks; Draw & Modify Lines,
  Polylines, Rectangles, Circles, & Arcs; Fillet, Chamfer, & Join Lines; User Dimensioning;
  Annotation Arrows; Group Multiple CAD Objects
- **Bidding/Estimating** — Basic Job Costing; Configure Material Tax & Markup by Material; Set a
  Sell Price for Materials
- **Input & Output** — Assembly, Wall Elevation, and Part Sheets; Material Summary; Board/Panel
  Stock, Door, Drawer, Roll Out, & Face Frame Cut List; Door, Drawer Box, & Roll Out List Report;
  Door, Drawer Box, & Roll Out Check List; Import/Export Orders (ORD & ORDX); Import Custom Orders
  (CSV file); Import/Export Setup Packages; Import/Export Images; Custom Data Link to 3rd Party
  Software (Transmit to Factory); Import 3D DXF; Import SketchUp 2014 Model
- **General** — User Created Standards; Create & Edit Intelli-Joints; Access to the Object Tree;
  User Defined Object Intelligence; User Defined Variables; Batch Process Multiple Jobs

### \*Cabinets (Compatible Industry Solution)
Define Cabinet Construction Methods; Face Frame & Frame Overlay Construction; Frameless & 32mm
Construction; Custom Cabinet Catalog Assemblies; Change Cabinet Name, Size, Hinging, & Price;
Define Drawer and Roll Out Construction Methods; Typical Door/Drawer Front/End Panel
Configuration; Create Door Profiles; Modify Part Size & Position; Modify Interior and Exterior
Assembly Finish; Multiple Toe Kick Types; Full Section Control; Mirror Reverse an Assembly; Open
Doors & Drawers for Presentations; Full Positional & Rotational Control; Copy & Paste & Place
Assemblies; Relate to Part Intelligence Wizard; Drawer Box Section Editor; Dovetail Drawer
Specification; Add Moldings to Assemblies; Grain Matching; Save Groups of Assemblies; Radius &
Angle Ends; Parallel Line Assembly Shaping; Lock/Unlock/Renumber Automatic Assembly Numbering;
Door Section Editor; Save Alias Assemblies; Combine Multiple Assemblies/Toes in Plan View; Beaded
Face Frames & Sub-Frames; Auto-Fill Cabinets

### \*Closets (Compatible Industry Solution)
Same core assembly toolset as \*Cabinets (construction methods, catalog assemblies, section
control, drawer/door editors, etc. — 32mm construction only, no face-frame option), plus
closet-specific features: Wire Baskets; Machining for Wire Baskets; Closet Assemblies; Closet
Verticals; Closet Horizontals; Hanging Sections; Angled Shoe Shelves

---

## x2D CAD
Plan & Assembly Cross Section Views; Custom View Layers & Dimension Styles; Save Drawing Scenes to
a Separate File; Live Drawing Scenes; User Defined Drawing Library; Text Prompting Symbols; User
Defined Vector Hatching (PAT); Multi-Line Text; Assembly Leaders; Flip/Mirror/Rotate/Trim 2D CAD
Objects; Scale & Stretch 2D CAD Objects; Offset CAD Objects; 2D DXF Import & Export; CAD Saved
with Assemblies; Add CAD to Saved 3D Views; Create Live Data Tables (cut list data restricted in
CABINET VISION Design)

**+Submittals** *(not compatible with CABINET VISION Design)* — Deep CAD Intelligence; Automated
Case Part Operations; Unique pre-formatted Catalog Assemblies; Advanced Door, Drawer Front, & Box
Attributes; File drawer rails; Keku clips and other fasteners; Hinge & Plate Attributes; Cam lock
Attributes; Drawer Pull Attributes; Shelf Supports & Standards

## xBidding
Full Job Costing; Custom Labor Costing; Labor per Part & Assembly; Price by Part; Define Part
Pricing Matrices; Create and Assign Vendors to Materials; Access to over 150 Bid Methods; Breakout
Bids by Room; Custom Reporting Engine; Export Bid Data for 3rd Party Software

**+Catalog Editor** — Create, Copy, & Edit Catalogs; Custom Pricing Options; Stock Catalog
Pricing; Modular End to End Catalogs; Simple Pricing Tables; Create Read Only Catalogs; Create
Distributable Catalogs

## xCountertops
Define Countertop Construction Methods; Countertop Modifications; Specify Countertop Joint
Machining (Tite-Joints/Alignment Boring); Modify Sink/Cooktop Cut-Outs

## xCRM
Manage Jobs by Designer/Engineer; Manage Jobs by Customer; Contact Management (Users, Customers,
Vendors, Contractors); Contact Reports; Job Revision Tracking

## xOptimizer
Panel Optimization; Check Sheet Sizes to Fit Machine; Multiple Sheet Size Definition for a Single
Material; Automatically Use Larger Sheet Sizes for Oversized Parts; Pattern Diagram Print Outs;
Recognizes Grain Match Input; Offcut Manager; Optimization Off-Fall Tracking; Modify Optimization
Properties After Optimization; Re-Optimize a Single Material; Cost and Time Report; Send optimized
sheet to drawing

**+Saw** — Output to a NC Panel Saw *(also listed as a +addition under xMachining — see below)*

## xRendering
Save renders to image file; Realtime Rendering; Advanced Rendering; Architectural Photorealistic
Rendering; Cartoon Rendering; Hand Drawn Rendering; Hatch Rendering; Export COLLADA

**+Tour** — Advanced Realtime Rendered Walkthrough; HDR Backgrounds

## xReporting
Over 150 Predefined Reports; User Defined Report Groups; Custom Report Editor; Filter Report Data;
Multiple text file type Exports; User Definable Assembly/Elevation/Part Sheets; Export Report
Data; Output Part List to 3rd Party Optimizers

## xShaping
Parametric Assembly/Part/Route Shaping (Advanced Constraints); Part Level CAM Editor and Reports
Views; Split Parts; Add & Modify Operations on Parts; Ability to Library Parts; Replace Part
w/Library Parts or DXF's; Exploded Assembly View; Edit Part Shape from Room Level; Combine
Multiple Assemblies/Toes in Elevation View; Define & Apply Flutes to Parts

## xMachining
Open/Save/Import/Export NC File (.PNC); Import Blum Dynaplan BXF Files; Save Alphacam Drawing
File (Post machines only); Multiple Primary and/or Secondary Machines; Define Workflows with and
Utilize Machine Sets; Integrated Reporting (including basic labels); Report Editor; Advanced Tool
Strategies; Control Feeds and Speeds of Tools by Material; Control Maximum Depth Per Pass of Tools
by Material; Manually Add and Copy Parts to Part List; Edit Part Banding; Compensate for
Edgebanders with Pre-Mill Stations; Cabinet, Part, Material Filtering

**With ALPHACAM Standard or Higher:** Advanced Toolpath Simulation; Use S2M CENTER Tools within
ALPHACAM; Full Modification of S2M CENTER Toolpaths; Save ALPHACAM Operations to the Part Library;
Output Native ALPHACAM Operation Cluster; Ball & Bullnose Router; Import ALPHACAM Tools; Edit S2M
CENTER Operations within ALPHACAM; Open Job (.pnc) In ALPHACAM

**With +3rd Party CAM, +Point to Point, or +Router:** Import Custom Layered DXF's; User Defined
DXF Layer Schedules; Edit Part Shapes; Add Operations to Parts; Create and Modify Toolsets;
Advanced Tool Set Logic; Pocketing for MDF Slats & Shaker Doors; Automatically Add Miter
Operations; Part Library; Route Outline Only Of Through Holes; Specify Lead Type Per Part; Specify
Outline Tools Per Material; Automatic Tooling and Toolpath Generation; Pocketing of Rectangles and
Circles; Display All Machining; Basic Toolpath Simulation; Shaped Router Bits, Saw Tool, V-Bit
Tool, Dovetail Tool; Control the order of operations; Pocket Waste

### xMachining +additions
- **+3rd Party CAD Import** — Batch Import of 3rd Party CAD Data
- **+3rd Party CAM** — Export Layered Geometry to 3rd Party CAM Applications
- **+Chop Saw** — Output to a Chop Saw
- **+Drill & Dowel** — Output to a Drill & Dowel Machine
- **+Label** — Standalone Label Station Application; Design Labels; Export Real Time Label Info to
  NC Saws; Show Label Position on Nested/Optimized Sheet; Labels For On-Board Nest Machine Label
  Systems; 2D Bar Code Definition; Show Part On Sheet Graphic; Generate Labels for Saw Off-Cuts
  (+Saw); Generate Labels for Nest Off-Cuts (+Router)
- **+Material Handling** — Output to a Material Handling System
- **+Point to Point** — Output to Point to Points (Machining Centers); Automatic Point-to-Point
  Runfield Control; Automatic Point-to-Point Mirroring; ABC Axis Rotation
- **+Part List Export** — Output to a CUT File, Custom CUT File, or PNL
- **+Router** — Output to Nested Based Router; Block Nesting, TrueShape Nesting & 6th Face
  Nesting; Check Sheet Sizes to Fit Machine; Automatically Use Larger Sheet Sizes for Oversized
  Parts; Multiple Sheet Size Definition for a Single Material; Control Lead-In/Out Offsets;
  Combine Operations on Part Edge with Part Outline; Linked Part Outline (Bridge) Nesting; Common
  Line Cutting; Intelligent Small Part Handling (Tabs, Onionskins, Return Onionskins); Pattern
  Diagram Print Outs; Import Custom Layered DXF's; User Defined DXF Layer Schedules; Recognizes
  Grain Match Input; Optimize Gang Drill Operations; First Pass Offset (onion skin); Add/Drag/
  Drop/Cut/Copy/Paste Nest Parts; Manually Rotate or Flip Over a Part in a Nest; Move Parts in a
  Nest; Nest By Cabinet Order; Re-Nest / Add Parts from Library to Existing Nested Sheet(s); Offcut
  Manager; Square Up Off-Cuts in Nest; Nesting Off-Fall Tracking; Edit Tool, Trim, and Optimization
  Properties By Material; Save and Open Nested/Optimized "Ready for Output" Job State; ABC Axis
  Rotation; Send optimized sheet to drawing
- **+Saw** — Output to a NC Panel Saw; Panel Optimizer; Check Sheet Sizes to Fit Machine; Multiple
  Sheet Size Definition for a Single Material; Automatically Use Larger Sheet Sizes for Oversized
  Parts; Pattern Diagram Print Outs; Recognizes Grain Match Input; Offcut Manager; Optimization
  Off-Fall Tracking; Modify Optimization Properties After Optimization; Re-Optimize a Single
  Material; Cost and Time Report; Send optimized sheet to drawing
- **+Simulation** — Simulation (requires +Router or +Point-to-Point, and Intelli-CAM NC Link only)
- **+Special** — Output to a Specialized Machine

---

## Status (as of 2026-09-02)
- This lineup is current — sourced from a Cabinet Vision sales rep less than a month before this
  was added to the Knowledge Base.
- Ironwood Shopworks doesn't hold a CV license itself yet — the work to date has been inside other
  shops' existing systems. Knowledge captured here comes from that hands-on experience across
  client installs, not from Ironwood's own licensed instance.
- When Ironwood does license CV, the intended purchase is **Core, x2D CAD, xShaping, xMachining,
  and xReporting** — these are judged to have the greatest impact on production. These five are the
  priority for building out real depth; the rest (\*Cabinets, \*Closets, xBidding, xCountertops,
  xCRM, xOptimizer, xRendering) still get a file each so nothing's missing, but may stay thin or
  empty until there's a reason to fill them in.
- The module list doesn't map 1:1 to the production-stage folders — it cuts across Bidding, Design
  & Drafting, Engineering, and Machining depending on the module. That's expected, since Cabinet
  Vision itself is cross-cutting.
