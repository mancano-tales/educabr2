# Comparative international educational-attainment series

Returns harmonised series of educational attainment for ~111 countries,
every 5 years from 1870 to 2010, broken down by sex. The bundled data
comes from Lee & Lee (2016), *Human capital in the long run* (JDE 122,
147–169) — a widely used cross-country dataset that reconstructs
attainment back to the 19th century.

## Usage

``` r
get_attainment(
  level = NULL,
  year = NULL,
  geo_level = c("country"),
  geo = NULL,
  dimension = c("none", "sex"),
  source = NULL,
  wide = FALSE,
  lang = c("en", "pt")
)
```

## Arguments

- level:

  Character vector of education levels. One or more of `"primary"`,
  `"secondary"`, `"tertiary"`. `NULL` (default) returns all three.

- year:

  Integer vector or two-element `c(min, max)` range. `NULL` for all
  years (1870–2010 in 5-year steps).

- geo_level:

  Always `"country"` for this dataset (kept for API consistency with
  other `get_*()` functions).

- geo:

  Character vector of ISO 3166-1 alpha-3 country codes (e.g. `"BRA"`,
  `"USA"`, `"ARG"`). `NULL` (default) returns all 111 countries
  available in Lee & Lee (2016).

- dimension:

  Sex breakdown. One of:

  - `"none"` (default) — sex totals only (`dim_sex = "total"`);

  - `"sex"` — break down by sex (`male`, `female`), drops the total.

- source:

  Character vector of source keys. `NULL` returns all available sources
  (currently only `"lee_lee_2016"`).

- wide:

  Logical. If `TRUE`, pivots the result to wide form (one column per
  indicator key). Default `FALSE`.

- lang:

  One of `"en"` (default) or `"pt"`. When `"pt"`, factor levels and
  indicator labels are translated via `inst/dict/i18n.yaml`. Country
  names (`geo_name`) are left in English regardless — they come from the
  upstream source.

## Value

A tibble in the canonical educabr2 long schema (see
`inst/dict/schema.yaml`). Columns: `year`, `geo_level`, `geo_code`,
`geo_name`, `level`, `dim_sex`, `age_group`, `indicator`, `value`,
`unit`, `source`, `source_note`. `geo_level` is always `"country"`,
`unit` is always `"percent"` (0–100), `age_group` is always `"15-64"`.

## Details

The indicator is the **cumulative** share of the population aged 15–64
that has completed at least the level indicated by `level`. Lee & Lee
publish the data in non-cumulative form ("highest attained level =
primary/secondary/tertiary"); the bundled dataset sums the upper
categories so that, for any (country, year, sex):

- `level = "primary"` ≥ `level = "secondary"` ≥ `level = "tertiary"`.

This matches the conventional "share of adults who reached at least X"
reported in comparative work.

Coverage is comparative-international: ISCED-style `primary` /
`secondary` / `tertiary` levels, intentionally distinct from the
Brazilian `fundamental` / `medio` / `superior` levels in
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/dev/reference/get_enrollment.md)
and
[`get_schooling()`](https://mancano-tales.github.io/educabr2/dev/reference/get_schooling.md)
because the underlying definitions differ.

## Examples

``` r
# Tertiary completion in Brazil over time
get_attainment(level = "tertiary", geo = "BRA")
#> # A tibble: 29 × 12
#>     year geo_level geo_code geo_name level    dim_sex age_group indicator  value
#>    <int> <chr>     <chr>    <chr>    <chr>    <chr>   <chr>     <chr>      <dbl>
#>  1  1870 country   BRA      Brazil   tertiary total   15-64     attainme… 0.0137
#>  2  1875 country   BRA      Brazil   tertiary total   15-64     attainme… 0.0153
#>  3  1880 country   BRA      Brazil   tertiary total   15-64     attainme… 0.0177
#>  4  1885 country   BRA      Brazil   tertiary total   15-64     attainme… 0.0211
#>  5  1890 country   BRA      Brazil   tertiary total   15-64     attainme… 0.0256
#>  6  1895 country   BRA      Brazil   tertiary total   15-64     attainme… 0.0315
#>  7  1900 country   BRA      Brazil   tertiary total   15-64     attainme… 0.109 
#>  8  1905 country   BRA      Brazil   tertiary total   15-64     attainme… 0.160 
#>  9  1910 country   BRA      Brazil   tertiary total   15-64     attainme… 0.219 
#> 10  1915 country   BRA      Brazil   tertiary total   15-64     attainme… 0.275 
#> # ℹ 19 more rows
#> # ℹ 3 more variables: unit <chr>, source <chr>, source_note <chr>

# Primary completion across Latin America, post-1950
get_attainment(level = "primary",
               geo   = c("BRA", "ARG", "CHL", "MEX", "URY"),
               year  = c(1950, 2010))
#> # A tibble: 65 × 12
#>     year geo_level geo_code geo_name  level   dim_sex age_group indicator  value
#>    <int> <chr>     <chr>    <chr>     <chr>   <chr>   <chr>     <chr>      <dbl>
#>  1  1950 country   ARG      Argentina primary total   15-64     attainmen…  45.0
#>  2  1955 country   ARG      Argentina primary total   15-64     attainmen…  49.8
#>  3  1960 country   ARG      Argentina primary total   15-64     attainmen…  57.0
#>  4  1965 country   ARG      Argentina primary total   15-64     attainmen…  62.1
#>  5  1970 country   ARG      Argentina primary total   15-64     attainmen…  69.3
#>  6  1975 country   ARG      Argentina primary total   15-64     attainmen…  78.6
#>  7  1980 country   ARG      Argentina primary total   15-64     attainmen…  86.9
#>  8  1985 country   ARG      Argentina primary total   15-64     attainmen…  96.6
#>  9  1990 country   ARG      Argentina primary total   15-64     attainmen… 105. 
#> 10  1995 country   ARG      Argentina primary total   15-64     attainmen… 112. 
#> # ℹ 55 more rows
#> # ℹ 3 more variables: unit <chr>, source <chr>, source_note <chr>

# Compare male vs female secondary completion in Brazil
get_attainment(level = "secondary", geo = "BRA", dimension = "sex")
#> # A tibble: 58 × 12
#>     year geo_level geo_code geo_name level    dim_sex age_group indicator  value
#>    <int> <chr>     <chr>    <chr>    <chr>    <chr>   <chr>     <chr>      <dbl>
#>  1  1870 country   BRA      Brazil   seconda… female  15-64     attainme… 0.0370
#>  2  1875 country   BRA      Brazil   seconda… female  15-64     attainme… 0.0379
#>  3  1880 country   BRA      Brazil   seconda… female  15-64     attainme… 0.0393
#>  4  1885 country   BRA      Brazil   seconda… female  15-64     attainme… 0.0413
#>  5  1890 country   BRA      Brazil   seconda… female  15-64     attainme… 0.0440
#>  6  1895 country   BRA      Brazil   seconda… female  15-64     attainme… 0.0476
#>  7  1900 country   BRA      Brazil   seconda… female  15-64     attainme… 0.208 
#>  8  1905 country   BRA      Brazil   seconda… female  15-64     attainme… 0.304 
#>  9  1910 country   BRA      Brazil   seconda… female  15-64     attainme… 0.714 
#> 10  1915 country   BRA      Brazil   seconda… female  15-64     attainme… 0.737 
#> # ℹ 48 more rows
#> # ℹ 3 more variables: unit <chr>, source <chr>, source_note <chr>
```
