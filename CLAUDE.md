# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Commands

``` r

# Load package (required before running ETL scripts or tests)
devtools::load_all()

# Run all tests
devtools::test()

# Run a single test file
testthat::test_file("tests/testthat/test-schema.R")

# Full CRAN check
devtools::check()
rcmdcheck::rcmdcheck(args = "--as-cran")

# Regenerate documentation
devtools::document()

# Build and preview pkgdown site
pkgdown::build_site()

# Run a specific ETL script (always from package root, after load_all())
source("data-raw/01_build_enrollment_kang_fgv.R")

# Launch dashboard locally during development
shiny::runApp("inst/dashboard")
```

## Architecture

### Public API

Three user-facing functions expose the internal datasets: -
[`get_enrollment()`](https://mancano-tales.github.io/educabr/reference/get_enrollment.md)
— school enrollment (counts and gross rates), backed by
`enrollment_kang_fgv` + `enrollment_tertiary` -
[`get_schooling()`](https://mancano-tales.github.io/educabr/reference/get_schooling.md)
— mean years of schooling, backed by `schooling_kang_fgv` -
[`educabr_cite()`](https://mancano-tales.github.io/educabr/reference/educabr_cite.md)
— builds `bibentry`/APA/BibTeX citations for any source key from
`source` column values

All three return tibbles in the same **canonical tidy-long schema**: one
row per observation, alternative sources as separate rows (never
separate columns), aggregations encoded as explicit `"total"` factor
levels (never `NA`).

### Schema contract

The schema lives in `inst/dict/schema.yaml`. It defines required
columns, controlled vocabularies (factor levels), primary-key columns,
and year domain. `R/utils-schema.R` provides `load_schema()` and
`validate_against_schema()` — every ETL script must call the latter
before
[`usethis::use_data()`](https://usethis.r-lib.org/reference/use_data.html).

Supporting dictionaries: - `inst/dict/vocabularies/sources.yaml` —
source keys + citation metadata (drives
[`educabr_cite()`](https://mancano-tales.github.io/educabr/reference/educabr_cite.md)) -
`inst/dict/vocabularies/indicators.yaml` — indicator key registry -
`inst/dict/i18n.yaml` — PT-BR label translations applied when
`lang = "pt"`

### Data loading pattern

[`get_enrollment()`](https://mancano-tales.github.io/educabr/reference/get_enrollment.md)
calls `.load_enrollment_panel()`, which iterates
`.enrollment_datasets()` (a registry of dataset names), fetches each
from the package namespace, fills any missing optional columns with
`.ENR_DEFAULTS`, and row-binds them into a single canonical frame. New
enrollment datasets must be registered in `.enrollment_datasets()`.

### ETL pipeline (`data-raw/`)

Scripts follow a five-step pattern: **READ → TIDY → VALIDATE → ANNOTATE
→ WRITE**. Run them with `devtools::load_all()` active so
`educabr:::validate_against_schema()` is accessible. Each script writes
one `.rda` to `data/`. After running, update `data-raw/_manifest.yaml`.

### Dashboard (`inst/dashboard/`)

The Shiny app (`app.R` + `global.R`) consumes only the public API. It is
deployed to shinyapps.io. During development run it with
`shiny::runApp("inst/dashboard")` rather than
[`run_dashboard()`](https://mancano-tales.github.io/educabr/reference/run_dashboard.md)
(which requires the package to be installed).

## Key conventions

- **Factor levels vs NA**: `"total"` means “no breakdown on this
  dimension”; `NA` means the value is unknown. Never use `NA` for
  aggregates.
- **Source keys**: Always snake_case identifiers declared in
  `sources.yaml` (e.g. `kang_paese_felix_2021`). Derived rows use
  composite keys like `"source_a+source_b"`.
- **Column names**: English. PT-BR labels are opt-in via `lang = "pt"`
  and resolved through `i18n.yaml` at query time — never baked into the
  stored data.
- **`is_derived`**: Flag for rows computed by combining components
  across sources. Excluded by default (`include_derived = FALSE`) to
  avoid double-counting.
- **ETL dependencies**: `dplyr`, `tidyr`, `readxl` are Suggests (not
  Imports) — they are only needed for `data-raw/` scripts, not for end
  users.
