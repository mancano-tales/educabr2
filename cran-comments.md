## Resubmission

This is a resubmission of `educabr2` (now version 0.1.3). In response to
the review of 0.1.1 (Konstanze Lauseker, 2026-09-24):

* **Acronyms in the Description.** Every acronym is now spelled out:
  INEP (National Institute for Educational Studies and Research), PNAD
  (National Household Sample Survey) and IBGE (Brazilian Institute of
  Geography and Statistics); the Censo Escolar, Censo da Educação
  Superior (CENSUP), Censo Demográfico and Anuário Estatístico are given
  by their English names.
* **Examples wrapped in `if(FALSE)`.** The examples of
  `get_expenditure()` and `get_progression()` used `@examplesIf FALSE`;
  they now run unconditionally (all together take < 0.5 s). No example
  in the package is wrapped in `if(FALSE)` or `\dontrun{}`.
* **Installing packages in `inst/dashboard/global.R`.** The dashboard no
  longer installs anything: if `educabr2` is missing it stops with an
  error telling the user how to install it.

Other changes since 0.1.1: data corrections (no double counting in the
Lee & Lee attainment shares and in the tertiary enrollment panel), a
stricter schema validator, and a cleaner `educabr_cite(style = "text")`.

## Test environments

* Local Windows 11, R 4.6.0 (release): `R CMD build` +
  `R CMD check --as-cran` on the tarball, PDF manual built with TinyTeX
  — 0 errors, 0 warnings, 1 note ("New submission")
* GitHub Actions (all with `--no-manual`):
  - ubuntu-latest (devel, release, oldrel-1)
  - macos-latest (release)
  - windows-latest (devel, release)

## R CMD check results

0 errors | 0 warnings | 1 note

* "New submission". The incoming check may also list proper nouns
  (Kang, Paese, Menetrier, Censo, CENSUP, ...) as possibly misspelled.

## Reverse dependencies

None (first release).

## Notes for the reviewer

* Source size is ~0.3 MB; the six packaged datasets total ~80 KB on
  disk (compressed `.rda`).
* No external network access at runtime; no system-level dependencies.
* `Suggests:` lists Shiny, plotly, DT, bslib, and scales for the
  bundled dashboard (`run_dashboard()`); none are loaded unless the
  user invokes the dashboard.
* Vignettes are knitted in English and Portuguese.
