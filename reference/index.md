# Package index

## Data access

Public API for the harmonised series.

- [`get_enrollment()`](https://mancano-tales.github.io/educabr/reference/get_enrollment.md)
  : Brazilian school-enrollment series
- [`get_schooling()`](https://mancano-tales.github.io/educabr/reference/get_schooling.md)
  : Brazilian mean years of schooling

## Dashboard

- [`run_dashboard()`](https://mancano-tales.github.io/educabr/reference/run_dashboard.md)
  : Launch the educabr Shiny dashboard

## Datasets

Internal backing stores for
[`get_enrollment()`](https://mancano-tales.github.io/educabr/reference/get_enrollment.md)
and
[`get_schooling()`](https://mancano-tales.github.io/educabr/reference/get_schooling.md).
End users should call the `get_*()` functions rather than loading these
objects directly.

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
