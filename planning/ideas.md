# Ideas — parking lot

Half-baked ideas that don't fit anywhere else yet. Promote them to
their own file when they get traction; delete them when they go cold.

---

- [ ] **Quarto blog or pkgdown article** showing how one might
  reproduce a published education paper (e.g. Kang/Paese/Felix 2021)
  end-to-end using only `educabr`. Strong story, doubles as marketing
  and as a validation of the harmonised series.

- [ ] **`educabr_summary(df)`** — generic summariser for any
  `get_*()` output: prints year range, geographic coverage, sources
  involved, distinct levels. Saves the user from typing
  `range(df$year); unique(df$source)` every time.

- [ ] **Cohort cuts** — turn long-format annual series into birth-cohort
  series (each row = "people born in 1980", value = mean years of
  schooling observed at age 30). Single helper:
  `to_cohort(df, observed_age)`. Surprisingly useful for life-course
  papers.

- [ ] **Spatial integration with `geobr`** — every `get_*(geo_level =
  "UF")` could optionally `left_join` with `geobr::read_state()` and
  return an `sf` object behind a flag (`as_sf = TRUE`). Removes
  boilerplate for map plots.

- [ ] **PT-BR `run_dashboard(lang = "pt")`** — UI labels are mostly
  English. The dictionary in `inst/dict/i18n.yaml` already has the
  translations.

- [ ] **`compute_gap()` extension: confidence intervals via
  bootstrap** — for inequality gaps, point estimates without bands
  are misleading.

- [ ] **Onboarding script** — `educabr::welcome()` that prints a
  one-screen orientation: what's in the package, three example
  calls, link to the vignette.

- [ ] **Reach out to FGV-IBRE** for primary-source endorsement (they
  authored the Kang series). Their endorsement → free publicity
  inside the Brazilian education-research community.

- [ ] **Issue templates** (`.github/ISSUE_TEMPLATE/`) — "Report a
  data discrepancy", "Request a new source", "Bug in a `get_*()`
  function". Lowers the friction for outside contributions.

- [ ] **Translated function docs** — `roxygen2` doesn't natively
  support multiple languages, but we could ship `man-pt/` alongside
  `man/` and have a `educabr_help("get_enrollment", lang = "pt")`
  shim. Niche but valuable for the target audience.
