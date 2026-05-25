# Integration analysis: Sidney Bissoli's `educabR`

> **Repo**: <https://github.com/SidneyBissoli/educabR>
> **CRAN**: <https://CRAN.R-project.org/package=educabR>
> **Version inspected**: 0.9.0 (2026-05)
> **License**: MIT

This document compares `mancano-tales/educabr` (this package) with
`SidneyBissoli/educabR` and sketches plausible paths from "two
parallel packages" to "shared ecosystem" or "merged package".

## Side-by-side

| Dimension | `educabr2` (Mançano) | `educabR` (Bissoli) |
|---|---|---|
| **Status** | 0.1.0, pre-CRAN | 0.9.0, on CRAN, stable |
| **License** | GPL (>= 3) | MIT |
| **Focus** | Harmonised long-run series | On-demand INEP microdata |
| **Time horizon** | 1871-2024 | 1995-2024 (mostly) |
| **API axis** | By **theme/indicator** (`get_enrollment`, `get_schooling`) | By **source** (`get_ideb`, `get_enem`, `get_censo_escolar`, ...) |
| **N user functions** | 4 | ~17 |
| **Architecture** | Bundled `.rda` + filter | Download + cache + parse |
| **Datasets** | 3 bundled, harmonised | 14 sources, fetched on demand |
| **Schema** | Canonical tidy-long (`geo_code`, `indicator`, `value`, `source`) | Source-native column names per dataset |
| **Dashboard** | Yes (`run_dashboard()`) | No |
| **Naming convention** | `get_*()` | `get_*()` ✓ shared |

## Where the packages **agree**

- Both target Brazilian education researchers in R.
- Both use `get_*()` naming and return tidy tibbles.
- Both use `roxygen2` + `testthat` + `pkgdown` + lifecycle badges.
- Both depend on `cli` / `rlang`.
- Both eschew Stata/Excel as a deliverable — pure R objects.

## Where they **diverge** (and why a naive merge fails)

### 1. Licence incompatibility

`educabR` is MIT, `educabr2` is GPL-3. A merged codebase can use either
license, but **GPL is "infectious"** — combining MIT code with GPL
code produces a GPL deliverable. This forces all existing MIT users
to accept the stricter copyleft terms, which they didn't sign up for.

> **Decision needed if merging:** either (a) Sidney relicenses
> `educabR` as GPL-3, or (b) this package relicenses to MIT, or (c) we
> keep two licences in one repo by namespace (unusual, fragile).

### 2. Schema-vs-source axis

The two packages organise the API along **orthogonal** axes:

- `educabR::get_ideb(year=2023, level="estado", stage="anos_iniciais")`
  → wraps INEP's IDEB download; columns mirror INEP.
- `educabr2::get_enrollment(level="fundamental", indicator="rate")`
  → harmonised across **multiple** sources; columns mirror our schema.

A merged API would need to expose both "give me the INEP IDEB table
verbatim" and "give me a harmonised indicator that happens to use
IDEB among its inputs". That is two different mental models for the
same word `get_*()`.

### 3. Schema differences

`educabR` returns tibbles with source-native columns
(`uf_sigla`, `municipio_codigo`, `rede`, `indicador`, `valor`).
`educabr2` returns the canonical schema documented in
`inst/dict/schema.yaml`: `geo_level`, `geo_code`, `geo_name`,
`network`, `indicator`, `value`, `source`, `unit`, `dim_*`.

For a merge, one of three options:

- (i) Adopt the `educabr2` canonical schema; rewrite `educabR`'s 14
  functions to emit it. **Most consistent**, biggest refactor.
- (ii) Adopt source-native schemas; drop the canonical layer.
  **Easiest** but loses the cross-source comparability that motivates
  `educabr2`.
- (iii) Two output modes per function (`tidy = TRUE` default,
  `tidy = FALSE` for native). **Compromise** but doubles the test
  surface.

## Integration scenarios

### Scenario A — Independent siblings (default; current state)

Two packages, no shared code. Cross-reference each other in READMEs.
**Cost**: zero. **Benefit**: each can move at its own pace.

### Scenario B — `educabr2` Suggests `educabR`

`educabr2` ships `get_*()` functions that, for recent years, delegate
to `educabR::get_*()` for the raw fetch and then transform to the
canonical schema. `educabR` listed in `Suggests:`, lazy-loaded only
when the user asks for an indicator that needs INEP microdata.

**Pros**: no duplication of download/parse code; user installs
`educabR` only if they need post-2014 indicators.
**Cons**: dependency on someone else's release cadence; need a
`educabR ↔ educabr2` schema adapter (~200 lines).

### Scenario C — Merged package

One repo, one CRAN entry. All `get_*()` functions live in one
namespace. Requires resolving (1), (2), (3) above.

**Pros**: single install, single namespace, no API surface confusion.
**Cons**: 2 maintainers' release calendars need to sync; one of us
loses authorship credit on past versions.

## Recommended path (v0.3 → v1.0)

1. **v0.3**: implement Scenario B for IDEB and SAEB only.
   Demonstrate the adapter pattern in a vignette ("Joining
   harmonised series with recent INEP indicators").
2. **v0.4**: open an issue on `educabR` asking whether Sidney is
   interested in (a) relicensing to GPL or (b) a co-maintained
   "umbrella" repo. If yes → start Scenario C planning. If no →
   stay on Scenario B.
3. **v1.0**: if no merge, document the relationship explicitly in
   both READMEs ("`educabR` for recent INEP downloads, `educabr2` for
   harmonised long-run series — both speak the same `get_*()`
   convention and can be used together").

## Open questions

- [ ] Reach out to Sidney before v0.2 release to coordinate naming
      and avoid user confusion ("educabr2" vs "educabR" — one letter,
      same audience).
- [ ] Should the package consider renaming to disambiguate
      (`educabr2.brasil`? `educabr2.historica`?)? Renames are cheap
      pre-CRAN, expensive post-CRAN.
