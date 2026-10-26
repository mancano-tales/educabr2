# Brazilian public expenditure on education

Returns the harmonised series of public expenditure on education,
compiled by Kang & Menetrier (2024) from the long-run Brazilian national
accounts and educational statistics. Three indicator families are
exposed:

## Usage

``` r
get_expenditure(
  level = NULL,
  indicator = NULL,
  year = NULL,
  source = NULL,
  wide = FALSE,
  lang = c("en", "pt")
)
```

## Arguments

- level:

  Character vector of stage codes: `"fundamental_anos_iniciais"`,
  `"fundamental_anos_finais"`, `"fundamental"`, `"medio"`,
  `"fundamental_medio"`, `"superior"`, `"total"`. The two "double ratio"
  indicators are tagged with `level = "total"`. `NULL` (default) means
  no filter.

- indicator:

  Character vector. Convenience aliases are accepted: `"share_gdp"`,
  `"per_student"`, `"double_ratio_es_ef1"`, `"double_ratio_es_ef_em"`.
  Full indicator keys (`"expenditure_share_gdp"`, etc.) also work.
  `NULL` (default) returns all four indicators.

- year:

  Integer vector or two-element `c(min, max)` range. `NULL` for all
  years.

- source:

  Character vector of source keys. `NULL` returns all available sources
  (currently only `"kang_menetrier_2024"`).

- wide:

  Logical. If `TRUE`, pivots the result to wide form (one column per
  indicator). Default `FALSE`.

- lang:

  One of `"en"` (default) or `"pt"`. When `"pt"`, factor levels and
  indicator labels are translated via `inst/dict/i18n.yaml`.

## Value

A tibble in the canonical educabr2 long schema (see
`inst/dict/schema.yaml`). Columns: `year`, `geo_level`, `geo_code`,
`geo_name`, `level`, `network`, `dim_race`, `age_group`, `indicator`,
`value`, `unit`, `source`, `source_note`. `network` is always
`"publica"` (public-sector expenditure only).

## Details

- `expenditure_share_gdp` — total public expenditure on a given stage,
  as share of GDP.

- `expenditure_per_student_pct_gdp_pc` — per-student public expenditure
  in the public network, expressed as share of GDP per capita (a
  unit-free, cross-country-comparable measure).

- `expenditure_double_ratio_es_ef1` and
  `expenditure_double_ratio_es_ef_em` — Kang & Menetrier's "double
  ratio" indicators of fiscal regressivity (per-student spending on
  tertiary divided by per-student spending on, respectively, EF1 and
  EF+EM combined).

All series are national (BR), 1933-2010. The data behind this function
is the internal dataset
[expenditure_kang_fgv](https://mancano-tales.github.io/educabr2/reference/expenditure_kang_fgv.md).

## Examples

``` r
# Total public expenditure on education as share of GDP
get_expenditure(indicator = "share_gdp", level = "total")
#> # A tibble: 78 × 13
#>     year geo_level geo_code geo_name level network dim_race age_group indicator 
#>    <int> <chr>     <chr>    <chr>    <chr> <chr>   <chr>    <chr>     <chr>     
#>  1  1933 BR        BR       Brasil   total publica total    NA        expenditu…
#>  2  1934 BR        BR       Brasil   total publica total    NA        expenditu…
#>  3  1935 BR        BR       Brasil   total publica total    NA        expenditu…
#>  4  1936 BR        BR       Brasil   total publica total    NA        expenditu…
#>  5  1937 BR        BR       Brasil   total publica total    NA        expenditu…
#>  6  1938 BR        BR       Brasil   total publica total    NA        expenditu…
#>  7  1939 BR        BR       Brasil   total publica total    NA        expenditu…
#>  8  1940 BR        BR       Brasil   total publica total    NA        expenditu…
#>  9  1941 BR        BR       Brasil   total publica total    NA        expenditu…
#> 10  1942 BR        BR       Brasil   total publica total    NA        expenditu…
#> # ℹ 68 more rows
#> # ℹ 4 more variables: value <dbl>, unit <chr>, source <chr>, source_note <chr>

# Per-student spending in tertiary education over time
get_expenditure(indicator = "per_student", level = "superior")
#> # A tibble: 78 × 13
#>     year geo_level geo_code geo_name level  network dim_race age_group indicator
#>    <int> <chr>     <chr>    <chr>    <chr>  <chr>   <chr>    <chr>     <chr>    
#>  1  1933 BR        BR       Brasil   super… publica total    NA        expendit…
#>  2  1934 BR        BR       Brasil   super… publica total    NA        expendit…
#>  3  1935 BR        BR       Brasil   super… publica total    NA        expendit…
#>  4  1936 BR        BR       Brasil   super… publica total    NA        expendit…
#>  5  1937 BR        BR       Brasil   super… publica total    NA        expendit…
#>  6  1938 BR        BR       Brasil   super… publica total    NA        expendit…
#>  7  1939 BR        BR       Brasil   super… publica total    NA        expendit…
#>  8  1940 BR        BR       Brasil   super… publica total    NA        expendit…
#>  9  1941 BR        BR       Brasil   super… publica total    NA        expendit…
#> 10  1942 BR        BR       Brasil   super… publica total    NA        expendit…
#> # ℹ 68 more rows
#> # ℹ 4 more variables: value <dbl>, unit <chr>, source <chr>, source_note <chr>

# The fiscal-regressivity "double ratio" — ES vs EF1
get_expenditure(indicator = "double_ratio_es_ef1")
#> # A tibble: 78 × 13
#>     year geo_level geo_code geo_name level network dim_race age_group indicator 
#>    <int> <chr>     <chr>    <chr>    <chr> <chr>   <chr>    <chr>     <chr>     
#>  1  1933 BR        BR       Brasil   total publica total    NA        expenditu…
#>  2  1934 BR        BR       Brasil   total publica total    NA        expenditu…
#>  3  1935 BR        BR       Brasil   total publica total    NA        expenditu…
#>  4  1936 BR        BR       Brasil   total publica total    NA        expenditu…
#>  5  1937 BR        BR       Brasil   total publica total    NA        expenditu…
#>  6  1938 BR        BR       Brasil   total publica total    NA        expenditu…
#>  7  1939 BR        BR       Brasil   total publica total    NA        expenditu…
#>  8  1940 BR        BR       Brasil   total publica total    NA        expenditu…
#>  9  1941 BR        BR       Brasil   total publica total    NA        expenditu…
#> 10  1942 BR        BR       Brasil   total publica total    NA        expenditu…
#> # ℹ 68 more rows
#> # ℹ 4 more variables: value <dbl>, unit <chr>, source <chr>, source_note <chr>

# All indicators for 1933-1950 in wide form
get_expenditure(year = c(1933, 1950), wide = TRUE)
#> # A tibble: 126 × 14
#>     year geo_level geo_code geo_name level     network dim_race age_group source
#>    <int> <chr>     <chr>    <chr>    <chr>     <chr>   <chr>    <chr>     <chr> 
#>  1  1937 BR        BR       Brasil   fundamen… publica total    NA        kang_…
#>  2  1938 BR        BR       Brasil   fundamen… publica total    NA        kang_…
#>  3  1939 BR        BR       Brasil   fundamen… publica total    NA        kang_…
#>  4  1940 BR        BR       Brasil   fundamen… publica total    NA        kang_…
#>  5  1941 BR        BR       Brasil   fundamen… publica total    NA        kang_…
#>  6  1942 BR        BR       Brasil   fundamen… publica total    NA        kang_…
#>  7  1943 BR        BR       Brasil   fundamen… publica total    NA        kang_…
#>  8  1944 BR        BR       Brasil   fundamen… publica total    NA        kang_…
#>  9  1945 BR        BR       Brasil   fundamen… publica total    NA        kang_…
#> 10  1946 BR        BR       Brasil   fundamen… publica total    NA        kang_…
#> # ℹ 116 more rows
#> # ℹ 5 more variables: source_note <chr>, expenditure_double_ratio_es_ef1 <dbl>,
#> #   expenditure_double_ratio_es_ef_em <dbl>,
#> #   expenditure_per_student_pct_gdp_pc <dbl>, expenditure_share_gdp <dbl>
```
