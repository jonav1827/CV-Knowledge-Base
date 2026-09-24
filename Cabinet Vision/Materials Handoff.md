# Materials: Handoff (where we left off)

Written 2026-09-23 at the end of a session on the Materials part of `Materials & Schedules.md`. Read this
first when resuming. Everything here is a pointer; the real content lives in the files named below.

## The goal
Finish **step 1 (Materials)** of the build order in `Materials & Schedules.md` to the point where Claude
could walk a brand-new user through it step by step, at or near 100% confidence. Jon's stated plan for the
next session: finish verifying what can be verified, then have Claude **walk him through creating a
material** as a test of how well the documentation holds up.

## Working method that worked (keep using it)
- **One question at a time**, as a multiple-choice list with **"Other" available** and the recommended
  option first. Jon asked for this explicitly. Screenshots are welcome and are the fastest way to confirm a
  window's real layout.
- **Check the Knowledge Base and the help before asking.** Jon got (fairly) annoyed when asked how to
  remove an override, because `Core.md` already covers it. Grep `Core.md`, `Parameters.md`, `UCS.md` and the
  help text (`Reference/Help/CABINET VISION 2025 Help.txt`) first.
- **Don't claim what a screenshot doesn't show** (for example which pane was active). Mark inferences as
  inferred or unverified in the file.
- Mark anything not confirmed in Jon's own CV as *to confirm* / *unverified* in the file.

## What was covered this session
All written into `Materials & Schedules.md` (the Finishes, Finish Types and Textures section) unless noted.

**Finishes window:** selector, binoculars search (by name), New/Copy/Delete, Name/Description/ID, RGB
palette and sliders, and the lone horizontal slider that scales R, G and B together (left = darker, right =
lighter; the help calls it Luminance). **No Save button: edits are written on Close** (the help says CV asks
Yes to save).

**Finish Types:** window layout, Shader list (seven), five sliders with no numeric readout, the Preview
panel (all preview-only, including its Texture checkbox). Jon's list is mostly his own. His method: **Copy
one close to what you want and tune it against the Preview.** Shader use: Wood for wood/woodgrain laminate,
Plastic for solid colors, Metal for hardware (Glass and Mirror for glass/mirrors).

**Textures:**
- Texture Manager layout (New, Delete, List/Thumbnail views, search and category panes). Groups starting
  with `x` are Jon's "to be deleted" mark and are ignored.
- **Import Texture window** (New): import button top left; after importing, Name, Description, Tile, Decal
  and World Size enable.
- **Tile OFF** = stretched once over the face (World size ignored). **Tile ON** = repeats at World
  Width x Height. Non-seamless images show seams when tiled.
- **Decal OFF** for things that would be painted or stained (blends with the finish); **Decal ON** for
  manufactured products (melamine, Chemetal, Cleaf) so the finish doesn't tint them.
- **Where images live:** the database's `Graphics` folder (Jon's work PC: `Z:\Planit\Common 2025\Database\
  Graphics`). To update an image in place, overwrite the same-named file there.
- **The texture picker** is the Texture Manager plus a **Recent** group, **Automatic** and **Blank**
  checkboxes, and a **System Textures** icon whose function is unknown (see below). Jon prefers Thumbnail
  view.

**How Finish/Finish Type/Texture resolve:**
- Assigned per layer in Material Properties. A **locked color swatch** wins; **Automatic** follows the room.
- **Blank** = no texture (finish only); **Automatic** = the room's texture.
- Room **Interior/Exterior** finishes can be set at **Job, Room, Assembly and Part** level (nearest wins):
  Job/Room/Assembly Properties → **Finish** tab; in the **3D view** (room with nothing selected, or an
  assembly selected, which shows its mappings in the sidebar).
- **Part override:** right-click part → Properties → **Finish** tab (Front Face, Back Face, Edges, End, each
  Interior/Exterior/Select plus a Texture button). The part's **Overrides** tab lists every override;
  remove one by selecting its row and pressing Delete/Remove. UCS-created overrides can't simply be deleted.
- Library edits reach existing jobs **only via Update Job**.
- Jon's troubleshooting order for a part that looks wrong: **check the material the schedule maps to it
  first**, then overrides. The **material schedule carries the part mapping**; a part whose material differs
  from the schedule has been overridden. Read the material a part really uses in Part Properties or an
  assembly report.

**Also added:**
- Jon's convention: materials **mimic reality**, with Edge/End set to the **core** of panel stock; solid
  lumber and banding follow the same idea.
- "Extra facts from the help" (rendering dependencies, smoked-glass recipe, Materials Visual / Finish Types
  Visual in the 3D Properties tab, all visual-only).
- **`Core.md` → "Multi-Window Mode (split views)"**: Window Mode (Normal / Split Horizontal / Split
  Vertical), per-pane tabs, live Reports pane (assemblies at room level, parts with Material at assembly
  level), Set Columns shows/hides columns, layout remembered globally.

## Open items (nothing below is confirmed)
1. **System Textures icon** (Texture picker toolbar): tooltip only says "System Textures"; clicking it
   changes nothing visible; the help doesn't mention it.
2. **S2M one-sided/two-sided rule (help only):** the help says the Face/Back texture on panel stock decides
   whether S2M treats it as two-sided (same or no texture) or one-sided (different textures, no flipping).
   **Jon had believed texture is purely visual and had never seen this.** Worth a real test: send a part
   with more operations on one side to S2M with matching Face/Back textures, then with different ones.
3. **Vendors:** the help describes a Vendors button and Default Vendor row that Jon's Material Properties
   don't show (checked on a panel stock sheet and a hinge). Whether it is hidden, licensed separately or
   off is **not answered**: the question was skipped at the end of the session.
4. **Not yet asked:** whether the material naming pattern is deliberate; Shadowline Channel (L/C/J choice
   has no field); Counter Top (no help page, fields inferred); Shadowline Bracket (inferred); the three
   help-versus-CV disagreements (Wire Basket type codes, Sliding Door Roller dado reference, Drawer Guide
   `SCREF`).
5. **Material Manager and Material Properties walkthrough** (earlier sections of the file) was drafted from
   the help and is still described as "waiting on Jon to check it in CV."
6. **Multi-window details:** which pane makes the ribbon/sidebar change was not recorded.
7. **CVData / SQL:** only Panel Stock and Board Stock creation by SQL is proven; the 9-step pre-flight
   checklist in `CVData Materials & SQL.md` has not been run on the live database.

## Next session
1. Work through open items 3 and 4 one question at a time (ask Vendors again, or drop it).
2. Optionally run the S2M texture test (item 2).
3. **The test:** Claude walks Jon through **creating a material** (New Material wizard, then Properties,
   layers with Finish/Finish Type/Texture, then checking it in the schedule). Claude should do this from the
   documentation alone, and every place it hesitates or Jon corrects it becomes an edit to
   `Materials & Schedules.md`.
4. Then continue the build order in `Materials & Schedules.md`: **Parts** (Part Manager), then **Schedules**
   one kind at a time, then **In the job** (resolution, priority, overrides).

## Files touched
- `Materials & Schedules.md`: Finishes / Finish Types / Textures section, resolution rules, help facts,
  troubleshooting order, multi-window pointer.
- `Core.md`: new Multi-Window Mode section.
- `Materials Handoff.md`: this file.
