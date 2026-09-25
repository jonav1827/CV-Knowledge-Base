# Machining — Products

Specific hardware, materials, machines, or software relevant to this stage — what's
good, what's not, and when to use what.

**Status:** general knowledge from web sources gathered 2026-09-24 (see `Notes.md`), not yet checked against
Ironwood's own tooling. Bit terms here are the common woodworking ones; CV's S2M CENTER calls the same bits
**up-shear**, **down-shear** and **compression** (see `Notes.md`).

---

## Spiral router bits: upcut, downcut and compression

### How each is built and what it does

| | **Upcut** | **Downcut** | **Compression** |
|---|---|---|---|
| **Flute direction** | Spirals upward (like a staircase going up) | Spirals downward | Both: upcut at the tip, downcut above it, with a compression zone where they overlap |
| **What it does to the chips** | Lifts them up and out of the cut | Pushes them down into the cut | Compresses the material layers toward the middle |
| **Top surface** | Rough or frayed; can tear delicate veneer | **Clean**, no fraying | **Clean** |
| **Bottom surface** | **Clean** | Rough or torn out on a through cut | **Clean** |
| **Chip clearing** | Excellent | Poor: chips pack into the cut, are recut and make heat | Between the two; feed more slowly than an upcut |
| **Heat and bit life** | Less heat, longer life on deep cuts | More heat, shorter life | Needs a proper first pass to work |
| **Feed rate** | Faster feeds are tolerable | Moderate, to avoid clogging | Slower than upcut |
| **Holding the work** | **Pulls the work up**, so hold it well (vacuum, tabs, or tape and glue) | Presses the work down onto the spoilboard, which helps thin material | Neutral |

### What each is best for

- **Upcut:** pockets and cavities, deep slots, mortises, dados and grooves, fast roughing, through cuts where
  the top edge does not matter, and aluminum (always). Also MDF and solid hardwood. It is the most universal
  of the three.
- **Downcut:** work where the **top surface** must be clean: veneered plywood, laminates, painted or stained
  wood, engraving and shallow cuts on finished surfaces, and thin material. Not for through cuts that need a
  clean bottom, and not for deep pockets, because chips pack.
- **Compression:** **through cuts in sheet goods where both faces show**: plywood, veneered plywood,
  melamine and laminate, MDF and particleboard, panel and cabinet work, production runs, and full-depth cuts
  with visible edges.

### The compression bit's key rule

**The first pass must cut deep enough for the downcut portion to be engaged.** If the cut is so shallow that
only the upcut section touches the material, you get the result of an upcut bit. In the sources' words, the
first pass has to be below the upcut portion, and a compression bit used only at a shallow depth is "an upcut
bit that cost more". One source's example: a 1/4 in compression bit at 0.5 mm depth only uses the upcut zone.
One source gives a minimum of **about 25 percent of the cutting length**. (Single-source figure, unverified.)

Other compression limits and tips:
- **Not good for shallow pockets**, and **not good for very deep cuts** (chip evacuation runs out).
- **Ramp in and use lead-ins** to extend bit life.
- It is designed to cut through in a single pass, but more passes are fine if the first one meets the depth
  requirement.
- Smaller machines may not have the depth to place the first pass correctly.

### Depth and limits by type

- **Downcut:** about a quarter of the bit diameter per pass in one source, and not recommended for pockets
  deeper than about 1 to 2 inches, because chips pack. An air blast helps clear chips.
- **Upcut:** deeper passes and faster feeds are tolerable.
- **Compression:** engage the downcut portion on the first plunge (above).

### Choosing by material

| Material | Best choice | Why | Alternative |
|---|---|---|---|
| MDF | Upcut | Dust management, less fuzz | Compression if through-cutting |
| Solid hardwood | Upcut | Standard for pockets and carving | Downcut for finish passes |
| Plywood, through cuts | **Compression** | Clean top and bottom | Upcut plus a separate downcut pass |
| Veneered plywood | Compression or downcut | Prevents veneer tearout | Upcut with a very shallow final pass |
| Laminate and melamine | Compression or downcut | Prevents chipping and delamination on the face | |
| Aluminum | Upcut, always | Recutting chips is the enemy | A single flute matters more than the helix |
| Plastics | Upcut (or O-flute) | Chip evacuation to avoid melting | |

### Flute count (independent of the bit type)

| Flutes | Use |
|---|---|
| 1 | Lots of chip space; plastics and softer materials |
| 2 | The workhorse for wood and aluminum; all-purpose |
| 3 | Good for hardwood finish passes, with slightly slower feeds; also a way to feed faster at a limited RPM (see `Processes.md`) |

### Where the sources disagree

- **MDF:** one source names upcut, another names compression for MDF and particleboard panel work. They agree on
  the rule underneath: use **compression when both faces of a through cut must be clean**, and upcut for pockets.
- **Compression orientation:** described as "the first quarter upcut, the rest downcut" in one source and "upcut at
  the tip, downcut above" in another. They mean the same bit: the tip cuts upward and the shank end cuts downward.

### Not covered by the sources

Helix angles and compression zone lengths, cutting speeds and chip loads by bit type, hold-down pressure,
tool life by type, coatings, diamond (PCD) tooling, drills and line-boring bits, V-bits, and edge-banding
tools.
