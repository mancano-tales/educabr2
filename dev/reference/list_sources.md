# List the data sources bundled with educabr2

Returns a tibble describing every entry in the controlled source
vocabulary (`inst/dict/vocabularies/sources.yaml`). One row per source
key, carrying short name, type, temporal/geographic coverage, DOI, URL
and free-text notes. Use this to discover which sources are available
before calling
[`educabr_cite()`](https://mancano-tales.github.io/educabr2/dev/reference/educabr_cite.md)
or filtering
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/dev/reference/get_enrollment.md)
/
[`get_schooling()`](https://mancano-tales.github.io/educabr2/dev/reference/get_schooling.md)
with the `source` argument.

## Usage

``` r
list_sources()
```

## Value

A `tibble` with columns:

- `key`:

  the source key used in the `source` column of
  [`get_enrollment()`](https://mancano-tales.github.io/educabr2/dev/reference/get_enrollment.md)
  /
  [`get_schooling()`](https://mancano-tales.github.io/educabr2/dev/reference/get_schooling.md)
  output.

- `short_name`:

  compact human-readable label.

- `type`:

  one of `"academic"`, `"academic_thesis"`, `"official_survey"`,
  `"census"`, `"administrative"`, `"administrative_microdata"`,
  `"historical_compilation"`.

- `year_start`, `year_end`:

  integer; `year_end` is `NA` for ongoing series.

- `geo`:

  character; comma-separated list of geographic levels covered (`"BR"`,
  `"region"`, `"UF"`).

- `doi`:

  character; `NA` when the source has none.

- `url`:

  stable URL for the source.

- `notes`:

  free-text remarks from the YAML.

## See also

[`educabr_cite()`](https://mancano-tales.github.io/educabr2/dev/reference/educabr_cite.md),
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/dev/reference/get_enrollment.md),
[`get_schooling()`](https://mancano-tales.github.io/educabr2/dev/reference/get_schooling.md).

## Examples

``` r
src <- list_sources()
head(src)
#> # A tibble: 6 × 9
#>   key               short_name type  year_start year_end geo   doi   url   notes
#>   <chr>             <chr>      <chr>      <int>    <int> <chr> <chr> <chr> <chr>
#> 1 paglayan_2022     Paglayan   acad…       1828     2015 BR    10.7… http… "Com…
#> 2 pnad_ibge         PNAD       offi…       1967     2015 BR, … NA    http… "Ann…
#> 3 pnadc_ibge        PNAD Cont… offi…       2012       NA BR, … NA    http… ""   
#> 4 censo_demografic… Censo Dem… cens…       1872     2022 BR, … NA    http… ""   
#> 5 censo_escolar_in… Censo Esc… admi…       1995       NA BR, … NA    http… ""   
#> 6 anuario_ibge      Anuário I… hist…       1908       NA BR, … NA    http… "Lon…

# Filter to academic papers only
src[src$type == "academic", c("key", "short_name", "doi")]
#> # A tibble: 6 × 3
#>   key                       short_name                     doi                  
#>   <chr>                     <chr>                          <chr>                
#> 1 paglayan_2022             Paglayan                       10.7910/DVN/LKE1WQ   
#> 2 kang_paese_felix_2021     Kang, Paese & Felix (2021)     10.1017/S02126109210…
#> 3 kang_menetrier_2024       Kang & Menetrier (2024)        10.1590/1980-5357543…
#> 4 kang_menetrier_comim_2024 Kang, Menetrier & Comim (2024) 10.1017/S02126109240…
#> 5 durham_2005               Durham (2005)                  NA                   
#> 6 walter_kang_2023          Walter & Kang (2024)           10.1080/20780389.202…

# Sources that include UF-level coverage
src[grepl("UF", src$geo), c("key", "year_start", "year_end")]
#> # A tibble: 8 × 3
#>   key                    year_start year_end
#>   <chr>                       <int>    <int>
#> 1 pnad_ibge                    1967     2015
#> 2 pnadc_ibge                   2012       NA
#> 3 censo_demografico_ibge       1872     2022
#> 4 censo_escolar_inep           1995       NA
#> 5 anuario_ibge                 1908       NA
#> 6 kang_paese_felix_2021        1933     2010
#> 7 kang_menetrier_2024          1955     2010
#> 8 walter_kang_2023             1925     2015
```
