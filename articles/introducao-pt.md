# Introdução ao educabr2 (PT-BR)

``` r

library(educabr2)
```

> Versão em português da vignette principal. Para a versão em inglês e
> canônica, veja
> **[`vignette("introduction", "educabr2")`](https://mancano-tales.github.io/educabr2/articles/introduction.md)**.

## Sobre o pacote

O **educabr2** disponibiliza, sob um único esquema *tidy* canônico, o
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
- **Atingimento educacional internacional** — 1870 a 2010, 111 países,
  proporções da população de 15-64 anos que completou os níveis
  primário, secundário e terciário, com desagregação por sexo (Lee &
  Lee 2016) — a trajetória brasileira lida contra o registro mundial sem
  sair do pacote.

Toda a transformação dos dados é auditável: cada linha do *output*
carrega o `source` (chave canônica em
`inst/dict/vocabularies/sources.yaml`) e um `source_note` com a
referência exata da tabela ou capítulo de origem.

## Instalação

``` r

# via GitHub
remotes::install_github("mancano-tales/educabr2")
```

## API em cinco funções

A interface pública é deliberadamente enxuta — uma função por tema,
todas devolvendo *tibbles* no mesmo esquema canônico:

``` r

# Esquema dos cinco principais resultados
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
#>  - attr(*, "educabr_meta")=List of 4
#>   ..$ build_script   : chr "data-raw/01_build_enrollment_kang_fgv.R"
#>   ..$ built_at       : POSIXct[1:1], format: "2026-05-18 09:38:50"
#>   ..$ primary_sources: chr [1:4] "kang_menetrier_comim_2024" "kang_paese_felix_2021" "kang_paese_felix_2021" "kang_menetrier_2024"
#>   ..$ raw_files      : chr [1:4] "data-raw/sources/kang_fgv_ibre_2023/1._matricula_primario_1871_2010_v_abril2023.xlsx" "data-raw/sources/kang_fgv_ibre_2023/2._matriculas_txmatriculas_porcor_1960_2010_v_abril2023.xlsx" "data-raw/sources/kang_fgv_ibre_2023/4._matricula_txmatriculas_1933_2010_v_abril2023.xlsx" "data-raw/sources/kang_fgv_ibre_2023/6._matricula_txmatriculas_estado_1955_2010_v_abril2023.xlsx"
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
#>  $ source_note: chr "Walter, J., & Kang, T. H. (2024). A new dataset of average years of schooling in Brazil, 1925-2015. Economic Hi"| __truncated__
#>  - attr(*, "educabr_meta")=List of 5
#>   ..$ build_script  : chr "data-raw/02_build_schooling_kang_fgv.R"
#>   ..$ built_at      : POSIXct[1:1], format: "2026-07-10 01:00:11"
#>   ..$ primary_source: chr "walter_kang_2023"
#>   ..$ citation      : chr "Walter, J., & Kang, T. H. (2024). A new dataset of average years of schooling in Brazil, 1925-2015. Economic Hi"| __truncated__
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
str(get_attainment(geo = "BRA", year = 1950))
#> tibble [3 × 12] (S3: tbl_df/tbl/data.frame)
#>  $ year       : int [1:3] 1950 1950 1950
#>  $ geo_level  : chr [1:3] "country" "country" "country"
#>  $ geo_code   : chr [1:3] "BRA" "BRA" "BRA"
#>  $ geo_name   : chr [1:3] "Brazil" "Brazil" "Brazil"
#>   ..- attr(*, "label")= chr "Country name"
#>   ..- attr(*, "format.stata")= chr "%20s"
#>  $ level      : chr [1:3] "primary" "secondary" "tertiary"
#>  $ dim_sex    : chr [1:3] "total" "total" "total"
#>  $ age_group  : chr [1:3] "15-64" "15-64" "15-64"
#>  $ indicator  : chr [1:3] "attainment_share_completed" "attainment_share_completed" "attainment_share_completed"
#>  $ value      : num [1:3] 23.611 4.345 0.519
#>  $ unit       : chr [1:3] "percent" "percent" "percent"
#>  $ source     : chr [1:3] "lee_lee_2016" "lee_lee_2016" "lee_lee_2016"
#>  $ source_note: chr [1:3] "Lee, J.-W., & Lee, H. (2016). Human capital in the long run. Journal of Development Economics, 122, 147-169. do"| __truncated__ "Lee, J.-W., & Lee, H. (2016). Human capital in the long run. Journal of Development Economics, 122, 147-169. do"| __truncated__ "Lee, J.-W., & Lee, H. (2016). Human capital in the long run. Journal of Development Economics, 122, 147-169. do"| __truncated__
#>  - attr(*, "educabr_meta")=List of 5
#>   ..$ build_script  : chr "data-raw/06_build_lee_lee_2016.R"
#>   ..$ built_at      : POSIXct[1:1], format: "2026-05-25 16:54:26"
#>   ..$ primary_source: chr "lee_lee_2016"
#>   ..$ citation      : chr "Lee, J.-W., & Lee, H. (2016). Human capital in the long run. Journal of Development Economics, 122, 147-169. do"| __truncated__
#>   ..$ raw_files     : chr "https://barrolee.github.io/BarroLeeDataSet/LeeLee/LeeLee_v1.dta"
```

Todas retornam *tibbles* longas seguindo o mesmo esquema canônico
(`inst/dict/schema.yaml`), com colunas para a unidade geográfica, a
dimensão de desigualdade (raça, sexo, etc.), a fonte e o valor. Os
filtros compartilhados (`year`, `geo_level`, `geo`, `source`, `wide`,
`lang`) funcionam de forma idêntica nas cinco funções. Como o conjunto
de colunas é o mesmo, resultados de temas diferentes podem ser
empilhados diretamente com
[`rbind()`](https://rdrr.io/r/base/cbind.html)/`bind_rows()`.

Note que o argumento `dimension` é deliberadamente assimétrico:
[`get_schooling()`](https://mancano-tales.github.io/educabr2/reference/get_schooling.md)
oferece raça *e* sexo;
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
apenas raça;
[`get_attainment()`](https://mancano-tales.github.io/educabr2/reference/get_attainment.md)
apenas sexo;
[`get_expenditure()`](https://mancano-tales.github.io/educabr2/reference/get_expenditure.md)
e
[`get_progression()`](https://mancano-tales.github.io/educabr2/reference/get_progression.md)
nenhum. As assimetrias reproduzem os limites físicos das fontes
históricas, não limitações do pacote.

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
1933-2000 em que as fontes oficiais são esparsas. O `educabr2` mantém
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
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
é o caminho recomendado para fixar uma série única em análises
secundárias.

Quando o que se quer é uma série única contínua (e não o painel lado a
lado), a **hierarquia de deduplicação** documentada do pacote dá a ordem
de precedência recomendada para anos sobrepostos: microdados do
CENSUP/INEP (2009-2024) → sinopses estatísticas do INEP (1995-2008) →
Kang, Paese & Felix (1990-1994) → Maduro Junior → Durham → IBGE
*Estatísticas do Século XX*. A fonte mais desagregada e oficial
disponível sempre prevalece.

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

Para esse intervalo de transição, o `educabr2` disponibiliza **totais
reconstruídos** (*reconstructed enrollment totals*) que somam o
componente presencial de cada fonte ao EAD publicado pelo INEP. Essas
linhas têm `is_derived = TRUE` e ficam fora do resultado padrão de
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md);
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
> conforme metodologia documentada em `educabr2` (Mançano 2026).”

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

## Caso 7 — o Brasil em perspectiva internacional

O painel de Lee & Lee (2016) permite ler a expansão brasileira contra
comparadores sem sair do pacote:

``` r

att <- get_attainment(
  level = "tertiary",
  geo   = c("BRA", "ARG", "KOR", "USA"),
  year  = c(1950, 2010)
)

att[att$year %in% c(1950, 1980, 2010),
    c("year", "geo_code", "value")]
#> # A tibble: 12 × 3
#>     year geo_code  value
#>    <int> <chr>     <dbl>
#>  1  1950 ARG       0.737
#>  2  1980 ARG       3.71 
#>  3  2010 ARG       2.31 
#>  4  1950 BRA       0.519
#>  5  1980 BRA       2.90 
#>  6  2010 BRA       6.59 
#>  7  1950 KOR       0.748
#>  8  1980 KOR       4.89 
#>  9  2010 KOR      33.6  
#> 10  1950 USA       7.16 
#> 11  1980 USA      17.9  
#> 12  2010 USA      27.5
```

## O sistema de visualização embutido

O pacote acompanha um conjunto de componentes de *plotting* desenhado
segundo os princípios de *Data Visualization* de Kieran Healy, para que
uma consulta vire figura pronta para publicação em três linhas:

- [`theme_educabr()`](https://mancano-tales.github.io/educabr2/reference/theme_educabr.md)
  — tema serifado minimalista; com `plot_titles = FALSE` remove títulos
  internos para manuscritos LaTeX/Quarto (onde legenda e nota vivem no
  documento). Se houver TinyTeX local (e os pacotes
  `showtext`/`sysfonts`), a fonte LaTeX Latin Modern Roman é registrada
  automaticamente.
- [`scale_colour_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_educabr.md)
  /
  [`scale_fill_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_educabr.md)
  — paleta Okabe-Ito, segura para daltonismo.
- `scale_x_year_educabr(anos)` — eixo de anos para séries seculares: o
  espaçamento dos rótulos segue o span dos dados e o primeiro e o último
  ano presentes são sempre rotulados.

``` r

library(ggplot2)

df <- get_schooling(geo_level = "BR", dimension = "sex")

ggplot(df, aes(year, value, colour = dim_sex)) +
  geom_line(linewidth = 0.9) +
  scale_colour_educabr(name = NULL) +
  scale_x_year_educabr(df$year) +
  theme_educabr() +
  labs(x = NULL, y = "Anos médios de estudo",
       title = "A inversão do gender gap educacional no século XX")
```

![](introducao-pt_files/figure-html/unnamed-chunk-10-1.png)

## Painel interativo

O pacote acompanha um painel Shiny com uma aba **Overview** curada
(quatro gráficos-história para público não técnico) e **seis abas
temáticas** — uma por tema (Enrollment, Tertiary Education, Educational
Attainment, Public Expenditure, Grade Progression, International
Comparison):

``` r

educabr2::run_dashboard()
```

O painel reproduz toda a comparação multi-fonte do ensino superior e as
séries de despesa, progressão e comparação internacional de forma
interativa, com um botão “View R code” em cada aba que gera o código
`educabr2` + `ggplot2` para reproduzir a visualização no seu ambiente R
local — já estilizado com o sistema de visualização do próprio pacote —
uma ponte direta entre exploração no painel e análise reprodutível em
script.

## Fontes e citação

A lista completa de fontes com DOIs e links está na vignette principal
em inglês
([`vignette("introduction", "educabr2")`](https://mancano-tales.github.io/educabr2/articles/introduction.md)).
A função
[`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md)
transforma qualquer chave de fonte (ou a coluna `source` de um
resultado) em referência pronta para colar:

``` r

educabr_cite("kang_paese_felix_2021", style = "text")
#> [1] "(2021). \"Kang, T. H., Paese, L. H. Z., & Felix, N. F. A. (2021). Late\nand unequal: Enrolments and retention in Brazilian education,\n1933-2010. Revista de Historia Económica / Journal of Iberian and Latin\nAmerican Economic History, 39(2), 191–218.\"\ndoi:10.1017/S0212610921000112\n<https://doi.org/10.1017/S0212610921000112>.\n<https://doi.org/10.1017/S0212610921000112>."
```

Cite **tanto** o pacote (pela harmonização) **quanto** as compilações
originais (pelo trabalho de arquivo que produziu os números). Para citar
o pacote em si:

> Mançano, T. (2026). *educabr2: Harmonized Historical Series on
> Brazilian Education* (versão 0.1.1).
> <https://github.com/mancano-tales/educabr2>
