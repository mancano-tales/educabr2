# Tertiary (ensino superior) enrollment — multi-source compilation

National-level (BR) Brazilian higher-education enrollment from 1907 to
2024, harmonised across seven different primary sources. The dataset is
consumed by
[`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
when `level = "superior"`. Multiple sources for the same
`(year, network)` are kept on purpose so users can compare competing
estimates — pass `source = "..."` to lock in a specific series.

## Usage

``` r
enrollment_tertiary
```

## Format

A tibble with approximately 1 350 rows and 16 columns matching the
canonical schema (`inst/dict/schema.yaml`). The tertiary-specific
columns are:

- level:

  Always `"superior"`.

- network:

  Administrative dependency: `federal`, `estadual`, `municipal`,
  `publica`, `privada`, plus the private sub-categories
  (`privada_particular` /
  `privada_comunitaria_confessional_filantropica` pre-2009,
  `privada_lucrativa` / `privada_nao_lucrativa` post-2009), `especial`,
  `total`.

- institution_type:

  INEP/MEC institutional category: `university`, `university_center`,
  `faculty`, `faculty_school_institute`, `integrated_faculty`,
  `integrated_faculty_university_center`, `technology_center`,
  `technology_center_fat`, `cefet_ifet`, `isolated_establishment`,
  `total`.

- modality:

  `presencial`, `ead`, or `total` (available from 2000 onwards).

- is_derived:

  `TRUE` when the row is a **reconstructed total** — a computed total
  combining the in-person enrollment from one source with the EAD
  enrollment from INEP, used to fix the 2000-2008 transition gap where
  the original sources excluded EAD from their nominal totals. Filtered
  out by
  [`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
  unless `include_derived = TRUE`.

## Source

Compilation curated by the package author (Mançano, 2026) from publicly
available sources. Raw file:
`data-raw/sources/tertiary_multisource/data_tertiary_v6_clean.xlsx`.
ETL: `data-raw/03_build_enrollment_tertiary.R`.

## Primary sources

- `ibge_seculo_xx` — Anuários Estatísticos 1908-1980.

- `durham_2005` — Durham (2005).

- `maduro_junior_2007` — Maduro Junior MSc dissertation.

- `kang_paese_felix_2021` — Kang, Paese & Felix RHE paper.

- `inep_sinopse_censup` — INEP Sinopse 1995-2008.

- `inep_microdados_censup` — INEP microdata 2009-2024.

- `inep_censup_powerbi` — INEP Power BI panel.

For derived rows the `source` column is the concatenation
`"<presencial_key>+<ead_key>"`; the exact composition is documented in
`source_note`.
