# Unverified Knowledge (running checklist)

Everything in the Knowledge Base that is **not yet confirmed in Jon's own CV**, in one place so it can be tested later.

**How to use:**
- Tick the box (`- [x]`) when an item is tested, and add the date and result on the line under it.
- Then update the source file the item came from (remove its *unverified* flag or correct the text).
- Add new items as they come up. The source file should also carry the *unverified* flag.
- Keep ticked items in place until they're moved to "Resolved" at the bottom.

Last compiled: 2026-09-25.

## Materials & Schedules (`Cabinet Vision/Materials & Schedules.md`)

- [ ] **M1. Texture decides one-sided vs two-sided panel stock in S2M.** Now confirmed **directly in
  Hexagon's S2M CENTER help** (`Reference/S2M Help/S2M Intro.txt`, the "Print" topic, with a worked
  "Particle Board" example) — this is no longer just the CV help's word. Face-dependent (different
  Face/Back textures) = one-sided, loaded a specific way; identical textures = two-sided, no load
  indicator needed. Still not seen by Jon in his own output.
  *Test remaining:* find or produce a real S2M pattern printout on Jon's system and confirm the load
  indicator appears as described.
- [ ] **M2. System Textures icon** in the Texture picker (tooltip "System Textures"). Not in the help; clicking it changes nothing visible in Jon's list.
  *Test:* click it on an install that has system textures loaded, or ask Hexagon support.
- [ ] **M3. Drawer Guide "Screw Center Reference to Top."** What the "bottom" reference is exactly (bottom of the guide vs bottom of the drawer box) and what `_M:SCREF` returns for each setting. The help contradicts itself (General tab: drawer box; Operations tab: guide; `SCREF`: 0 = Top). Jon's wording: True = top of the drawer box, False = bottom of the guide.
  *Test:* flip the setting on a test guide and watch where the mount holes land, then read `_M:SCREF` in a UCS or the Object Tree.
- [ ] **M4. Wire Basket type codes.** Help: 1 Side, 2 Top, 3 Bottom. CVData: 1 Side, 2 Bottom, 3 Top, 4 No Mount. Jon rarely uses baskets.
  *Test:* create a basket of each type and read `_M:GT`.
- [ ] **M5. Sliding Door Roller dado reference codes.** Help: 1 Back, 2 Center, 3 Front. CVData: 1 Center, 2 Back, 3 Front. Jon rarely uses rollers.
  *Test:* set each Slot Reference and read `_M:MNTDADOREF`.
- [ ] **M6. Which Properties tab holds which schedule**, and how a schedule is created and edited (Material Schedule Manager). Not yet written up.
  *Test:* walk through Job / Room / Assembly Properties and note each schedule tab (build order step 3).
- [ ] **M7. End-to-end walk-through of the Materials section.** The Material Manager and Properties text was drafted from the help and hasn't been checked against a live walk-through.
  *Test:* Claude walks Jon through creating a material from the docs alone.
- [ ] **M8. Which pane is active** when the ribbon shows Set Columns and the sidebar shows Order Entry / Bid Center (multi-window mode). The screenshots didn't record it.
  *Test:* click into a Reports pane, then a drawing pane, and watch the ribbon and sidebar.
- [ ] **M9. Counter Top material fields** (Cost Per Butt Joint, Miter Joint, Cutout, End Cap, End Splash, Scribe Trim). Separate module Ironwood doesn't have; inferred from column names.
  *Test:* out of scope until the module is available.

- [ ] **M10. Maximum Depth Per Pass = 0.** The help doesn't say what 0 means; presumed "no limit from the material, use the tool's value."
  *Test:* leave a material at 0 and confirm the toolpath uses the tool's maximum depth.
- [x] **M11. General CNC explanations** in the CNC section. Resolved 2026-09-25 — Jon: keep the Materials
  section scoped to what each setting does and affects, not general machining education. The up-shear/
  down-shear/compression and climb-vs-conventional explanations were trimmed out of `Materials &
  Schedules.md` in favor of short pointers to `04 Machining/Products.md` (bit physics, sourced) and
  `Machining.md` (the full Automatic Tool Selection Logic, which had also been moved there).

- [ ] **M12. "Missing board info" error and the Panel vs Board Stock rule** (MDF and engineered sheets = Panel Stock at every thickness; only solid species = Board Stock). Appears in `CVData Materials & SQL.md` section 5.5 and the Gotchas in `Materials & Schedules.md`. Not in the help; where it came from is unknown.
  *Test:* create a panel-style material as Board Stock (and the reverse) in a test job and see whether the error appears; ask Jon whether he has seen it.

- [ ] **M13a. Feed/speed math on output.** Both the CV help and the S2M help (`Reference/S2M Help/S2M Tid-Bits.txt`) use identical wording: tool feed rates at 1/4 in and 3/4 in cut depths are used to output varying feed rates by depth of cut and the material's percent. The calculation itself (interpolation, order of scaling) is still not spelled out anywhere found so far.
  *Test:* post a job with a known tool and a material at 100 percent, then at 80 percent, and compare the feed values in the G-code.
- [x] **M13. S2M Automatic Tool Selection logic and how the material CNC settings interact with S2M tool settings.** Resolved 2026-09-25: Jon obtained and added the S2M CENTER Help (`Reference/S2M Help/`, 4 PDFs + extracted text: Intro, Ribbonbar, Sidebar, Tid-Bits). The full tool-selection logic (by operation type: Part Outline, Vertical Hole, Horizontal Hole, Dado, Cutout/Pocket Route) is now written into `Materials & Schedules.md`'s CNC section. Note: the logic's reference charts (#1–#6) are diagrams that did not survive PDF-to-text conversion — read the source PDF directly if a chart is needed.

## CVData and SQL (`Cabinet Vision/CVData Materials & SQL.md`)

- [ ] **D1. Creating Banding, Laminate, Molding, Composite and flat Miscellaneous materials by SQL.** Structurally simple and clonable but not verified end to end. Only Panel Stock and Board Stock are proven.
  *Test:* follow the pre-flight checklist (Part 6.5), create one of each by cloning a wizard-made row, and check it in the Material Manager.
- [ ] **D2. Materials with no Extra-Info row of their type** (for example banding without `MaterialExtraBandingInfo`): fine, or quietly broken?
  *Test:* compare a working and a row-less material in a job.
- [ ] **D3. Pre-flight checklist (Part 6.5)** has not been run against the live database.
  *Test:* run the read-only queries and compare the results to the file.
- [ ] **D4. Shadowline Channel type storage.** The Info table has no type column and the Material Properties window has no field. Jon says the type is chosen in the **Assembly Wizard**.
  *Test:* document the Assembly Wizard, then check what it writes.
- [ ] **D5. Shadowline Bracket:** the "case front" meaning of `BracketHoleOffset` (shown as **Inset** in the window), and mapping the Operations fields (Diameter, Depth, Spacing) to columns.
  *Test:* change Inset on a test bracket and see where the holes move.

## UCS (`Cabinet Vision/UCS.md`)

- [ ] **U1. Bare-name `GetParameterValue`:** does it resolve up the tree or read only the immediate parent? Not yet proven.
  *Test:* in a UCS:JS, read a parameter defined only on an ancestor.
- [ ] **U2. Run-once / first-one-wins guard** for writing to the Room from a per-cabinet UCS (it currently writes once per cabinet).
  *Test:* design a guard parameter on the Room and confirm it writes once.

## Core (`Cabinet Vision/Core.md`)

- [ ] **C1. Unmatched Connectors** (Hardware Filters) and **Unmatched Operations** (Primary Operations): what "unmatched" means. Jon couldn't trigger the condition.
  *Test:* try to build a connector or operation with no matching definition.
- [ ] **C2. Frame Overlay vs Frame Openings** (Shop Annotations): what Frame Overlay does differently.
  *Test:* toggle each on a face-frame cabinet and compare the drawings.
- [ ] **C3. Stack Dimensions:** what it does. Not in the help; Jon has never figured it out.
  *Test:* toggle it in a job with stacked items and compare the dimensions.

## Machining and tooling (`04 Machining/`)

- [ ] **T1. All feeds-and-speeds numbers** (chip load tables, SFM ranges, the 16,000 to 22,000 RPM range, depth-of-cut rules). Web sources, mostly one source per number; not tested on Ironwood's machine.
  *Test:* compare against the feeds and speeds Jon already runs on his tools and materials; correct the tables to match.
- [ ] **T2. Compression bit rules:** the 25 percent minimum depth, the 1 to 2 inch limit for downcut pockets, a quarter of the diameter as a downcut pass depth, and "compression feeds slower than upcut." Single-source claims.
  *Test:* Jon confirms or corrects them against his own shop practice.
- [ ] **T3. CV "face chip = downcut, back chip = upcut."** An inference linking S2M's shear terms to up/down-cut terms (`04 Machining/Notes.md`). **Narrowed 2026-09-25:** Hexagon's own S2M CENTER help (now in `Reference/S2M Help/`) confirms CV's **own UI fields are literally named "Up Shear" and "Down Shear"** on a tool (Tool Catalog → Tool Set Properties → Tool Selection), and the Automatic Tool Selection Logic ties **Minimize Face Chip → a Down Shear bit** and **Minimize Back Chip → an Up Shear bit** (see `Materials & Schedules.md`'s CNC section). Up-shear/down-shear being the same thing as upcut/downcut is standard, well-established machining terminology (already assumed by `04 Machining/Products.md`), so the naming side of this is solid. What's still untested is the **live behavior**: does a real S2M run actually select the bit the logic describes.
  *Test:* set Minimize Face Chip only on a test material and check which bit S2M CENTER selects.
- [ ] **T4. SFM to RPM formula:** one page printed it upside down. Confirm the correct form used in the files (RPM = 12 x SFM / (pi x diameter)) against a second source or a calculator.
  *Test:* work one example by hand (1/4 in bit, 1,000 SFM gives about 15,279 RPM).

## Hardware (`Hardware/`)

- [ ] **H1. Old TANDEM 569** (`Hardware/Blum/TANDEM/TANDEM Runners.md`). The claim that older Blum catalogs listed a
  heavier-rated TANDEM 569 comes from general knowledge, not a catalog. (The MOVENTO heavy-duty half of this item
  was confirmed on 2026-09-25 from the 2026 MOVENTO catalog: 769. is rated 170 lb static.)
  *Test:* find an older TANDEM catalog, or ask Jon or a Blum rep.

## Still to document (not verification, but gaps)

- [ ] **Assembly Wizard.** Jon: "another VERY important area to cover." It sets the Shadowline Channel type, among other things.
- [ ] **Buyout material schedules.** Jon: schedule types can have a **Buyout** selection, and a Buyout schedule sends no parts to S2M even if the material is set to Optimize. Needs a full write-up with the schedules (build order step 3).
- [ ] **Setup Packages:** the Backup Utility in detail, and a walkthrough of the Setup Package window from screenshots (`Setup Packages.md`).
- [ ] **Parts (Part Manager) and Schedules,** steps 2 to 4 of the build order in `Materials & Schedules.md`.

## Resolved

- [x] **Vendors not visible in Material Properties** (2026-09-24): licensed separately.
- [x] **Material naming pattern** (2026-09-24): Ironwood's own standard (thickness, manufacturer, code, color | line); CV allows any name.
- [x] **Shadowline Bracket field name** (2026-09-24): the window label is **Inset**, not Bracket Hole Offset.
- [x] **Split-window layout memory** (2026-09-23): remembered globally.
- [x] **Decal / Tile / World size behavior** (2026-09-23): confirmed by Jon (see `Materials & Schedules.md`).
