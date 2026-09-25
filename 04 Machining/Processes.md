# Machining — Processes

Step-by-step how-tos: how things actually get done at this stage, the right way to do
them, and why. Cite source material in Reference/ where relevant.

**Status of everything below:** general CNC knowledge gathered from web sources on 2026-09-24 (listed in
`Notes.md`), not yet checked against Ironwood's own machine, tools or materials. Treat every number as a
**starting point to test**, not a setting. See `Notes.md` for where the sources disagree and what they leave
out.

---

## Feeds and speeds

### The four settings

| Setting | What it is | Units |
|---|---|---|
| **Spindle speed** | How fast the tool rotates | RPM |
| **Feed rate** | How fast the machine moves the tool through the material | inches per minute (IPM) or mm per minute |
| **Chip load** | The thickness of the chip each cutting edge (flute) removes in one revolution; the "bite size" | inches or mm per tooth |
| **Depth of cut** | How deep the tool cuts in one pass | inches or mm |

A fifth number, **surface speed** (SFM, surface feet per minute), is the speed of the cutting edge as it
passes over the material. It is how a material's ideal cutting speed is usually quoted, and it is converted to RPM
for a given tool diameter.

**The guiding rule every source repeats: you want chips, not dust.** Dust means the chip load is too small
and the edge is rubbing. Charts are starting points, not final answers.

### The formulas

```
Chip load  = Feed rate / (RPM x number of flutes)
Feed rate  = RPM x number of flutes x chip load
RPM        = 12 x SFM / (pi x tool diameter in inches)        (imperial, SFM to RPM)
SFM        = pi x tool diameter (inches) x RPM / 12
```

In metric, the feed formula is the same with millimeters: **feed (mm/min) = RPM x flutes x chip load (mm per
tooth)**.

*One source prints the RPM formula as (pi x diameter x SFM) / 12, which is upside down; its own worked
example (below) uses the correct one. See `Notes.md`.*

### Worked examples (from the sources)

1. **Plywood, 1/4 in bit, 2 flutes, SFM about 1,000, chip load 0.005 in.**
   RPM = 12 x 1000 / (pi x 0.25) = **about 15,279**. Feed = 15,279 x 2 x 0.005 = **about 153 IPM**.
2. **Plywood, 6 mm bit, 2 flutes, chip load 0.1 mm per tooth, 10,000 RPM.**
   Feed = 2 x 0.1 x 10,000 = **2,000 mm/min**. At 20,000 RPM the same chip load allows 4,000 mm/min.
3. **The same job on a spindle limited to 10,000 RPM: change to a 3-flute tool.**
   Feed = 3 x 0.1 x 10,000 = **3,000 mm/min.** More flutes is how you feed faster without more RPM.

### Setting a cut, step by step

1. **Choose the bit and material.** Diameter, number of flutes, and bit type (see `Products.md`).
2. **Pick a starting chip load** from the table below (or the 1/4 in plywood example above), and stay
   toward the low end at first.
3. **Choose the spindle speed.** Either convert from the material's SFM, or, if you are limited by the spindle,
   use the highest RPM it will run. The source's typical range for most materials is **16,000 to 22,000 RPM**.
4. **Calculate the feed rate** with the formula.
5. **Check the depth of cut** against the rules below.
6. **Make a test cut.** Look at the chips and the edge, listen, and adjust using the symptoms table.
   Raise the feed in small steps, and raise the depth of cut in small steps.

### Starting chip loads (mm per tooth, from one source)

**Beginner values:**

| Material | 2 mm | 3 mm | 4 mm | 6 mm | 8 mm |
|---|---|---|---|---|---|
| Hardwood | 0.02 | 0.04 | 0.06 | 0.08 | 0.10 |
| Plywood | 0.03 | 0.05 | 0.06 | 0.08 | 0.09 |
| MDF | 0.04 | 0.05 | 0.06 | 0.09 | 0.10 |
| Soft plastics | 0.05 | 0.07 | 0.08 | 0.10 | 0.12 |
| Aluminium | 0.01 | 0.02 | 0.02 | 0.03 | 0.04 |

**Experienced-user values:**

| Material | 3 mm | 6 mm | 8 mm |
|---|---|---|---|
| MDF | 0.08 | 0.12 | 0.14 |
| Plywood / softwood | 0.07 | 0.10 | 0.12 |
| Hardwood | 0.05 | 0.08 | 0.11 |
| Soft plastics | 0.10 | 0.12 | 0.14 |
| Hard plastics | 0.08 | 0.10 | 0.12 |
| Aluminium | 0.02 | 0.04 | 0.06 |
| Carbon steel | 0.01 | 0.02 | 0.03 |

Chip load rises with tool diameter because a bigger tool has more strength and more room for chips.
Start **below** the table and work up.

### Surface speed (SFM) guides

| Material | SFM |
|---|---|
| Softwood | 800 to 1,200 |
| Plywood | about 1,000 |
| Aluminum | 600 to 1,000 |

### Depth of cut

| Who | Maximum depth per pass |
|---|---|
| Beginner | half the tool diameter |
| Experienced | one tool diameter |

Hard materials (aluminum, acrylic) need less than that and soft ones may allow more. Bit type matters too:
one source suggests about **a quarter of the diameter per pass for a downcut bit**, and deeper passes are
tolerable with an upcut bit because it clears chips (see `Products.md`). **Heavy engagement** (more than
about a quarter of the tool's circumference in the cut) stops the tool cooling: lower the feed or the depth.

### Reading the cut: symptoms and fixes

| What you see or hear | Likely cause | Fix |
|---|---|---|
| **Dust, not chips** | Chip load too low | Raise the feed or lower the RPM |
| **Burning or melting** | Too much heat: feed too slow for the RPM, or chips not clearing (plastics melt when chips are not cleared) | Raise the feed and/or lower the RPM; improve chip evacuation (an O-flute bit for plastics) |
| **Tool screaming or whining** | Rubbing instead of cutting | Raise the feed |
| **Loud rumbling or chatter** | Tool overloaded or vibrating | Lower the feed and/or the depth of cut; shorten the tool stick-out |
| **Snapped bits** | Too big a bite, or chips not clearing | Lower the feed and/or the depth; improve chip evacuation |
| **Fuzzy or rough edge** | Deflection, or chip trouble | Raise the RPM or lower the feed |
| **Vibration and broken tools with low RPM and high feed** | Each flute takes too big a bite | Raise the RPM or lower the feed |
| **Overheated, dull tool with high RPM and low feed** | Flutes rub instead of cut | Raise the feed |

### What else changes the right settings

Machine rigidity, the material and how well it is held, the depth of cut, how sharp the tool is, the surface
finish required, how much of the tool is engaged, and how securely the workpiece is clamped. A rigid machine
running MDF can carry higher feeds, and dust collection matters in MDF.

### Other terms

- **Plunge rate:** the speed at which the bit is driven down into the material to start a cut.
- **Slew (rapid) rate:** the speed the machine moves when it is above the material between cuts.
- **Corner deceleration:** at a sharp corner the machine has to slow down. The source's example is a cutter at
  100 IPM approaching a 90 degree corner, to show why a programmed feed is not always the actual feed.

### Not covered by the sources

Stepover and stepdown values, material removal rate, spindle power, heat calculations, coolant, tool
deflection, and specific values for melamine, particleboard or laminate. See `Notes.md`.
