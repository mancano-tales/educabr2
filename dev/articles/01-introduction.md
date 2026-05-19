# Introduction to educabr

``` r

library(educabr)
```

## About the package

**educabr** provides, under a single canonical tidy schema, the most
extensive set of harmonised historical series on Brazilian education
available in analytic format:

- **Tertiary (higher-education) enrollment** — 1907 to 2024, **118
  years** of coverage, drawing on seven distinct primary sources (IBGE
  *Statistics of the 20th Century*, Durham, Maduro Junior, Kang, INEP
  Synopsis, INEP Microdata, and the INEP CENSUP Power BI panel).
- **Compulsory (fundamental) and upper-secondary enrollment** — 1933 to
  2010, with **race/colour** disaggregation from 1960 onwards (Kang,
  Paese & Felix 2021).
- **Mean years of schooling of the adult population** — 1925 to 2015,
  with breakdowns by **sex**, **race/colour**, **macroregion** and
  **state** (Walter & Kang 2024).

Every transformation is auditable: each output row carries a canonical
`source` key (catalogued in `inst/dict/vocabularies/sources.yaml`) and a
`source_note` with the exact table or chapter of origin.

## Installation

``` r

# From GitHub
remotes::install_github("mancano-tales/educabr")
```

## A two-function API

The public interface is intentionally minimal:

``` r

# Schemas of the two main return shapes
str(get_enrollment(level = "fundamental", year = 1950))
#> tibble [2 × 16] (S3: tbl_df/tbl/data.frame)
#>  $ year            : int [1:2] 1950 1950
#>  $ geo_level       : chr [1:2] "BR" "BR"
#>  $ geo_code        : chr [1:2] "BR" "BR"
#>  $ geo_name        : chr [1:2] "Brasil" "Brasil"
#>  $ level           : chr [1:2] "fundamental" "fundamental"
#>  $ network         : chr [1:2] "total" "total"
#>  $ institution_type: chr [1:2] "total" "total"
#>  $ modality        : chr [1:2] "total" "total"
#>  $ dim_race        : chr [1:2] "total" "total"
#>  $ age_group       : chr [1:2] "7-14" NA
#>  $ indicator       : chr [1:2] "enrollment_rate" "enrollment_count"
#>  $ value           : num [1:2] 4.55e+01 4.73e+06
#>  $ unit            : chr [1:2] "percent" "count"
#>  $ source          : chr [1:2] "kang_paese_felix_2021" "kang_paese_felix_2021"
#>  $ source_note     : chr [1:2] "Kang, Paese & Felix (2021). RHE 39(2):191-218. doi:10.1017/S0212610921000112" "Kang, Paese & Felix (2021). RHE 39(2):191-218. doi:10.1017/S0212610921000112"
#>  $ is_derived      : logi [1:2] FALSE FALSE
str(get_schooling(year = 1950))
#> tibble [1 × 12] (S3: tbl_df/tbl/data.frame)
#>  $ year       : int 1950
#>  $ geo_level  : chr "BR"
#>  $ geo_code   : chr "BR"
#>  $ geo_name   : chr "Brasil"
#>  $ dim_race   : chr "total"
#>  $ dim_sex    : chr "total"
#>  $ age_group  : chr NA
#>  $ indicator  : chr "mean_years_schooling"
#>  $ value      : num 1.59
#>  $ unit       : chr "years"
#>  $ source     : chr "walter_kang_2023"
#>  $ source_note: chr "Walter, J., & Kang, T. H. (2023). A new dataset of average years of schooling in Brazil, 1925-2015. FGV-IBRE working paper."
#>  - attr(*, "educabr_meta")=List of 5
#>   ..$ build_script  : chr "data-raw/02_build_schooling_kang_fgv.R"
#>   ..$ built_at      : POSIXct[1:1], format: "2026-05-17 19:08:24"
#>   ..$ primary_source: chr "walter_kang_2023"
#>   ..$ citation      : chr "Walter, J., & Kang, T. H. (2023). A new dataset of average years of schooling in Brazil, 1925-2015. FGV-IBRE working paper."
#>   ..$ raw_files     : chr "data-raw/sources/kang_fgv_ibre_2023/3._anos_estudo_1925_2015_v_abril2023.xlsx"
```

Both return long-format tibbles that follow the same canonical schema
(`inst/dict/schema.yaml`), with columns for the geographic unit, the
inequality dimension (race, sex, …), the source, and the value.

## Case 1 — gross enrollment rate by race/colour

Using `dimension = "race"` we can trace the trajectory of gross
fundamental-education enrollment for the five IBGE race/colour
categories between 1960 and 2010:

``` r

fund_race <- get_enrollment(
  level     = "fundamental",
  indicator = "rate",
  geo_level = "BR",
  dimension = "race",
  year      = c(1960, 2010)
)

head(fund_race)
#> # A tibble: 6 × 16
#>    year geo_level geo_code geo_name level      network institution_type modality
#>   <int> <chr>     <chr>    <chr>    <chr>      <chr>   <chr>            <chr>   
#> 1  1960 BR        BR       Brasil   fundament… total   total            total   
#> 2  1961 BR        BR       Brasil   fundament… total   total            total   
#> 3  1962 BR        BR       Brasil   fundament… total   total            total   
#> 4  1963 BR        BR       Brasil   fundament… total   total            total   
#> 5  1964 BR        BR       Brasil   fundament… total   total            total   
#> 6  1965 BR        BR       Brasil   fundament… total   total            total   
#> # ℹ 8 more variables: dim_race <chr>, age_group <chr>, indicator <chr>,
#> #   value <dbl>, unit <chr>, source <chr>, source_note <chr>, is_derived <lgl>
```

The gap between the three main categories (`white`, `black`, `brown`)
traces one of the central narratives in the sociological literature on
Brazilian education — relative convergence at compulsory levels
alongside persistent inequality at higher levels.

## Case 2 — multi-source comparison for tertiary enrollment

Brazilian tertiary enrollment has been reconstructed by **multiple
authors** with slightly different methodologies, especially for the long
1933–2000 period when official sources are sparse. The **educabr**
package keeps **all competing estimates** side by side, enabling direct
comparison:

``` r

ter_1980 <- get_enrollment(
  level     = "superior",
  year      = 1980,
  network   = "total",
  modality  = "total",
  indicator = "count"
)

ter_1980[, c("source", "value", "source_note")]
#> # A tibble: 4 × 3
#>   source                  value source_note                                     
#>   <chr>                   <dbl> <chr>                                           
#> 1 kang_paese_felix_2021 1377286 Kang, Paese & Felix (2021). RHE 39(2):191-218. …
#> 2 durham_2005           1377286 Durham (2005). Educação superior, pública e pri…
#> 3 kang_paese_felix_2021 1377286 Kang, Paese & Felix (2021), RHE 39(2):191-218. …
#> 4 maduro_junior_2007    1377286 Maduro Junior (2007). Taxas de matrícula e gast…
```

For 1980 several sources converge on the same value (~1.38 million),
which suggests a stabilised figure in the literature. For other years
estimates diverge — passing `source = "..."` to
[`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
is the recommended way to pin down a single series for secondary
analysis.

## Case 3 — the reconstructed totals problem (2000-2008)

Between 2000 and 2008 INEP began collecting distance-learning (EAD)
enrollment in a separate CENSUP table (`tabela7.x`), but **did not add**
it to the total of in-person enrollment published in `tabela5.x`. This
means that headline “total” series for that interval published by Kang,
Durham, Maduro Junior, and INEP’s own synopsis are **systematically
undercounted** — by up to ~700,000 enrollments in 2008 by our reckoning.

From 2009 onwards the CENSUP microdata already aggregate in-person and
EAD in the same registry, and the problem resolves itself.

For this transition interval, **educabr** ships **reconstructed totals**
that combine the in-person component of each source with INEP’s
published EAD figures. These rows carry `is_derived = TRUE` and are
excluded from the default
[`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
output; pass `include_derived = TRUE` to inspect them:

``` r

recon <- get_enrollment(
  level           = "superior",
  year            = c(2000, 2008),
  network         = "total",
  modality        = "total",
  indicator       = "count",
  include_derived = TRUE
)

recon[recon$is_derived, c("year", "source", "value")]
#> # A tibble: 23 × 3
#>     year source                                      value
#>    <int> <chr>                                       <dbl>
#>  1  2000 durham_2005+inep_sinopse_censup           2695927
#>  2  2000 inep_sinopse_censup+inep_sinopse_censup   2695927
#>  3  2000 kang_paese_felix_2021+inep_sinopse_censup 2695927
#>  4  2000 maduro_junior_2007+inep_sinopse_censup    2695927
#>  5  2001 durham_2005+inep_sinopse_censup           3045113
#>  6  2001 inep_sinopse_censup+inep_sinopse_censup   3036113
#>  7  2001 inep_sinopse_censup+inep_sinopse_censup   3036113
#>  8  2001 kang_paese_felix_2021+inep_sinopse_censup 3036113
#>  9  2001 maduro_junior_2007+inep_sinopse_censup    3036113
#> 10  2003 inep_sinopse_censup+inep_sinopse_censup   3936933
#> # ℹ 13 more rows
```

The composite `source` key (e.g.
`kang_paese_felix_2021+inep_sinopse_censup`) makes it explicit that this
is a combination: the **in-person component** comes from the first
source and the **EAD component** comes from the second. The
`source_note` records the exact composition for citation purposes.

> Suggested citation convention: “Reconstructed total computed from
> {in-person source} (in-person) and INEP CENSUP Synopsis (EAD),
> following the methodology documented in `educabr` (Mançano 2026).”

## Case 4 — mean years of schooling by sex

``` r

schooling_sex <- get_schooling(
  geo_level = "BR",
  dimension = "sex"
)

tail(schooling_sex)
#> # A tibble: 6 × 12
#>    year geo_level geo_code geo_name dim_race dim_sex age_group indicator   value
#>   <int> <chr>     <chr>    <chr>    <chr>    <chr>   <chr>     <chr>       <dbl>
#> 1  2010 BR        BR       Brasil   total    male    NA        mean_years…  8.03
#> 2  2011 BR        BR       Brasil   total    male    NA        mean_years…  8.2 
#> 3  2012 BR        BR       Brasil   total    male    NA        mean_years…  8.39
#> 4  2013 BR        BR       Brasil   total    male    NA        mean_years…  8.49
#> 5  2014 BR        BR       Brasil   total    male    NA        mean_years…  8.63
#> 6  2015 BR        BR       Brasil   total    male    NA        mean_years…  8.72
#> # ℹ 3 more variables: unit <chr>, source <chr>, source_note <chr>
```

This series captures the historical reversal of the *gender gap*: in
1925 men averaged more years of schooling than women; over the 20th
century that advantage inverts, and by 2015 women surpass men in average
attainment.

## Interactive dashboard

The package ships a Shiny dashboard for the three series:

``` r

educabr::run_dashboard()
```

The dashboard replicates the multi-source tertiary comparison
interactively. Each tab has a **“View R code”** button that emits the
`educabr` + `ggplot2` snippet needed to reproduce the visualisation in
your local R session — a direct bridge between dashboard exploration and
reproducible scripted analysis.

## Sources and citation

Every series carries a canonical source key (`source`) with the full
reference catalogued in `inst/dict/vocabularies/sources.yaml`. The seven
primary tertiary sources are:

- Kang, T. H., Paese, L. H. Z., & Felix, N. F. A. (2021). Late and
  unequal. *Revista de Historia Económica* 39(2), 191-218.
  [doi:10.1017/S0212610921000112](https://doi.org/10.1017/S0212610921000112)
- Kang, T. H., & Menetrier, I. (2024). Políticas elitistas e despesas
  públicas em educação. *Estudos Econômicos* 54(3).
  [doi:10.1590/1980-53575434tkim](https://doi.org/10.1590/1980-53575434tkim)
- Kang, T. H., Menetrier, I., & Comim, F. (2024). The side effects of a
  big push growth strategy. *RHE* 42(3), 387-414.
  [doi:10.1017/S0212610924000120](https://doi.org/10.1017/S0212610924000120)
- Walter, J. R., & Kang, T. H. (2024). A new dataset of average years of
  schooling in Brazil. *Economic History of Developing Regions* 39(3),
  307-336.
  [doi:10.1080/20780389.2024.2417268](https://doi.org/10.1080/20780389.2024.2417268)
- Durham, E. R. (2005). Educação superior, pública e privada. In
  Schwartzman (ed.), *Os desafios da educação no Brasil*, pp. 191-233.
- Maduro Junior, P. R. R. M. (2007). *Taxas de matrícula e gastos em
  educação no Brasil* \[MSc dissertation, FGV/EPGE\].
  [hdl:10438/110](https://hdl.handle.net/10438/110)
- IBGE (2007). *Estatísticas do Século XX*.
  [seculoxx.ibge.gov.br](https://seculoxx.ibge.gov.br/)
- INEP/MEC. *Sinopse Estatística da Educação Superior* (1995-2008).
- INEP/MEC. *Microdados do Censo da Educação Superior* (2009-2024).
- INEP/MEC. *CENSUP Power BI panel* (2010-2024).

To cite the package itself:

> Mançano, T. (2026). *educabr: Harmonized Historical Series on
> Brazilian Education* (version 0.0.0.9000).
> <https://github.com/mancano-tales/educabr>
