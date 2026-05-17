# educabr <img align="right" src="man/figures/logo-gemini.png.png?raw=true" alt="logo" width="180">

> Harmonized historical series on Brazilian education — enrollment and
> educational attainment, compiled and reconciled across decades of
> heterogeneous official and academic sources.

[![License: GPL (>= 3)](https://img.shields.io/badge/License-GPL--3-blue.svg)](LICENSE.md)
[![R-CMD-check](https://github.com/mancano-tales/educabr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/mancano-tales/educabr/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

**🇧🇷 PT-BR:** `educabr` reúne séries históricas tratadas sobre educação
formal no Brasil — matrículas por nível e rede, anos de estudo,
alfabetização e atingimento educacional — compiladas de fontes oficiais
e acadêmicas heterogêneas (Censo Escolar, PNAD, Censo Demográfico,
Anuário Estatístico do IBGE, Paglayan 2022, entre outras) e
reconciliadas em um único schema *tidy*, com proveniência explícita.

**🇺🇸 EN:** `educabr` provides curated long-run series on Brazilian
formal education — enrollment by stage and network, years of schooling,
literacy and attainment — compiled and reconciled from heterogeneous
official and academic sources into a single tidy schema with explicit
provenance.

---

## Status

🚧 **Em desenvolvimento ativo (v0.0.x).** O pacote está na fase M1 do
roadmap: schema canônico, pipeline ETL e esqueleto definidos; sem
funções de usuário ainda. Veja a seção [Roadmap](#roadmap).

---

## Posicionamento

`educabr` é complementar ao
[`educabR`](https://github.com/SidneyBissoli/educabR) de Sidney Bissoli,
que organiza acesso por **fonte oficial** (`get_ideb()`, `get_enem()`,
`get_censo_escolar()`, ...). Aqui o eixo é por **tema e série
histórica**: indicadores únicos compilados de múltiplas fontes ao longo
do tempo. Convenções de nomenclatura, schema de saída e utilidades de
cache são compatíveis, com vistas a uma eventual fusão.

Inspirações de design: [`geobr`](https://github.com/ipeaGIT/geobr) (família
de funções coerente), [`PNADCperiods`](https://cran.r-project.org/package=PNADCperiods)
(dashboard embutido + entrega metodológica) e o ecossistema
[`brverse`](https://github.com/ipea/brverse).

---

## Instalação

```r
# install.packages("remotes")
remotes::install_github("mancano-tales/educabr")
```

---

## Como vai funcionar (preview da API v0.4)

### Matrículas (`get_enrollment()`)

> Quem está estudando em determinada etapa e ano — *fluxo anual,
> perspectiva da escola.*

```r
library(educabr)

# Taxa líquida de matrícula no fundamental, por raça, 1980-2020
get_enrollment(
  level     = "fundamental",
  indicator = "net_rate",
  dimension = "race",
  year      = 1980:2020
)
```

### Escolaridade (`get_schooling()`)

> Quanto a população já estudou — *estoque acumulado, perspectiva da
> pessoa.*

```r
# Média de anos de estudo da população 25+, por raça
get_schooling(
  measure   = "years_of_schooling",
  dimension = "race",
  age_group = "25+",
  year      = 1980:2020
)
```

### Desigualdade como recorte, não como dataset

Desigualdade educacional não é um dado pronto: é um *recorte* aplicado a
um indicador. Toda função `get_*()` aceita o argumento `dimension`
(`race`, `sex`, `income`, `location`). O helper `compute_gap()` calcula
hiatos a partir do *output* dessas funções:

```r
get_schooling(measure = "years_of_schooling", dimension = "race",
              year = 1980:2020) |>
  compute_gap(by = "dim_race", ref = "white", method = "difference")
```

### Dashboard

```r
educabr::run_dashboard()       # Shiny app local
```

Também publicado em `shinyapps.io` (link após M5).

---

## Schema canônico

Todos os `get_*()` devolvem um *tibble* no schema *tidy* documentado em
[`inst/dict/schema.yaml`](inst/dict/schema.yaml): uma linha por
observação, fontes alternativas para o mesmo indicador como **linhas
distintas** (coluna `source`), agregações como nível de fator explícito
(`"total"`), nunca como `NA`. Vocabulários controlados de indicadores e
fontes ficam em
[`inst/dict/vocabularies/`](inst/dict/vocabularies).

---

## Roadmap

| Marco | Conteúdo | Status |
|---|---|---|
| **M1** | Schema canônico, esqueleto, ETL, CI, LICENSE | ✅ |
| **M2** | `get_enrollment()` (BR + UF, séries históricas) + 1ª vinheta | ⏳ |
| **M3** | `get_schooling()` com `dimension` + vinheta de desigualdade + `compute_gap()` | ⏳ |
| **M4** | Storage externo (release Zenodo) + utilidades de cache (`set_cache_dir`, `list_cache`, `clear_cache`) | ⏳ |
| **M5** | Dashboard `run_dashboard()` bilíngue + deploy shinyapps.io | ⏳ |
| **M6** | Polimento CRAN + pkgdown bilíngue + submissão | ⏳ |

---

## Citação

Após o primeiro release com DOI Zenodo:

```r
citation("educabr")
educabr_cite("paglayan_2022")   # cita também a fonte original do indicador
```

---

## Contribuindo

Issues e PRs são bem-vindos. Para contribuir com dados, abra uma issue
descrevendo a planilha-fonte, autor, cobertura geográfica/temporal e
licença — antes de mandar PR.

---

## Licença

Código sob **GPL (>= 3)**. Dados sob **CC BY 4.0** (exceto onde a fonte
original impuser restrições; consulte `inst/dict/vocabularies/sources.yaml`).
Veja [`LICENSE.md`](LICENSE.md).
