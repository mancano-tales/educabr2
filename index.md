# educabr2

**Português e English:** cada seção apresenta o mesmo conteúdo nos dois
idiomas. / Each section presents the same content in both languages.

> Séries históricas harmonizadas da educação brasileira em R:
> matrículas, escolaridade, despesa pública e progressão escolar, com
> proveniência por observação e painel interativo.
>
> Harmonized historical series on Brazilian education in R: enrollment,
> schooling, public expenditure and grade progression, with
> observation-level provenance and an interactive dashboard.

[![Licença / License: GPL (\>=
3)](https://img.shields.io/badge/License-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
[![R-CMD-check](https://github.com/mancano-tales/educabr2/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mancano-tales/educabr2/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/mancano-tales/educabr2/actions/workflows/pkgdown.yaml/badge.svg)](https://mancano-tales.github.io/educabr2/)
[![Ciclo de vida / Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23675602.svg)](https://doi.org/10.5281/zenodo.23675602)

**PT.** `educabr2` reúne séries de longo prazo sobre educação formal
brasileira, compiladas de fontes oficiais e acadêmicas e harmonizadas em
um esquema *tidy* comum. Os seis conjuntos de dados acompanham o pacote
e podem ser consultados offline. Fontes alternativas permanecem em
linhas distintas para permitir comparação e auditoria. A cobertura varia
por tema e fonte; consulte
[`list_sources()`](https://mancano-tales.github.io/educabr2/reference/list_sources.md)
e as vinhetas.

**EN.** `educabr2` brings together long-run series on Brazilian formal
education, compiled from official and academic sources and harmonized
into a common tidy schema. All six datasets ship with the package and
can be queried offline. Alternative sources remain in separate rows for
comparison and auditing. Coverage varies by theme and source; see
[`list_sources()`](https://mancano-tales.github.io/educabr2/reference/list_sources.md)
and the vignettes.

## Links rápidos / Quick links

- [Documentação /
  Documentation](https://mancano-tales.github.io/educabr2/) — referência
  de funções e artigos / function reference and articles.
- [Introdução em
  português](https://mancano-tales.github.io/educabr2/articles/introducao-pt.html)
  · [Introduction in
  English](https://mancano-tales.github.io/educabr2/articles/introduction.html).
- [Visualização em
  português](https://mancano-tales.github.io/educabr2/articles/visualizacao-pt.html)
  · [Visualization in
  English](https://mancano-tales.github.io/educabr2/articles/visualization.html).
- [Painel interativo / Interactive
  dashboard](https://qx3hly-tales-man0ano.shinyapps.io/educabr2/).
- [Problemas e sugestões / Issues and
  suggestions](https://github.com/mancano-tales/educabr2/issues).

## Instalação / Installation

**PT.** O pacote ainda não está no CRAN. Instale a versão de
desenvolvimento pelo GitHub; requer R \>= 4.1.

**EN.** The package is not yet on CRAN. Install the development version
from GitHub; R \>= 4.1 is required.

``` r

# Instale remotes uma vez / Install remotes once
# install.packages("remotes")
remotes::install_github("mancano-tales/educabr2")
library(educabr2)
```

## Uso / Usage

**PT.** São **cinco funções de acesso aos dados**, acompanhadas de
[`list_sources()`](https://mancano-tales.github.io/educabr2/reference/list_sources.md),
[`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md),
componentes de visualização e
[`run_dashboard()`](https://mancano-tales.github.io/educabr2/reference/run_dashboard.md).
Os filtros usam as chaves canônicas em ambos os idiomas. `lang = "pt"`
traduz rótulos de saída; `lang = "en"` mantém os valores canônicos.
Nomes de colunas e chaves de fonte permanecem estáveis. Nomes
geográficos preservam o idioma da fonte (inclusive os nomes de países em
inglês de Lee & Lee).

**EN.** There are **five data-access functions**, plus
[`list_sources()`](https://mancano-tales.github.io/educabr2/reference/list_sources.md),
[`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md),
plotting components and
[`run_dashboard()`](https://mancano-tales.github.io/educabr2/reference/run_dashboard.md).
Filters use canonical keys in both languages. `lang = "pt"` translates
output labels; `lang = "en"` retains canonical values. Column names and
source keys remain stable. Geographic names retain the source language
(including Lee & Lee’s English country names).

### `get_enrollment()` — matrículas / enrollment

**PT.** Contagens e taxas brutas de matrícula por etapa, ano e
geografia; desagregação por raça/cor quando disponível. O ensino
superior oferece comparação por fonte, rede, organização acadêmica e
modalidade.

**EN.** Enrollment counts and gross rates by stage, year and geography;
race/colour breakdowns where available. Tertiary enrollment supports
comparison by source, network, institution type and modality.

``` r

# Taxa bruta no ensino fundamental / Gross fundamental enrollment rate
get_enrollment(level = "fundamental", indicator = "rate", geo_level = "BR")

# Ensino superior por rede / Tertiary enrollment by network
get_enrollment(level = "superior", network = c("publica", "privada"),
               modality = "total", year = c(1990, 2024))

# Rótulos em português; filtros canônicos / Portuguese labels; canonical filters
get_enrollment(level = "fundamental", indicator = "rate",
               dimension = "race", year = c(1960, 2010), lang = "pt")
```

### `get_schooling()` — anos de estudo / years of schooling

**PT.** Anos médios de escolaridade da população adulta, com
desagregações por raça/cor e sexo e cobertura nacional, regional e
estadual.

**EN.** Mean years of schooling of the adult population, with
race/colour and sex breakdowns and national, regional and state
coverage.

``` r

get_schooling(geo_level = "BR")
get_schooling(dimension = "race")
get_schooling(dimension = "sex", lang = "pt")
```

### `get_expenditure()` — despesa pública / public expenditure

**PT.** Despesa educacional como proporção do PIB, gasto por estudante
em proporção do PIB per capita e indicadores de razão dupla de Kang &
Menetrier (2024).

**EN.** Education spending as a share of GDP, per-student spending as a
share of GDP per capita, and Kang & Menetrier’s (2024) double-ratio
indicators.

``` r

get_expenditure(indicator = "share_gdp", level = "total")
get_expenditure(indicator = "per_student", level = "superior")
# ES / EF1: gasto por estudante / Tertiary / early-primary spending per student
get_expenditure(indicator = "double_ratio_es_ef1")
```

### `get_progression()` — progressão escolar / grade progression

**PT.** GDR6: razão entre matrículas nas séries 4–6 e 1–3 do antigo
primário de oito anos. Cobre o Brasil e 20 UFs; as lacunas históricas da
fonte são preservadas.

**EN.** GDR6: enrollment in grades 4–6 divided by grades 1–3 of the
former eight-year primary system. Covers Brazil and 20 states;
historical gaps in the source are preserved.

``` r

get_progression()
get_progression(geo_level = "UF", geo = c("BA", "PE", "CE"),
                year = c(1980, 2010))
```

### `get_attainment()` — conclusão educacional internacional / international educational attainment

**PT.** Proporção da população de 15–64 anos que completou pelo menos o
nível primário, secundário ou terciário. Lee & Lee (2016): 111 países,
1870–2010, intervalos de cinco anos e desagregação por sexo.

**EN.** Share of the population aged 15–64 that completed at least
primary, secondary or tertiary education. Lee & Lee (2016): 111
countries, 1870–2010, five-year intervals and sex breakdowns.

``` r

get_attainment(level = "tertiary", geo = "BRA")
get_attainment(level = "primary", geo = c("BRA", "ARG", "CHL", "MEX", "URY"),
               year = c(1950, 2010))
get_attainment(level = "secondary", geo = "BRA", dimension = "sex")
```

### `list_sources()` — catálogo de fontes / source catalogue

**PT.** Lista chaves de fonte, nomes, tipo, cobertura, DOI e URL. Use as
chaves da coluna `source` para filtrar e citar os dados.

**EN.** Lists source keys, names, type, coverage, DOI and URL. Use the
keys in the `source` column to filter and cite data.

``` r

src <- list_sources()
src[src$type == "academic", c("key", "short_name", "doi")]
src[grepl("UF", src$geo), c("key", "year_start", "year_end")]
```

### `run_dashboard()` — painel Shiny / Shiny dashboard

**PT.** Uma visão geral com quatro gráficos narrativos (expansão
secular, redes pública e privada, avanço da EAD e inversão da diferença
de escolaridade por sexo) e seis abas temáticas. As abas cobrem
matrículas, ensino superior, escolaridade, despesa pública, progressão e
comparação internacional. Cada aba temática oferece filtros, tabela,
fontes, download CSV e código R reproduzível.

**EN.** An overview with four narrative charts (long-run expansion,
public and private networks, the rise of distance education and the
reversal of the schooling gender gap) and six thematic tabs. The tabs
cover enrollment, tertiary education, schooling, public expenditure,
progression and international comparison. Each thematic tab provides
filters, a table, sources, CSV download and reproducible R code.

``` r

educabr2::run_dashboard(lang = "pt")
educabr2::run_dashboard(lang = "en")
```

**PT.** O código exibido usa a API pública, `ggplot2` e `plotly`, com o
tema e as escalas do pacote. Remova a chamada final a `ggplotly()` para
obter uma figura estática.

**EN.** The displayed code uses the public API, `ggplot2` and `plotly`,
with the package’s theme and scales. Remove the final `ggplotly()` call
for a static figure.

## Dados e cobertura / Datasets and coverage

**PT.** Contagens verificadas nos objetos distribuídos com a versão
0.1.3. BR = Brasil; UF = unidade da federação. As funções `get_*()`
aplicam filtros, normalizam o esquema e traduzem rótulos.

**EN.** Counts verified against the objects bundled with version 0.1.3.
BR = Brazil; UF = state. The `get_*()` functions filter, normalize the
schema and translate labels.

| Conjunto / Dataset | Linhas / Rows | Cobertura / Coverage | Fontes / Sources |
|----|---:|----|----|
| `enrollment_kang_fgv` | 6,238 | BR: 1871–2010; UF: 1955–2010; raça/cor desde 1960 / race/colour from 1960 | Kang, Paese & Felix (2021); Kang & Menetrier (2024); Kang, Menetrier & Comim (2024) |
| `enrollment_tertiary` | 1,143 | BR, ensino superior / tertiary, 1907–2024; rede, organização, modalidade / network, institution type, modality | IBGE Século XX; Maduro Junior (2007); INEP Sinopse / Synopsis; INEP Microdados / Microdata; Kang em totais derivados / in derived totals |
| `schooling_kang_fgv` | 2,287 | BR + região / region + UF, 1925–2015; raça/cor e sexo / race/colour and sex | Walter & Kang (2024) |
| `expenditure_kang_fgv` | 1,170 | BR, 1933–2010; % PIB, por estudante, razões duplas / % GDP, per student, double ratios | Kang & Menetrier (2024) |
| `progression_kang_fgv` | 1,090 | BR + 20 UFs, GDR6, 1955–2010 | Kang, Paese & Felix (2021) |
| `lee_lee_2016` | 28,971 | 111 países / countries, 1870–2010; conclusão por nível e sexo / attainment by level and sex | Lee & Lee (2016) |

**PT.** Para montar uma série única, a precedência recomendada em
períodos sobrepostos é: microdados INEP CENSUP (2009–2024) → sinopses
INEP (1995–2008) → Kang, Paese & Felix (1990–1994) → Maduro Junior →
IBGE *Estatísticas do Século XX*. Essa é uma decisão analítica
explícita: a API preserva as estimativas concorrentes, sem escolher
automaticamente uma fonte. Em 1995, INEP, Maduro Junior e Kang et
al. reportam as mesmas 1.759.703 matrículas no ensino superior.

**EN.** To build a single series, the recommended precedence in
overlapping periods is: INEP CENSUP microdata (2009–2024) → INEP
synopses (1995–2008) → Kang, Paese & Felix (1990–1994) → Maduro Junior →
IBGE *Statistics of the 20th Century*. This is an explicit analytical
decision: the API preserves competing estimates rather than selecting a
source automatically. In 1995, INEP, Maduro Junior and Kang et
al. report the same 1,759,703 tertiary enrollments.

**PT.** Em 2000–2008, os totais presenciais e de EAD eram publicados
separadamente. Totais reconstruídos têm `is_derived = TRUE`, registram
as fontes componentes e só entram em
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
com `include_derived = TRUE`. A versão 0.1.3 inclui a Sinopse 2002, usa
`walter_kang_2024` (mantendo o alias antigo de 2023) e elimina a
duplicação do painel Power BI do INEP, cujos valores coincidem com os
microdados.

**EN.** In 2000–2008, in-person and distance-education totals were
published separately. Reconstructed totals have `is_derived = TRUE`,
record their component sources and enter
[`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
only with `include_derived = TRUE`. Version 0.1.3 includes the 2002
synopsis, uses `walter_kang_2024` (retaining the old 2023 alias) and
removes duplication from INEP’s Power BI panel, whose values match the
microdata.

## Visualização / Visualization

**PT.** O sistema de visualização segue os princípios de *Data
Visualization*, de Kieran Healy: tema minimalista serifado, paleta
Okabe-Ito segura para daltonismo e eixo temporal adequado a séries
longas.

**EN.** The plotting system follows Kieran Healy’s *Data Visualization*
principles: a minimal serif theme, the colourblind-safe Okabe-Ito
palette and a time axis suited to long series.

``` r

library(ggplot2)
df <- get_schooling(geo_level = "BR", dimension = "sex")
ggplot(df, aes(year, value, colour = dim_sex)) +
  geom_line(linewidth = 0.9) +
  theme_educabr() +
  scale_colour_educabr() +
  scale_x_year_educabr(df$year)
```

**PT.** Use
[`scale_fill_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_educabr.md)
para áreas e barras. `scale_x_year_educabr(anos)` escolhe o espaçamento
conforme a amplitude: 20 anos acima de seis décadas, 10 anos em
intervalos intermediários e
[`pretty()`](https://rdrr.io/r/base/pretty.html) para intervalos curtos.
Sempre rotula o primeiro e o último ano e evita sobreposição nas
extremidades.

**EN.** Use
[`scale_fill_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_educabr.md)
for areas and bars. `scale_x_year_educabr(years)` chooses spacing from
the span: 20 years beyond six decades, 10 years for intermediate spans
and [`pretty()`](https://rdrr.io/r/base/pretty.html) for short spans. It
always labels the first and last year and avoids collisions at the
endpoints.

**PT.** Com TinyTeX, `showtext` e `sysfonts`,
[`theme_educabr()`](https://mancano-tales.github.io/educabr2/reference/theme_educabr.md)
registra automaticamente Latin Modern Roman; caso a fonte ou as
dependências não estejam disponíveis, usa a fonte serifada do sistema. O
padrão `plot_titles = TRUE` exibe título, subtítulo e legenda dentro da
figura. Para manuscritos LaTeX/Quarto,
`theme_educabr(plot_titles = FALSE)` permite defini-los no documento,
evitando duplicação.

**EN.** With TinyTeX, `showtext` and `sysfonts`,
[`theme_educabr()`](https://mancano-tales.github.io/educabr2/reference/theme_educabr.md)
automatically registers Latin Modern Roman; if the font or dependencies
are unavailable, it uses the system serif font. The default
`plot_titles = TRUE` displays the title, subtitle and caption inside the
figure. For LaTeX/Quarto manuscripts,
`theme_educabr(plot_titles = FALSE)` lets you define them in the
document, avoiding duplication.

## Esquema / Schema

**PT.** Cada observação ocupa uma linha, fontes alternativas usam linhas
separadas (coluna `source`) e agregados usam `"total"`, não `NA`. O
contrato, as chaves e as unidades estão em
[`inst/dict/schema.yaml`](https://github.com/mancano-tales/educabr2/blob/main/inst/dict/schema.yaml);
os vocabulários em
[`inst/dict/vocabularies/`](https://github.com/mancano-tales/educabr2/tree/main/inst/dict/vocabularies)
e as traduções em
[`inst/dict/i18n.yaml`](https://github.com/mancano-tales/educabr2/blob/main/inst/dict/i18n.yaml).

**EN.** Each observation occupies one row, alternative sources use
separate rows (`source` column), and aggregates use `"total"`, not `NA`.
The contract, keys and units are in
[`inst/dict/schema.yaml`](https://github.com/mancano-tales/educabr2/blob/main/inst/dict/schema.yaml);
vocabularies are in
[`inst/dict/vocabularies/`](https://github.com/mancano-tales/educabr2/tree/main/inst/dict/vocabularies)
and translations in
[`inst/dict/i18n.yaml`](https://github.com/mancano-tales/educabr2/blob/main/inst/dict/i18n.yaml).

## Pacotes relacionados e integração / Related packages and integration

**PT.** O pacote complementar é o
[**educabR**](https://CRAN.R-project.org/package=educabR), de **Sidney
Bissoli** ([GitHub](https://github.com/SidneyBissoli/educabR),
[documentação](https://sidneybissoli.github.io/educabR/),
[DOI](https://doi.org/10.5281/zenodo.19410201)). Ele baixa e armazena em
cache dados oficiais do INEP, FNDE, CAPES e Tesouro Nacional sob
demanda, preservando os leiautes das agências. O `educabr2` distribui
séries históricas harmonizadas por tema, com proveniência. A
compatibilidade entre esquemas ainda está em desenvolvimento; os pacotes
não são versões sucessivas de um mesmo produto.

**EN.** The complementary package is
[**educabR**](https://CRAN.R-project.org/package=educabR), by **Sidney
Bissoli** ([GitHub](https://github.com/SidneyBissoli/educabR),
[documentation](https://sidneybissoli.github.io/educabR/),
[DOI](https://doi.org/10.5281/zenodo.19410201)). It downloads and caches
official INEP, FNDE, CAPES and National Treasury data on demand,
preserving agency layouts. `educabr2` distributes harmonized historical
series by theme, with provenance. Schema compatibility is still under
development; the packages are not successive versions of the same
product.

| Necessidade / Need | Use |
|----|----|
| Microdados de escolas, cursos ou exames / School, course or exam microdata | `educabR` |
| Indicadores como publicados (IDEB, CPC, FUNDEB) / Indicators as published (IDEB, CPC, FUNDEB) | `educabR` |
| Séries históricas que atravessam fontes e quebras / Historical series crossing sources and breaks | `educabr2` |
| Detalhe recente junto de uma série longa / Recent detail alongside a long series | Ambos, com harmonização explícita / Both, with explicit harmonization |

``` r

# Série histórica agregada / Aggregate historical series
hist <- educabr2::get_enrollment(
  level = "superior", indicator = "count", network = "total",
  institution_type = "total", modality = "total", source = "inep_microdados_censup"
)
# Consulta separada; requer educabR / Separate query; requires educabR
# cursos <- educabR::get_censo_superior(2023, type = "cursos")
```

**PT.** A [issue
\#8](https://github.com/mancano-tales/educabr2/issues/8) concentra o
planejamento: aprimorar e validar os dados já tratados, ampliar sua
cobertura e entregá-los pelas funções existentes. As séries pequenas
continuam distribuídas com o pacote; dados remotos versionados e cache
serão avaliados se houver necessidade. A proposta externa anterior foi
retirada; uma colaboração será considerada depois de uma entrega local
demonstrável. Se usar ambos os pacotes, cite ambos.

**EN.** [Issue \#8](https://github.com/mancano-tales/educabr2/issues/8)
now holds the planning: improve and validate the curated data, expand
coverage and deliver it through existing functions. Small series remain
bundled; versioned remote data and caching will be assessed if needed.
The earlier external proposal was withdrawn; collaboration will be
considered after a demonstrable local deliverable. If you use both
packages, cite both.

| Pacote / Package | Uso complementar / Complementary use |
|----|----|
| [`censobr`](https://CRAN.R-project.org/package=censobr) | Microdados censitários e denominadores populacionais / Census microdata and population denominators |
| [`PNADcIBGE`](https://CRAN.R-project.org/package=PNADcIBGE) | PNAD Contínua e escolaridade recente / Continuous PNAD and recent schooling |
| [`geobr`](https://CRAN.R-project.org/package=geobr) | Limites oficiais e mapas / Official boundaries and maps |
| [`basedosdados`](https://CRAN.R-project.org/package=basedosdados) | Tabelas no BigQuery e cruzamentos entre áreas / BigQuery tables and cross-domain joins |

**PT.** O desenho do pacote também se inspira em
[`geobr`](https://github.com/ipea/geobr),
[`PNADCperiods`](https://cran.r-project.org/package=PNADCperiods) e no
ecossistema [`brverse`](https://github.com/ipea/brverse).

**EN.** The package design also draws on
[`geobr`](https://github.com/ipea/geobr),
[`PNADCperiods`](https://cran.r-project.org/package=PNADCperiods) and
the [`brverse`](https://github.com/ipea/brverse) ecosystem.

## Como citar / How to cite

**PT.** Cite o pacote pelo trabalho de harmonização e as fontes
originais pelos dados utilizados.
[`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md)
produz referências APA/BibTeX a partir das chaves de fonte; consulte
primeiro os dados e cite apenas as fontes efetivamente usadas.

**EN.** Cite the package for harmonization and the original sources for
the data used.
[`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md)
builds APA/BibTeX references from source keys; query the data first and
cite only the sources actually used.

``` r

citation("educabr2")
educabr_cite("kang_paese_felix_2021")
educabr_cite(c("walter_kang_2024", "inep_microdados_censup"))
educabr_cite()  # Todas as fontes / All sources

d <- get_enrollment(level = "fundamental", indicator = "rate")
educabr_cite(unique(d$source), style = "text")
```

**Referência sugerida / Suggested citation:**

Mançano, T. (2026). *educabr2: Harmonized Historical Series on Brazilian
Education* (R package version 0.1.3). Zenodo.
<https://doi.org/10.5281/zenodo.23679357>

``` bibtex
@Manual{educabr2,
  title  = {educabr2: Harmonized Historical Series on Brazilian Education},
  author = {Tales Mançano},
  year   = {2026},
  note   = {R package version 0.1.3},
  doi    = {10.5281/zenodo.23679357},
  url    = {https://github.com/mancano-tales/educabr2},
}
```

**PT.** Cada versão tem um DOI próprio (0.1.3:
[10.5281/zenodo.23679357](https://doi.org/10.5281/zenodo.23679357)); o
DOI [10.5281/zenodo.23675602](https://doi.org/10.5281/zenodo.23675602)
aponta para a versão mais recente.

**EN.** Each release has its own DOI (0.1.3:
[10.5281/zenodo.23679357](https://doi.org/10.5281/zenodo.23679357)); DOI
[10.5281/zenodo.23675602](https://doi.org/10.5281/zenodo.23675602)
resolves to the latest release.

## Contribuições / Contributing

**PT.** Issues e PRs são bem-vindos. Para acrescentar dados, abra
primeiro uma issue com o arquivo de origem, autoria, cobertura
geográfica e temporal e licença. Mantenha a documentação pública
equivalente em português e inglês. Veja o [guia de
contribuição](https://github.com/mancano-tales/educabr2/blob/main/.github/CONTRIBUTING.md).

**EN.** Issues and PRs are welcome. To add data, first open an issue
describing the source file, authorship, geographic and temporal
coverage, and license. Keep public documentation equivalent in
Portuguese and English. See the [contribution
guide](https://github.com/mancano-tales/educabr2/blob/main/.github/CONTRIBUTING.md).

## Licença / License

**PT.** Código sob **GPL (\>= 3)**. Dados sob **CC BY 4.0**, exceto
quando a fonte original impõe restrições; consulte o [catálogo de
fontes](https://github.com/mancano-tales/educabr2/blob/main/inst/dict/vocabularies/sources.yaml)
e o [texto da GPL-3](https://www.gnu.org/licenses/gpl-3.0.html).

**EN.** Code under **GPL (\>= 3)**. Data under **CC BY 4.0**, except
where the original source imposes restrictions; see the [source
catalogue](https://github.com/mancano-tales/educabr2/blob/main/inst/dict/vocabularies/sources.yaml)
and the [GPL-3 text](https://www.gnu.org/licenses/gpl-3.0.html).
