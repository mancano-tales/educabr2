# educabr 0.1.0

First public release. Initial set of harmonised long-run series on
Brazilian education plus a bundled Shiny dashboard.

## Datasets

* `enrollment_kang_fgv` — 6,238 rows. Brazilian school enrollment
  counts and gross rates by stage (EF1, EF2, EF, EM, ES), 1933-2010
  at national level and 1955-2010 at UF level, with breakdown by
  colour/race 1960-2010. Per-paper source attribution
  (`kang_paese_felix_2021`, `kang_menetrier_2024`,
  `kang_menetrier_comim_2024`).

* `enrollment_tertiary` — 1,341 rows. Brazilian tertiary enrollment
  1907-2024 compiled across seven primary sources: IBGE
  *Estatísticas do Século XX*, Durham (2005), Maduro Junior (2007),
  Kang/Paese/Felix (2021), INEP CENSUP Synopsis (1995-2008), INEP
  CENSUP Microdata (2009-2024), and the INEP CENSUP Power BI panel.
  Multiple sources per year-network are kept on purpose to support
  cross-source comparison. Includes 25 *reconstructed total* rows
  (`is_derived = TRUE`) that fill the 2000-2008 transition period
  where INEP published in-person and EAD enrollment separately.

* `schooling_kang_fgv` — 2,287 rows. Mean years of schooling for
  the adult population, 1925-2015 (BR), 1950-2015 (region, UF), with
  sex and race breakdowns at BR level (Walter & Kang 2024).

## API

* `get_enrollment()` — long-format access to enrollment series with
  filters for `level`, `network`, `institution_type`, `modality`,
  `year`, `geo_level`/`geo`, `dimension`, `indicator`, `source`,
  `include_derived`. Returns the canonical schema with English
  labels (`lang = "en"`) or PT-BR labels (`lang = "pt"`).

* `get_schooling()` — long-format access to the mean-years-of-schooling
  series with filters for `year`, `geo_level`/`geo`, `dimension`,
  `source`, `lang`.

* `run_dashboard()` — launches the bundled Shiny dashboard locally.

* `educabr_cite()` — builds `bibentry` objects (or APA-style prose, or
  BibTeX) for any of the harmonised data sources, driven by the
  controlled vocabulary in `inst/dict/vocabularies/sources.yaml`.

## Dashboard

* Three-theme navbar (English UI): Enrollment, Tertiary Education,
  Educational Attainment.
* Tertiary Education tab features multi-source comparison with
  interaction-based colour palette (each source × modality
  combination gets a unique colour shade), shape-by-source, and
  linetype-by-modality encoding.
* "View R code" button on every tab generates a self-contained,
  copy-pasteable R snippet (educabr + ggplot2) that reproduces the
  current chart locally.

## Schema

* Canonical *tidy-long* schema documented in
  `inst/dict/schema.yaml` with primary-key constraints, year
  domain, controlled vocabularies for factor levels, and
  conventions for missing values.
* 13 primary source entries documented in
  `inst/dict/vocabularies/sources.yaml` with DOIs, URLs, and
  coverage metadata.
* PT-BR labels for every factor level in `inst/dict/i18n.yaml`.

## Build pipeline

* `data-raw/01_build_enrollment_kang_fgv.R` — Kang/FGV-IBRE 2023
  compilation (4 xlsx files → enrollment_kang_fgv.rda).
* `data-raw/02_build_schooling_kang_fgv.R` — Walter & Kang 2024
  series (1 xlsx file → schooling_kang_fgv.rda).
* `data-raw/03_build_enrollment_tertiary.R` — multi-source tertiary
  compilation, with canonicalisation of 69 raw source strings into
  7 canonical keys and 4 composite derived-row keys, plus
  exact-duplicate deduplication.

## Tests

* 9 tests for `get_enrollment()` (core filters and pivots).
* 9 tests for `get_schooling()`.
* 7 tests for the tertiary-specific arguments
  (`institution_type`, `modality`, `include_derived`, composite
  source keys, loader normalisation of legacy datasets).
