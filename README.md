# educabr2 <img src="man/figures/logo.png" align="right" height="139" alt="educabr2 logo" />

> Harmonised historical series on Brazilian education — enrollment and
> educational attainment, compiled and reconciled across decades of
> heterogeneous official and academic sources.

[![License: GPL (>= 3)](https://img.shields.io/badge/License-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
[![R-CMD-check](https://github.com/mancano-tales/educabr2/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mancano-tales/educabr2/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/mancano-tales/educabr2/actions/workflows/pkgdown.yaml/badge.svg)](https://mancano-tales.github.io/educabr2/)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

`educabr2` provides curated long-run series on Brazilian formal
education — enrollment by stage and network, years of schooling,
literacy and attainment — compiled and reconciled from heterogeneous
official and academic sources (Censo Escolar, PNAD, Censo Demográfico,
Anuário Estatístico do IBGE, INEP CENSUP, Kang/FGV-IBRE, Walter & Kang,
among others) into a single tidy schema with explicit per-row
provenance.

**🇧🇷** `educabr2` reúne séries históricas tratadas sobre educação
formal no Brasil — matrículas, anos de estudo, atingimento educacional
— em um único schema *tidy*, com proveniência explícita. Veja a
[vinheta em português](https://mancano-tales.github.io/educabr2/articles/introducao-pt.html).

---

## Quick links

- 📖 **[Reference site](https://mancano-tales.github.io/educabr2/)** —
  function reference, articles, news
- 📊 **[Live dashboard](https://qx3hly-tales-man0ano.shinyapps.io/educabr2/)**
  — interactive multi-source comparison on shinyapps.io
- 📝 **[Get started](https://mancano-tales.github.io/educabr2/articles/introduction.html)**
  — 10-minute tour of the API
- 🐛 **[Issues](https://github.com/mancano-tales/educabr2/issues)**

---

## Installation

`educabr2` is not yet on CRAN. Install the development version from
GitHub:

```r
# install.packages("remotes")
remotes::install_github("mancano-tales/educabr2")
```

---

## Usage

The package exposes six top-level data-access functions, two utility
functions, and the bundled dashboard launcher.

### `get_enrollment()` — school enrollment

> Who is enrolled at a given stage in a given year. *Annual flow,
> school perspective.*

```r
library(educabr2)

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

```r
# Mean years of schooling for adults, Brazil
get_schooling(geo_level = "BR")

# Same series broken down by race and by sex
get_schooling(dimension = "race")
get_schooling(dimension = "sex")
```

### `get_expenditure()` — public expenditure on education

> How much the State spends on education. *Annual flow, public-purse
> perspective.*

```r
# Total public expenditure on education as share of GDP
get_expenditure(indicator = "share_gdp", level = "total")

# Per-student spending in tertiary education, all years
get_expenditure(indicator = "per_student", level = "superior")

# Kang & Menetrier's "double ratio" of fiscal regressivity (ES / EF1)
get_expenditure(indicator = "double_ratio_es_ef1")
```

### `get_progression()` — grade-progression indicators

> How students flow through the early primary grades. *Internal-flow
> ratio.*

```r
# National GDR6 series (1955-2010)
get_progression()

# GDR6 across Northeast states from 1980
get_progression(geo_level = "UF",
                geo = c("BA", "PE", "CE", "PB", "MA", "PI", "RN", "AL", "SE"),
                year = c(1980, 2010))
```

### `get_attainment()` — comparative international attainment

> Share of the population aged 15–64 who completed at least a given
> education level. *Accumulated stock, cross-country perspective.*
> Source: Lee & Lee (2016), ~111 countries, 1870–2010.

```r
# Tertiary completion in Brazil over time
get_attainment(level = "tertiary", geo = "BRA")

# Primary completion across Latin America, post-1950
get_attainment(level = "primary",
               geo   = c("BRA", "ARG", "CHL", "MEX", "URY"),
               year  = c(1950, 2010))

# Compare male vs female secondary completion in Brazil
get_attainment(level = "secondary", geo = "BRA", dimension = "sex")
```

### `list_sources()` — list bundled data sources

> Returns a tibble describing every source in the controlled vocabulary,
> with short name, type, temporal/geographic coverage, DOI and URL.

```r
src <- list_sources()

# Filter to academic papers only
src[src$type == "academic", c("key", "short_name", "doi")]

# Sources that include UF-level coverage
src[grepl("UF", src$geo), c("key", "year_start", "year_end")]
```

### `run_dashboard()` — interactive Shiny app

```r
educabr2::run_dashboard()
```

A curated **Overview** tab — four fixed story charts for broad
audiences (secular expansion, public × private with the 1997/2005
regulatory landmarks, the rise of EAD, the gender reversal in
schooling) — plus six thematic tabs:

* **Enrollment** — Kang/FGV series by stage, year, race
* **Tertiary Education** — multi-source comparison 1907–2024
  (Kang, Maduro Jr., IBGE Século XX, INEP CENSUP), with optional
  reconstructed totals for the 2000–2008 in-person + EAD split
* **Educational Attainment** — Walter & Kang mean years of schooling
  by BR / region / UF, with race and sex breakdowns
* **Public Expenditure** — Kang & Menetrier (2024) series on public
  spending in education: share of GDP by stage, per-student spending
  as share of GDP per capita, and the "double ratio" indicators of
  fiscal regressivity (Brazil, 1933–2010)
* **Grade Progression** — Kang/Paese/Felix (2021) GDR6 progression
  ratio (enrollment in grades 4-6 / grades 1-3 of the old eight-year
  primary system), BR and 20 UFs, 1955–2010
* **International Comparison** — Lee & Lee (2016) attainment shares
  (primary/secondary/tertiary completed, population 15–64), 111
  countries, 1870–2010, with sex breakdowns — Brazil against the
  world record in the same interface

Every chart has a "View R code" button that prints a self-contained
snippet (educabr2 + ggplot2 + plotly, styled with the package's own
`theme_educabr()` / Okabe-Ito scales / `scale_x_year_educabr()`) you
can paste into RStudio to reproduce the interactive chart locally.

---

## Datasets

Six internal datasets back the public functions:

| Dataset | Rows | Coverage | Source(s) |
|---|---:|---|---|
| `enrollment_kang_fgv` | 6,238 | BR + UF, EF1/EF2/EF/EM/ES, 1933–2010 (+ race breakdown 1960–2010) | Kang, Paese & Felix (2021); Kang & Menetrier (2024); Kang, Menetrier & Comim (2024) |
| `enrollment_tertiary` | 1,341 | BR, ensino superior, 1907–2024, by network/institution/modality | IBGE *Século XX*; Maduro Jr. (2007); Kang/Paese/Felix (2021); INEP CENSUP Synopsis / Microdata / Power BI |
| `schooling_kang_fgv` | 2,287 | BR + region + UF, mean years of schooling, 1925–2015, with race and sex breakdowns | Walter & Kang (2024) |
| `expenditure_kang_fgv` | 1,170 | BR, public expenditure on education (% GDP, per-student, "double ratios"), 1933–2010 | Kang & Menetrier (2024) |
| `progression_kang_fgv` | 1,090 | BR + 20 UFs, GDR6 grade-progression ratio, 1955–2010 | Kang, Paese & Felix (2021) |
| `lee_lee_2016` | ~29,000 | 111 countries, primary/secondary/tertiary attainment, 1870–2010 (5-year steps), by sex | Lee & Lee (2016) |

End users should call the `get_*()` functions. The datasets are
exposed for inspection but the public API normalises schema
differences, applies per-source filters and translates labels.

**Deduplication hierarchy.** When the same year and sector are
covered by multiple sources, the recommended order of precedence is:
INEP CENSUP microdata (2009–2024) → INEP statistical synopses
(1995–2008) → Kang, Paese & Felix (1990–1994) → Maduro Junior →
Durham → IBGE *Estatísticas do Século XX*. The most disaggregated
and official source available always wins; all competing estimates
remain in the panel for auditing.

**Validation.** Overlapping windows are preserved deliberately so
the sources can be checked against each other: in 1995, for example,
the INEP synopsis, Durham (2005) and Kang et al. (2021) all report
exactly 1,759,703 tertiary enrollments — a perfect triangulation of
the academic reconstructions against the official record.

---

## Data Visualization

The `educabr2` package includes a built-in visualization system based on Kieran Healy's *Data Visualization* (2018/2026) design principles. It provides a consistent aesthetic theme and colorblind-safe palettes matching the ongoing MA Thesis *The Politics of Reforming Tertiary Education* (Tales Mançano, 2026).

To style your plots, use the `theme_educabr()` and `scale_fill_educabr()` / `scale_colour_educabr()` functions:

```r
library(ggplot2)
library(educabr2)

# Query some data
df <- get_enrollment(level = "superior", dimension = "race")

# Build a plot
ggplot(df, aes(x = year, y = value, fill = dim_race)) +
  geom_area() +
  theme_educabr() +
  scale_fill_educabr() +
  scale_x_year_educabr(df$year)
```

### Year Axis for Historical Series (`scale_x_year_educabr()`)

Most series in `educabr2` span many decades (some more than a century), and
default `ggplot2` breaks become unreadable at that scale. The exported
`scale_x_year_educabr(years)` scale picks the break spacing from the span of
the data you actually plot — every 20 years beyond six decades, every 10
years for intermediate spans, `pretty()` breaks below that — and always
labels the first and last year present in the series, dropping any grid
break that would collide with those extreme labels. Pass it the vector of
years being plotted (typically `df$year`).

### Font Auto-Registration (TinyTeX & Latin Modern)

To match formal academic publications, the theme tries to use the standard LaTeX font family **Latin Modern Roman**.
* **Automatic Registration:** If you have **TinyTeX** installed on your system (e.g. via `tinytex::install_tinytex()`) and have the `showtext` and `sysfonts` R packages installed, `theme_educabr()` will automatically locate the `.otf` font files in your TinyTeX directories and load them dynamically using `sysfonts::font_add()`.
* **Graceful Fallback:** If the font files are not found on your system or the required packages are missing, the theme will automatically and silently fall back to your system's default `"serif"` font family.

### Omit/Include Titles Inside Plot (`plot_titles`)

Depending on where you are presenting your charts, you may want to include titles within the image or handle them in the document text:
* **For General Presentations (`plot_titles = TRUE`):** This is the default. The plot titles, subtitle, and caption are styled and rendered inside the image canvas itself.
* **For LaTeX/Quarto Manuscripts (`plot_titles = FALSE`):** This hides the title, subtitle, and caption from the ggplot canvas, allowing you to specify them as metadata captions (e.g. `fig-cap` in Quarto or `\caption{}` in LaTeX) in the main document, which prevents duplicate titles and enables proper page layout.

```r
# Hide title elements within the plot canvas for manuscripts
ggplot(df, aes(x = year, y = value, fill = dim_race)) +
  geom_area() +
  theme_educabr(plot_titles = FALSE) +
  scale_fill_educabr()
```

---

## Schema

All `get_*()` functions return a `tibble` in the canonical tidy-long
schema documented in
[`inst/dict/schema.yaml`](inst/dict/schema.yaml): one row per
observation, alternative sources for the same indicator as **separate
rows** (column `source`), aggregations as an explicit factor level
(`"total"`) rather than `NA`. Controlled vocabularies live in
[`inst/dict/vocabularies/`](inst/dict/vocabularies), and PT-BR labels
for every factor level in
[`inst/dict/i18n.yaml`](inst/dict/i18n.yaml).

---

## Related work

`educabr2` is complementary to
[`educabR`](https://github.com/SidneyBissoli/educabR) (Sidney Bissoli),
which organises access **by official source** (`get_ideb()`,
`get_enem()`, `get_censo_escolar()`, …). Here the axis is **by theme
and historical series**: single indicators compiled across multiple
sources over long time spans.

In practice: need **current-year microdata** (IDEB, ENEM, Censo
Escolar, SAEB, and other INEP indicators fetched and cached on
demand)? Use `educabR`. Need a **harmonised long-run series** with
explicit per-row provenance, going back decades before INEP's own
microdata exists? Use `educabr2`. The two are designed to be used
side by side, not as alternatives to each other.

Design inspirations:
[`geobr`](https://github.com/ipea/geobr) (coherent function family),
[`PNADCperiods`](https://cran.r-project.org/package=PNADCperiods)
(embedded dashboard + methodological delivery), and the
[`brverse`](https://github.com/ipea/brverse) ecosystem.

---

## Citation

Cite both the package (for the harmonisation work) and the
**originating sources** for any data you actually use. The
`educabr_cite()` helper builds APA / BibTeX entries for every
bundled source:

```r
citation("educabr2")                              # cite the package

educabr_cite("kang_paese_felix_2021")            # cite one source
educabr_cite(c("walter_kang_2023",               # cite many
              "inep_microdados_censup"))
educabr_cite()                                   # all bundled sources

# Typical workflow — query first, then cite only what you used
d   <- get_enrollment(level = "fundamental", indicator = "rate")
educabr_cite(unique(d$source), style = "text")
```

---

## Contributing

Issues and PRs welcome. To contribute new data, open an issue first
describing the source file, author, geographic/temporal coverage and
licence — before submitting a PR.

---

## License

Code under **GPL (>= 3)**. Data redistributed under **CC BY 4.0**
(except where the original source imposes restrictions; see
[`inst/dict/vocabularies/sources.yaml`](inst/dict/vocabularies/sources.yaml)).
See the [GPL-3 licence text](https://www.gnu.org/licenses/gpl-3.0.html).

---

## Como citar / How to cite

Se você usar este pacote em uma publicação, cite tanto o pacote quanto
as fontes originais dos dados que utilizou. Para obter a entrada BibTeX
ou a referência APA do pacote, use:

If you use this package in a publication, cite both the package and the
original data sources you drew from. To get the BibTeX entry or APA
reference for the package, run:

```r
citation("educabr2")
```

**Referência sugerida / Suggested citation:**

Mançano, T., & Alcantara, V. (2026). *educabr2: Harmonized
Historical Series on Brazilian Education* (R package version
0.1.1). GitHub. <https://github.com/mancano-tales/educabr2>

**BibTeX:**

```bibtex
@Manual{educabr2,
  title  = {educabr2: Harmonized Historical Series on Brazilian Education},
  author = {Tales Mançano and Victor Alcantara},
  year   = {2026},
  note   = {R package version 0.1.1},
  url    = {https://github.com/mancano-tales/educabr2},
}
```

Cite also the **originating sources** for any data you actually use.
The `educabr_cite()` helper builds APA / BibTeX entries for every
bundled source (see [Citation](#citation) above).

Um DOI Zenodo acompanhará o primeiro lançamento marcado com uma *tag*
de versão. / A Zenodo DOI will accompany the first tagged release.
