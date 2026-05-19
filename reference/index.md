# Package index

## Data access

Public API for the harmonised series. Each function returns a tibble in
the canonical tidy-long schema documented in `inst/dict/schema.yaml`.

- [`get_enrollment()`](https://mancano-tales.github.io/educabr/reference/get_enrollment.md)
  : Brazilian school-enrollment series
- [`get_schooling()`](https://mancano-tales.github.io/educabr/reference/get_schooling.md)
  : Brazilian mean years of schooling

## Citations

Cite the originating data sources, not only the package itself.

- [`educabr_cite()`](https://mancano-tales.github.io/educabr/reference/educabr_cite.md)
  : Generate citations for educabr data sources

## Dashboard

Launch the bundled Shiny dashboard. A read-only deployment is also
[hosted on
shinyapps.io](https://qx3hly-tales-man0ano.shinyapps.io/educabr/).

- [`run_dashboard()`](https://mancano-tales.github.io/educabr/reference/run_dashboard.md)
  : Launch the educabr Shiny dashboard

## Backing datasets

Internal backing stores for
[`get_enrollment()`](https://mancano-tales.github.io/educabr/reference/get_enrollment.md)
and
[`get_schooling()`](https://mancano-tales.github.io/educabr/reference/get_schooling.md).
End users should call the `get_*()` functions instead of loading these
objects directly — the public API normalises schema differences across
datasets, applies filters and translates labels.

- [`enrollment_kang_fgv`](https://mancano-tales.github.io/educabr/reference/enrollment_kang_fgv.md)
  : Enrollment series — Kang / FGV-IBRE 2023 compilation
- [`enrollment_tertiary`](https://mancano-tales.github.io/educabr/reference/enrollment_tertiary.md)
  : Tertiary (ensino superior) enrollment — multi-source compilation
- [`schooling_kang_fgv`](https://mancano-tales.github.io/educabr/reference/schooling_kang_fgv.md)
  : Mean years of schooling — Walter & Kang 2023 compilation

## Package

- [`educabr`](https://mancano-tales.github.io/educabr/reference/educabr-package.md)
  [`educabr-package`](https://mancano-tales.github.io/educabr/reference/educabr-package.md)
  : educabr: Harmonized Historical Series on Brazilian Education
