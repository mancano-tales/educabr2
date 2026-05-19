# Roadmap

High-level milestones. Each milestone bundles a coherent set of
changes worth a version bump; granular tasks live in the topic files
(see `planning/README.md`).

## Current: 0.1.0 — first public release (2026-05-18)

Initial set of harmonised long-run series (Kang/FGV enrollment,
Walter & Kang schooling, multi-source tertiary), public API
(`get_enrollment`, `get_schooling`, `educabr_cite`,
`run_dashboard`), bundled Shiny dashboard, pkgdown site.

- [x] R CMD check --as-cran: 0/0/0
- [x] Live dashboard on shinyapps.io
- [x] pkgdown site live at https://mancano-tales.github.io/educabr/
- [x] 37 tests passing

## v0.2 — first CRAN submission (target: 2026-06)

Polish only — no API breakage. See [`cran-checklist.md`](cran-checklist.md).

- [ ] `list_sources()` helper (mentioned in YAML but never built)
- [ ] `check_win_devel()` clean
- [ ] Spell check + URL check clean
- [ ] `LICENSE` file separate from `LICENSE.md`
- [ ] Tag v0.2.0, release on GitHub, submit to CRAN

## v0.3 — PNAD Contínua integration (target: 2026-Q3)

Brings the schooling series forward from 2015 → present by tapping
the IBGE PNAD Contínua microdata. Adds an on-demand fetcher pattern
to the package — first non-bundled data path. See
[`integration-pnadc.md`](integration-pnadc.md).

- [ ] `get_schooling(source = "pnadc")` reads from PNADcIBGE
- [ ] Cache layer for downloaded quarters
- [ ] Vignette: extending the historical series to 2024
- [ ] CI: skip live download tests on CRAN, run on GitHub

## v0.4 — Inequality cuts everywhere (target: 2026-Q4)

Promised in the README from day one but not yet wired through every
indicator. Also `compute_gap()` helper that turns long-format
breakdowns into the usual gap/ratio metrics (white-black gap, M/F
ratio, etc.).

- [ ] `compute_gap(df, by, ref, method = c("difference", "ratio", "log_ratio"))`
- [ ] `dimension = "income"` for indicators where PNAD has it
- [ ] `dimension = "location"` (urban/rural)
- [ ] Vignette: "Reading inequality off the harmonised series"

## v0.5 — More data (target: 2026-Q4 / 2027-Q1)

Onboarding work for new datasets. See
[`datasets-wishlist.md`](datasets-wishlist.md) for the candidate list
and rationale.

## v1.0 — Stable API + multilingual docs (target: 2027-Q1)

- [ ] Function signatures frozen, lifecycle promoted from
      `experimental` → `stable`
- [ ] PT-BR vignettes for every EN vignette (currently only the intro
      is bilingual)
- [ ] Zenodo DOI for the release; `citation("educabr")` cites it
- [ ] Decision point on `educabR` (Sidney) integration — see
      [`integration-educabR.md`](integration-educabR.md)
