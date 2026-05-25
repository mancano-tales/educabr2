# Public expenditure on education — Kang & Menetrier 2024 compilation

Long-run Brazilian public expenditure on education, compiled by Kang &
Menetrier (2024) from a combination of national-accounts sources
(Anuário Estatístico, IPEA, FGV-IBRE) and educational statistics. The
dataset is the internal backing store consumed by
[`get_expenditure()`](https://mancano-tales.github.io/educabr2/dev/reference/get_expenditure.md);
end-users should call that function rather than loading this object
directly.

## Usage

``` r
expenditure_kang_fgv
```

## Format

A tibble with approximately 1 170 rows and 13 columns:

- year:

  `integer`. Reference year (1933–2010).

- geo_level:

  `character`. Always `"BR"`.

- geo_code:

  `character`. Always `"BR"`.

- geo_name:

  `character`. Always `"Brasil"`.

- level:

  `character`. Education stage: `"fundamental_anos_iniciais"`,
  `"fundamental_anos_finais"`, `"fundamental"`, `"medio"`,
  `"fundamental_medio"` (EF+EM combined, i.e. educação básica regular),
  `"superior"`, or `"total"`. The two "double ratio" indicators carry
  `level = "total"` because they are system-wide ratios rather than
  per-stage values.

- network:

  `character`. Always `"publica"` — these are public-sector expenditure
  indicators.

- dim_race:

  `character`. Always `"total"`.

- age_group:

  `character`. Always `NA`.

- indicator:

  `character`. One of `"expenditure_share_gdp"`,
  `"expenditure_per_student_pct_gdp_pc"`,
  `"expenditure_double_ratio_es_ef1"`,
  `"expenditure_double_ratio_es_ef_em"`.

- value:

  `double`.

- unit:

  `character`. One of `"percent_gdp"`, `"percent_gdp_per_capita"`, or
  `"ratio"` (for the double ratios).

- source:

  `character`. Always `"kang_menetrier_2024"`.

- source_note:

  `character`. Inline bibliographic reference.

## Source

Kang, T. H., & Menetrier, I. (2024). Políticas elitistas e despesas
públicas em educação no Brasil, 1933-2010. *Estudos Econômicos (São
Paulo)*, 54(3), e53575434.
[doi:10.1590/1980-53575434tkim](https://doi.org/10.1590/1980-53575434tkim)
. Compilation: FGV/IBRE (April 2023 revision). ETL script:
`data-raw/04_build_expenditure_kang_fgv.R`.

## Coverage

|  |  |  |
|----|----|----|
| **Indicator** | **Stages** | **Years** |
| `expenditure_share_gdp` | EF1/EF2/EF/EM/EF+EM/ES/total | 1933–2010 |
| `expenditure_per_student_pct_gdp_pc` | EF1/EF2/EF/EM/EF+EM/ES | 1933–2010 |
| `expenditure_double_ratio_es_ef1` | — | 1933–2010 |
| `expenditure_double_ratio_es_ef_em` | — | 1933–2010 |
