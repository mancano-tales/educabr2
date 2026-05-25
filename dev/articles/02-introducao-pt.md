# Introdução ao educabr (PT-BR)

``` r

library(educabr)
```

> Versão em português da vignette principal. Para a versão em inglês e
> canônica, veja
> **[`vignette("01-introduction", "educabr")`](https://mancano-tales.github.io/educabr/dev/articles/01-introduction.md)**.

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
- **Despesa pública em educação** — 1933 a 2010, em % do PIB por
  estágio, por estudante em % do PIB per capita, e os indicadores de
  **razão dupla** de regressividade fiscal (Kang & Menetrier 2024).
- **Razão de progressão escolar (GDR6)** — 1955 a 2010, BR + 20 UFs,
  *proxy* da retenção nos primeiros anos do antigo primário (Kang, Paese
  & Felix 2021).

Toda a transformação dos dados é auditável: cada linha do *output*
carrega o `source` (chave canônica em
`inst/dict/vocabularies/sources.yaml`) e um `source_note` com a
referência exata da tabela ou capítulo de origem.

## Instalação

``` r

# via GitHub
remotes::install_github("mancano-tales/educabr")
```

## API em quatro funções

A interface pública é deliberadamente enxuta — uma função por tema,
todas devolvendo *tibbles* no mesmo esquema canônico:

``` r

# Esquema dos quatro principais resultados
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
str(get_expenditure(level = "total", indicator = "share_gdp", year = 1950))
#> tibble [1 × 13] (S3: tbl_df/tbl/data.frame)
#>  $ year       : int 1950
#>  $ geo_level  : chr "BR"
#>  $ geo_code   : chr "BR"
#>  $ geo_name   : chr "Brasil"
#>  $ level      : chr "total"
#>  $ network    : chr "publica"
#>  $ dim_race   : chr "total"
#>  $ age_group  : chr NA
#>  $ indicator  : chr "expenditure_share_gdp"
#>  $ value      : num 1.53
#>  $ unit       : chr "percent_gdp"
#>  $ source     : chr "kang_menetrier_2024"
#>  $ source_note: chr "Kang & Menetrier (2024). Estudos Econômicos 54(3). doi:10.1590/1980-53575434tkim"
#>  - attr(*, "educabr_meta")=List of 5
#>   ..$ build_script  : chr "data-raw/04_build_expenditure_kang_fgv.R"
#>   ..$ built_at      : POSIXct[1:1], format: "2026-05-19 02:42:48"
#>   ..$ primary_source: chr "kang_menetrier_2024"
#>   ..$ citation      : chr "Kang & Menetrier (2024). Estudos Econômicos 54(3). doi:10.1590/1980-53575434tkim"
#>   ..$ raw_files     : chr "data-raw/sources/kang_fgv_ibre_2023/5._despesa_pub_educ_1933_2010_v_abril2023.xlsx"
str(get_progression(year = 1980))
#> tibble [1 × 13] (S3: tbl_df/tbl/data.frame)
#>  $ year       : int 1980
#>  $ geo_level  : chr "BR"
#>  $ geo_code   : chr "BR"
#>  $ geo_name   : chr "Brasil"
#>  $ level      : chr "fundamental_anos_iniciais"
#>  $ network    : chr "total"
#>  $ dim_race   : chr "total"
#>  $ age_group  : chr NA
#>  $ indicator  : chr "gross_distribution_ratio_grade_6"
#>  $ value      : num 0.461
#>  $ unit       : chr "ratio"
#>  $ source     : chr "kang_paese_felix_2021"
#>  $ source_note: chr "Kang, Paese & Felix (2021). RHE 39(2):191-218. doi:10.1017/S0212610921000112"
#>  - attr(*, "educabr_meta")=List of 5
#>   ..$ build_script  : chr "data-raw/05_build_progression_kang_fgv.R"
#>   ..$ built_at      : POSIXct[1:1], format: "2026-05-19 02:43:16"
#>   ..$ primary_source: chr "kang_paese_felix_2021"
#>   ..$ citation      : chr "Kang, Paese & Felix (2021). RHE 39(2):191-218. doi:10.1017/S0212610921000112"
#>   ..$ raw_files     : chr "data-raw/sources/kang_fgv_ibre_2023/7._gdr6_1955_2010_v_abril2023.xlsx"
```

Todas retornam *tibbles* longas seguindo o mesmo esquema canônico
(`inst/dict/schema.yaml`), com colunas para a unidade geográfica, a
dimensão de desigualdade (raça, sexo, etc.), a fonte e o valor. Os
filtros compartilhados (`year`, `geo_level`, `geo`, `source`, `wide`,
`lang`) funcionam de forma idêntica nas quatro funções.

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
[`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
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
[`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md);
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

## Caso 5 — regressividade fiscal na despesa educacional

Kang & Menetrier (2024) operacionalizam uma tese clássica da economia
política da educação brasileira — que o Estado gasta
desproporcionalmente mais por aluno no ensino superior do que no ensino
primário — por meio do indicador de **razão dupla**: a despesa pública
por estudante no Ensino Superior dividida pela despesa por estudante no
EF1 (anos iniciais).

``` r

razao <- get_expenditure(indicator = "double_ratio_es_ef1")
razao[razao$year %in% c(1933, 1960, 1980, 2000, 2010),
      c("year", "value")]
#> # A tibble: 5 × 2
#>    year value
#>   <int> <dbl>
#> 1  1933 66.0 
#> 2  1960 86.6 
#> 3  1980 15.9 
#> 4  2000 16.8 
#> 5  2010  8.36
```

Em 1933 o Estado gastava cerca de **66 vezes** mais por aluno do ES do
que por aluno dos primeiros anos do primário. Em 2010 essa razão havia
caído para menos de **9**. A série deixa explícito que a expansão fiscal
da educação básica ao longo da segunda metade do século XX reduziu
significativamente a regressividade — embora não a tenha eliminado.

## Caso 6 — retenção no início do primário (GDR6)

O **GDR6** (*Gross Distribution Ratio* da 6ª série) — definido como a
razão entre as matrículas em séries 4–6 e as matrículas em séries 1–3 do
antigo primário de oito anos — é um indicador de fluxo que mede quantas
crianças avançam para além dos primeiros anos do primário. Valores mais
altos indicam menos evasão e menos repetência nos anos iniciais.

``` r

gdr_estados <- get_progression(
  geo_level = "UF",
  geo       = c("SP", "BA"),
  year      = c(1955, 2010)
)

gdr_estados[gdr_estados$year %in% c(1960, 1980, 2000, 2010),
            c("year", "geo_code", "value")]
#> # A tibble: 8 × 3
#>    year geo_code value
#>   <int> <chr>    <dbl>
#> 1  1960 BA       0.187
#> 2  1980 BA       0.276
#> 3  2000 BA       0.649
#> 4  2010 BA       0.848
#> 5  1960 SP       0.273
#> 6  1980 SP       0.665
#> 7  2000 SP       1.09 
#> 8  2010 SP       0.952
```

O fosso persistente entre SP e BA é uma das ilustrações canônicas da
desigualdade regional na literatura histórica: em 1960 a diferença já é
ampla, e só se estreita de forma substantiva depois das reformas dos
anos 1990.

> **Cobertura UF — atenção.** A compilação de Kang, Paese & Felix cobre
> **20** unidades da federação (`AL`, `AM`, `BA`, `CE`, `ES`, `GO`,
> `MA`, `MG`, `MT`, `PA`, `PB`, `PE`, `PI`, `PR`, `RJ`, `RN`, `RS`,
> `SC`, `SE`, `SP`). Os estados mais novos ou de origem territorial (AC,
> AP, DF, MS, RO, RR, TO) **não** constam da fonte. A série nacional
> brasileira tem buracos documentados em 1988-1990 e 1994, em razão das
> transições oficiais da estrutura de séries.

## Painel interativo

O pacote acompanha um painel Shiny com **cinco abas** — uma por tema
(Enrollment, Tertiary Education, Educational Attainment, Public
Expenditure, Grade Progression):

``` r

educabr::run_dashboard()
```

O painel reproduz toda a comparação multi-fonte do ensino superior e as
novas séries de despesa e progressão de forma interativa, com um botão
“View R code” em cada aba que gera o código `educabr` + `ggplot2` para
reproduzir a visualização no seu ambiente R local — uma ponte direta
entre exploração no painel e análise reprodutível em script.

## Fontes e citação

A lista completa de fontes com DOIs e links está na vignette principal
em inglês
([`vignette("01-introduction", "educabr")`](https://mancano-tales.github.io/educabr/dev/articles/01-introduction.md)).
Para citar o pacote em si:

> Mançano, T. (2026). *educabr: Harmonized Historical Series on
> Brazilian Education* (versão 0.0.0.9000).
> <https://github.com/mancano-tales/educabr>
