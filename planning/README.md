# Planning

This folder holds the **project-level planning artefacts** for
`educabr2` — roadmap, CRAN-submission checklist, dataset wishlist, and
design notes for forthcoming integrations.

It is **not shipped** with the package (see `.Rbuildignore`); it lives
in the repo so the maintainer and any collaborator can see at a glance
what is in flight, what is queued, and why a given decision was made.

## Files

| File | Purpose |
|---|---|
| [`ROADMAP.md`](ROADMAP.md) | Macro milestones (v0.2 → v1.0) with dated estimates |
| [`cran-checklist.md`](cran-checklist.md) | Concrete tasks remaining before first CRAN submission |
| [`datasets-wishlist.md`](datasets-wishlist.md) | Data sources to incorporate, ranked by priority |
| [`integration-educabR.md`](integration-educabR.md) | Compatibility analysis with Sidney Bissoli's `educabR`; merge scenarios |
| [`integration-pnadc.md`](integration-pnadc.md) | Design notes for the planned `PNADcIBGE` adapter (schooling indicators) |
| [`ideas.md`](ideas.md) | Parking lot for half-baked ideas that don't fit anywhere else yet |

## How to use this folder

- **Picking a task**: open the relevant file, scan the checklists,
  open a GitHub issue copying the item, link the issue back here in
  the corresponding line.
- **Adding a task**: edit the relevant file, prefix with
  `- [ ]` and a short description. Don't worry about perfection —
  this folder is supposed to be messy.
- **Resolving a task**: tick the checkbox `- [x]` and add a short
  note (`done in #PR`, `dropped because X`, `deferred to v0.3`).
- **Big design decisions**: get their own file
  (`integration-*.md`, `proposal-*.md`). Keep `ROADMAP.md` thin and
  link out to the detail files.

## Conventions

- Dates in ISO format (`2026-05-18`) when a target matters.
- Reference GitHub issues / PRs with `#NN` and external links with
  the full URL.
- Don't put secrets, credentials, or personal data here.
