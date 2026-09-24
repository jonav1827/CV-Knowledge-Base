# Materials: Handoff (where we left off)

Written 2026-09-23 at the end of a session on the Materials part of `Materials & Schedules.md`. Read this
first when resuming. Everything here is a pointer; the real content lives in the files named below.

## START HERE: latest state (updated 2026-09-24, end of the third session)

**To resume on another machine:** run `git pull`, then read, in this order:
1. This file (you're here).
2. `Knowledge Base/Unverified Knowledge.md`: the running checklist of everything not yet confirmed in Jon's
   CV, with a test for each item. Tick items off as they're tested.
3. `Knowledge Base/Cabinet Vision/Walkthrough - Create a Panel Stock Material.md`: the **draft
   walk-through** Jon is fine-tuning (see below).
4. `Knowledge Base/Cabinet Vision/Materials & Schedules.md`: the full reference the walk-through draws on.

**Where the Materials work stands**
- **Finishes, Finish Types and Textures:** written up and confirmed against Jon's screenshots (see the
  detailed section further down this file).
- **Material properties, panel stock:** the Material section and the **CNC section** now have Jon's real
  practice for every field, plus a plain-language explanation of each option and how it interacts with a
  tool setting. Key points:
  - **Optimize** varies by material (Off for hand-cut, outsourced or display-only materials). **A Buyout
    material schedule sends no parts to S2M even if a material is set to Optimize.**
  - **S2M Material:** set it On for any material set to Optimize.
  - **Grain Dependent:** Off for plain colors, On for grained. **Drop Width/Length:** 0. **Feed/Spindle
    %:** 100. **Chip options:** both on for two-sided finished, Face only for one-sided. **Climb Cut:**
    clean-up passes. **Max Depth Per Pass:** follows the tooling unless very thick dense hardwood.
  - The real cutting values (feed, RPM, depth, rotation) are **normally set in the tool definitions**; the
    material's settings work with them. **Tooling itself is not documented yet**, and Jon asked to keep
    tooling detail out of scope for now (a "tooling detail" paragraph in the file is marked for later).
- **Naming:** minimum is `<thickness> <material name> <type>` (example `3/4 Hardrock Maple Sheet`). Avoid
  `"`, `'`, `|` and `#`. The description can be anything.
- **Resolved this session:** Vendors is licensed separately; Counter Top is a separate module (out of
  scope); Shadowline Channel type is chosen in the **Assembly Wizard**; Shadowline Bracket's field is
  **Inset**; Drawer Guide "Screw Center Reference to Top" is documented but partly unsettled (help
  contradicts itself; checklist M3).

**The walk-through draft** (`Walkthrough - Create a Panel Stock Material.md`): Jon called it "a solid
walkthrough" that still needs fine-tuning. It is marked **(unchecked)** for the New Material wizard screens
(steps 3 to 6), because those come from the help and Jon wasn't at CV to confirm them. **Next time at CV:**
start a New material and confirm what each wizard screen shows, then edit the draft to match. Jon may also
have made his own edits to that file: **re-read it before changing it.**

**Skill-level discussion (started, not finished).** Jon shared a web-search summary of Beginner /
Intermediate / Advanced / Expert Cabinet Vision skills (not to be saved verbatim; it's an unverified
AI-style summary) to help define the tiers on his website and to calibrate his own level. Findings:
- The website tiers (Beginner: UI, hierarchy, Job/Room/Assembly properties, overrides, basic drawings;
  Intermediate: layers, simple assembly modification, parametric equations/basic object intelligence,
  materials and schedules; Advanced: templates and titleblocks only; Expert: UCS, shaping and constraining)
  place several things lower than the clip does (hierarchy, overrides, parametric equations), and the
  **Advanced tier is nearly empty**.
- Proposed framework: **Beginner = operate, Intermediate = configure, Advanced = build, Expert =
  administer/integrate**, with the test "could a new hire do this independently after their first week?"
- **Pending:** a sorting exercise (Claude proposes a tier for each website and Knowledge Base topic, Jon
  corrects). Jon asked to park it and asked for this handoff instead. The website was **not** changed.

**Also open (not started):** the **Assembly Wizard** (Jon: "VERY important"), the S2M CENTER Help (not in
the Knowledge Base; Jon may be able to export it like the CV help), Setup Packages details, and Parts /
Schedules (steps 2 to 4 of the build order).

**Working notes for Claude:** one question at a time, multiple choice with "Other"; search the Knowledge
Base and the help before asking; never state what a screenshot doesn't show; mark anything unconfirmed as
unverified in the file. Markdown links to files with spaces did not open in the editor; tell Jon to use
Ctrl+P to find a file by name. Jon asks for each commit and push explicitly; don't commit unprompted.

---

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

## Open items
**The live list is now `Knowledge Base/Unverified Knowledge.md`** (a running checklist with a test for each
item). Keep that file current; the list below is the original end-of-first-session snapshot, and items 3 and
4 were since resolved (see the next section).

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

## Added in the continuation session (2026-09-24)
- **Vendors:** licensed separately (resolved).
- **Naming pattern:** Jon's own company standard; CV allows any name (resolved).
- **Counter Top:** separate module Jon doesn't have; out of scope (resolved).
- **Shadowline Bracket:** seen on Jon's material. The window's field is **Inset** (1 15/32), not "Bracket
  Hole Offset" (that is the database column name, `BracketHoleOffset`); Operations has Diameter, Depth and
  Spacing. Corrected in `Materials & Schedules.md` and `CVData Materials & SQL.md`.
- **Shadowline Channel:** confirmed no L/C/J field on the material; the type is **chosen in the Assembly
  Wizard**. Jon flagged the **Assembly Wizard as another VERY important area to cover** (not yet
  documented; needs its own file or section).

## Next session
1. Pick items from `Unverified Knowledge.md` to test (for example the S2M texture rule, M1).
2. Document the **Assembly Wizard** (Jon: "VERY important").
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
