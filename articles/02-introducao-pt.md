# Introdução ao educabr (PT-BR)

``` r

library(educabr)
```

> Versão em português da vignette principal. Para a versão em inglês e
> canônica, veja
> **[`vignette("01-introduction", "educabr")`](https://mancano-tales.github.io/educabr/articles/01-introduction.md)**.

## Sobre o pacote

O **educabr** disponibiliza, sob um único esquema *tidy* canônico, o
conjunto mais extenso de séries históricas harmonizadas sobre educação
brasileira disponível em formato analítico:

- **Matrículas no ensino superior** — 1907 a 2024, **118 anos** de
  cobertura, articulando sete fontes primárias distintas (IBGE
  Estatísticas do Século XX, Durham, Maduro Junior, Kang, INEP Sinopse,
  INEP Microdados e o painel CENSUP do INEP).
- **Matrículas no ensino fundamental e médio** — 1933 a 2010, com
  desagregação por **cor/raça** a partir de 1960 (Kang, Paese & Felix
  2021).
- **Anos médios de escolaridade da população adulta** — 1925 a 2015, com
  desagregação por **sexo**, **cor/raça**, **macrorregião** e **unidade
  da federação** (Walter & Kang 2024).

Toda a transformação dos dados é auditável: cada linha do *output*
carrega o `source` (chave canônica em
`inst/dict/vocabularies/sources.yaml`) e um `source_note` com a
referência exata da tabela ou capítulo de origem.

## Instalação

``` r

# via GitHub
remotes::install_github("mancano-tales/educabr")
```

## API em duas funções

Toda a interface pública gira em torno de duas funções:

``` r

# Esquema dos dois principais resultados
str(get_enrollment(level = "fundamental", year = 1950))
#> tibble [2 × 16] (S3: tbl_df/tbl/data.frame)
#>  $ year            : int [1:2] 1950 1950
#>  $ geo_level       : chr [1:2] "BR" "BR"
#>  $ geo_code        : chr [1:2] "BR" "BR"
#>  $ geo_name        : chr [1:2] "Brasil" "Brasil"
#>  $ level           : chr [1:2] "fundamental" "fundamental"
#>  $ network         : chr [1:2] "total" "total"
#>  $ institution_type: chr [1:2] "total" "total"
#>  $ modality        : chr [1:2] "total" "total"
#>  $ dim_race        : chr [1:2] "total" "total"
#>  $ age_group       : chr [1:2] "7-14" NA
#>  $ indicator       : chr [1:2] "enrollment_rate" "enrollment_count"
#>  $ value           : num [1:2] 4.55e+01 4.73e+06
#>  $ unit            : chr [1:2] "percent" "count"
#>  $ source          : chr [1:2] "kang_paese_felix_2021" "kang_paese_felix_2021"
#>  $ source_note     : chr [1:2] "Kang, Paese & Felix (2021). RHE 39(2):191-218. doi:10.1017/S0212610921000112" "Kang, Paese & Felix (2021). RHE 39(2):191-218. doi:10.1017/S0212610921000112"
#>  $ is_derived      : logi [1:2] FALSE FALSE
str(get_schooling(year = 1950))
#> tibble [1 × 12] (S3: tbl_df/tbl/data.frame)
#>  $ year       : int 1950
#>  $ geo_level  : chr "BR"
#>  $ geo_code   : chr "BR"
#>  $ geo_name   : chr "Brasil"
#>  $ dim_race   : chr "total"
#>  $ dim_sex    : chr "total"
#>  $ age_group  : chr NA
#>  $ indicator  : chr "mean_years_schooling"
#>  $ value      : num 1.59
#>  $ unit       : chr "years"
#>  $ source     : chr "walter_kang_2023"
#>  $ source_note: chr "Walter, J., & Kang, T. H. (2023). A new dataset of average years of schooling in Brazil, 1925-2015. FGV-IBRE working paper."
#>  - attr(*, "educabr_meta")=List of 5
#>   ..$ build_script  : chr "data-raw/02_build_schooling_kang_fgv.R"
#>   ..$ built_at      : POSIXct[1:1], format: "2026-05-17 19:08:24"
#>   ..$ primary_source: chr "walter_kang_2023"
#>   ..$ citation      : chr "Walter, J., & Kang, T. H. (2023). A new dataset of average years of schooling in Brazil, 1925-2015. FGV-IBRE working paper."
#>   ..$ raw_files     : chr "data-raw/sources/kang_fgv_ibre_2023/3._anos_estudo_1925_2015_v_abril2023.xlsx"
```

Ambas retornam *tibbles* longas seguindo o mesmo esquema canônico
(`inst/dict/schema.yaml`), com colunas para a unidade geográfica, a
dimensão de desigualdade (raça, sexo, etc.), a fonte e o valor.

## Caso 1 — taxa bruta de matrícula por raça/cor

Aqui usamos a desagregação `dimension = "race"` para comparar a
trajetória de matrícula no ensino fundamental entre os cinco grupos de
cor/raça do IBGE entre 1960 e 2010.

``` r

ef_raca <- get_enrollment(
  level     = "fundamental",
  indicator = "rate",
  geo_level = "BR",
  dimension = "race",
  year      = c(1960, 2010)
)

head(ef_raca)
#> # A tibble: 6 × 16
#>    year geo_level geo_code geo_name level      network institution_type modality
#>   <int> <chr>     <chr>    <chr>    <chr>      <chr>   <chr>            <chr>   
#> 1  1960 BR        BR       Brasil   fundament… total   total            total   
#> 2  1961 BR        BR       Brasil   fundament… total   total            total   
#> 3  1962 BR        BR       Brasil   fundament… total   total            total   
#> 4  1963 BR        BR       Brasil   fundament… total   total            total   
#> 5  1964 BR        BR       Brasil   fundament… total   total            total   
#> 6  1965 BR        BR       Brasil   fundament… total   total            total   
#> # ℹ 8 more variables: dim_race <chr>, age_group <chr>, indicator <chr>,
#> #   value <dbl>, unit <chr>, source <chr>, source_note <chr>, is_derived <lgl>
```

A diferença entre as três principais categorias (`white`, `black`,
`brown`) acompanha uma das narrativas centrais da literatura sociológica
sobre educação no Brasil — convergência relativa nas matrículas
obrigatórias acompanhada de persistente desigualdade em níveis mais
altos.

## Caso 2 — comparação multi-fonte no ensino superior

O ensino superior brasileiro foi reconstituído por **diversos autores**
com metodologias ligeiramente diferentes, sobretudo para o longo período
1933-2000 em que as fontes oficiais são esparsas. O `educabr` mantém
**todas as estimativas concorrentes** lado a lado, permitindo comparação
direta:

``` r

es_1980 <- get_enrollment(
  level     = "superior",
  year      = 1980,
  network   = "total",
  modality  = "total",
  indicator = "count"
)

es_1980[, c("source", "value", "source_note")]
#> # A tibble: 4 × 3
#>   source                  value source_note                                     
#>   <chr>                   <dbl> <chr>                                           
#> 1 kang_paese_felix_2021 1377286 Kang, Paese & Felix (2021). RHE 39(2):191-218. …
#> 2 durham_2005           1377286 Durham (2005). Educação superior, pública e pri…
#> 3 kang_paese_felix_2021 1377286 Kang, Paese & Felix (2021), RHE 39(2):191-218. …
#> 4 maduro_junior_2007    1377286 Maduro Junior (2007). Taxas de matrícula e gast…
```

Note que para 1980 várias fontes convergem para o mesmo valor (~1,38
milhão), o que sugere uma estimativa estabilizada na literatura. Para
outros anos as estimativas divergem — passar `source = "..."` no
[`get_enrollment()`](https://mancano-tales.github.io/educabr/reference/get_enrollment.md)
é o caminho recomendado para fixar uma série única em análises
secundárias.

## Caso 3 — o problema dos totais reconstruídos (2000-2008)

Entre 2000 e 2008 o INEP começou a coletar matrículas em **EAD (educação
a distância)** em uma tabela específica do CENSUP (`tabela7.x`), porém
**não as somou** ao total das matrículas presenciais publicadas na
`tabela5.x`. Isso significa que séries “totais” desse intervalo
publicadas por Kang, Durham, Maduro Junior e pela própria sinopse do
INEP estão **sistematicamente subestimadas** — em até 700 mil matrículas
em 2008, segundo nosso cálculo.

A partir de 2009, os microdados do CENSUP já agregam presencial e EAD no
mesmo cadastro, e o problema se resolve.

Para esse intervalo de transição, o `educabr` disponibiliza **totais
reconstruídos** (*reconstructed enrollment totals*) que somam o
componente presencial de cada fonte ao EAD publicado pelo INEP. Essas
linhas têm `is_derived = TRUE` e ficam fora do resultado padrão de
[`get_enrollment()`](https://mancano-tales.github.io/educabr/reference/get_enrollment.md);
para inspecioná-las basta passar `include_derived = TRUE`:

``` r

recon <- get_enrollment(
  level           = "superior",
  year            = c(2000, 2008),
  network         = "total",
  modality        = "total",
  indicator       = "count",
  include_derived = TRUE
)

recon[recon$is_derived, c("year", "source", "value")]
#> # A tibble: 23 × 3
#>     year source                                      value
#>    <int> <chr>                                       <dbl>
#>  1  2000 durham_2005+inep_sinopse_censup           2695927
#>  2  2000 inep_sinopse_censup+inep_sinopse_censup   2695927
#>  3  2000 kang_paese_felix_2021+inep_sinopse_censup 2695927
#>  4  2000 maduro_junior_2007+inep_sinopse_censup    2695927
#>  5  2001 durham_2005+inep_sinopse_censup           3045113
#>  6  2001 inep_sinopse_censup+inep_sinopse_censup   3036113
#>  7  2001 inep_sinopse_censup+inep_sinopse_censup   3036113
#>  8  2001 kang_paese_felix_2021+inep_sinopse_censup 3036113
#>  9  2001 maduro_junior_2007+inep_sinopse_censup    3036113
#> 10  2003 inep_sinopse_censup+inep_sinopse_censup   3936933
#> # ℹ 13 more rows
```

O nome composto do `source` (ex.:
`kang_paese_felix_2021+inep_sinopse_censup`) explicita que se trata de
uma combinação: o **componente presencial** vem da primeira fonte e o
**componente EAD** vem da segunda. O `source_note` registra a composição
exata para fins de citação.

> Convenção de citação sugerida: “Total reconstruído computado a partir
> de {fonte_presencial} (presencial) e INEP Sinopse CENSUP (EAD),
> conforme metodologia documentada em `educabr` (Mançano 2026).”

## Caso 4 — anos médios de escolaridade por sexo

``` r

escolaridade_sexo <- get_schooling(
  geo_level = "BR",
  dimension = "sex"
)

tail(escolaridade_sexo)
#> # A tibble: 6 × 12
#>    year geo_level geo_code geo_name dim_race dim_sex age_group indicator   value
#>   <int> <chr>     <chr>    <chr>    <chr>    <chr>   <chr>     <chr>       <dbl>
#> 1  2010 BR        BR       Brasil   total    male    NA        mean_years…  8.03
#> 2  2011 BR        BR       Brasil   total    male    NA        mean_years…  8.2 
#> 3  2012 BR        BR       Brasil   total    male    NA        mean_years…  8.39
#> 4  2013 BR        BR       Brasil   total    male    NA        mean_years…  8.49
#> 5  2014 BR        BR       Brasil   total    male    NA        mean_years…  8.63
#> 6  2015 BR        BR       Brasil   total    male    NA        mean_years…  8.72
#> # ℹ 3 more variables: unit <chr>, source <chr>, source_note <chr>
```

A série mostra a inversão histórica do *gender gap*: em 1925 os homens
tinham em média mais anos de estudo que as mulheres; ao longo do século
XX a vantagem inverte e em 2015 mulheres ultrapassam homens em
escolaridade média.

## Painel interativo

O pacote acompanha um painel Shiny com as três séries:

``` r

educabr::run_dashboard()
```

O painel reproduz toda a comparação multi-fonte do ensino superior de
forma interativa, com um botão “View R code” em cada aba que gera o
código `educabr` + `ggplot2` para reproduzir a visualização no seu
ambiente R local — uma ponte direta entre exploração no painel e análise
reprodutível em script.

## Fontes e citação

A lista completa de fontes com DOIs e links está na vignette principal
em inglês
([`vignette("01-introduction", "educabr")`](https://mancano-tales.github.io/educabr/articles/01-introduction.md)).
Para citar o pacote em si:

> Mançano, T. (2026). *educabr: Harmonized Historical Series on
> Brazilian Education* (versão 0.0.0.9000).
> <https://github.com/mancano-tales/educabr>
