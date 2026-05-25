# Grade-progression series (GDR6) — Kang, Paese & Felix 2021 compilation

Long-run Brazilian grade-progression ratio reconstructed by Kang, Paese
& Felix (2021). The bundled indicator is **GDR6** (Gross Distribution
Ratio for grade 6, defined as the ratio of enrollment in grades 4-6 to
enrollment in grades 1-3 of the old eight-year primary system), reported
for BR and 20 federation units, 1955-2010. The dataset is the internal
backing store consumed by
[`get_progression()`](https://mancano-tales.github.io/educabr2/dev/reference/get_progression.md).

## Usage

``` r
progression_kang_fgv
```

## Format

A tibble with approximately 1 090 rows and 13 columns:

- year:

  `integer`. Reference year (1955–2010).

- geo_level:

  `character`. `"BR"` or `"UF"`.

- geo_code:

  `character`. `"BR"` or 2-letter IBGE UF code.

- geo_name:

  `character`. Human-readable geographic name.

- level:

  `character`. Always `"fundamental_anos_iniciais"`.

- network:

  `character`. Always `"total"`.

- dim_race:

  `character`. Always `"total"`.

- age_group:

  `character`. Always `NA`.

- indicator:

  `character`. Always `"gross_distribution_ratio_grade_6"`.

- value:

  `double`. Unitless ratio (typically in the 0.1–1.0 range).

- unit:

  `character`. Always `"ratio"`.

- source:

  `character`. Always `"kang_paese_felix_2021"`.

- source_note:

  `character`. Inline bibliographic reference.

## Source

Kang, T. H., Paese, L. H. Z., & Felix, N. F. A. (2021). Late and
unequal: Enrolments and retention in Brazilian education, 1933-2010.
*Revista de Historia Económica*, 39(2), 191–218.
[doi:10.1017/S0212610921000112](https://doi.org/10.1017/S0212610921000112)
. Compilation: FGV/IBRE (April 2023 revision). ETL script:
`data-raw/05_build_progression_kang_fgv.R`.

## UF coverage

Kang, Paese & Felix's compilation covers 20 federation units (AL, AM,
BA, CE, ES, GO, MA, MG, MT, PA, PB, PE, PI, PR, RJ, RN, RS, SC, SE, SP).
Newer or territorial-origin UFs (AC, AP, DF, MS, RO, RR, TO) are not
covered by the source. National BR series has gaps at 1988, 1989, 1990
and 1994 reflecting transitions in the official grade structure.
