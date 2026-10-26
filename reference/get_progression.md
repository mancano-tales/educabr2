# Brazilian grade-progression series

Returns harmonised series of grade-progression indicators in the
Brazilian school system. The bundled indicator is **GDR6** (Gross
Distribution Ratio for grade 6), defined as enrollment in grades 4-6 of
the old eight-year primary system divided by enrollment in grades 1-3.
Higher values indicate fewer drop-outs and repeaters in the early grades
of primary education.

## Usage

``` r
get_progression(
  indicator = NULL,
  year = NULL,
  geo_level = c("BR", "UF"),
  geo = NULL,
  source = NULL,
  wide = FALSE,
  lang = c("en", "pt")
)
```

## Arguments

- indicator:

  Character vector of indicator keys. Currently only
  `"gross_distribution_ratio_grade_6"` is available; the alias `"gdr6"`
  is also accepted. `NULL` (default) returns all indicators.

- year:

  Integer vector or two-element `c(min, max)` range. `NULL` for all
  years.

- geo_level:

  One of `"BR"` (national, default) or `"UF"` (state).

- geo:

  Character vector of 2-letter UF codes when `geo_level = "UF"`. `NULL`
  (default) returns all UFs available for the indicator. **Coverage
  note:** the source covers 20 UFs, not all 27 — newer /
  territorial-origin federation units (`AC`, `AP`, `DF`, `MS`, `RO`,
  `RR`, `TO`) are not in Kang's compilation. Passing one of those codes
  emits a warning explaining the gap and returns the remaining (covered)
  UFs only.

- source:

  Character vector of source keys. `NULL` returns all available sources
  (currently only `"kang_paese_felix_2021"`).

- wide:

  Logical. If `TRUE`, pivots to wide form. For this indicator the effect
  is minimal (only one indicator column today), but the parameter is
  provided for API consistency. Default `FALSE`.

- lang:

  One of `"en"` (default) or `"pt"`. When `"pt"`, factor levels and
  indicator labels are translated via `inst/dict/i18n.yaml`.

## Value

A tibble in the canonical educabr2 long schema (see
`inst/dict/schema.yaml`). Columns: `year`, `geo_level`, `geo_code`,
`geo_name`, `level`, `network`, `dim_race`, `age_group`, `indicator`,
`value`, `unit`, `source`, `source_note`. `level` is always
`"fundamental_anos_iniciais"` and `unit` is always `"ratio"`.

## Details

GDR6 was reconstructed by Kang, Paese & Felix (2021) for the BR national
level and for 20 federation units (UFs), 1955-2010. The dataset behind
this function is
[progression_kang_fgv](https://mancano-tales.github.io/educabr2/reference/progression_kang_fgv.md).

## Examples

``` r
# National series, all years
get_progression()
#> # A tibble: 52 × 13
#>     year geo_level geo_code geo_name level  network dim_race age_group indicator
#>    <int> <chr>     <chr>    <chr>    <chr>  <chr>   <chr>    <chr>     <chr>    
#>  1  1955 BR        BR       Brasil   funda… total   total    NA        gross_di…
#>  2  1956 BR        BR       Brasil   funda… total   total    NA        gross_di…
#>  3  1957 BR        BR       Brasil   funda… total   total    NA        gross_di…
#>  4  1958 BR        BR       Brasil   funda… total   total    NA        gross_di…
#>  5  1959 BR        BR       Brasil   funda… total   total    NA        gross_di…
#>  6  1960 BR        BR       Brasil   funda… total   total    NA        gross_di…
#>  7  1961 BR        BR       Brasil   funda… total   total    NA        gross_di…
#>  8  1962 BR        BR       Brasil   funda… total   total    NA        gross_di…
#>  9  1963 BR        BR       Brasil   funda… total   total    NA        gross_di…
#> 10  1964 BR        BR       Brasil   funda… total   total    NA        gross_di…
#> # ℹ 42 more rows
#> # ℹ 4 more variables: value <dbl>, unit <chr>, source <chr>, source_note <chr>

# GDR6 for São Paulo and Bahia, post-1980
get_progression(geo_level = "UF", geo = c("SP", "BA"),
                year = c(1980, 2010))
#> # A tibble: 54 × 13
#>     year geo_level geo_code geo_name level  network dim_race age_group indicator
#>    <int> <chr>     <chr>    <chr>    <chr>  <chr>   <chr>    <chr>     <chr>    
#>  1  1980 UF        BA       Bahia    funda… total   total    NA        gross_di…
#>  2  1981 UF        BA       Bahia    funda… total   total    NA        gross_di…
#>  3  1982 UF        BA       Bahia    funda… total   total    NA        gross_di…
#>  4  1983 UF        BA       Bahia    funda… total   total    NA        gross_di…
#>  5  1984 UF        BA       Bahia    funda… total   total    NA        gross_di…
#>  6  1985 UF        BA       Bahia    funda… total   total    NA        gross_di…
#>  7  1986 UF        BA       Bahia    funda… total   total    NA        gross_di…
#>  8  1987 UF        BA       Bahia    funda… total   total    NA        gross_di…
#>  9  1991 UF        BA       Bahia    funda… total   total    NA        gross_di…
#> 10  1992 UF        BA       Bahia    funda… total   total    NA        gross_di…
#> # ℹ 44 more rows
#> # ℹ 4 more variables: value <dbl>, unit <chr>, source <chr>, source_note <chr>

# Compare BR and the Northeast states
get_progression(geo_level = "UF",
                geo = c("BA", "PE", "CE", "PB", "MA", "PI", "RN", "AL", "SE"))
#> # A tibble: 467 × 13
#>     year geo_level geo_code geo_name level  network dim_race age_group indicator
#>    <int> <chr>     <chr>    <chr>    <chr>  <chr>   <chr>    <chr>     <chr>    
#>  1  1955 UF        AL       Alagoas  funda… total   total    NA        gross_di…
#>  2  1956 UF        AL       Alagoas  funda… total   total    NA        gross_di…
#>  3  1957 UF        AL       Alagoas  funda… total   total    NA        gross_di…
#>  4  1958 UF        AL       Alagoas  funda… total   total    NA        gross_di…
#>  5  1959 UF        AL       Alagoas  funda… total   total    NA        gross_di…
#>  6  1960 UF        AL       Alagoas  funda… total   total    NA        gross_di…
#>  7  1961 UF        AL       Alagoas  funda… total   total    NA        gross_di…
#>  8  1962 UF        AL       Alagoas  funda… total   total    NA        gross_di…
#>  9  1963 UF        AL       Alagoas  funda… total   total    NA        gross_di…
#> 10  1964 UF        AL       Alagoas  funda… total   total    NA        gross_di…
#> # ℹ 457 more rows
#> # ℹ 4 more variables: value <dbl>, unit <chr>, source <chr>, source_note <chr>
```
