# Machining — Notes

Anecdotes, lessons learned, and the "why" behind the processes — things worth
remembering that don't fit a clean how-to.

---

## Tooling research (2026-09-24)

### Sources read

Nine web pages, read through a page-extraction step (which summarizes, so anything a page says that is not in
`Processes.md` or `Products.md` may have been dropped):

| Topic | Source |
|---|---|
| Feeds and speeds | Tools Today, "Understanding CNC Feeds and Speeds" |
| Feeds and speeds | ShopSabre, "CNC Feeds and Speeds Explained" |
| Feeds and speeds | XPRO CNC, "CNC Speeds and Feeds Explained: The Beginner's Guide" |
| Feeds and speeds | Mekanika, "CNC Feeds and Speeds Explained" |
| Upcut, downcut, compression | FindBuyTool, "Choosing the Ultimate Spiral Router Bit" |
| Upcut, downcut, compression | Tools Today, "Downcut, Upcut and Compression Bits" |
| Upcut, downcut, compression | Zahyox, "Downcut vs Upcut vs Compression Router Bits" |
| Upcut, downcut, compression | SpeTools, "Up-Cut, Down-Cut, Compression Router Bits Guide" |
| Upcut, downcut, compression | CNCRouterInfo, "Upcut vs Downcut vs Compression" |

### What is reliable and what isn't

- **The formulas** agree across sources (chip load and feed rate) and match standard machining practice.
- **The numbers** (chip load tables, SFM ranges, depth-of-cut rules) come mostly from **one source each** (the chip
  load tables from one metric page, the SFM figures from another). Treat them as starting points, not as
  Ironwood's settings.
- **The SFM to RPM formula** was printed upside down by one source (RPM = pi x diameter x SFM / 12). The correct
  form is **RPM = 12 x SFM / (pi x diameter)**, and that page's own worked example (1/4 in bit at 1,000 SFM giving
  15,279 RPM) uses the correct one. The upside-down version may also be an extraction slip, so check any page you
  rely on.
- **ShopSabre's page** defines feed rate as "the distance the cutting tool travels during one spindle revolution"
  (which is really feed per revolution) while also measuring it in inches per minute. Use IPM for feed rate and
  inches per tooth for chip load.
- **Bit-type rules** (up, down, compression) agree across the five pages that cover them.
- **Single-source claims** worth testing before relying on them: the 25 percent minimum depth for a compression
  bit, the 1 to 2 inch limit for a downcut pocket, a quarter of the diameter as a downcut pass depth, and that
  compression bits feed slower than upcut bits.

### What the sources leave out (useful for a cabinet shop)

Nothing here covers the things a cabinet shop most needs: chip loads and speeds for **melamine, particleboard
and laminate** (only plywood and MDF appear), **tool life** and re-sharpening, **coatings**, **diamond (PCD)
tooling**, **drills and line-boring bits** (the machining behind adjustable-shelf holes), **V-bits**, **edge
banding tools**, **stepover and stepdown**, and how feeds change for **nesting** cut paths (ramps, lead-ins,
tabs and onion skins). These would need other sources or Jon's own experience.

### How this connects to Cabinet Vision

The general knowledge above lines up with the CNC section on a material in CV (see `Cabinet Vision/Materials &
Schedules.md`):

| CV material setting | What the tooling knowledge says |
|---|---|
| **Feed Rate Percent** and **Spindle Speed Percent** | Percentages of the tool's optimum feed and spindle speed for that material. They scale the chip-load math above (the feed and RPM together set the chip load) |
| **Minimize Face Chip** | S2M's automatic tool selection tries for a **down-shear (downcut)** bit: a clean top surface |
| **Minimize Back Chip** | It tries for an **up-shear (upcut)** bit: a clean bottom surface |
| **Both on** | It tries for a **compression** bit: clean top and bottom, which is the sheet-goods through-cut case |
| **Climb Cut** | Cut climb rather than conventional |
| **Maximum Depth Per Pass** | The tool's depth per pass; CV uses the smaller of the material's and the tool's value |

That mapping of "face chip is downcut, back chip is upcut" is an inference from the tooling terms (the CV help
gives the shear names but not the words upcut and downcut), so it is worth confirming — though it's a naming
equivalence, not a physical-behavior question: up-shear/down-shear and upcut/downcut are the same standard
machining terms for the same bit geometry. **Update 2026-09-25:** the S2M CENTER help is now in the repo
(`Cabinet Vision/Reference/S2M Help/`, added by Jon — see `Cabinet Vision/S2M Handoff.md`), and its full
**Automatic Tool Selection Logic** is written up in `Cabinet Vision/Materials & Schedules.md`'s CNC section.
It confirms CV's own UI literally uses "Up Shear" and "Down Shear" as tool properties, and spells out, by
operation type (Part Outline, Hole, Dado, Cutout/Pocket Route), the exact order S2M tries bits in — Compression
consistently comes up when both Minimize Face Chip and Minimize Back Chip are on. **It still does not say how a
chip-load choice becomes an actual feed for a nested job** — the closest it gets is the same "feed rate at a
1/4 in and 3/4 in deep cut, scaled by the material's percent" wording already in the CV help, with the exact
interpolation left unstated (see `Unverified Knowledge.md` item M13a). See item T3 there for what's now settled
versus what still needs a live S2M run to confirm.

### Open questions for Jon

- Which bits does Ironwood actually run for sheet goods (compression, downcut, upcut), and at what diameters?
- Is the CNC a router with a fixed RPM range (which would make more flutes the way to feed faster)?
- Which materials does he cut most (melamine, plywood, MDF, solid)?
- What feeds and speeds does he already run that work well? Those are more useful than any table above.
