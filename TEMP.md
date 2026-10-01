# TEMP (work in progress between sessions)

A holding area for knowledge that has been worked out in a session but not yet filed. It travels with
the repo so work can be picked up on either machine.

**How to use:**
- Read this first when resuming. Each block says where it is headed and what is still open.
- When an item is resolved, move it into its proper file and delete it from here.
- Items that still need testing go to `Unverified Knowledge.md`, not here.
- Keep everything generic: no shop names, job data, construction IDs or copied UCS code.

Last updated: 2026-09-30.

## UCS:M — cabinet-assembly attribute pass (headed for `Cabinet Vision/UCS.md`)

**Where this came from.** A review of a working UCS:M that runs pre-build on `For Each CAB Assembly`.
It builds a cabinet's sidebar attributes and leaves values on the assembly for other UCSs to read; it
creates no parts. Jon has confirmed the entries below in substance. The wording has not had its final
review, and nothing has been merged into `UCS.md` yet.

**Terms to keep when filing these.**
- Say "system parameter", not "native".
- A system parameter does nothing by itself in these patterns. The UCS queries it, and the UCS's own
  code does the work.
- Nothing "locks" an attribute. A value forced on every rebuild acts as a lock.
- Use integers for class and end-type comparisons (`CLASS == 1`, `LEND == 5`). The named constants
  (`ASM_CLASS_BASE`, `ASM_END_APPL_FE`) work in UCS:M, but Jon prefers the integers.

### New entries (drafted)

- **Ownership flag.** When a UCS writes a system parameter, have it set its own flag in the same block
  (`UCS_SCT := 1`). The undo branch runs only when the flag exists, then removes the value and the
  flag. A value the user set by hand never has the flag, so the UCS never reverts it. No better
  approach has been found. Possible refinement, untested: store the original value in the flag on the
  first write, so the undo restores it instead of assuming the default.
- **Forcing an attribute from a queried condition.** A UCS can query a system parameter and, when it
  holds a certain value, assign the attribute unconditionally (`ATTR = 'X'`). The dropdown still shows,
  but any change the user makes reverts on the next rebuild. To hand the choice back, put a delete-gate
  above the null check that fires when the forced value is present and the condition no longer holds,
  so the list is recreated at its default.
- **Resetting a list when the class changes.** Seed a check parameter with `CLASS` inside a null check,
  so it is written once. Above it, compare it to the current `CLASS`; on a mismatch, delete the check
  parameter and the class-dependent attribute so both are rebuilt for the new class.
- **An attribute driving a system override.** A UCS-created attribute can be the sidebar control for a
  system parameter: the UCS reads the attribute and writes the system parameter to match. Depending on
  the parameter, the off state is either a second value or a `delete`. Deleting an override parameter
  returns it to the construction's value.
- **Hiding a cabinet's automatic dimensions.** Rotate the assembly slightly on Y (`AY := .001`).
  Verified for `AY`; `AX` and `AZ` are untried. Pair it with an ownership flag so the rotation can be
  set back.
- **Sub-assemblies.** `For Each CAB Assembly` visits every cabinet assembly, sub-assemblies included.
  `CON` flags a sub-assembly, so `CON != null` in the exit gate keeps a cabinet-level UCS off them.
- **Door stops from scribe.** Setting the top or bottom scribe (`SCT`, `SCB`) to the width of that rail
  moves the top or bottom inside the frame, where it acts as the door stop.
- **Separate toe kick.** When toe kicks are built and installed apart from the cabinet, the UCS sets
  toe height to 0 (`TOEH := 0`) pre-build.
- **Mutually exclusive sub-attributes can share one number** (`02.1`), with each branch deleting the
  other's attribute.
- **`<style>` or `<desc>` on a parameter that doesn't exist throws an error.** Make sure every path
  creates the parameter before those lines run.
- **Exit cleanup resets the assembly.** It deletes every parameter the UCS created and undoes every
  system parameter it changed (toe height, scribe, rotation), undoing those before their flags are
  deleted. A UCS that targets the assembly afterward starts from a clean object.
- **Query-only versus writable.** `LEND`, `REND`, `LADJ`, `RADJ` and `CLASS` are query only; write end
  types through `ETL` / `ETR`. The value lists are in the system parameter reference.

### Changes to existing notes (drafted)

- **Null and 0.** `UCS.md` says a stored flag of 0 reads back as null. Narrow it: a Boolean seeded
  inside a null check holds 0 as 0 and does not read as null on the next rebuild. Where the null/0
  conflation does occur is still unclear.
- **Troubleshooting gotcha.** A text value in an `<int>` choice list (`None = None` in place of
  `None = 0`) can keep working and hide the mistake. If an integer list misbehaves, check that each
  stored value is a number.

### Headed elsewhere

- **End type is automatic** (fundamentals, not UCS). CV decides whether an end is finished or
  unfinished from what surrounds the cabinet; the construction method decides which kind of finished
  end is used. Location undecided: `Cabinet Vision/Cabinets.md`, or `Cabinet Vision/Core.md` next to
  the Show End Types note.

### Open questions

- Does a class 5 or higher assembly reach a `<style>` line for an attribute its class never created,
  and does that error roll back the whole UCS? Untested, since these assemblies are rarely above
  class 3. Belongs in `Unverified Knowledge.md` once this block is filed.
- Does a typed assignment from another parameter that is seeded once (`CHECK<int> = CLASS`) show as
  `[Static]` or `[Equation]` in the Object Tree? Low priority.
- Where exactly does CV read a stored 0 as null?

### Still to learn from the next UCSs

- A lighting attribute's "Custom" choice takes the lighting parameters off the cabinet and puts them
  on the parts that use them. The parts UCS shows how.
- Which UCSs consume the cabinet-type, lighting and override attributes this pass creates.
