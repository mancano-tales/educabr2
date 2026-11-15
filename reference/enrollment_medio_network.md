# Upper-secondary enrollment by network — INEP Censo Escolar

National (BR) enrollment in regular upper-secondary education (*ensino
médio regular*) by administrative dependency, 1996-2024. Prefer
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
with `level = "medio"` and a `network` other than `"total"`.

## Usage

``` r
enrollment_medio_network
```

## Format

A tibble with 162 rows and 16 columns matching the canonical schema
(`inst/dict/schema.yaml`):

- level:

  Always `"medio"`.

- network:

  `federal`, `estadual`, `municipal`, `publica` (their sum), `privada`
  and `total`.

- indicator:

  Always `"enrollment_count"`.

- source:

  `inep_sinopse_censo_escolar` (1996-2006) or
  `inep_microdados_censo_escolar` (2007-2024); `source_note` names the
  table or microdata file.

## Source

INEP/MEC, Sinopses Estatísticas da Educação Básica (1996-2006) and
Microdados do Censo Escolar (2007-2024). Extraction:
`data-raw/sources/censo_escolar_inep/extract_medio_rede.R`. ETL:
`data-raw/07_build_enrollment_medio_network.R`.

## Coverage and caveats

2003 and 2004 are missing: INEP publishes them only as PDFs whose tables
are images. From 2007 the Censo Escolar records each student
(Educacenso), so the level drops between 2006 and 2007 while the shares
by network barely move. The totals differ from the `medio` series in
[enrollment_kang_fgv](https://mancano-tales.github.io/educabr2/reference/enrollment_kang_fgv.md),
which follows Kang, Paese & Felix (2021).

## Português

Matrículas no ensino médio regular por dependência administrativa,
Brasil, 1996–2024. Fontes: Sinopses Estatísticas da Educação Básica
(1996–2006) e Microdados do Censo Escolar (2007–2024). Faltam 2003 e
2004, publicados pelo INEP só em PDF com tabelas em imagem. Em 2007 o
Censo Escolar passou a registrar cada aluno (Educacenso), o que quebra o
nível da série; as proporções por rede quase não mudam. `publica` é a
soma de federal, estadual e municipal. ETL:
`data-raw/07_build_enrollment_medio_network.R`.
