# Contributing to educabr2

Thanks for considering a contribution. The fastest way to be useful
depends on what you have in mind.

## Quick map

| You want to… | Best path |
|----|----|
| Report a bug in a `get_*()` function | Open an [issue](https://github.com/mancano-tales/educabr2/issues/new) with a minimal reprex |
| Suggest a new data source | Open an issue first (see “Adding a dataset” below) — please **do not** open a PR cold |
| Propose a UX change to the dashboard | Open an issue with a screenshot or sketch |
| Fix a typo / improve docs | Send a PR straight away, no issue needed |
| Add tests for an existing function | Send a PR straight away |
| Discuss compatibility with [`educabR`](https://github.com/SidneyBissoli/educabR) | See [`planning/integration-educabR.md`](https://mancano-tales.github.io/educabr2/planning/integration-educabR.md) and chime in via issue |

The `planning/` folder lists everything queued for the package (roadmap,
CRAN checklist, datasets wishlist, integration designs). Skim it before
proposing something new — your idea may already be scoped, or live in a
related design doc.

## Adding a dataset

`educabr2` is opinionated about which data it ships. New sources are
welcome but they need:

1.  **A stable provenance** — DOI, archive link, or government portal
    URL that will not vanish next year.
2.  **A clear redistribution licence** — public domain, CC0, CC BY are
    straightforward; restrictive academic licences need explicit
    permission from the authors (paste correspondence in the issue).
3.  **A bibliographic citation** added to
    `inst/dict/vocabularies/sources.yaml` (the helper
    [`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.html)
    reads from there).
4.  **An ETL script** under `data-raw/NN_build_<dataset>.R` that takes
    the raw file, harmonises it to the canonical schema documented in
    `inst/dict/schema.yaml`, and writes a `data/<dataset>.rda`.
5.  **Validation** via `educabr2:::validate_against_schema()` (called at
    the end of the ETL script).
6.  **A test file** under `tests/testthat/test-<dataset>.R` with a
    fixture exercising the loader.

Open the issue with these six bullets in mind — we’ll iterate on the
design before any code is written.

## Code style

- Roxygen2 (markdown) for all exported functions.
- [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html) /
  [`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html)
  for user-facing errors; do not use base
  [`stop()`](https://rdrr.io/r/base/stop.html) /
  [`warning()`](https://rdrr.io/r/base/warning.html) for new code.
- snake_case for objects and functions; `dplyr`-style verb naming for
  helpers (`filter_`, `arrange_`, etc.).
- Keep imports minimal: prefer `rlang::%||%` and base R over adding a
  new dependency.

## Before opening a PR

``` r

devtools::document()                       # roxygen
devtools::test()                           # all tests pass
devtools::check(cran = TRUE)               # 0 errors, 0 warnings, 0 notes
spelling::spell_check_package()            # 0 issues
```

If you added a new function: - export it in roxygen (`@export`) - add it
to `_pkgdown.yml` under the appropriate reference section - add an entry
to `NEWS.md` under the development-version heading - write at least one
example in the roxygen block (CRAN runs them)

## Licensing

By contributing, you agree that your contribution will be released under
the **GPL (\>= 3)** licence that covers the rest of the package. Data
contributions are released under **CC BY 4.0** unless the source licence
dictates otherwise (in which case, flag it explicitly in the issue).
