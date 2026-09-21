# Setup Packages

A **Setup Package** is how Cabinet Vision moves custom objects from one installation to another. (The `.pkg` groups that appear in the Material Manager come from Setup Package imports.) A Setup Package
moves specific objects from one CV installation to another as a single file, and **the unique identifiers
are stored and recreated on the receiving system**, so it is plug and play. (This is also why material IDs
differ between systems and must never be copied across.) The help's example is a Blum Metabox drawer system:
without a package you would export each UCS and Intelli-Joint and rebuild each drawer guide material and
schedule by hand, then link them in the UCS.

**Where:** Utilities tab → **Setup Package** button (from the start screen).

**What can go in a package:** bid reports (custom reports and Word forms), catalogs, connections,
construction methods, door catalogs, doors, drawer boxes, drawings (title blocks and symbols), finish types,
finishes, Intelli-Joints, labels (Label-IT or saw graphics only), machines, material schedules, materials,
parameters, parts, profiles, rate tables, reports, roll outs, S2M reports, textures, tools, top construction
methods, User Created Standards and vendors.

**What comes along automatically:**
- A **material** brings its finishes and textures.
- A **material schedule** brings all of its materials.
- A **door** brings its profiles and material schedules.
- A **drawer box** or **roll out** brings its material schedule.
- A **tool set** brings its tools.
- A **UCS** brings everything it calls: Intelli-Joints, materials, finishes, material schedules and so on.

**Exporting:** select items in the list (there is no limit) and click **Add Items To Package**, then **Save
Current Package**. Fill in the **Create License** screen (a license description and your contact details) and
save the file. If the package holds an object catalog you also choose a license type: none (a normal
catalog), **Protected** (read-only, optionally hiding the cut list) or **Distributed** (a self-contained
read-only catalog that carries its own materials and construction methods; it cannot be updated, only
replaced). You can then close the screen or e-mail the package from Outlook.

**Importing:** Setup Package → **Open An Existing Package**, pick the file, open the **Import** tab and click
**Import Package**. Before importing you can set a **prefix** (Add Prefix) that is added to the names of every
imported object. For items that already exist you choose how to handle them:

| Option | What it does |
|---|---|
| All Matches - Overwrite | Overwrites every existing item with the package's version |
| All Matches - Use Existing | Keeps your existing items and ignores the package's |
| Child Matches - Overwrite | Overwrites existing children of the package's items that match |
| Child Matches - Use Existing | Keeps your existing children |
| Toggle Overwrite | Lets you choose overwrite or use-existing item by item |

**Uninstalling:** Setup Package → **Show History of Imports**, select the package and **Delete**.

The separate **Backup Utility** (Utilities tab) backs up the Core Data (construction methods, materials,
material schedules, doors, parts, catalogs and more) and is not the same as a Setup Package.

*Still to cover: the Backup Utility in detail, and a walkthrough of the Setup Package window from screenshots.*
