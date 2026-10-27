# Contribuir / Contributing to educabr2

## Português

Contribuições são bem-vindas. Para relatar erros em `get_*()`, abra uma
[issue](https://github.com/mancano-tales/educabr2/issues/new) com exemplo
mínimo reproduzível. Para propor dados, abra uma issue antes do PR. Para
alterações no painel, inclua captura ou esboço. Correções de texto e novos
testes de funções existentes podem vir diretamente por PR.

Discussões de compatibilidade com o `educabR`, de Sidney Bissoli, estão na
[issue #8](https://github.com/mancano-tales/educabr2/issues/8) e em
`planning/integration-educabR.md`. Consulte `planning/` antes de propor
algo que já esteja planejado.

### Acrescentar dados

A proposta deve trazer:

1. Proveniência estável: DOI, arquivo permanente ou portal oficial.
2. Licença clara de redistribuição; fontes restritas exigem permissão
   explícita dos autores, registrada na issue.
3. Referência bibliográfica em `inst/dict/vocabularies/sources.yaml`,
   utilizada por `educabr_cite()`.
4. Script ETL em `data-raw/NN_build_<dataset>.R`, que harmonize os dados ao
   esquema de `inst/dict/schema.yaml` e grave `data/<dataset>.rda`.
5. Validação por `educabr2:::validate_against_schema()` ao fim do ETL.
6. Teste em `tests/testthat/test-<dataset>.R`, com fixture do carregador.

### Estilo e verificação

Use roxygen2 com Markdown para funções exportadas, `cli::cli_abort()` e
`cli::cli_warn()` para novos erros/avisos, nomes snake_case e verbos no
estilo dplyr. Mantenha dependências mínimas; prefira base R e `rlang::%||%`
a acrescentar pacotes desnecessários.

Antes do PR, execute `devtools::document()`, `devtools::test()`,
`devtools::check(cran = TRUE)` e `spelling::spell_check_package()`.
Documente limitações da validação. Para novas funções, use `@export`,
registre a função em `_pkgdown.yml`, escreva exemplo executável e explique
o que mudou e por quê no commit/PR. Mantenha a documentação pública
nos dois idiomas. Para mudanças no painel ou traduções, execute também
`Rscript tools/check-bilingual.R`.

### Licença

Contribuições de código seguem GPL (>= 3). Dados seguem CC BY 4.0, salvo
exigência distinta da fonte original, que deve ser informada na issue.

## English

Thanks for considering a contribution. The fastest way to be useful
depends on what you have in mind.

## Quick map

| You want to… | Best path |
|---|---|
| Report a bug in a `get_*()` function | Open an [issue](https://github.com/mancano-tales/educabr2/issues/new) with a minimal reprex |
| Suggest a new data source | Open an issue first (see "Adding a dataset" below) — please **do not** open a PR cold |
| Propose a UX change to the dashboard | Open an issue with a screenshot or sketch |
| Fix a typo / improve docs | Send a PR straight away, no issue needed |
| Add tests for an existing function | Send a PR straight away |
| Discuss compatibility with [`educabR`](https://github.com/SidneyBissoli/educabR) | See [`planning/integration-educabR.md`](../planning/integration-educabR.md) and chime in via issue |

The `planning/` folder lists everything queued for the package
(roadmap, CRAN checklist, datasets wishlist, integration designs).
Skim it before proposing something new — your idea may already be
scoped, or live in a related design doc.

## Adding a dataset

`educabr2` is opinionated about which data it ships. New sources are
welcome but they need:

1. **A stable provenance** — DOI, archive link, or government portal
   URL that will not vanish next year.
2. **A clear redistribution licence** — public domain, CC0, CC BY are
   straightforward; restrictive academic licences need explicit
   permission from the authors (paste correspondence in the issue).
3. **A bibliographic citation** added to
   `inst/dict/vocabularies/sources.yaml` (the helper
   [`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.html)
   reads from there).
4. **An ETL script** under `data-raw/NN_build_<dataset>.R` that takes
   the raw file, harmonises it to the canonical schema documented in
   `inst/dict/schema.yaml`, and writes a `data/<dataset>.rda`.
5. **Validation** via `educabr2:::validate_against_schema()` (called
   at the end of the ETL script).
6. **A test file** under `tests/testthat/test-<dataset>.R` with a
   fixture exercising the loader.

Open the issue with these six bullets in mind — we'll iterate on the
design before any code is written.

## Code style

- Roxygen2 (markdown) for all exported functions.
- `cli::cli_abort()` / `cli::cli_warn()` for user-facing errors; do
  not use base `stop()` / `warning()` for new code.
- snake_case for objects and functions; `dplyr`-style verb naming for
  helpers (`filter_`, `arrange_`, etc.).
- Keep imports minimal: prefer `rlang::%||%` and base R over adding a
  new dependency.

## Before opening a PR

```r
devtools::document()                       # roxygen
devtools::test()                           # all tests pass
devtools::check(cran = TRUE)               # 0 errors, 0 warnings, 0 notes
spelling::spell_check_package()            # 0 issues
# For dashboard or translation changes:
# Rscript tools/check-bilingual.R
```

If you added a new function:
- export it in roxygen (`@export`)
- add it to `_pkgdown.yml` under the appropriate reference section
- describe the change and its motivation in the commit and PR; keep public documentation equivalent in Portuguese and English
- write at least one example in the roxygen block (CRAN runs them)

## Licensing

By contributing, you agree that your contribution will be released
under the **GPL (>= 3)** licence that covers the rest of the package.
Data contributions are released under **CC BY 4.0** unless the source
licence dictates otherwise (in which case, flag it explicitly in the
issue).
