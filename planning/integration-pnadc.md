# Integration design: PNAD Contínua via `PNADcIBGE`

> **External package**: `PNADcIBGE` (CRAN)
>   <https://CRAN.R-project.org/package=PNADcIBGE>
> **IBGE portal**: <https://www.ibge.gov.br/estatisticas/sociais/trabalho/9171-pesquisa-nacional-por-amostra-de-domicilios-continua-mensal.html>
> **Target version**: educabr2 v0.3
> **Status**: scoped, not implemented

## Why

`schooling_kang_fgv` stops in 2015. After that, the canonical
household-survey source for educational attainment in Brazil is PNAD
Contínua. Extending the series to the current quarter (a) keeps the
package relevant for present-day analyses, and (b) introduces the
first **on-demand fetcher** path to educabr2 — which is foundational
infrastructure for v0.4+ (Censo Demográfico 2022, IDEB, etc.).

## What the user should see

```r
# Stays the same — bundled Kang series, ends in 2015
get_schooling(geo_level = "BR")

# New: explicit opt-in to PNADc, extends through latest available quarter
get_schooling(geo_level = "BR",
              source = c("walter_kang_2024", "pnadc_ibge"))

# Or just PNADc, recent years only
get_schooling(source = "pnadc_ibge", year = c(2020, 2024))
```

When PNADc is requested for the first time, the package downloads
the relevant quarters via `PNADcIBGE::get_pnadc()`, computes the
mean-years-of-schooling indicator, caches the result, and returns it
in the canonical schema. Subsequent calls hit the cache.

## Design decisions

### 1. Bundled vs on-demand

PNADc microdata is ~500 MB per quarter; bundling is out. **On-demand
download with disk cache** is the only realistic option.

- Cache location: `tools::R_user_dir("educabr2", "cache")` (XDG-compliant,
  cross-platform, survives package reinstall).
- Cache key: `pnadc_<year>_<quarter>.rds` storing the **aggregated
  indicator** (a tibble of ~6 rows: BR × age_group × year), not the
  raw microdata.
- Cache invalidation: never, unless the user calls
  `educabr_clear_cache("pnadc")`.

### 2. CRAN compatibility

CRAN forbids tests that hit the network or write outside `tempdir()`.
Solutions:

- Wrap network calls in `if (interactive() && pnadc_available())`
  guards.
- Real download tests in `tests/testthat/skip-on-cran.R` (run on
  GitHub Actions, skipped on CRAN).
- Unit-test the aggregation logic with a **fixture** of mock
  PNADc-like microdata (10-50 rows) — same pattern we already use
  for `get_enrollment` / `get_schooling` tests.

### 3. Dependency management

Add to `Suggests:`, not `Imports:`:

```
Suggests:
    PNADcIBGE
```

Then in `get_schooling.R`:

```r
if (any(source == "pnadc_ibge") &&
    !requireNamespace("PNADcIBGE", quietly = TRUE)) {
  cli::cli_abort(c(
    "PNADcIBGE source requested but the package isn't installed.",
    i = "Run {.code install.packages(\"PNADcIBGE\")}."
  ))
}
```

This keeps the base install of `educabr2` lightweight (no transitive
deps from PNADcIBGE unless the user opts in).

### 4. Indicator computation

The Walter & Kang "mean years of schooling" indicator uses a specific
recoding of grade-completed to years (e.g., EJA blocks count as their
nominal grade). PNADc has the comparable variable `VD3005` (anos de
estudo). For comparability with the pre-2015 Kang series:

- Use `VD3005` directly (it already encodes years of completed
  schooling).
- Apply the same age filter Kang uses (population 25+).
- Weight with `V1028` (sample weight).
- Aggregate to year (mean of all four quarters).

Validation: the pooled 2015 PNADc estimate should land within ±0.1
years of Kang's 2015 value. If not, document the gap explicitly in a
vignette section ("Why PNADc and Kang diverge at the boundary").

### 5. Source vocabulary entry

Already drafted in `inst/dict/vocabularies/sources.yaml`:

```yaml
pnadc_ibge:
  short_name: PNAD Contínua
  full_name: Pesquisa Nacional por Amostra de Domicílios Contínua. IBGE.
  type: official_survey
  url: https://www.ibge.gov.br/estatisticas/sociais/trabalho/9171-...
  coverage: { years: [2012, null], geo: [BR, region, UF] }
```

`educabr_cite("pnadc_ibge")` already works for this key.

## Implementation outline (estimated 1-2 days)

- [ ] `R/get_schooling_pnadc.R` — internal `.fetch_pnadc_schooling()`
  function: downloads, aggregates, caches.
- [ ] Extend `get_schooling()` to dispatch on `source`: if
  `"pnadc_ibge"` requested, call the new fetcher and merge with the
  bundled Kang panel.
- [ ] `R/cache.R` — minimal cache layer (`.educabr_cache_dir()`,
  `.educabr_cache_get()`, `.educabr_cache_set()`,
  `educabr_clear_cache()`).
- [ ] `tests/testthat/test-get-schooling-pnadc.R` — fixture-based
  unit test of the aggregator.
- [ ] `tests/testthat/test-pnadc-live.R` — live download, with
  `skip_on_cran()` and `skip_if_offline()`.
- [ ] `vignettes/03-extending-with-pnadc.Rmd` — walk-through of the
  workflow.
- [ ] DESCRIPTION: add `PNADcIBGE` to Suggests; bump version to 0.3.0.

## Open questions

- [ ] Do we expose age_group as a filter (currently the Kang series is
  always "25+")? Adds power but increases the API surface.
- [ ] PNADc has quarterly granularity but Kang is annual. Do we
  return only annual aggregates, or expose `frequency = c("annual",
  "quarterly")`? Annual matches the legacy series; quarterly is more
  faithful to PNADc.
- [ ] Should we also pull literacy (`V3001 == 1`) as a separate
  indicator, since it's almost-free given the same download? Probably
  yes — defer to v0.4.
