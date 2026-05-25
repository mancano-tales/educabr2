# Package index

## Data access

Public API for the harmonised series. Each function returns a tibble in
the canonical tidy-long schema documented in `inst/dict/schema.yaml`.

- [`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
  : Brazilian school-enrollment series
- [`get_schooling()`](https://mancano-tales.github.io/educabr/dev/reference/get_schooling.md)
  : Brazilian mean years of schooling
- [`get_expenditure()`](https://mancano-tales.github.io/educabr/dev/reference/get_expenditure.md)
  : Brazilian public expenditure on education
- [`get_progression()`](https://mancano-tales.github.io/educabr/dev/reference/get_progression.md)
  : Brazilian grade-progression series

## Citations and provenance

Discover the underlying sources and cite them — not only the package
itself.

- [`list_sources()`](https://mancano-tales.github.io/educabr/dev/reference/list_sources.md)
  : List the data sources bundled with educabr2
- [`educabr_cite()`](https://mancano-tales.github.io/educabr/dev/reference/educabr_cite.md)
  : Generate citations for educabr2 data sources

## Dashboard

Launch the bundled Shiny dashboard. A read-only deployment is also
[hosted on
shinyapps.io](https://qx3hly-tales-man0ano.shinyapps.io/educabr/).

- [`run_dashboard()`](https://mancano-tales.github.io/educabr/dev/reference/run_dashboard.md)
  : Launch the educabr2 Shiny dashboard

## Backing datasets

Internal backing stores for the public `get_*()` functions. End users
should call the functions instead of loading these objects directly —
the public API normalises schema differences across datasets, applies
filters and translates labels.

- [`enrollment_kang_fgv`](https://mancano-tales.github.io/educabr/dev/reference/enrollment_kang_fgv.md)
  : Enrollment series — Kang / FGV-IBRE 2023 compilation
- [`enrollment_tertiary`](https://mancano-tales.github.io/educabr/dev/reference/enrollment_tertiary.md)
  : Tertiary (ensino superior) enrollment — multi-source compilation
- [`schooling_kang_fgv`](https://mancano-tales.github.io/educabr/dev/reference/schooling_kang_fgv.md)
  : Mean years of schooling — Walter & Kang 2023 compilation
- [`expenditure_kang_fgv`](https://mancano-tales.github.io/educabr/dev/reference/expenditure_kang_fgv.md)
  : Public expenditure on education — Kang & Menetrier 2024 compilation
- [`progression_kang_fgv`](https://mancano-tales.github.io/educabr/dev/reference/progression_kang_fgv.md)
  : Grade-progression series (GDR6) — Kang, Paese & Felix 2021
  compilation

## Package

- [`educabr2`](https://mancano-tales.github.io/educabr/dev/reference/educabr2-package.md)
  [`educabr2-package`](https://mancano-tales.github.io/educabr/dev/reference/educabr2-package.md)
  : educabr2: Harmonized Historical Series on Brazilian Education
