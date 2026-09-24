# Walkthrough: Create a Panel Stock Material

*DRAFT for Jon to edit. Steps marked **(unchecked)** come from the CV 2025 help and have not been confirmed on
Jon's screen yet (see `Unverified Knowledge.md`, item M7). Sources for the details behind each step are in
`Materials & Schedules.md`.*

## Before you start: choose the name

- Minimum: `<thickness> <material name> <type>`, for example `3/4 Hardrock Maple Sheet`. You can add more, such as sheet size.
- Use only letters, numbers and `/`, up to 50 characters. **Never use `"`, `'`, `|` or `#`.** Write `3/4`, not `3/4"`.
- The **description** can be anything, up to 100 characters.

## Steps

**1. Open the catalog.** Start screen → **Main** tab → **Material** button (Catalogs group).

**2. Pick the group.** Click the group in the left Group pane where the material should live. The new material goes into the selected group.

**3. Click New** in the ribbon (Materials set). *(unchecked)*

**About the wizard:** using it is optional. **Everything in the wizard can also be set or changed in Material Properties.** The one exception is the material **Type**, which can't be changed after it's created.

**4. Wizard screen 1: Type, Name, Description (unchecked).**
- **Type: Panel Stock.**
- Enter the Name and Description. Click **Next**.

**5. Wizard screen 2: Unit of Issue and size (unchecked).**
- **Unit of Issue:** Sheet.
- **Thickness, Width and Length:** a new panel starts at 48 x 96 x 3/4. Enter the real values.
  - **Thickness is the most important**, because construction and the cut list depend on it.
  - **Width and length matter too.** Wrong sheet sizes give bad nesting patterns and can lead to under- or over-ordering sheets.
- Click **Next**.

**6. Wizard screen 3: Display (unchecked).**
- **Suggested, not required:** mimic reality. For example, set Edge and End to the panel's core. Doing this makes spotting discrepancies much easier than combing through material reports.
- Set the Finish, Finish Type and Texture for **Face, Back, Edge and End**:
  - **Finish** is the color. A color swatch locks that color to the material, and **Automatic** means it follows the room's finish.
  - **Finish Type** is how the material interacts with the environment when rendered.
  - **Texture** is the pattern on the surface. **Blank** means no pattern (finish only), and **Automatic** uses the room's texture.
- Click **Finish**.

**7. Open Properties.** Select the material and press **Properties** (or double-click it). On the **General** tab:

### Material section

- Default Cost, Sell Price, Default Markup, Sales Tax and Default Tax Rate, and Waste all start at 0.
- Leave **Estimate** on if it should reach the Bid Center.
- **S2M Material:** if the material is set to Optimize, also set this On. These materials go to S2M anyway, so they should exist there as S2M materials.

### CNC section

Some of these settings only affect nesting. Others work together with a setting on the **tool** (the real cutting values are normally set in the tool definitions).

*Nesting and offcuts (material only):*
- **Optimize:** whether parts of this material go to the Optimizer/Nester. On for sheet goods you nest. Off for materials cut by hand, outsourced, or used for display. **A Buyout schedule sends nothing to S2M, even if this is On.**
- **Grain Dependent:** whether parts may rotate on the sheet. Off for plain colors, On for grained.
- **Drop Width and Drop Length:** the minimum size a leftover needs to count as an offcut instead of scrap. Leave at 0.

*Works with a tool setting:*
- **Feed Rate Percent and Spindle Speed Percent:** the tool holds the real feed rate and RPM, and the material scales them. Leave at 100 (the tool's value as-is).
- **Maximum Depth Per Pass:** the tool has its own limit, and the smaller of the two is used. Leave at the default, unless the stock is very thick, dense hardwood.
- **Climb Cut:** the tool's rotation and this setting together decide which direction the toolpath runs. Leave off (it's mainly for clean-up passes).
- **Minimize Face Chip and Minimize Back Chip:** these tell S2M which kind of tool to prefer (Face = down-shear, Back = up-shear, both = compression), but only when the operation's tool is **Auto Select**. Set both on for materials finished on both sides, and Face only for one-sided (unfinished back).

### Layer sections

Re-check Face, Back, Edge and End.

**8. Use it.**
- The material must be mapped in a **Material Schedule** before a part uses it. This isn't documented yet.
- Existing jobs don't see a new or changed material until you run **Update Job → Materials**.

## Variations

- Use **Alias** for the same material with a different sheet size or cost.
- Avoid **Redefine** unless you mean it. It re-runs the wizard and loses Model Editor changes.
- Delete in CV, not SQL.
