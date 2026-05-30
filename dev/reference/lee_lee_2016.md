# Comparative international educational attainment — Lee & Lee 2016

Long-run cross-country educational-attainment series compiled by Lee &
Lee (2016), covering 111 countries every 5 years from 1870 to 2010. The
bundled indicator is the **cumulative** share of the population aged
15–64 who completed at least the level indicated by `level` (`primary`,
`secondary`, or `tertiary`). The dataset is the internal backing store
consumed by
[`get_attainment()`](https://mancano-tales.github.io/educabr2/dev/reference/get_attainment.md).

## Usage

``` r
lee_lee_2016
```

## Format

A tibble with approximately 29 000 rows and 12 columns:

- year:

  `integer`. Reference year (1870–2010, in 5-year steps).

- geo_level:

  `character`. Always `"country"`.

- geo_code:

  `character`. ISO 3166-1 alpha-3 country code (e.g. `"BRA"`, `"USA"`,
  `"ARG"`).

- geo_name:

  `character`. English country name as supplied by the upstream source
  (e.g. `"Brazil"`, `"United Kingdom"`).

- level:

  `character`. ISCED-style level: `"primary"`, `"secondary"`, or
  `"tertiary"`.

- dim_sex:

  `character`. `"male"`, `"female"`, or `"total"` (= Lee & Lee
  `sex == "MF"`).

- age_group:

  `character`. Always `"15-64"` — Lee & Lee report attainment for the
  population aged 15–64.

- indicator:

  `character`. Always `"attainment_share_completed"`.

- value:

  `double`. Cumulative share (0–100) who completed at least the
  indicated level.

- unit:

  `character`. Always `"percent"`.

- source:

  `character`. Always `"lee_lee_2016"`.

- source_note:

  `character`. Inline bibliographic reference.

## Source

Lee, J.-W., & Lee, H. (2016). Human capital in the long run. *Journal of
Development Economics*, 122, 147–169.
[doi:10.1016/j.jdeveco.2016.05.006](https://doi.org/10.1016/j.jdeveco.2016.05.006)
. Dataset: <https://barrolee.github.io/BarroLeeDataSet/DataLeeLee.html>.
ETL script: `data-raw/06_build_lee_lee_2016.R`.

## Cumulative encoding

Lee & Lee publish *non-cumulative* shares (`lpc`, `lsc`, `lhc`):
fraction of the population whose **highest** completed level is primary
/ secondary / tertiary. The ETL script
(`data-raw/06_build_lee_lee_2016.R`) sums the upper categories to
express the more conventional "share who completed at least X" used in
cross-country comparisons:

- `level = "primary"` value = lpc + ls + lsc + lh + lhc

- `level = "secondary"` value = lsc + lh + lhc

- `level = "tertiary"` value = lhc

By construction, primary ≥ secondary ≥ tertiary for any (country, year,
sex). To recover Lee & Lee's original non-cumulative values, subtract:
e.g. "primary only (highest)" = `primary - secondary`.
