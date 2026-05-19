# educabr

> Harmonised historical series on Brazilian education — enrollment and
> educational attainment, compiled and reconciled across decades of
> heterogeneous official and academic sources.

[![License: GPL (\>=
3)](https://img.shields.io/badge/License-GPL--3-blue.svg)](https://mancano-tales.github.io/educabr/LICENSE.md)
[![R-CMD-check](https://github.com/mancano-tales/educabr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mancano-tales/educabr/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/mancano-tales/educabr/actions/workflows/pkgdown.yaml/badge.svg)](https://mancano-tales.github.io/educabr/)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

`educabr` provides curated long-run series on Brazilian formal education
— enrollment by stage and network, years of schooling, literacy and
attainment — compiled and reconciled from heterogeneous official and
academic sources (Censo Escolar, PNAD, Censo Demográfico, Anuário
Estatístico do IBGE, INEP CENSUP, Kang/FGV-IBRE, Walter & Kang, among
others) into a single tidy schema with explicit per-row provenance.

**🇧🇷** `educabr` reúne séries históricas tratadas sobre educação formal
no Brasil — matrículas, anos de estudo, atingimento educacional — em um
único schema *tidy*, com proveniência explícita. Veja a [vinheta em
português](https://mancano-tales.github.io/educabr/articles/02-introducao-pt.html).

------------------------------------------------------------------------

## Quick links

- 📖 **[Reference site](https://mancano-tales.github.io/educabr/)** —
  function reference, articles, news
- 📊 **[Live
  dashboard](https://qx3hly-tales-man0ano.shinyapps.io/educabr/)** —
  interactive multi-source comparison on shinyapps.io
- 📝 **[Get
  started](https://mancano-tales.github.io/educabr/articles/01-introduction.html)**
  — 10-minute tour of the API
- 🐛 **[Issues](https://github.com/mancano-tales/educabr/issues)**

------------------------------------------------------------------------

## Installation

`educabr` is not yet on CRAN. Install the development version from
GitHub:

``` r

# install.packages("remotes")
remotes::install_github("mancano-tales/educabr")
```

------------------------------------------------------------------------

## Usage

The package exposes three top-level functions plus the bundled dashboard
launcher.

### `get_enrollment()` — school enrollment

> Who is enrolled at a given stage in a given year. *Annual flow, school
> perspective.*

``` r

library(educabr)

# Gross enrollment rate for ensino fundamental, Brazil, all years
get_enrollment(
  level     = "fundamental",
  indicator = "rate",
  geo_level = "BR"
)

# Tertiary enrollment by network, all sources kept side by side
get_enrollment(
  level    = "superior",
  network  = c("publica", "privada"),
  modality = "total",
  year     = c(1990, 2024)
)

# Enrollment rates by race/colour, 1960 onward
get_enrollment(
  level     = "fundamental",
  indicator = "rate",
  dimension = "race",
  year      = c(1960, 2010)
)
```

### `get_schooling()` — educational attainment

> How much the population has already studied. *Accumulated stock,
> person perspective.*

``` r

# Mean years of schooling for adults, Brazil
get_schooling(geo_level = "BR")

# Same series broken down by race and by sex
get_schooling(dimension = "race")
get_schooling(dimension = "sex")
```

### `run_dashboard()` — interactive Shiny app

``` r

educabr::run_dashboard()
```

Three navbar tabs:

- **Enrollment** — Kang/FGV series by stage, year, race
- **Tertiary Education** — multi-source comparison 1907–2024 (Kang,
  Maduro Jr., IBGE Século XX, INEP CENSUP), with optional reconstructed
  totals for the 2000–2008 in-person + EAD split
- **Educational Attainment** — Walter & Kang mean years of schooling by
  BR / region / UF, with race and sex breakdowns

Every chart has a “View R code” button that prints a self-contained
snippet (educabr + ggplot2 + plotly) you can paste into RStudio to
reproduce the interactive chart locally.

------------------------------------------------------------------------

## Datasets

Three internal datasets back the public functions:

| Dataset | Rows | Coverage | Source(s) |
|----|---:|----|----|
| `enrollment_kang_fgv` | 6,238 | BR + UF, EF1/EF2/EF/EM/ES, 1933–2010 (+ race breakdown 1960–2010) | Kang, Paese & Felix (2021); Kang & Menetrier (2024); Kang, Menetrier & Comim (2024) |
| `enrollment_tertiary` | 1,341 | BR, ensino superior, 1907–2024, by network/institution/modality | IBGE *Século XX*; Maduro Jr. (2007); Kang/Paese/Felix (2021); INEP CENSUP Synopsis / Microdata / Power BI |
| `schooling_kang_fgv` | 2,287 | BR + region + UF, mean years of schooling, 1925–2015, with race and sex breakdowns | Walter & Kang (2024) |

End users should call
[`get_enrollment()`](https://mancano-tales.github.io/educabr/reference/get_enrollment.md)
/
[`get_schooling()`](https://mancano-tales.github.io/educabr/reference/get_schooling.md).
The datasets are exposed for inspection but the public API normalises
schema differences, applies per-source filters and translates labels.

------------------------------------------------------------------------

## Schema

All `get_*()` functions return a `tibble` in the canonical tidy-long
schema documented in
[`inst/dict/schema.yaml`](https://mancano-tales.github.io/educabr/inst/dict/schema.yaml):
one row per observation, alternative sources for the same indicator as
**separate rows** (column `source`), aggregations as an explicit factor
level (`"total"`) rather than `NA`. Controlled vocabularies live in
[`inst/dict/vocabularies/`](https://mancano-tales.github.io/educabr/inst/dict/vocabularies),
and PT-BR labels for every factor level in
[`inst/dict/i18n.yaml`](https://mancano-tales.github.io/educabr/inst/dict/i18n.yaml).

------------------------------------------------------------------------

## Related work

`educabr` is complementary to
[`educabR`](https://github.com/SidneyBissoli/educabR) (Sidney Bissoli),
which organises access **by official source** (`get_ideb()`,
`get_enem()`, `get_censo_escolar()`, …). Here the axis is **by theme and
historical series**: single indicators compiled across multiple sources
over long time spans.

Design inspirations: [`geobr`](https://github.com/ipeaGIT/geobr)
(coherent function family),
[`PNADCperiods`](https://cran.r-project.org/package=PNADCperiods)
(embedded dashboard + methodological delivery), and the
[`brverse`](https://github.com/ipea/brverse) ecosystem.

------------------------------------------------------------------------

## Citation

``` r

citation("educabr")
```

A Zenodo DOI will accompany the first tagged release.

------------------------------------------------------------------------

## Contributing

Issues and PRs welcome. To contribute new data, open an issue first
describing the source file, author, geographic/temporal coverage and
licence — before submitting a PR.

------------------------------------------------------------------------

## License

Code under **GPL (\>= 3)**. Data redistributed under **CC BY 4.0**
(except where the original source imposes restrictions; see
[`inst/dict/vocabularies/sources.yaml`](https://mancano-tales.github.io/educabr/inst/dict/vocabularies/sources.yaml)).
See [`LICENSE.md`](https://mancano-tales.github.io/educabr/LICENSE.md).
