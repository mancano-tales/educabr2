# Tertiary (ensino superior) enrollment — multi-source compilation

National-level (BR) Brazilian higher-education enrollment from 1907 to
2024, harmonised across official records and academic compilations. The
dataset is consumed by
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
when `level = "superior"`. Multiple sources for the same
`(year, network)` are kept on purpose so users can compare competing
estimates — pass `source = "..."` to lock in a specific series.

## Usage

``` r
enrollment_tertiary
```

## Format

A tibble with 1 143 rows and 16 columns matching the canonical schema
(`inst/dict/schema.yaml`). The tertiary-specific columns are:

- level:

  Always `"superior"`.

- network:

  Administrative dependency: `federal`, `estadual`, `municipal`,
  `publica`, `privada`, plus the private sub-categories
  (`privada_particular` /
  `privada_comunitaria_confessional_filantropica` pre-2009,
  `privada_lucrativa` / `privada_nao_lucrativa` post-2009), `especial`,
  `total`. `especial` (INEP category "Especial", art. 242 CF; microdata
  2012-2024) is an "of which" breakdown of `municipal`, following INEP's
  own classification.

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
  [`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
  unless `include_derived = TRUE`.

## Source

Compilation curated by the package author (Mançano, 2026) from publicly
available sources. Raw file:
`data-raw/sources/tertiary_multisource/data_tertiary_v6_clean.xlsx`.
ETL: `data-raw/03_build_enrollment_tertiary.R`.

## Primary sources

- `ibge_seculo_xx` — Anuários Estatísticos 1908-1980.

- `maduro_junior_2007` — Maduro Junior MSc dissertation.

- `kang_paese_felix_2021` — only as the in-person component of derived
  rows; the Kang series itself is in
  [enrollment_kang_fgv](https://mancano-tales.github.io/educabr2/reference/enrollment_kang_fgv.md).

- `inep_sinopse_censup` — INEP Sinopse 1995-2008.

- `inep_microdados_censup` — INEP microdata 2009-2024. The INEP Power BI
  panel, bundled until 0.1.1, was dropped in 0.1.2 because every cell
  equals this aggregation.

For derived rows the `source` column is the concatenation
`"<presencial_key>+<ead_key>"`; the exact composition is documented in
`source_note`.

## Português

Matrículas no ensino superior: 1.143 linhas, Brasil, 1907–2024. Prefira
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
com `level = "superior"`. `network` registra rede e subcategorias
privadas antes/depois de 2009; `institution_type` registra organização
acadêmica; `modality` distingue presencial, EAD e total. A categoria
`especial` (2012–2024) é um subconjunto da municipal, não uma parcela a
ser somada novamente. Fontes: IBGE Século XX, Maduro Junior (2007), INEP
Sinopses (1995–2008, incluindo 2002) e Microdados (2009–2024). Kang
entra como componente presencial de totais derivados. `is_derived` marca
totais reconstruídos (presencial + EAD, 2000–2008), excluídos por
padrão; `source` combina as chaves das fontes e `source_note` detalha a
composição. O painel Power BI do INEP foi retirado por duplicar os
microdados. ETL: `data-raw/03_build_enrollment_tertiary.R`.

Colunas: `year` é o ano; `geo_level`, `geo_code` e `geo_name`
identificam nível, código e nome geográficos; `indicator`, `value` e
`unit` registram indicador, valor e unidade; `source` é a chave de fonte
e `source_note` a nota bibliográfica. Dimensões usam `"total"` para
agregados, preservando `NA` para informação desconhecida. Os dados
mantêm identificadores canônicos; consulte a função pública com
`lang = "pt"` para traduzir rótulos.
