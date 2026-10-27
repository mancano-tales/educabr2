# Enrollment series — Kang / FGV-IBRE 2023 compilation

Long-run Brazilian school enrollment data compiled and harmonized by
Kang, Paese & Felix (2021) and refreshed by FGV/IBRE in April 2023. The
dataset is the internal backing store consumed by
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md);
end-users should call that function rather than loading this object
directly, as it applies filters, label translation, and optional
pivoting.

## Usage

``` r
enrollment_kang_fgv
```

## Format

A tibble with 6 238 rows and 16 columns (the canonical enrollment
columns, including `institution_type`, `modality` and `is_derived`,
which take their defaults except as noted under `modality`):

- year:

  `integer`. Reference year of the observation (1871–2010).

- geo_level:

  `character`. Geographic aggregation level: `"BR"` (national) or `"UF"`
  (state).

- geo_code:

  `character`. Geographic code: `"BR"` for national; IBGE 2-letter UF
  abbreviation (e.g. `"SP"`, `"BA"`) for states.

- geo_name:

  `character`. Human-readable geographic name in Portuguese (e.g.
  `"Brasil"`, `"São Paulo"`).

- level:

  `character`. Education stage using the educabr2 vocabulary:
  `"fundamental_anos_iniciais"`, `"fundamental_anos_finais"`,
  `"fundamental"`, `"medio"`, `"superior"`.

- network:

  `character`. Administrative dependency. Always `"total"` in this
  source (no network breakdown available).

- dim_race:

  `character`. Race/colour dimension using the educabr2 vocabulary
  (`"white"`, `"black"`, `"brown"`, `"asian"`, `"indigenous"`).
  `"total"` when not disaggregated. Race breakdown is available at BR
  level for 1960–2010 only.

- age_group:

  `character`. Reference age bracket of the rate indicator (e.g.
  `"7-14"`, `"15-17"`, `"18-24"`). `NA` for count indicators, which are
  headcounts not tied to a population bracket.

- indicator:

  `character`. Indicator key: `"enrollment_count"` (absolute headcount)
  or `"enrollment_rate"` (gross enrollment rate, 0–100 scale).

- value:

  `double`. Numeric value of the indicator.

- unit:

  `character`. Unit of measurement: `"count"` or `"percent"`.

- modality:

  `character`. `"total"`, except the tertiary (`superior`) rows for
  2000-2008, which are `"presencial"`: Kang's series for those years
  counts in-person enrollment only and matches INEP Sinopse's presencial
  figures.

- source:

  `character`. Compact source key, one per FGV/IBRE file:
  `"kang_menetrier_comim_2024"` (primary 1871-1932),
  `"kang_paese_felix_2021"` (all stages 1933-2010 and by race),
  `"kang_menetrier_2024"` (UF). Full metadata in
  `inst/dict/vocabularies/sources.yaml`.

- source_note:

  `character`. Inline bibliographic reference.

## Source

Kang, T. H., Paese, L. H. Z., & Felix, N. F. A. (2021). Late and
unequal: Enrolments and retention in Brazilian education, 1933-2010.
*Revista de Historia Económica*, 39(2), 191–218.
[doi:10.1017/S0212610921000112](https://doi.org/10.1017/S0212610921000112)
. Data compilation: FGV/IBRE (April 2023 revision). ETL script:
`data-raw/01_build_enrollment_kang_fgv.R`.

## Coverage

|                               |           |                |
|-------------------------------|-----------|----------------|
| **Scope**                     | **Years** | **Indicators** |
| BR — primário (anos iniciais) | 1871–1932 | count          |
| BR — all stages (EF, EM, ES)  | 1933–2010 | count, rate    |
| BR — by race (EF, EM, ES)     | 1960–2010 | count, rate    |
| UF — ensino fundamental       | 1955–2010 | count, rate    |

## Schema

Column definitions, primary-key constraints, and unit conventions are
specified in `inst/dict/schema.yaml`. The dataset is validated against
that schema every time it is rebuilt (see
`data-raw/01_build_enrollment_kang_fgv.R`).

## Português

Matrículas de Kang/FGV-IBRE: 6.238 linhas, Brasil (1871–2010) e UFs
(1955–2010), com raça/cor nacional desde 1960. Prefira
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md).
`level` identifica a etapa; `network` é `"total"`; `dim_race` contém as
categorias de cor/raça do IBGE; `age_group` registra o denominador
etário das taxas (ausente nas contagens). `indicator` distingue
`enrollment_count` (contagem) e `enrollment_rate` (taxa bruta, escala
0–100). `modality` é `"presencial"` no superior de 2000–2008 e `"total"`
nos demais casos. Fontes: Kang, Paese & Felix (2021), Kang & Menetrier
(2024) e Kang, Menetrier & Comim (2024). ETL:
`data-raw/01_build_enrollment_kang_fgv.R`.

Colunas: `year` é o ano; `geo_level`, `geo_code` e `geo_name`
identificam nível, código e nome geográficos; `indicator`, `value` e
`unit` registram indicador, valor e unidade; `source` é a chave de fonte
e `source_note` a nota bibliográfica. Dimensões usam `"total"` para
agregados, preservando `NA` para informação desconhecida. Os dados
mantêm identificadores canônicos; consulte a função pública com
`lang = "pt"` para traduzir rótulos.
