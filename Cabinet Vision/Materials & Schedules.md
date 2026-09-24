# Materials and Schedules

Schedules are how Cabinet Vision assigns materials, profiles, hardware and layers throughout a job,
and understanding them is a fundamental of CV. This file is being built up one topic at a time; items
marked *to confirm* are not yet verified.

## How the three pieces relate

- **Parts.** Each schedule is made of a collection of parts, and CV uses those parts in various ways
  inside a job. CV has its own directory of default parts, categorized by the schedule that uses
  them, and a user can also add custom parts, which then become mappable inside the schedules. Parts
  are managed in the **Part Manager** (the **Part** button in the **Catalogs** group of the Main tab).
- **Schedules.** A schedule is a collection of the parts relevant to it, with a material mapped to
  each one. CV then assigns those materials in the job. A row in a schedule is a part.
- **Materials.** All of the properties of each material: size, texture, finish, pricing, machining,
  vendor, custom parameters and more. The **Material** button in the **Catalogs** group holds every
  material that exists.

In short: parts say *what needs a material*, materials say *what exists*, and a schedule says *which
material goes on which part* for a job.

## What a Material Schedule does

- A part is a member of a schedule. When it is built in a job, it looks up its material there.
- Thickness follows the material, so a part's `DZ` normally comes from its scheduled material's
  thickness (it can still be overridden).
- A single part can override its scheduled material without changing the schedule, either manually or
  from a UCS (`MATID := <id>`).
- Schedules are edited from the **Material Schedules** button in the **Catalogs** group of the Main
  tab on the start screen (the same group as Part, Material, Door, Intelli-Joint, Machine, Tool,
  Molding and Profile).

## Materials

### Where to find them

| Window | Path |
|---|---|
| **Material Manager** (the catalog) | Start screen → **Main** tab → **Material** button (Catalogs group) |
| **Material Properties** (one material) | From the Material Manager, select a material and press **Properties**, double-click it, or right-click → **Properties** |
| **New Material wizard** | Material Manager → **New** (see "Creating a material" below) |

### Material Manager

The catalog window. Its ribbon has a **Return** button, a **Materials** set (**New**, **Copy**,
**Alias**, **Delete**, **Properties**) and a **Finishes** set (**Finish**, **Finish Type**,
**Texture**), which open the finish, finish-type and texture libraries.

- **Left side:** a search box with a filter, arrow buttons to expand, collapse and move folders up,
  down, in and out, and the folder tree. The folders and subfolders are **organizing folders that
  Jon has heavily rearranged** to keep the catalog usable, so they are not CV's defaults. For example
  the panel-stock folder is split into subfolders by manufacturer. Imported packages (`.pkg`) also
  appear as folders, and there are "To Be Deleted" and "Deleted" folders for retiring materials.
- **Right side:** a table of the materials in the selected folder, with tabs **Material**, **CNC**,
  **Size**, **Finishes**, **Finish Types** and **Textures**. The Material tab's columns are ID, Name,
  Description, Type, Unit Of Issue, Default Cost, Sell Price, Default Markup and Sales Tax.
- **Naming pattern** (Jon's company standard): the name reads thickness, manufacturer, code, color; the
  description repeats the same pieces in a different order. **CV lets you name a material anything**; this is
  just Ironwood's own standard, kept for consistency and easy searching. **Minimum for a name:
  `<thickness> <material name> <type>`** (extras such as sheet size are optional). **Don't use `|`, `"` or
  `'`** (script issues); a pipe appears on only one of Jon's materials, to list that material's textures.
  Also avoid `#` (see Gotchas). **The description can be anything.** It doesn't have to follow the naming
  standard.

### Searching, groups and the material area

The left sidebar of the Material Manager has two panes, and the right side is the material area.

**Search pane.**
- **Quick Search** at the top searches material **names, descriptions and IDs**. Press Enter or click the
  Filter button. It already does partial-word matching (it pads your text with `*` on both sides), and
  the wildcards `*` (any characters) and `?` (one character) also work.
- **Saved Searches** are listed below it. Click **Add Search**, then **New**, name it, and add lines that
  each say what to search on (Name, Description…), how to compare (for example "similar to"), what to
  compare to, and how to group the line with the next ("or", "none"…). The help's example finds any
  material whose name or description contains "Oak". Select a saved search from the list to activate
  it.

**Group pane** (what this file has been calling the folders). You can organize materials into an
unlimited number of **Groups and Sub-Groups**.
- **Create Group** makes a new group or sub-group; **Delete Group** removes an *empty* one; right-click
  in the pane also offers Create, Rename and Delete.
- Move groups by drag and drop or with the Move buttons. Move materials into a group by dragging
  them, and select several at once the usual Windows way.
- The **Grouped** material summary reports subtotal costs by these groups.

**Material area** (right side). It lists the materials in the selected group, or the results of an
active search. The standard properties are on the **Material** tab and the type-specific ones are on the
extra tabs. The ID and Name always stay visible. Editing on these tabs is a quick way to change a
property on many materials at once, while the **Properties** window is better for setting up one
material.

**Right-click options on a material:** Copy, Delete, Alias, **Redefine** and Properties. **Redefine**
re-runs the New Material wizard on the selected material, and it **loses any changes you made in the
Model Editor, including modified parameters and formulas**.

### Vendors

**Not visible in this installation.** The help describes a **Vendors** button and a **Default Vendor** row,
but the Material Properties windows checked here (a panel stock sheet and a hinge) have neither: the
Advanced ribbon is Kit, Composite, Parameters, Profile and Model, and the Material group runs from
Description through Estimate, Load Model and S2M Material with no vendor row. The vendor features below are
from the help. **Jon says Vendors is licensed separately**, which is why it isn't visible here.

Vendors are a separate list you manage in the **Vendor** utility (from the Material Manager), which
also has **Return**, **New** and **Delete**. Each vendor has a name, address, phone, mobile, fax,
email, primary contact, comment, your account number with them, and the **sales tax you pay** when
buying from them. You then attach vendors to a material with its **Vendors** button, giving each a
SKU, cost and markup, and choose the default vendor (see Material Properties). Setup packages can
transfer vendors between computers.

### Material Properties

One material's editor. The ribbon has **Return**, **New**, **Copy**, **Delete** and **Select**, plus an
**Advanced** set: **Kit**, **Composite**, **Parameters**, **Profile** and **Model**. Which of those are
enabled depends on the material's type (for a panel-stock sheet, Kit and Parameters are on and
Composite, Profile and Model are greyed out). There are two tabs, **General** and **Operations**, and a
preview swatch. **General** is grouped into sections:

- **Material:** ID, Name, Description, **Type** (greyed out; set when the material is created), Unit
  Of Issue, Default Cost, Sell Price, Default Markup, Sales Tax, Default Tax Rate, Waste, Estimate and
  **S2M Material**. S2M is Screen-to-Machine; this flag decides whether the material is accessible
  in the S2M material catalog as well as the regular CV material catalog (unflagged materials appear
  only in CV).
- **Size:** Width, Length, Thickness.
- **CNC:** Optimize, Grain Dependent, Drop Width, Drop Length, Feed Rate Percent, Spindle Speed Percent,
  Minimize Face Chip, Minimize Back Chip, Climb Cut, Maximum Depth Per Pass.
- **Layer sections.** Flat materials show **Layer - Face** and the collapsed **Layer - Back**, **Layer - Edge**
  and **Layer - End**. **Hardware types show one layer section per model piece** instead: a hinge shows
  **Layer - Base Plate** and **Layer - Arm**, each with a Finish (a **color swatch means that color is locked** to the layer, here a fixed grey; an inherited finish shows the word **Automatic** instead), a Finish Type (Metal - Matte on a new
  hinge) and a Texture (Blank). Each section has a
  **Finish**, **Finish Type** and **Texture** (the face layer of a wood panel shows an automatic finish,
  a wood finish type and a named texture).

The thickness set here is what a part's `DZ` follows when the part is scheduled onto this material.

**What the buttons do** (from Hexagon's CABINET VISION 2025 help, checked against how you use them):
- **Alias** (Material Manager ribbon): adds a child material that takes most of its properties from
  its parent and overrides only a few (the "differentiators"). Use it for panel stock that is identical
  except for name, sheet size and cost. The alias appears as a sub-item of its parent; the fields it
  can change are editable and the rest are locked because they come from the parent. The
  differentiators differ by type: for **Panel Stock** they are Name, Description, Vendor, Default Cost,
  Sell Price, Default Markup, Sales Tax, Default Tax Rate, Width and Length; for **Banding** they are
  Name, Description, Vendor, the cost and tax fields, Finishes and Finish Types.
- **Kit:** attaches extra materials to the selected one, with a quantity for each (the help's example
  is a wire pull with two mounting screws). A material with a kit shows a visual marker in the
  Material Manager.
- **Composite:** only for the Composite type. It defines a sheet material made of several layers of
  sheet goods. You add sheet materials, order the layers with Up and Down, and set **Face Up**
  (whether that layer faces up) and **Oversize** (an oversize amount for that layer) on each.
- **Profile:** only for the Molding and Molding Set types. On a **Molding** it associates a profile
  shape with the molding, and can import one from the system-level Molding Manager. A **Molding Set**
  also opens the Profile tab. There you can import **multiple existing moldings into a single set** and
  change the **orientation** of each and how they **relate to one another**, but the imported moldings
  themselves cannot be modified there.
- **Model:** the Model Editor imports 3D DXF or SketchUp models to represent the material, placed on
  work planes.
- **Parameters:** opens the Parameter Editor to add a parameter to the selected material. A UCS reads
  it with `_M:ParameterName` on an object that uses the material, and it does not show in the Object
  Tree. Connector materials get an extra toolbar for a connector UCS that runs after a secondary
  operation is created.
- **Vendors:** opens the Material Vendor Manager, where you assign the vendors you buy the material
  from. Each vendor has a **SKU**, a **Cost** and a **Markup**, and you pick a **Current Default
  Vendor**.
- **Select:** picks a different material to work on in Material Properties. A System Materials tool
  shows the built-in (non-user) materials, which appear in red.
- **Opening Properties:** the Properties button, double-clicking the material, or right-clicking it and
  choosing Properties.

### Composite, kit, models and operations in depth

**Composite materials.**
- *What:* a sheet material made of several layers of sheet goods. It is its own material type
  (Composite) and is the only type that has the Composite button active.
- *Set up:* create a material of type Composite, open its Properties, click **Composite**, and add sheet
  materials from the catalog to the stack. Order the layers with Up and Down and remove one with the
  Right button. On each layer set **Face Up** (whether that layer faces up or down) and **Oversize** (an
  oversize amount for that layer). Its overall Length, Width and Thickness are calculated from the
  layers and cannot be edited.
- *Pre-Assembled* decides how it is built: if on, the layers are assembled before cutting and
  machining; if off, each layer is cut and machined separately and put together afterward.
- *In reports:* cut lists (for example the panel stock and laminate cut lists) mark parts made of
  sub-materials, and list the materials a composite is made of below it, in the order they go in the
  composite. A separate Composite Materials report lists them.
- *Where it is useful:* panels with a face material over a core or backer; door and drawer front
  components made of layers; and thick built-up panels or tops made by laminating sheets.

**Kit materials.**
- *What:* a material with other materials attached to it as a kit, each with a quantity. The help's
  example is a wire pull that comes with two mounting screws.
- *Set up:* open the material's Properties, click **Kit**, then add materials from the catalog to the
  kit (button or drag) and set the quantity of each. A material with a kit shows a visual marker in
  the Material Manager.
- *In reports:* the "Material Summary w/Kits" reports (including the optimized and grouped versions)
  list the kit parts along with the material. Several of the optimized versions have restrictions
  set in the Bid Center.
- *Where it is useful:* accessory sets (a material that always comes with its extras), and anything
  that must show on the material summary together with those extras so purchasing sees the full set.

**Models and operations on hardware.**
- *Which materials carry a model or a profile:*

  | Type | Model | Profile |
  |---|---|---|
  | Panel Stock | No | No |
  | Board Stock | No | No |
  | Laminate | No | No |
  | Banding | No | No |
  | Counter Top | No | No |
  | Composite | No | No |
  | Molding | No | **Yes** |
  | Molding Set | No | **Yes**, in the Profile tab moldings are imported into a set and positioned; the moldings themselves cannot be modified there |
  | Hinge | **Yes** | No |
  | Hinge Plate | **Yes** | No |
  | Drawer Guide | **Yes** | No |
  | Pull | **Yes** | No |
  | Wire Basket | **Yes** | No |
  | Rod | **Yes** | No |
  | Sliding Door Roller | **Yes** | No |
  | Sliding Door Rail | Yes (weakest confirmation) | No |
  | Leg | **Yes** | No |
  | Leg Leveler | **Yes** | No |
  | Caster | **Yes** | No |
  | Connector | **Yes** | No |
  | Miscellaneous | Only when its **Model** property is True | No |
  | Shadowline Channel | **Yes** | No |
  | Shadowline Bracket | **Yes** | No |
  | Finger Pull | **Yes** | No |

  So **models are carried by the hardware types**, **profiles only by Molding** (and Molding Set,
  which combines several existing moldings on its Profile tab without being able to modify them), and sheet goods, board stock, banding, laminate, counter top and composite carry
  neither. Turning a model on for a Miscellaneous material sets its Model property to True, which
  turns on Load Model.
- *Two sources of operations:*
  1. **System-generated:** for hardware types (Drawer Guide, Hinge, Hinge Plate, Pull, Rod, Sliding Door
     Rail, Sliding Door Roller, Wire Basket) CV builds the machining from the fields on the material
     (mount-hole diameters, depths, spacings, offsets, cup and anchor holes). These appear on the
     **Operations** tab. For a drawer guide you define the left guide and CV mirrors it for the right.
  2. **Custom, from a model:** a work plane in the Model Editor can hold operations (holes, pockets,
     routes) added in the CAM editor.
- *Building a model (the help's entry-knob example):*
  1. Create a Miscellaneous material and set **Model** to True (for a pull, hinge or other hardware
     type the Model button is already available).
  2. Click **Model** in the ribbon. A brown sample **Assembly** part is shown to help orient the graphic;
     you can change its thickness to match the door or panel the hardware will sit on.
  3. The **Primary Work Plane** is the container and the insertion (reference) point of the model;
     everything is referenced from it, and its true position is set when the model is placed in a job.
  4. Choose a view (Front, Back, Left…), select the Primary Work Plane and click **Add Work Plane**, then
     set that plane's X and Y. Additional work planes search for matching surfaces and carry their
     operations onto them, but only within the part the primary surface touches.
  5. With the work plane selected, click **Add Hardware** and import a 3D DXF or SketchUp file. Set the
     import options, then set the imported object's Name, Description, Finish, Finish Type and X, Y, Z
     (X and Y center it on the plane; Z lets a plate into an edge).
  6. To machine it, right-click the work plane and choose **Edit** (or double-click). In the CAM editor
     add holes, pockets and so on to that work plane, then **Return**.
  7. Switch to 3D mode to check, adjust the Primary Work Plane's X and Y to position the model, and
     **Return** to save.
- *Where the models come from (Jon's practice):* manufacturer downloads (DXF or SketchUp) and models he
  draws himself.
- *Importing a model (3D DXF or SketchUp):*
  - The import utilities state that imported objects **are not machinable and are visual only**. Machining
    comes from the material's generated operations and from operations added on a work plane in the
    CAM editor.
  - **Options in the DXF import window:** Browse and Select, then Import (if nothing happens the file does not
    meet CV's requirements); Line, Fill and Solid Render preview modes; **Flip X, Y and Z** (each turns the model
    90 degrees); **Scale** (better to build the file at its final size); **Type** (the part type to associate);
    **Texture Map** (Arbitrary, AutoAxis, Cylindrical, Local Auto Axis, Spherical, X Plane, Y Plane and Z Plane
    are shown, although the help says seven); **Smooth Surface**; and **Single Sided Faces** with **Reverse
    Faces** for files that look distorted or vague in the preview.
  - **3D DXF rules:** CV reads AutoCAD Release 12 and 13 DXF files. Only **polygon-based** models are used;
    lines, arcs, text and blocks are ignored. **Polyface Mesh** and **3D Face** objects import; **3D Mesh**
    objects do not (in AutoCAD, Explode converts them to 3D Faces). **Solids** cannot be imported directly.
  - **Materials must be distinguished by layer.** The import window lists the model's layers, and objects
    with the same material sit on the same layer. Distinctions made by color or by object are ignored, so a
    model with several colors on one layer imports as a single material.
  - **The 3DS conversion technique** turns solids, or models that use color or object to separate materials,
    into layer-based polygon models: export the model from AutoCAD as 3DS (deriving objects by layer),
    clear the drawing, re-import the 3DS (Available Materials set to Add All, Save to Layer set to By
    Object; it imports as a Polyface Mesh), then export that as a DXF. To separate by color or object
    instead, choose that option in the first step.
  - **SketchUp:** CV currently supports SketchUp 2020 and earlier files.
- *Putting it to use:* a model material is placed on a part. In the example you create the part in the
  **Part Manager** (Pull group, new part named EKNOB), assign the model material to that part in the
  **Pull Material Schedule** (Material Schedules), then start a job with that schedule active and add
  the part to an assembly. CV places the hardware with all of its machining.
- *Where it is useful:* hardware that has to show in 3D and be machined correctly, such as pulls,
  knobs, hinges, plates, drawer guides and connectors. Model placement can also be driven by a UCS
  (see `UCS.md`).

### Hardware operations per type

For the hardware types the help describes the machining as **fields on the material**, which CV turns
into operations when the hardware is applied to a part. The generated operations are listed on the
material's **Operations** tab. What each type builds from:

| Type | Operations generated from these fields |
|---|---|
| **Drawer Guide** | **Mount holes:** diameter, depth, whether they are referenced from the top of the guide (Top Reference), the screw-center distance to that reference, and up to six hole positions measured from the front of the drawer box. **Front mount holes** and **back mount holes:** horizontal offset from the drawer box side, vertical offset from the reference, diameter, depth, spacing and quantity. **Back mount notches:** length, height and horizontal offset. **Bottom mount holes and grooves (System type only):** first position, horizontal offset, diameter, depth, spacing, quantity, and groove width and depth |
| **Hinge** | **Hinge cup:** diameter and depth. **Anchor holes:** distance from the cup center to the anchor holes, diameter, depth and spacing |
| **Hinge Plate** | **Mounting holes:** diameter, depth and spacing (plus a plate hole offset that positions the graphic) |
| **Pull** | **Mounting holes:** diameter. The center-to-center distance sets the pull length and the insets place it on the door or drawer front |
| **Finger Pull** | **Mount holes:** first hole X and Y position, diameter, depth and spacing. Edge Trim is the amount removed from the door edge |
| **Rod** | **Boring:** one of six patterns, plus diameter, depth, spacing and quantity of the bores |
| **Sliding Door Rail** | **Boring:** first hole position from the left, diameter, depth and spacing. **Slot:** width and depth |
| **Sliding Door Roller** | **Mount plate holes 1 to 5:** horizontal and vertical offset, diameter and depth each. **Slot in the door:** width, depth, dado reference (Back, Center or Front of the door) and dado offset |
| **Wire Basket** | **Mount holes:** diameter, depth and up to six positions measured from the front of the basket |
| **Connector** | Built from the connector **Type**; a connector's primary operation creates secondary operations and can run a UCS attached to the connector to adjust them (see the Parameters button above) |

**What the Operations tab looks like (a hinge).** The generated machining is not a separate list: the
Operations tab is a property sheet of the same fields, grouped by operation. For a hinge it has two groups,
**Anchor Holes** (Cup To Anchor, Diameter, Depth, Spacing) and **Hinge Cup** (Diameter, Depth). A new hinge
starts with a cup of 1 3/8 diameter and 15/32 depth, and anchor holes of 5/16 diameter and 15/32 depth,
3/8 from the cup and 1 7/8 apart. The General tab holds the placement and behavior fields (overlays,
door end to hinge, inset, spacing, opening angle, door edge to reference point, roll out clearance) and the
Operations tab holds the machining sizes.

**What the Operations tab looks like (a side-mount drawer guide).** Three groups, all fields you can change:
**Mount Holes** (Diameter, Depth, and Position 1 through Position 6 measured from the front of the drawer box),
**Front Mount Holes** and **Back Mount Holes** (each with Horizontal Offset, Vertical Offset, Diameter,
Depth, Spacing and Quantity). A new guide starts with mount holes 3/16 in diameter and 15/32 deep and only
**Position 1** set, at 1 1/4 (which matches the 32 mm graphic hole offset in the database reference). The front
and back mount holes are all 0, so **no front or back mount holes are machined until you enter values**
(a Quantity of 0 means none). The back-notch fields are not here; they are on the General tab in the Guide
group. **What each group machines:** **Mount Holes** are the guide's holes into the cabinet side, with Position 1 to
Position 6 as extra screw holes along the guide measured from the front of the drawer box. **Front Mount
Holes** and **Back Mount Holes** are holes into the drawer box front and back. For **System** guides two more
groups appear on this tab, **Bottom Mount Holes** and **Bottom Mount Grooves** (first position, horizontal
offset, diameter, depth, spacing and quantity for the holes; horizontal offset, width and depth for the
grooves); they do not appear on a side-mount guide.

**What the Operations tab looks like (a pull).** A single group, **Mounting Holes**, with one field, **Diameter**
(3/16 on a new pull). On the General tab the Pull group has only **Type** (Knob, greyed out after creation),
**Horizontal Inset** and **Vertical Inset**. The help's New Material page also lists Center to Center, Width
and Depth for a pull, but **those fields are not on this knob**. For a multi-hole pull the **hole spacing
(center to center) is set in the model's work plane operations**, not as a field on the material.

**Reference points.** Many of these fields position the hardware's graphic as well as its holes. Where a
type has a model, the model is drawn with its first mounting hole, or its primary holes, at the
**graphic reference point**, and the field (for example a hinge plate's Plate Hole Offset, a drawer
guide's first position, a hinge's Door End to Hinge) shifts the model by that distance when it is used
in an assembly. This is why a model's origin and the material's fields have to agree.

**Molding in practice:** Jon does not use the Molding material type. His moldings are defined in the Molding
Manager and drawn into jobs, which matches the help's advice that molding you make yourself belongs in the
Molding Manager with a plain Board Stock material assigned.

**For a drawer guide you define only the left guide.** CV creates the right guide and its operations
automatically as a mirror of the left.

**On the Operations tab you can only change the values shown** (the fixed groups, such as Anchor Holes and
Hinge Cup on a hinge); you cannot add extra operations there. Extra machining comes from the model's work
planes, added by hand in the CAM editor (see the model steps above). When a material has both generated
operations (from its fields) and a model whose work planes carry operations, **both are applied**. A change
to these values reaches an existing job only after **Update Job → Materials**.

### What each property does

All from the CABINET VISION 2025 help unless noted.

**Material section (every type):**
- **ID:** CV's internal number; not editable.
- **Name:** anything that identifies the material, up to 50 characters. Use only letters, numbers and a
  `/` in fractions; quotation marks (`"`) and the pound symbol (`#`) cause errors in optimization and
  the S2M Center. Write `1/2in Melamine`, not `1/2" Melamine`. **Jon's rule:** also avoid `|` and `'` (script
  issues; the pipe is used on only one of his materials, to list that material's textures). **Minimum for a
  name: `<thickness> <material name> <type>`.**
- **Description:** up to 100 characters. It can be anything and doesn't have to follow the naming standard.
- **Type:** fixed when the material is created; not editable.
- **Unit Of Issue:** the unit you buy the material in. The choices are BD FT (per board foot), BD M
  (per board meter), Cubic FT, Cubic M, Each, Pair (for drawer guides and other hardware sold in
  pairs), Per FT, Per M, Sheet, SQ FT and SQ M. (The help's Properties page says nine options but
  lists eleven.)
- **Default Vendor:** if vendors are assigned, choosing one makes **Default Cost, Default Markup and
  Default Tax Rate come from that vendor and greys those fields out**. Choosing None lets you type
  your own values, and None is the only choice when no vendor is attached.
- **Default Cost:** what you pay for the material.
- **Sell Price:** what you charge the customer for the material.
- **Default Markup:** the percent you add for the material itself, most often to cover transportation or
  overhead. More markups can be added in the Bid Center.
- **Sales Tax and Default Tax Rate:** whether you pay tax on the material and the percent. This is the
  tax you pay when buying; the tax you charge the customer is entered in the Bid Center.
- **Waste:** a waste percent for the material.
- **Estimate:** whether the material is sent to the Bid Center and calculated with the "% of Material
  Cost" bid method.
- **Load Model:** on materials that support 3D models only, whether the model is loaded into a job.
  Models can be large and slow a job down, so this turns them off for specific materials.
- **S2M Material:** makes the material available in the S2M CENTER material catalog as well. **Jon's
  practice:** if a material is set to **Optimize**, also set it as an **S2M Material**. These materials
  naturally go to S2M on output, so there's no reason they shouldn't also exist in S2M as an S2M material.

**Why width and length matter (Jon):** thickness is the most important size, but width and length are
important in their own right. **Wrong sheet width or length gives bad nesting patterns and can lead to
under- or over-ordering sheets.**

**Size, by type:** Panel Stock has **Width, Length and Thickness**; Banding has Thickness and **Length
Trim** (extra banding length to allow for feeding and end trimming on an edgebander); Board Stock has
Thickness and **Rough Thickness** (used only when the unit is board feet or board meters); a Caster has
Height (used to set an assembly's elevation); Molding has a Type and Length; a Pull has a Type plus
**Horizontal Inset** and **Vertical Inset** (where the pull's reference point sits on the door or drawer
front). **Thickness is the most important property of a material**, because cabinet construction depends
on it to produce a correct cut list. Banding's width is not entered: it takes the thickness of the
part it is attached to.

**Where the CNC settings are normally set, and how the material's values fit in.** Jon: the real feed
rate, spindle speed, depth and rotation are **normally set in the tool definitions** (Tool catalog / S2M).
The material's CNC section does not replace them; it works **with** the tool. From the help:
- **Feed Rate Percent / Spindle Speed Percent** scale the tool's optimum feed rate and RPM. The help says
  the material "will have an effect on the final feed rate," so **account for the material's % feed rate
  when testing**. The tool holds the real values (feed in inches or mm per minute; spindle speed in RPM,
  roughly 4000 to 24000, and some machines ignore it and use a preset speed).
- **Maximum Depth Per Pass:** both the material and the tool have one, and the **smaller** is used.
- **Climb Cut** (material) combines with the tool's **Rotate Clockwise** to set the toolpath direction.
- **Minimize Face/Back Chip** guide S2M's **Automatic Tool Selection** logic. An operation's tool set to
  **Auto Select** (the recommended default) follows that logic; a specifically chosen tool is used instead.
  The logic itself is in the separate S2M CENTER Help, which is not in this Knowledge Base.

**Tooling detail, to be covered when tooling is documented: how feed and speed are applied on output (from
the help's Tools table reference; the exact math is inferred).** A tool stores its own **feed rate at a 1/4 in deep cut** and **at a 3/4 in deep cut**, plus a
**descent rate** and a **spindle speed (RPM)**. The help says these are "used to dynamically output varying
feed rates based on depth of cut and percentage value entered into Material Catalog." So the output feed
rate for a cut depends on the **depth of that cut** (presumably worked out between the tool's 1/4 in and
3/4 in values) and is then **adjusted by the material's Feed Rate Percent**. Spindle speed comes from the
tool and is scaled by the material's Spindle Speed Percent. A **post processor** turns the result into
G-code and handles units (the help's example: a MultiCAM post expects inches per minute but outputs inches
per second). An RPM of 0 on a tool usually causes a G-code error, and some machines ignore the RPM value
and use a preset speed for the tool. *(Inferred, not stated: the calculation order, and that feed is
interpolated between the two depths.)*

**CNC section (sheet and board stock):**
- **Optimize:** whether the material is sent to the Optimizer/Nester. Set up sheet goods even if you
  don't own the module yet. **Jon's practice: it varies by material.** Reasons to leave it **Off**: the
  material is **cut by hand**, is **outsourced**, or is used **primarily for display**. **Buyout override:**
  certain schedule types have a **Buyout** selection, and a **BUYOUT material schedule sends none of its
  parts to S2M, even for a material that is set to Optimize.** *(Buyout is not yet documented; to be covered
  with the schedules.)*
- **Grain Dependent:** whether parts may be rotated across the sheet in the Optimizer/Nester. **Jon's
  practice:** Off for plain colors (parts may rotate freely), On for grained materials (grain direction
  stays fixed).
- **Drop Width / Drop Length:** the minimum width / length a leftover must have to count as an offcut
  instead of scrap. A leftover has to meet **both** minimums to be an offcut; S2M tracks offcuts (counter,
  optional labels and images). At 0 every leftover counts as an offcut. To pick values, use the smallest
  piece you'd actually keep and reuse. **Jon's practice:** leaves both at 0.
- **Feed Rate Percent / Spindle Speed Percent:** the percentage of the optimum tool feed rate / spindle
  speed to use with this material. **Jon's practice:** always 100.
- **Minimize Face Chip:** the S2M Center's automatic tool selection tries for a down-shear bit.
- **Minimize Back Chip:** it tries for an up-shear bit. With both on, it tries for a compression bit.
  *(General CNC knowledge, not from the help and not yet confirmed by Jon: the three main spiral cutter types
  are **up-shear** (up-cut, pulls chips up and out; leaves a clean bottom edge but can chip the top face),
  **down-shear** (down-cut, pushes chips down and holds the sheet flat; leaves a clean top face but can
  chip or burn the bottom), and **compression** (up-shear on the lower section and down-shear on the upper
  section; clean on both faces, but the cut must go deep enough for the two sections to overlap the
  material, so it suits full-depth through cuts better than shallow pockets and dados). "Face" is the side
  that faces up on the nest, which S2M chooses; see `Unverified Knowledge.md` item M1.)*
  **Jon's practice:** both options on for materials finished on **both sides**; **Face only** for one-sided
  materials (unfinished back).
- **Climb Cut:** whether the material is cut with a climb cut. Together with the tool's **Rotate Clockwise**
  setting it decides the toolpath direction: with Climb Cut on, an outside pass runs in the same direction as
  the tool's rotation, and an inside cut always runs opposite to an outside cut. *(General CNC knowledge, not
  from the help: a climb cut has the bit rotating with the feed where it touches the material, which usually
  gives a cleaner edge but pulls the bit along, so it needs a rigid machine and good hold-down; a conventional
  cut rotates against the feed.)* **Jon's practice:** climb cutting is used primarily for **clean-up
  passes**.
- **Maximum Depth Per Pass:** the depth a tool can cut per pass in this material; the smaller of the
  material's and the tool's value is used. A cut deeper than this takes several passes. **Jon's practice:**
  it usually follows the tooling (leave it at the default) **unless the material is very thick, dense
  hardwood**. *(What a value of 0 means isn't stated in the help; presumably "no limit from the material, use
  the tool's value." Unverified.)*

**Layer sections (Face, Back, Edge, End):** each layer has a **Finish**, a **Finish Type** and a
**Texture**.
- A fixed finish shows as a color swatch. **Automatic** means the finish comes from the
  job, room, assembly or part finish; choosing a finish **locks that color to the material**.
- If a material has no pattern, give it the Blank texture.
- **For CNC users, the textures decide whether the material is one-sided or two-sided (from the help;
  UNVERIFIED, see `Unverified Knowledge.md` item M1, and Jon had not seen this behavior).** If the face and
  back have the same texture (or none), the material is two-sided and the S2M Center may flip parts
  over when one side has more operations. If the face and back textures differ, the material is
  treated as one-sided and parts are not flipped. The S2M Center then decides which side faces up by
  operation count and tells the operator which texture (by name) to put up.

**Operations tab:** lists operations that CV generates for hardware types such as drawer guides,
hinges and pulls. It is covered in the help's New Material topic for each of those types.

### Properties that are specific to each type

Every type shares the Material section and the Layer sections above; each adds its own group. Types
marked *Operations tab* also have an Operations tab listing the machining operations CV generates for
that hardware (the help describes them under the New Material topic for that type).

| Type | Its own properties | Notes |
|---|---|---|
| **Banding** | Thickness, Length Trim | Width comes from the part it is attached to. Solid stock can be defined as banding for solid wood edges |
| **Board Stock** | Thickness, Rough Thickness, CNC section | Rough thickness only matters for board-foot units. Enter dimensional lumber by its finished thickness |
| **Panel Stock** | Width, Length, Thickness, CNC section | Aliases can vary name, cost and sheet size |
| **Laminate** | Length, Width, Thickness | |
| **Composite** | Pre-Assembled; Length, Width and Thickness (calculated, not editable) | Pre-Assembled decides whether the layers are joined before cutting and machining, or each layer is cut and machined separately. Built with the Composite button |
| **Miscellaneous** | Thickness, Model (True/False) | Setting Model to True lets you attach a model and turns on Load Model |
| **Caster** | Height | Sets an assembly's elevation when applied |
| **Leg** | Type, Height, Width (diameter) | |
| **Leg Leveler** | Height | |
| **Molding** | Type, Length, Cost Per Joint, Miter Trim | For **bought** molding that has one SKU covering every property. Molding you make yourself belongs in the Molding Manager with a plain Board Stock material assigned. CV optimizes the lengths you buy, so set up an alias for each length. Types: Applied, Base Board, Casing, Ceiling, Chair Rail, Crown, Door Applied, Light Rail, Scribe |
| **Molding Set** | none of its own; a set is built on its Profile tab by importing several existing moldings and setting each one's orientation and relation to the others (the moldings themselves are not editable there) | |
| **Pull** | Type, Center to Center (sets the pull length), Width, Depth, Horizontal Inset, Vertical Inset, mounting-hole diameter | *Operations tab.* Insets place the pull's reference point on the door or drawer front |
| **Finger Pull** | Type (C-Rail, Flat-Rail, U-Rail), Length, Height, Width, Edge Trim, mount holes | Edge Trim is the amount removed from the door edge to make room for the finger pull |
| **Hinge** | Type (Concealed, Double Door, Exposed), Horizontal and Vertical Overlay (face-frame cabinets only), Door End to Hinge, Inset, Maximum Spacing, Opening Angle, Door Edge to Reference Point, Roll Out Clearance; hinge cup and anchor-hole sizes | *Operations tab.* Maximum Spacing is how far apart hinges go before another is added. Inset 0 puts the door forward of the face by its thickness; a positive value moves it back, a negative one moves it out |
| **Hinge Plate** | Type (Panel or Frame), Plate Hole Offset, mounting holes | *Operations tab* |
| **Drawer Guide** | Type (Side Mount, Bottom Mount, Top Mount, System), Height, Length, Extension, Screw Center Reference to Top and to Box, Back Notch Length, Height and Offset, Side Clearance, Minimum Above Box, Minimum Below Box, mount holes | *Operations tab.* Cost is **per guide, not per pair** (enter half the pair price). "Mount" describes how the guide attaches to the cabinet, not to the drawer, so a typical side-mounted drawer slide is a Side Mount. Side Clearance is multiplied by 2 and subtracted from the opening width to get the drawer box width. The two Minimum values start to set the drawer box height |
| **Rod** | Length; boring pattern (six patterns), diameter, depth, spacing, quantity | *Operations tab.* Height only applies to the oval type |
| **Shadowline Channel / Rail** | Type, Length, Width, Depth | |
| **Sliding Door Rail** | Type, Length; boring and slot | *Operations tab* |
| **Sliding Door Roller** | Type (Roller or Slot), Mount On Back, Door Edge Inset, Door End Inset, Slot Reference and Offset; up to five mount-plate holes | *Operations tab* |
| **Wire Basket** | Type (Side, Top or Bottom Mount), Depth, Width, Height, First Hole Offset; mount holes | *Operations tab* |
| **Connector** | Type | Types include Cabineo, Clamex, Divario, FastenLink, Lockdowel, Peanut, Rafix and Tenso, plus a generic Connector you define yourself in the Model Editor. Clamex and Tenso need a machine with Lamello's Clamex saw, and FastenLink needs a shaped tool in the S2M Center tool catalog. A connector's primary operation can run a UCS attached to the connector |

### Creating a material

**The wizard is optional** (Jon): every setting in the New Material wizard can also be set or changed later
in **Material Properties**. The one thing you can't change afterward is the material **Type**.

1. Open the **Material Manager** (Main tab → **Material** button).
2. Click **New** (in the Material Manager, or in Material Properties, where the new material goes into
   the same category as the selected one). This opens the New Material wizard.
3. First screen: choose the **Type**, then enter the **Name** (up to 50 characters, letters, numbers and
   `/` only) and **Description** (up to 100). The type cannot be changed later.
4. Click **Next**. The next screen depends on the type. It always has **Unit of Issue**, plus the size
   for that type: thickness for banding or board stock; length, width and thickness for panel stock;
   height for a caster; type and length for molding; type for a pull.
5. **Display** screen: choose the **Finish**, **Finish Type** and **Texture** for the face, back, edge,
   end and any components.
6. Click **Finish**. Then open the material's **Properties** to set cost, markup, tax, waste, the CNC
   section and vendors.

**Rules the help gives:** every material must be listed in the Material Manager before it can be used
in a job (a job takes a snapshot, so run Update Job → Materials to pick up later changes), there is no
limit on how many you add, and every sheet or board good must have a valid **thickness**.

### What CV fills in for a new material (defaults)

**Every new material starts with:** Default Cost, Sell Price, Default Markup, Default Tax Rate and Waste at
0, Sales Tax off, **Estimate on**, no default vendor, and S2M Material off. Load Model is on, but its row
only shows for types that can carry a model. CV stores every dimension in **millimeters** and shows it in
your unit (inches here), so 37 mm appears as 1 15/32 and 20 mm as 25/32 (both confirmed on a hinge).

**Sheet and stock types** (sheet size, thickness and CNC section):

| Type | Unit of Issue | Starting values |
|---|---|---|
| Panel Stock | Sheet | 48 x 96, thickness 3/4 |
| Board Stock | SQ FT | Thickness 1/2, Rough Thickness 3/4 |
| Laminate | Sheet | Size 48 x 96 x 1/16; **Oversize 1/2** |
| Banding | Per FT | Length Trim 1/2, thickness 0.5 mm |
| Composite | Each | Pre-Assembled off; its size is calculated from its layers and cannot be edited |
| Counter Top | Each | Six charges (see below), all 0 |
| Molding | Per FT | Type Crown, Length 8 ft, Cost Per Joint 0, Miter Trim 0 |
| Miscellaneous | Each | Thickness 3/4, Model off |

**CNC section defaults** (Panel Stock, Board Stock, Laminate and Composite): Optimize on, Grain Dependent on,
Drop Width and Drop Length 0, Feed Rate Percent and Spindle Speed Percent 100, **Minimize Face Chip and
Minimize Back Chip both on (which selects a compression bit)**, Climb Cut off, Maximum Depth Per Pass 0.
The **Laminate Oversize** is added to the part so the laminate can be trimmed flush after pressing: a
12 x 29 1/4 part with 1 in of oversize needs a 14 x 31 1/4 blank.

**Hardware types** (Unit of Issue Each unless noted):

| Type | Starting values |
|---|---|
| Hinge | Concealed; Horizontal and Vertical Overlay 1; Door End to Hinge 37 mm (shows as 1 15/32); Inset 0; Maximum Spacing 24; Opening Angle 125 degrees; Door Edge to Reference Point 20 mm (shows as 25/32); Roll Out Clearance 0. **Operations tab:** hinge cup diameter 1 3/8 and depth 15/32; anchor holes cup to anchor 3/8, diameter 5/16, depth 15/32, spacing 1 7/8 |
| Hinge Plate | Type Frame; Plate Hole Offset 37 mm |
| Drawer Guide (**Pair**) | Side Mount; Height 1; Length 400 mm (shows as 15 3/4); Extension 18; Screw Center Reference to Top False; Screw Center To Box Reference 0; Back Notch Length, Height and Offset 0; **Side Clearance 8.5 mm (shows as 11/32); Minimum Below Box 1/32; Minimum Above Box 12.5 mm (shows as 1/2)**. **Operations tab:** mount holes 3/16 diameter and 15/32 deep with Position 1 at 1 1/4 (Positions 2 to 6 at 0); front mount holes and back mount holes all 0. Layers: **Assembly Member** and **Box Member** |
| Pull | Knob (fixed at creation); Horizontal Inset 1 1/2; Vertical Inset 2. **Operations tab:** Mounting Holes, Diameter 3/16 (the only field). Layers: **Shaft** and **Pull**, each with a fixed grey finish, Metal - Matte and a Blank texture |
| Wire Basket | Side Mount; Depth 14, Width 18, Height 6; First Hole Offset 32 mm |
| Rod | Length 36 |
| Sliding Door Rail | Length 36 |
| Sliding Door Roller | Roller; Door Edge Inset 2; Door End Inset 3; Mount On Back on; Slot Reference Center; Slot Offset 0 |
| Leg, Leg Leveler, Caster | Height 4 (this sets the assembly's elevation) |
| Connector | Type Rafix |
| Shadowline Channel | Length 36 |
| Finger Pull | Length 30; Edge Trim 3/4 |
| Shadowline Bracket | **Inset** 1 15/32 (37 mm); the preview shows a two-hole bracket with the inset measured to the top hole. **Operations tab:** hole Diameter 3/16, Depth 15/32, Spacing 1 1/4. Layer: one, a locked grey with Metal - Matte and a Blank texture. Seen on Jon's material (no help page). *(The earlier guess "Bracket Hole Offset" was wrong; the window's label is Inset.)* |
| Molding Set | Nothing of its own (unit Each) |

**Counter Top** belongs to a **separate module that Ironwood doesn't have**, so it is not verified in Jon's CV
and is out of scope for now. It has no help page. Its fields, inferred from their names, are Cost Per Butt Joint, Cost Per
Miter Joint, Cost Per Cutout, Cost Per End Cap, Cost Per End Splash and Scribe Trim, plus a size (for
example 16 deep by 8 ft by 3/4). It carries neither a model nor a profile.

### Sub-types (the Type dropdown on each material)

- **Hinge:** Concealed, Exposed, Double Door. The Type is fixed when the material is created and shows greyed
  out afterward. It could only be changed by editing the database directly, which is advanced and rarely done.
- **Hinge Plate:** Panel, Frame, Inline (the help lists only Panel and Frame).
- **Drawer Guide:** Side Mount, Bottom Mount, Top Mount, System.
- **Pull:** Knob, Pull, Cup.
- **Wire Basket:** Side Mount, Bottom Mount, Top Mount, No Mount (the help lists three).
- **Sliding Door Roller:** Roller, Slot. Its **Slot Reference** is Center, Back or Front.
- **Finger Pull:** only C-Rail exists in this build; the help also lists Flat-Rail and U-Rail.
- **Shadowline Channel:** L-Channel, C-Channel and J-Channel exist as choices, but the material has no
  field for them (confirmed on Jon's material: its only own field is **Length**, and the layer is a locked
  grey with Metal - Matte and a Blank texture). **The channel type is chosen in the Assembly Wizard**
  (Jon: "another VERY important area to cover"; not yet documented). Kit, Parameters and Model are
  enabled on this type, Composite and Profile are not. Jon's example material carries an `x` name prefix
  (his "to be deleted" mark).
- **Molding:** Crown, Top Edging, Light Rail, Scribe, Base Board, Chair Rail, Casing, Applied, Ceiling,
  Bead, Outside Edge, Inside Edge, Raised Panel, Door Route, Finger Pull, Door Applied.
- **Connector (21):** Rafix, Clamex P-10, Clamex P-15, Clamex P Medius 15/10, Tenso P-14, Connector
  (generic, no model), Lockdowel, FastenLink, Clamex P Medius 14-10, Clamex P-14, Cabineo 8, Cabineo 12,
  Divario P-18, Tenso P-10, Peanut 1, Peanut 2, Clamex S-20, Cabineo X, Lockdowel Spring Pin, Lockdowel
  H-Clip and Lockdowel Channel Lock. Clamex and Tenso types need a 4 1/2-axis machine with Lamello's
  Clamex saw, FastenLink needs a shaped tool in the S2M Center tool catalog, and the generic Connector has
  no model so you can build your own.

### Gotchas

- **Never put a quotation mark in a name** (write `1/2in Melamine`, not `1/2" Melamine`); it breaks job
  optimization. The help also warns against `#`.
- **Board Stock and Panel Stock read different size tables.** *(UNVERIFIED: the "missing board info"
  error and the MDF/solid-species rule come from `CVData Materials & SQL.md` section 5.5 and are not in the
  help; their original source is unknown. See `Unverified Knowledge.md` item M12.)* The claim there is that
  choosing the wrong type gives "missing board info" in jobs even when the sizes are filled in, and that MDF
  and engineered sheets are Panel Stock at every thickness while only solid species are Board Stock.
- **What decides whether parts reach S2M is Optimize plus a valid sheet size, not the S2M Material
  flag, and a Buyout schedule overrides both** (see Optimize under CNC section). S2M Material only lists the material in S2M CENTER's own material catalog (for per-material
  overrides, adding a material to a job by hand, and stand-alone work such as Import Cutlist). **Jon sets it
  On for every material that is set to Optimize**, since those materials go to S2M anyway.
- **Drawer guide cost is per guide, not per pair.** Side Clearance is doubled and subtracted from the
  opening to get the drawer box width; Minimum Above Box, with the drawer construction method, sets the
  box height.
- **Banding has no width**; it always takes the thickness of the part it goes on.
- **Aliases are not supported** for Composite, Connector or Molding Set materials.
- **Composite** size fields are read-only and calculated from the layers.
- **Miscellaneous** is the only type where a model is a per-material choice (its Model property).
- **Deleting** a material does not remove it: CV renames it `{d}<name>(n)` and marks it deleted.
- **Update Job → Materials** is how later catalog changes reach an existing job (see Update Job under
  System parameters in `UCS.md`).

For how all of this is stored in CVData, and for creating many materials by script, see
`CVData Materials & SQL.md`.

### Material parameters (read with `_M:`)

*(Jon has added only a few custom material parameters so far.)* A UCS reads a material's values with `_M:NAME` on a part that uses that material (for example `_M:DZ` is
the thickness of the part's material). The same tokens drive the formulas inside models (`_M:HEIGHT`,
`_M:DEPTH`, and so on; see `CVData Materials & SQL.md`). Custom parameters you add to a material with the
**Parameters** button are read the same way and do **not** show in the Object Tree. The names are not always
the same as the window labels, so use this table.

| Type | Parameter (read as `_M:NAME`) | What it returns |
|---|---|---|
| Banding | `DZ`, `TRIM` | Thickness; length trim |
| Board Stock | `DZ`, `RT` | Thickness; rough thickness |
| Laminate, Panel Stock, Composite | `DX`, `DY`, `DZ` | Width; length; thickness |
| Laminate | `TRIM` | The oversize value |
| Composite | `_PREASM` | Pre-assembled (0 no, 1 yes) |
| Board, Composite, Laminate, Panel | `CNCOPT`, `CNCGD`, `CNCDW`, `CNCDL`, `CNCFRP`, `CNCSSP`, `CNCMFC`, `CNCMBC`, `CNCCC`, `CNCMDPP` | Optimize; grain dependent; drop width; drop length; feed rate percent (0 to 100); spindle speed percent (0 to 100); minimize face chip; minimize back chip; climb cut; maximum depth per pass. The yes/no ones return 0 or 1 |
| Hinge | `HT`, `SOLAY`, `TBOLAY`, `MDETH`, `INSET`, `MHS`, `OA`, `DBE`, `ROCLR` | Type (1 Concealed, 2 Exposed, 3 Double Door); horizontal overlay; vertical overlay; door end to hinge center; inset; maximum hinge spacing; opening angle; door edge to reference point; roll out clearance |
| Hinge Plate | `PHOFF` | Plate hole offset |
| Drawer Guide | `GT`, `HEIGHT`, `DEPTH`, `EXT`, `MH1P`, `SCREF`, `SCTBB`, `BKNLEN`, `BKNHGT`, `BKNOFF` | Type (1 Side, 2 Bottom, 3 Top, 4 System); height; length; extension; first hole offset; screw center reference; screw center to box bottom; back notch length, height and offset |
| Drawer Guide, Wire Basket | `SC`, `MBB`, `MAB` | Side clearance; minimum below box; minimum above box |
| Wire Basket | `GT`, `DEPTH`, `WIDTH`, `DZ`, `MH1P` | Type; depth; width; height; first hole offset |
| Pull | `PT`, `IW`, `IH` | Type (1 Knob, 2 Pull, 3 Cup); horizontal inset; vertical inset |
| Molding | `DY`, `_MJCOST`, `_MTRIM` | Length; cost per joint; miter trim |
| Miscellaneous | `DZ`, `MODEL` | Thickness; whether it includes a model (0 or 1) |
| Caster, Leg, Leg Leveler | `Height` | Height |
| Rod, Shadowline Channel, Sliding Door Rail | `LEN` | Length |
| Sliding Door Roller | `MNTPLTSTL`, `MNTPLTPOSSIDE`, `MNTPLTPOSTOP`, `MNTPLTONBACK`, `MNTDADOREF`, `MNTDADOOFF` | Type (1 Roller, 2 Slot); edge inset; end inset; mounts on back (0 or 1); dado reference; dado offset |
| Connector | `CONT` | Connector type (the help lists values 1 to 6: Rafix, Clamex P-10, Clamex P-15, Clamex P Medius 15/10, Tenso P-14, Connector) |
| FastenLink connector | `_FLPLUNGEDEPTH`, `_FLRAMPDEPTH`, `_FLGLUEDEPTH`, `_FLFULLDEPTH`, `_FLRAMPSPAN`, `_FLFLATSPAN`, `_FLGLUESPAN`, `_FLFULLSPAN` | Tool depths (initial plunge, bottom of the ramp, top of the glue pocket, bottom of the cut) and spans measured from the entry of the fastenlink (to the ramp bottom, the start of the start glue pocket, the start of the end glue pocket, and its assembled position) |

**Places where the help's parameter list and the CVData reference disagree** (check the live value before
relying on either):
- **Wire Basket type codes:** the help says 1 Side Mount, 2 Top Mount, 3 Bottom Mount; the CVData lookup says
  1 Side Mount, 2 Bottom Mount, 3 Top Mount, 4 No Mount.
- **Sliding Door Roller dado reference:** the help says 1 Back, 2 Center, 3 Front; the CVData lookup says
  1 Center, 2 Back, 3 Front.
- **Drawer Guide screw center reference (`SCREF`):** the help says 0 = Top, 1 = Bottom; the CVData column
  `ScrewCenterRefTop` reads as true = top. **Confirmed in Jon's CV:** the window field is labeled **Screw
  Center Reference to Top**, and **True** measures the screw
  centers from the **top of the drawer box** and **False** from the **bottom of the guide** (Jon's
  clarification). So True = top matches CVData and the label, and the help's 0/1 wording looks reversed.
  `CVData Materials & SQL.md` says false references the bottom "of the drawer box", which differs from Jon's
  "bottom of the guide"; treat Jon's wording as the confirmed one. **The help contradicts itself on this
  field:** the General-tab entry says top of the **Drawer Box** (enabled) or the Drawer Box **bottom** (not
  enabled); the Operations "Mount Holes → Top Reference" entry says top of the **Guide**; and the `SCREF`
  parameter says 0 = Top, 1 = Bottom. *(What the "bottom" reference is exactly, and the value `_M:SCREF`
  returns, are still unsettled.)* *(What `_M:SCREF` actually
  returns for each setting was not tested; check the live value before a UCS relies on it.)*
- **Wire Basket and Sliding Door Roller:** not checked, because Jon rarely uses them. Leave both
  disagreements above as unverified.
- The help lists the Closet Rod length parameter as applying to "Banding", which is a typo in the help.

### Setup packages

The `.pkg` groups in the Material Manager come from **Setup Package** imports. Setup Packages transfer many kinds of
objects (materials are only one), so they are covered in `Setup Packages.md`.

### Finishes, Finish Types and Textures

The **Finish**, **Finish Type** and **Texture** buttons in the Material Manager open three libraries.
*(Confirmed against Jon's CV install unless marked otherwise. All three are opened from the Material
Manager ribbon's **Finishes** set.)*

- **A Finish** is a named color. The **Finishes** window has a selector dropdown (with a color chip),
  a binoculars **Search**, and **New**, **Copy** and **Delete** buttons. Fields: **Name**, **Description**
  and a read-only **ID**. Below them is a color palette (click to pick a starting color), three RGB
  sliders with 0 to 255 boxes, a preview swatch, and one horizontal slider under the swatch. That slider
  scales all three RGB values together: **left = every RGB value drops (darker), right = every RGB value
  rises (lighter)**. The help calls this **Luminance**, but the window doesn't label it.
  **There is no Save button: edits are written when you press Close.** The binoculars **Search** finds
  finishes by name.
- **A Finish Type** describes how a surface reflects light. The window has a selector dropdown and
  **New**, **Copy** and **Delete** buttons, then Name, Description, a read-only ID, the Shader dropdown
  and the sliders below, with a **Preview** panel on the right. **Jon's Finish Type list is mostly his
  own**, not CV's out-of-the-box set (the help lists six system types; the Shader dropdown has seven
  entries). Slider settings have no numeric readout. As an example, Jon's **Matte** (Wood shader) has
  Ambient about mid-way, Diffuse low (about a quarter), and Specular, Shininess and Transparency at zero,
  which fits the help's "Diffuse below 50% is more matte." **Jon's method for a new Finish Type: Copy
  an existing one that's close, then adjust it while watching the Preview.** **Which Shader Jon uses:**
  Wood for wood and woodgrain laminate, Plastic for solid colors, Metal for hardware (Glass and Mirror for
  glass and mirrors). It has a **Shader** (Glass, Gloss Metal,
  Gloss Plastic, Metal, Mirror, Plastic or Wood) and sliders for **Ambient** (base color; typically
  50%), **Diffuse** (above 50% is shinier, below is more matte), **Specular** (mirror-like reflection),
  **Shininess** (how much it reflects) and **Transparency** (how much the texture below shows through,
  so wood grain shows through a stain).
- **A Texture** is the pattern (such as a wood grain) that appears on a layer. Textures are usually black
  and white and pick up their color from the room's finish, but a texture can also be a full-color image
  (such as a scanned marble sample). The Texture window's toolbar can **Import Image**, **Delete**, and
  switch between a list view and a thumbnail view; double-click a texture (or right-click →
  **Properties**) to edit it.
  **Texture properties** (list view): ID and Path (not editable), Name and Description, **World
  Width** and **World Height** (the real-world size the image represents), **Decal** (on = the finish
  is not blended with the texture, so the texture stands alone and is not tinted by the room finish)
  and **Tile** (on = the pattern repeats at the world width and height across the surface; without it
  the texture appears once and may not cover the surface). Texture categories also have a **Show Model
  Folder** option, which shows textures that came in with imported SketchUp models. Import an image
  with **New** (or Import Image) from a file that lives somewhere other than the folder you import it
  into. The help's example makes speaker cloth by creating a Miscellaneous material with the new
  texture on its face, then assigning that material to the flat-panel category in a Door material
  schedule. Textures can also be added from a job's 3D view.
- The Finish Type window has a **Preview** area (a sphere) for testing the finish type against a
  **Finish** picker, a **Light** picker (for example White Light), **Brightness**, and a **Texture**
  checkbox with a browse button. **All of these are preview-only**, including the Texture checkbox:
  nothing chosen there is saved onto the Finish Type.
- **How the Texture Manager looks.** Toolbar: **New**, **Delete**, **List view** and **Thumbnail view**
  (the help calls the New button "Import Image"). Left sidebar: a search pane and a category pane, mostly
  manufacturers (Egger, Fenix, Kronospan, Prism, Wilsonart and so on) plus Glass, Wood and Metal. Groups
  starting with **x** are Jon's own mark for "to be deleted"; ignore them. Columns: ID, Name, Description,
  Path, World Width, World Height, Decal and Tile.

**Adding a texture: the Import Texture window.** In the Texture Manager, pick the category, then press
**New**. The **Import Texture** window opens. Top left is an **import-image button** (an image icon with a
green arrow). Below it is a preview area, then **Name**, **Description**, **Tile** and **Decal** checkboxes,
and a **World Size** group (**Width** and **Height**, both 0 by default), with **OK** and **Cancel**. When
first opened, Name, Description, Tile, Decal, the World Size boxes and OK are all greyed out. **After you import
an image, it shows in the preview and those fields (and OK) become editable.** You set the name, description,
tile, decal and world size, then press OK.

**Where texture images live, and how to update one (confirmed by Jon):** imported images are kept with the
CV database, in the **`Graphics`** folder of the database directory (on Jon's work PC:
`Z:\Planit\Common 2025\Database\Graphics`). The Texture Manager's Path column shows just the file name. A
texture is **not easy to change once imported**. Deleting and recreating it works but is the slow way.
**To update an image in place:** edit the source image, then copy it (**with the same file name**) into
that `Graphics` folder and choose **overwrite** when Windows asks. The texture then shows the updated
image.
**How Decal, Tile and World size work (confirmed by Jon):**
- **Tile OFF:** the image is **stretched once over the whole face**. World Width and World Height are
  ignored (a texture with 0 and 0 is normal).
- **Tile ON:** the image repeats at World Width x World Height across the surface, so those two values
  matter only here (for example a 48 x 96 sheet image). **A non-seamless image (edges that don't match
  their opposite edges) shows obvious seams when tiled and gives poor results.**
- **Decal** decides whether the texture blends with the finish:
  - **Decal OFF** for anything that would normally be **painted or stained** (raw wood, for example).
    The texture blends with the finish color, which looks more realistic.
  - **Decal ON** for **manufactured products** such as melamine, Chemetal and Cleaf. The finish would not
    naturally be applied to them, so the texture stays unaffected by the finish.

**Where library edits go (confirmed by Jon):** a job snapshots Finishes, Finish Types and Textures like
materials. Editing the library changes existing jobs **only through Update Job**.

**Where these get assigned, and how they resolve (confirmed by Jon):**
1. **On the material:** each layer in Material Properties has a Finish, Finish Type and Texture. A
   **locked color swatch** on a layer always wins. The word **Automatic** means the layer follows the
   room's finish.
2. **Room finishes:** a room has an **Interior** finish and an **Exterior** finish. They can be set at
   **Job, Room, Assembly and Part** level, and the level nearest the part wins.
3. **On a part (override):** right-click a part, **Properties**, **Finish** tab in **Part Properties**
   (tabs: General, Comment, Flutes, Finish, Overrides, Parameters). There are four groups: **Front Face,
   Back Face, Edges, End**. Each has an **Interior / Exterior / Select** choice (Select enables a finish
   dropdown for that surface, greyed out otherwise) and a **Texture** button. **Interior and Exterior mean
   the room's Interior and Exterior finish.** You can't change a material's own layers from a job; this
   is a part-level **override** that stays until you remove it.

**Where each level is edited (confirmed by Jon):**
- **Job:** Job Properties → **Finish** tab.
- **Room:** Room Properties → **Finish** tab. Room finishes/textures can also be changed **in the 3D
  (perspective) view when nothing specific is selected**.
- **Assembly:** Assembly Properties → **Finish** tab, or select the assembly in the 3D view. It
  highlights, and its **current mappings appear in the sidebar** where they can be edited.
- **Part:** Part Properties → **Finish** tab (above).

**The 3D view sidebar (seen in Jon's CV 2025):**
- **Nothing selected:** the sidebar shows **Camera, Lights, Finishes, Textures** and **CAD (F7)**, then
  the Job Parameters and Room Parameters lists. **Finishes** opens a list of color swatches, one per room
  surface: Assembly Exterior, Assembly Interior, Wall, Floor, Ceiling, Counter Top, Molding,
  Doors/Windows, Appliances, Bath Fixtures and Sinks. **Textures** opens a matching list with texture
  previews: Assembly Exterior, Assembly Interior, Wall, Floor, Ceiling, Counter Top, **Splash** and
  Molding (Splash appears only in the Textures list). These are the room-level finishes and textures.
- **An assembly selected:** it highlights (cyan outline) and the sidebar shows that assembly's name (for
  example *MW Tall*) with a **Visual** group (**Exterior Finish**, **Interior Finish**, **Exterior
  Texture**, **Interior Texture**) and a **Materials** group (**Assembly** material, **Pulls**).
- **Texture choices include two special entries (Jon):** **Blank** (shown as **-None-** in the sidebar)
  applies **no texture and uses just the finish**, and **Automatic** uses the **room's texture**. Blank is
  a real choice, not an "unset" state; it is the same Blank a new hinge layer starts with.

**The texture picker.** Choosing a texture (for example from a Texture button or field) opens the **Texture
Manager** window itself, with a few additions compared with opening it from the Material Manager: a
**Recent** group at the top of the category tree, an **Automatic** checkbox (bottom left), a **Blank**
checkbox (bottom middle), and one extra icon in the toolbar next to the List and Thumbnail buttons.
**Thumbnail view** shows a grid of image previews with names and is **Jon's preferred view**; **List view**
shows the columns (ID, Name, Description, Path, World Width, World Height, Decal, Tile). In Jon's list the
wood-grain textures (Alder, Baltic Birch, Rift Cut Walnut, Hickory and others) have **Decal off, Tile on**
at sizes like 36 x 72 or 48 x 96, while flat or manufactured ones (Silk White, Light Gray, Particle Board,
Stainless Steel) have **Decal on**, which matches the Decal rule above.

The extra toolbar icon (yellow and blue) has the tooltip **"System Textures"** and nothing else. Jon
believes it hides CV's system textures, but that is **unverified**, and the help doesn't document it.
**Clicking it changes nothing visible in Jon's list** (possibly because no system textures are loaded);
treat it as an unexplained control.

**Extra facts from the help (not yet checked in Jon's CV):**
- **Texture may decide one-sided versus two-sided panel stock for S2M (help only; Jon had believed texture
  was purely visual and had not seen this, so treat it as UNVERIFIED until tested).** If the Face and Back layers have the
  **same texture, or no texture**, the material is **two-sided** and S2M CENTER may flip parts to balance
  operations. If the Face and Back **textures differ**, S2M treats it as one-sided, never flips parts, and
  tells the operator which texture (by name) to put face up. For a material with no pattern, choose the
  **Blank** texture on the layer.
- **Jon's suggested practice for panel stock layers (a suggestion, not a rule):** set each material to
  **mimic reality**, including setting the **Edge and End layers to the core** of the panel, so anything that
  looks off is easy to spot visually in 3D. Doing this makes spotting discrepancies much easier than
  combing through material reports. Solid lumber (Board Stock) and banding follow the same idea: a real look on every
  layer. Face and Back textures therefore vary by material (some match, some differ), which is
  why the S2M sidedness rule above is worth testing.
- **Closing a Finish or Finish Type window asks whether to save** ("click Yes to save"), which matches
  Jon's "saves when I close".
- **3D view → Properties tab → Materials Visual and Finish Types Visual** list every material and finish
  type in the current job and let you change their color, texture and finish type. **Changes there are for
  visual purposes only** and it saves returning to the System level to tune a render.
- **Rendering dependencies:** wood grain shows only in **Texture render mode or xRender**; see-through glass
  needs Preferences → Views tab → **High Detail**; a **mirror's reflection** shows only in xRender's
  **Architectural Render**. The Finish Type Preview itself uses PhotoVision.
- **Smoked glass recipe (help):** make a very dark Finish (all RGB sliders to the top for black), **Copy**
  the **Glass** Finish Type and tune **Shininess** and **Transparency**, then put that Finish, Finish Type
  and the **Blank** texture on every layer of a Miscellaneous material, and drag that material onto the door
  glass-panel part in a Door Material Schedule.
- **System Textures icon:** the help has nothing on it (searched for system texture wording and the picker).

**Troubleshooting a part that looks wrong in 3D (Jon's order):** check **the material mapped to that
part** first. Only if the material is correct, dig into **overrides** (the part's Finish and Overrides tabs,
then higher levels). **The material schedule carries the mapping for parts.** If the material a part is
actually using differs from what the schedule says for that part, **the part's material has been
overridden.** To read the material a part is actually using, open **Part Properties**, or look at a **report table of
that assembly**. *(The full schedule walkthrough comes in step 3 of the build order.)*

**Multi-window mode (Jon's side note):** CV can be run in a multi-window mode that shows several things at
once, including a **live report of everything inside the view you're working in**. It is useful for
checking materials while you work, and Jon doesn't use it as much as he thinks he should. At the assembly
level the live report lists each part with its **Material**. Full details are in "Multi-Window Mode" in
`Core.md`.

**The part's Overrides tab** (Part Properties) **lists every override currently set on the part**, including
finish and texture ones made from the Finish tab. An override stays until it is removed. Removing (clearing)
one means deleting the parameter CV inserted on that branch, and where you do that depends on where it
lives (a Part's Overrides tab, or the Object Tree). A UCS-created override can't simply be deleted because
it is re-applied on rebuild. See "How overrides work" and "Clearing an override" in `Core.md`.

**To remove one from a part:** open Part Properties → **Overrides** tab, **select the override's row, and
press Delete/Remove**.

*(Still to confirm: a fresh end-to-end walk-through of this whole section, since the last few answers were
picked from lists and the exact button label and any confirmation prompt were not seen.)*

### Material types

Every material has exactly one **Type**, chosen from this list when the material is created (**New**).
After that the Type field is greyed out in Material Properties. The types are:

Banding, Board Stock, Caster, Composite, Connector, Drawer Guide, Finger Pull, Hinge, Hinge Plate,
Laminate, Leg, Leg Leveler, Miscellaneous, Molding, Molding Set, Panel Stock, Pull, Rod, Shadowline
Bracket, Shadowline Channel, Sliding Door Rail, Sliding Door Roller and Wire Basket.

The help's New Material topic lists 22 types (it has no Shadowline Bracket), while the dropdown in this
installation shows the 23 above, so the installed version is the one to trust. The catalog data also
contains a **Counter Top** type that is not in that creation dropdown.

The Type is separate from the folder a material sits in (the folders are Jon's own organization).
The Material parameters reference (`Reference/`) lists which parameters apply to which types.

## Priority

Like parameters, the nearest schedule wins: an **assembly's** schedule, then the **room's**, then the
**job's**.

## Kinds of schedule

There is more than one kind. Known so far (there may be others):

Assembly, Closet Rod, Countertop, Door, Drawer Box, Hinge, Molding, Pull, Roll Out, Room, Sliding Door
Rail, Wire Basket and Layers (Layer Schedules are covered in `Core.md`).

They are stored in tabs within the **Job**, **Room** and **Assembly Properties** windows (*which tab
holds which schedule is still to confirm*).

## How schedules meet the UCS

- **Dimming a part:** a dim'd part looks up the material schedule for its material, and `DZ` follows
  that material's thickness. Set `MATID` only to force a different material. See "The nine basic
  parameters in code, and creating objects with dim" in `UCS.md`.
- **`_M:SCHEDID`** (System Defined Query Only, applies to a part) returns the ID of the part's material
  schedule as a whole (two parts on the same named schedule return the same number), not a row.
  Because the schedule is assigned upstream and a UCS never writes it, it is a stable field to branch
  on. Read the schedule to decide what to do, and write the material (`MATID`), so the UCS is not
  reading a value it also changes. See `UCS.md`, "Discriminate on a field you don't write".
- **Updating:** a job snapshots materials, construction and doors when it is created. Run
  **Update Job** (Utilities tab) and tick **Materials** to pull later changes into an existing job.

## Order we are building this in

1. **Materials:** the material catalog and its properties (drafted from the help; the walkthrough is
   waiting on Jon to check it in CV).
2. **Parts:** the Part Manager and how a part is defined (including its material type).
3. **Schedules:** one kind at a time, starting with the Material Schedule.
4. **In the job:** resolution, priority and overrides (much of this is written above and in `UCS.md`).

Still to confirm along the way: which tab in each Properties window holds which schedule, and how a
schedule is created and edited (the Material Schedule Manager).
