# Changelog

## educabr2 0.1.0.9000 (development version)

CRAN-readiness polish plus two new themes (public expenditure and
grade-progression). No breaking changes to existing `get_*()` signatures
or to `enrollment_kang_fgv` / `schooling_kang_fgv` contents.

### CI / build

- Renamed vignettes from `01-introduction.Rmd` / `02-introducao-pt.Rmd`
  to `introduction.Rmd` / `introducao-pt.Rmd` — the numeric-prefix
  pattern triggered an `R CMD check --as-cran` WARNING about invalid
  file names in `inst/doc`, which had been breaking the CI matrix since
  the dashboard-tabs push.
  [`vignette("introduction", "educabr2")`](https://mancano-tales.github.io/educabr/dev/articles/introduction.md)
  and
  [`vignette("introducao-pt", "educabr2")`](https://mancano-tales.github.io/educabr/dev/articles/introducao-pt.md)
  are now the canonical entry points (the pkgdown URLs follow the new
  names too).
- `inst/WORDLIST` extended with the new technical vocabulary (`GDR6`,
  `regressivity`, `Unitless`, …) and the PT-BR terms introduced in Case
  5 / Case 6 of the vignettes — spell check is clean again.

### New themes & datasets

- `expenditure_kang_fgv` — 1,170 rows. Public expenditure on education,
  Brazil, 1933-2010 (Kang & Menetrier 2024). Four indicators:
  `expenditure_share_gdp`, `expenditure_per_student_pct_gdp_pc`, and the
  two “double ratio” indicators of fiscal regressivity
  (`expenditure_double_ratio_es_ef1`,
  `expenditure_double_ratio_es_ef_em`).
- `progression_kang_fgv` — 1,090 rows. Grade-progression ratio GDR6
  (enrollment in grades 4-6 / grades 1-3 of the old eight-year primary
  system), BR + 20 UFs, 1955-2010 (Kang, Paese & Felix 2021).

### New public API

- [`get_expenditure()`](https://mancano-tales.github.io/educabr/dev/reference/get_expenditure.md)
  — long-format access to the public-expenditure series. Supports
  indicator aliases (`"share_gdp"`, `"per_student"`,
  `"double_ratio_es_ef1"`, `"double_ratio_es_ef_em"`).
- [`get_progression()`](https://mancano-tales.github.io/educabr/dev/reference/get_progression.md)
  — long-format access to grade-progression indicators. Supports
  indicator alias `"gdr6"`. Filters by `geo_level` / `geo` like
  [`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md).

### Schema additions (additive only)

- New `level` value: `fundamental_medio` (EF + EM combined; appears in
  expenditure data).
- New `unit` values: `percent_gdp` and `percent_gdp_per_capita`
  (alongside the existing `percent`, `ratio`, `years`, `count`).
- `inst/dict/vocabularies/indicators.yaml` gains entries for every
  indicator emitted by the new datasets, with PT-BR translations
  surfaced in `inst/dict/i18n.yaml`.

### Dashboard

- Two new navbar tabs: **Public Expenditure** and **Grade Progression**,
  built on top of
  [`get_expenditure()`](https://mancano-tales.github.io/educabr/dev/reference/get_expenditure.md)
  and
  [`get_progression()`](https://mancano-tales.github.io/educabr/dev/reference/get_progression.md).
  Each tab carries the standard educabr2 layout — sidebar filters,
  series plot (plotly), table view (DT), source cards, CSV download, and
  a “View R code” modal that emits a reproducible educabr2 + ggplot2 +
  plotly snippet.

### Other changes

- [`list_sources()`](https://mancano-tales.github.io/educabr/dev/reference/list_sources.md)
  — new helper returning a tibble of every entry in the source
  vocabulary (key, short_name, type, coverage, DOI, URL, notes).
  Discovery counterpart to
  [`educabr_cite()`](https://mancano-tales.github.io/educabr/dev/reference/educabr_cite.md).
- [`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
  /
  [`get_schooling()`](https://mancano-tales.github.io/educabr/dev/reference/get_schooling.md):
  examples now run during `R CMD check` (previously skipped with
  `@examplesIf FALSE`).
- CI: added `windows-latest, r: 'devel'` to the R-CMD-check matrix —
  covers what `check_win_devel()` does, on every push.
- Docs: `.github/CONTRIBUTING.md`, `inst/WORDLIST` for clean spell
  checks, abbreviation “anos inic.” → “anos iniciais” in
  `enrollment_kang_fgv` Rd table for readability.

## educabr2 0.1.0

First public release. Initial set of harmonised long-run series on
Brazilian education plus a bundled Shiny dashboard.

### Datasets

- `enrollment_kang_fgv` — 6,238 rows. Brazilian school enrollment counts
  and gross rates by stage (EF1, EF2, EF, EM, ES), 1933-2010 at national
  level and 1955-2010 at UF level, with breakdown by colour/race
  1960-2010. Per-paper source attribution (`kang_paese_felix_2021`,
  `kang_menetrier_2024`, `kang_menetrier_comim_2024`).

- `enrollment_tertiary` — 1,341 rows. Brazilian tertiary enrollment
  1907-2024 compiled across seven primary sources: IBGE *Estatísticas do
  Século XX*, Durham (2005), Maduro Junior (2007), Kang/Paese/Felix
  (2021), INEP CENSUP Synopsis (1995-2008), INEP CENSUP Microdata
  (2009-2024), and the INEP CENSUP Power BI panel. Multiple sources per
  year-network are kept on purpose to support cross-source comparison.
  Includes 25 *reconstructed total* rows (`is_derived = TRUE`) that fill
  the 2000-2008 transition period where INEP published in-person and EAD
  enrollment separately.

- `schooling_kang_fgv` — 2,287 rows. Mean years of schooling for the
  adult population, 1925-2015 (BR), 1950-2015 (region, UF), with sex and
  race breakdowns at BR level (Walter & Kang 2024).

### API

- [`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
  — long-format access to enrollment series with filters for `level`,
  `network`, `institution_type`, `modality`, `year`, `geo_level`/`geo`,
  `dimension`, `indicator`, `source`, `include_derived`. Returns the
  canonical schema with English labels (`lang = "en"`) or PT-BR labels
  (`lang = "pt"`).

- [`get_schooling()`](https://mancano-tales.github.io/educabr/dev/reference/get_schooling.md)
  — long-format access to the mean-years-of-schooling series with
  filters for `year`, `geo_level`/`geo`, `dimension`, `source`, `lang`.

- [`run_dashboard()`](https://mancano-tales.github.io/educabr/dev/reference/run_dashboard.md)
  — launches the bundled Shiny dashboard locally.

- [`educabr_cite()`](https://mancano-tales.github.io/educabr/dev/reference/educabr_cite.md)
  — builds `bibentry` objects (or APA-style prose, or BibTeX) for any of
  the harmonised data sources, driven by the controlled vocabulary in
  `inst/dict/vocabularies/sources.yaml`.

- [`list_sources()`](https://mancano-tales.github.io/educabr/dev/reference/list_sources.md)
  — returns a tibble describing every entry in the source vocabulary
  (key, type, temporal/geographic coverage, DOI, URL). Discovery
  counterpart to
  [`educabr_cite()`](https://mancano-tales.github.io/educabr/dev/reference/educabr_cite.md).

### Dashboard

- Three-theme navbar (English UI): Enrollment, Tertiary Education,
  Educational Attainment.
- Tertiary Education tab features multi-source comparison with
  interaction-based colour palette (each source × modality combination
  gets a unique colour shade), shape-by-source, and linetype-by-modality
  encoding.
- “View R code” button on every tab generates a self-contained,
  copy-pasteable R snippet (educabr2 + ggplot2) that reproduces the
  current chart locally.

### Schema

- Canonical *tidy-long* schema documented in `inst/dict/schema.yaml`
  with primary-key constraints, year domain, controlled vocabularies for
  factor levels, and conventions for missing values.
- 13 primary source entries documented in
  `inst/dict/vocabularies/sources.yaml` with DOIs, URLs, and coverage
  metadata.
- PT-BR labels for every factor level in `inst/dict/i18n.yaml`.

### Build pipeline

- `data-raw/01_build_enrollment_kang_fgv.R` — Kang/FGV-IBRE 2023
  compilation (4 xlsx files → enrollment_kang_fgv.rda).
- `data-raw/02_build_schooling_kang_fgv.R` — Walter & Kang 2024 series
  (1 xlsx file → schooling_kang_fgv.rda).
- `data-raw/03_build_enrollment_tertiary.R` — multi-source tertiary
  compilation, with canonicalisation of 69 raw source strings into 7
  canonical keys and 4 composite derived-row keys, plus exact-duplicate
  deduplication.

### Tests

- 9 tests for
  [`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
  (core filters and pivots).
- 9 tests for
  [`get_schooling()`](https://mancano-tales.github.io/educabr/dev/reference/get_schooling.md).
- 7 tests for the tertiary-specific arguments (`institution_type`,
  `modality`, `include_derived`, composite source keys, loader
  normalisation of legacy datasets).
