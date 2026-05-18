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
  [`get_enrollment()`](https://mancano-tales.github.io/educabr/reference/get_enrollment.md).
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
if (FALSE) {
# National series, all years
get_schooling()

# By race, 1960-2015
get_schooling(dimension = "race", year = c(1960, 2015))

# By sex across states
get_schooling(dimension = "sex", geo_level = "UF", geo = c("SP", "BA"))
}
```
