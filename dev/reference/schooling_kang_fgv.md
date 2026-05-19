# Mean years of schooling — Walter & Kang 2023 compilation

Long-run Brazilian mean years of schooling reconstructed by Walter &
Kang (2023) from Censuses and household surveys. The dataset is the
internal backing store consumed by
[`get_schooling()`](https://mancano-tales.github.io/educabr/dev/reference/get_schooling.md);
end-users should call that function rather than loading this object
directly.

## Usage

``` r
schooling_kang_fgv
```

## Format

A tibble with approximately 2 300 rows and 12 columns:

- year:

  `integer`. Reference year (1925–2015). BR-level series starts in 1925;
  region and UF series start in 1950.

- geo_level:

  `character`. `"BR"`, `"region"`, or `"UF"`.

- geo_code:

  `character`. `"BR"` for national; IBGE single/double- letter
  macro-region code (`"N"`, `"NE"`, `"CO"`, `"SE"`, `"S"`); or IBGE
  2-letter UF code.

- geo_name:

  `character`. Human-readable geographic name in Portuguese.

- dim_race:

  `character`. Race/colour dimension: `"white"`, `"black"`, `"brown"`,
  `"asian"`, `"indigenous"`, or `"total"`. Race breakdown available at
  BR level only.

- dim_sex:

  `character`. Sex: `"male"`, `"female"`, or `"total"`. Sex breakdown
  available at BR level only.

- age_group:

  `character`. Always `NA` in this dataset; included for schema
  compatibility.

- indicator:

  `character`. Always `"mean_years_schooling"`.

- value:

  `double`. Mean years of schooling of the adult population.

- unit:

  `character`. Always `"years"`.

- source:

  `character`. Always `"walter_kang_2023"`.

- source_note:

  `character`. Inline bibliographic reference.

## Source

Walter, J., & Kang, T. H. (2023). A new dataset of average years of
schooling in Brazil, 1925-2015. FGV-IBRE working paper. ETL script:
`data-raw/02_build_schooling_kang_fgv.R`.

## Coverage

|                          |           |                |
|--------------------------|-----------|----------------|
| **Scope**                | **Years** | **Breakdowns** |
| BR — total               | 1925–2015 | —              |
| BR — by sex              | 1925–2015 | male, female   |
| BR — by race             | 1925–2015 | 4 categories   |
| Macro-region (5 regiões) | 1950–2015 | —              |
| UF (27 estados)          | 1950–2015 | —              |
