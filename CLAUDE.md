# CV Knowledge Base

## What this is
Jon Navas's (Ironwood Shopworks) knowledge base for Cabinet Vision and every production stage of a
cabinet shop: Bidding, Design & Drafting, Engineering, Machining, Production & Custom, Finishing,
Install, plus manufacturer hardware. It is kept current over time so Claude can act as an
encyclopedia and troubleshooting reference for drafting, CV development (UCS, parameters, CVData),
training material and consulting work. See `README.md` for the folder structure and conventions.

Jon is teaching Claude Cabinet Vision over many sessions. Treat what he explains as durable domain
knowledge: write it up here (or suggest where it belongs) rather than just acknowledging it.

This repo is used on two machines:
- **Jon's main PC**, where it is a git submodule at `Knowledge Base/` inside a separate private repo.
- **Weathervane Woodworking's PC** (a client shop), cloned on its own, for hands-on CV, CVData and
  SQL sessions. Weathervane's owner can read everything in this repo, so **never add client-specific
  or private business information here.**

## Rules
- **Jon makes all commits and pushes.** Don't commit or push on your own initiative; edit and stage,
  then show him what's going out. On Weathervane's PC, commits are SSH-signed and pushes use a write
  key, both protected by Jon's passphrase, which Claude cannot type. Give Jon the command to run.
- **Never store the passphrase** in any file, environment variable or setting.
- **Before Jon pushes, list every outgoing commit** (`git log origin/main..HEAD --show-signature`)
  and flag anything not signed by Jon's key or any uncommitted change he didn't make.
- **On Weathervane's PC, never sign into github.com, the GitHub CLI or VS Code Settings Sync**, and
  don't install GitHub-related VS Code extensions. Access is through the two SSH deploy keys only.

## Writing style
- **Never use the phrase "source of truth."** Use "one place to check" or "the fuller version."
- **Settings and reference sections say what a setting does and what it actually affects**, not
  general explanations. Background theory goes in the more specific file for that topic (bit physics
  in `04 Machining/Products.md`, S2M tool selection in `Cabinet Vision/Machining.md`), with a short
  pointer and a one-line summary left in the settings file.
- **Hardware:** one folder per product line, `Hardware/<Manufacturer>/<Product line>/`, with each
  write-up stored next to its source catalog PDF. Related products can share a folder.
- **Technical catalogs only.** If a manufacturer PDF is a marketing brochure (no part numbers,
  sizing or drilling data), don't write it up; say so and ask for the technical catalog.

## SQL and CVData safety (Weathervane's PC)
Weathervane's CV database is a working shop's live data. Never run anything that writes to it
(INSERT, UPDATE, DELETE, ALTER, DROP, restore over it). Work against a restored copy, or query
through a read-only login (`db_datareader` only). Their job and customer data stays theirs: document
schema, structure and behavior here, never their job data.

## Weathervane PC setup status
Done before this repo could be cloned: Git, SSH keys (`kb_read` read-only without a passphrase,
`kb_write` with Jon's passphrase), `~/.ssh/config` host aliases `github-kb-read` and
`github-kb-write`, and the clone. Still to do, in order:
1. **Check the repo wiring** (repo-level config, not global):
   - `git remote -v`: fetch via `github-kb-read`, push via `github-kb-write`
     (`git remote set-url --push origin git@github-kb-write:jonav1827/CV-Knowledge-Base.git`).
   - `gpg.format ssh`, `user.signingkey` = `$HOME\.ssh\kb_write.pub`, `commit.gpgsign true`.
   - Jon tests with `git push --dry-run` (passphrase prompt, then "Everything up-to-date").
2. **Block Jon's connected claude.ai services.** In `$HOME\.claude\settings.json`, add
   `permissions.deny` for `Artifact`, `ArtifactData`, `ArtifactComments` and every claude.ai
   connector MCP server (`mcp__claude_ai_<name>`). The Windows account and the Claude login are
   shared with Weathervane's owner, and Jon's Artifacts and Docs hold private business material.
   After a restart, report exactly which `mcp__` and `Artifact` tools are still visible.
3. **SQL tools (separate session):** SSMS, `winget install sqlcmd`, and the read-only login or
   restored copy described above.
