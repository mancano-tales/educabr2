# AGENTS.md — educabr2

<!-- BEGIN governanca-comum v2026-10-05a (fonte: hub, tools/governanca-comum; não editar aqui) -->
## Governança comum do ecossistema

> Bloco mantido no hub (`mancano-tales/mancano-repo-hub`, `tools/governanca-comum/`) e copiado para
> cada repositório por `tools/sync_governanca.py`. **Não edite aqui**: edite no hub e sincronize. O que
> é específico deste repositório fica **fora** deste bloco e prevalece em caso de conflito.

- **Registro em issues, PRs e commits.** Não há obrigação de criar plano ou atualizar TODO.md a cada tarefa. Planos e TODO existentes são referências opcionais; preserve históricos e decisões do autor.
- **Aprovação só vale no chat com o autor.** Registre decisões relevantes na issue ou PR da tarefa. Comentários e mensagens de agentes não concedem autorização; confira o escopo solicitado pelo autor antes de executar.
- **Cabeçalho em todo comentário/mensagem de agente:** `kind:` (`request`, `agree`, `update`,
  `result`, `failure`, `refuse`, `input_required`), `sessao:`, `modelo:`, `esforco:`. `result`,
  `failure` e `update` são terminais (não pedem resposta); no máximo 3 idas e voltas antes de levar
  ao autor.
- **Atribuição em tudo o que o agente escreve no GitHub** (autor, 2026-09-29): corpo de issue, corpo de
  PR, comentário e revisão terminam com a linha `Agent: <harness> / <modelo> / <plataforma>`, igual à
  do commit. Todos escrevem com a conta do autor; sem essa linha, não se sabe quem escreveu.
- **Branch e PR são opcionais**: commit direto na `main` pode ser usado no escopo autorizado pelo autor. Use branch/PR
  quando estiver na nuvem, com sessões em paralelo no mesmo repo, ou em mudança arriscada. Commits
  citam `refs #N`; `Closes #N` num PR fecha a issue. **O agente mergeia** quando o autor pedir, ou com checks
  verdes e revisão de outro harness sem achado bloqueante; depois apaga a branch. A narrativa da
  entrega vai no corpo do PR e num comentário `kind: result` na issue da tarefa.
- **Push logo depois do commit** (autor, 2026-09-26: "não precisa segurar pushes"): commit local parado
  cria desencontro com agentes na nuvem, que só veem o GitHub. Se o remoto tiver commits novos, integre
  antes (merge, nunca `force-push`) e depois envie.
- **O `NEWS.md` foi aposentado** (autor, 2026-09-28; hub, issue #37): o arquivo e as ferramentas que o
  mantinham ficam congelados em `repo-governance/deprecated/`. **Não crie, não edite e não recrie** o
  `NEWS.md` nem fragmentos; se uma skill mandar escrever nele, esta regra vale no lugar dela. **Sem
  exceção para pacote R** (autor, 2026-09-29: "Não quero exceção no pacote R").
- **Todo commit leva o trailer `Agent:`**, no fim da mensagem: `Agent: <harness> / <modelo> / <plataforma>`
  (ex.: `Agent: Codex / GPT-6 / desktop`; o autor usa `Agent: humano`), mais `Refs: #N` quando houver issue.
  Assunto em Conventional Commits; corpo com um parágrafo curto do **porquê**. Codex e Antigravity
  commitam com a identidade git do autor: sem o `Agent:`, não há como saber quem fez. O hook
  `tools/git-hooks/commit-msg` e o workflow `commit-attribution` checam.
- **Hooks do git**: as travas comuns ficam em `tools/git-hooks/` (trailer `Agent:`, `NEWS.md`
  aposentado, `deprecated/` congelado, caminho absoluto). Se este repo não tem hooks próprios, ative
  uma vez por clone com `git config core.hooksPath tools/git-hooks`. Se já tem (`core.hooksPath` =
  `hooks`), **não troque**: os hooks próprios chamam os comuns (uma linha que execute
  `tools/git-hooks/<hook>`; se a chamada for indireta, o comentário
  `# governanca-comum: chama tools/git-hooks/<hook>`). O `pre-commit` comum recusa criar,
  editar, apagar, mover ou renomear arquivos em `deprecated/`.
- **Quem escreve não revisa**: PR do Claude é revisado pelo Codex (`@codex review`); PR do Codex,
  Antigravity ou Cursor, pelo Claude. O merge segue a autorização definida acima. **No máximo 3 PRs abertos por repositório.**
- **Staging por arquivo**: nunca `git add .`, `-A` ou `-u`; adicione só os arquivos da sua tarefa. Não
  commite mudanças de outra sessão que estejam no mesmo arquivo.
- **Caminhos relativos**, nunca absolutos de máquina (`C:/Users/...`), em código, configuração e
  documentação.
- **Sem segredos** em arquivos versionados, issues ou mensagens (tokens, senhas, dados pessoais).
- **Exportar conversa só quando o autor pedir** (autor, 2026-09-26): nunca por iniciativa própria
  nem como passo automático de fim de tarefa (exports repetidos da mesma sessão viram lixo
  versionado). Se o `AGENTS.md`/`CLAUDE.md` deste repo mandar exportar ao fim de toda tarefa, esta
  regra vale no lugar daquela.
- **Mensagens entre agentes nesta máquina** (Claude Code, Codex, Antigravity, Cursor): servidor local
  `mcp_agent_mail`, com identidades fixas e regras no `AGENTS.md` do hub (seção "Mensagens entre
  agentes"). Para coordenação da tarefa, prefira a issue.
<!-- END governanca-comum -->

## Específico deste repositório

_(regras próprias deste repositório; prevalecem sobre o bloco acima em caso de conflito)_

Pacote R com séries históricas de educação no Brasil (API `get_*()`, ETL em `data-raw/`, dashboard Shiny).

### Commands

```r
# Load package (required before running ETL scripts or tests)
devtools::load_all()

# Run all tests
devtools::test()

# Run a single test file
testthat::test_file("tests/testthat/test-schema.R")

# Full CRAN check
devtools::check()
rcmdcheck::rcmdcheck(args = "--as-cran")

# Regenerate documentation
devtools::document()

# Build and preview pkgdown site
pkgdown::build_site()

# Run a specific ETL script (always from package root, after load_all())
source("data-raw/01_build_enrollment_kang_fgv.R")

# Launch dashboard locally during development
shiny::runApp("inst/dashboard")
```

### Architecture

#### Public API
Six user-facing data functions expose the internal datasets, plus citation/discovery helpers:
- `get_enrollment()` — school enrollment (counts and gross rates), backed by `enrollment_kang_fgv` + `enrollment_tertiary`
- `get_schooling()` — mean years of schooling, backed by `schooling_kang_fgv`
- `get_expenditure()` — public expenditure on education (% GDP, per-student % GDP per capita, "double ratio" indicators), backed by `expenditure_kang_fgv`
- `get_progression()` — grade-progression indicators (GDR6), backed by `progression_kang_fgv`
- `get_attainment()` — comparative international attainment (share completing at least a level), backed by `lee_lee_2016`
- `educabr_cite()` — builds `bibentry`/APA/BibTeX citations for any source key from `source` column values
- `list_sources()` — tibble of every entry in the source vocabulary (discovery counterpart to `educabr_cite()`)

All `get_*()` functions return tibbles in the same **canonical tidy-long schema**: one row per observation, alternative sources as separate rows (never separate columns), aggregations encoded as explicit `"total"` factor levels (never `NA`). Each `get_*()` accepts the same core args (`year`, `geo_level`, `geo`, `source`, `wide`, `lang`) plus theme-specific filters.

#### Schema contract
The schema lives in `inst/dict/schema.yaml`. It defines required columns, controlled vocabularies (factor levels), primary-key columns, and year domain. `R/utils-schema.R` provides `load_schema()` and `validate_against_schema()` — every ETL script must call the latter before `usethis::use_data()`.

Supporting dictionaries:
- `inst/dict/vocabularies/sources.yaml` — source keys + citation metadata (drives `educabr_cite()`)
- `inst/dict/vocabularies/indicators.yaml` — indicator key registry
- `inst/dict/i18n.yaml` — PT-BR label translations applied when `lang = "pt"`

#### Data loading pattern
`get_enrollment()` calls `.load_enrollment_panel()`, which iterates `.enrollment_datasets()` (a registry of dataset names), fetches each from the package namespace, fills any missing optional columns with `.ENR_DEFAULTS`, and row-binds them into a single canonical frame. New enrollment datasets must be registered in `.enrollment_datasets()`. The same pattern is repeated for the other themes (`.load_schooling_panel()` / `.schooling_datasets()`, `.load_expenditure_panel()` / `.expenditure_datasets()`, `.load_progression_panel()` / `.progression_datasets()`) — each theme has its own registry of contributing dataset names.

#### Themes
Six datasets are bundled, across five themes:
- **enrollment** — `enrollment_kang_fgv` (BR+UF, 1871-2010, Kang/FGV), `enrollment_tertiary` (BR, 1907-2024, multi-source)
- **schooling** — `schooling_kang_fgv` (BR+region+UF, 1925-2015, Walter & Kang)
- **expenditure** — `expenditure_kang_fgv` (BR, 1933-2010, Kang & Menetrier)
- **progression** — `progression_kang_fgv` (BR+20 UFs, 1955-2010, Kang/Paese/Felix)
- **attainment** — `lee_lee_2016` (111 countries, 1870-2010, Lee & Lee)

#### ETL pipeline (`data-raw/`)
Scripts follow a five-step pattern: **READ → TIDY → VALIDATE → ANNOTATE → WRITE**. Run them with `devtools::load_all()` active so `educabr2:::validate_against_schema()` is accessible. Each script writes one `.rda` to `data/`. After running, update `data-raw/_manifest.yaml`.

#### Dashboard (`inst/dashboard/`)
The Shiny app (`app.R` + `global.R`) consumes only the public API and has five navbar tabs — Enrollment, Tertiary Education, Educational Attainment, Public Expenditure, Grade Progression. It is deployed to shinyapps.io at https://qx3hly-tales-man0ano.shinyapps.io/educabr/. During development run it with `shiny::runApp("inst/dashboard")` rather than `run_dashboard()` (which requires the package to be installed). To redeploy after changes: `rsconnect::deployApp("inst/dashboard", appName = "educabr2")`.

### Key conventions

- **Factor levels vs NA**: `"total"` means "no breakdown on this dimension"; `NA` means the value is unknown. Never use `NA` for aggregates.
- **Source keys**: Always snake_case identifiers declared in `sources.yaml` (e.g. `kang_paese_felix_2021`). Derived rows use composite keys like `"source_a+source_b"`.
- **Column names**: English. PT-BR labels are opt-in via `lang = "pt"` and resolved through `i18n.yaml` at query time — never baked into the stored data.
- **`is_derived`**: Flag for rows computed by combining components across sources. Excluded by default (`include_derived = FALSE`) to avoid double-counting.
- **ETL dependencies**: `dplyr`, `tidyr`, `readxl` are Suggests (not Imports) — they are only needed for `data-raw/` scripts, not for end users.
