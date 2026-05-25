# Brazilian mean years of schooling

Returns harmonized series of average years of schooling at the national,
macro-region, or state level, optionally broken down by color/race or
sex. The bundled data comes from Walter & Kang (2023), a FGV-IBRE
working paper that reconstructs the series from 1925 to 2015.

## Usage

``` r
get_schooling(
  year = NULL,
  geo_level = c("BR", "region", "UF"),
  geo = NULL,
  dimension = c("none", "race", "sex"),
  source = NULL,
  wide = FALSE,
  lang = c("en", "pt")
)
```

## Arguments

- year:

  Integer vector or two-element `c(min, max)` range. `NULL` for all
  years.

- geo_level:

  One of `"BR"` (national, default), `"region"` (macro-region), or
  `"UF"` (state). Region and UF series start in 1950.

- geo:

  Character vector of geographic codes. For `geo_level = "UF"`, 2-letter
  IBGE UF abbreviations (e.g. `"SP"`, `"BA"`). For
  `geo_level = "region"`, one or more of `"N"`, `"NE"`, `"CO"`, `"SE"`,
  `"S"`. `NULL` (default) returns all geographies at that level.

- dimension:

  Inequality breakdown. One of:

  - `"none"` (default) — national totals only (no race or sex split);

  - `"race"` — breakdown by IBGE color/race (`white`, `black`, `brown`,
    `asian`, `indigenous`), totals across sex;

  - `"sex"` — breakdown by sex (`male`, `female`), totals across race.
    Race and sub-national breakdowns are only available at
    `geo_level = "BR"`.

- source:

  Character vector of source keys. `NULL` returns all available sources
  (currently only `"walter_kang_2023"`).

- wide:

  Logical. If `TRUE`, pivots the result to wide form. For this indicator
  the effect is minimal (only one indicator column), but the parameter
  is provided for API consistency with
  [`get_enrollment()`](https://mancano-tales.github.io/educabr2/dev/reference/get_enrollment.md).
  Default `FALSE`.

- lang:

  One of `"en"` (default) or `"pt"`. When `"pt"`, factor levels are
  translated via `inst/dict/i18n.yaml`.

## Value

A tibble following the canonical schema in `inst/dict/schema.yaml`.
Columns: `year`, `geo_level`, `geo_code`, `geo_name`, `dim_race`,
`dim_sex`, `age_group`, `indicator`, `value`, `unit`, `source`,
`source_note`. The `level` and `network` columns are omitted (not
applicable to population-level attainment averages).

## Examples

``` r
# National series, all years
get_schooling()
#> # A tibble: 91 × 12
#>     year geo_level geo_code geo_name dim_race dim_sex age_group indicator  value
#>    <int> <chr>     <chr>    <chr>    <chr>    <chr>   <chr>     <chr>      <dbl>
#>  1  1925 BR        BR       Brasil   total    total   NA        mean_year…  1.13
#>  2  1926 BR        BR       Brasil   total    total   NA        mean_year…  1.15
#>  3  1927 BR        BR       Brasil   total    total   NA        mean_year…  1.16
#>  4  1928 BR        BR       Brasil   total    total   NA        mean_year…  1.18
#>  5  1929 BR        BR       Brasil   total    total   NA        mean_year…  1.2 
#>  6  1930 BR        BR       Brasil   total    total   NA        mean_year…  1.2 
#>  7  1931 BR        BR       Brasil   total    total   NA        mean_year…  1.21
#>  8  1932 BR        BR       Brasil   total    total   NA        mean_year…  1.23
#>  9  1933 BR        BR       Brasil   total    total   NA        mean_year…  1.24
#> 10  1934 BR        BR       Brasil   total    total   NA        mean_year…  1.26
#> # ℹ 81 more rows
#> # ℹ 3 more variables: unit <chr>, source <chr>, source_note <chr>

# By race, 1960-2015
get_schooling(dimension = "race", year = c(1960, 2015))
#> # A tibble: 224 × 12
#>     year geo_level geo_code geo_name dim_race dim_sex age_group indicator  value
#>    <int> <chr>     <chr>    <chr>    <chr>    <chr>   <chr>     <chr>      <dbl>
#>  1  1960 BR        BR       Brasil   asian    total   NA        mean_year…  3.52
#>  2  1961 BR        BR       Brasil   asian    total   NA        mean_year…  3.87
#>  3  1962 BR        BR       Brasil   asian    total   NA        mean_year…  4.19
#>  4  1963 BR        BR       Brasil   asian    total   NA        mean_year…  4.3 
#>  5  1964 BR        BR       Brasil   asian    total   NA        mean_year…  4.54
#>  6  1965 BR        BR       Brasil   asian    total   NA        mean_year…  4.81
#>  7  1966 BR        BR       Brasil   asian    total   NA        mean_year…  5.02
#>  8  1967 BR        BR       Brasil   asian    total   NA        mean_year…  5.23
#>  9  1968 BR        BR       Brasil   asian    total   NA        mean_year…  5.36
#> 10  1969 BR        BR       Brasil   asian    total   NA        mean_year…  5.55
#> # ℹ 214 more rows
#> # ℹ 3 more variables: unit <chr>, source <chr>, source_note <chr>

# By sex across states
get_schooling(dimension = "sex", geo_level = "UF", geo = c("SP", "BA"))
#> # A tibble: 0 × 12
#> # ℹ 12 variables: year <int>, geo_level <chr>, geo_code <chr>, geo_name <chr>,
#> #   dim_race <chr>, dim_sex <chr>, age_group <chr>, indicator <chr>,
#> #   value <dbl>, unit <chr>, source <chr>, source_note <chr>
```
