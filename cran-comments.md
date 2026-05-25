## Submission

This is the first CRAN submission of `educabr2` (version 0.1.0).

The package provides curated long-run series on Brazilian formal
education (enrollment by stage and network 1871–2010 from the
Kang/FGV-IBRE compilation; tertiary enrollment 1907–2024 combining INEP
microdata with academic sources; mean years of schooling 1925–2015
from Walter & Kang) in a single tidy schema with explicit per-row
provenance, plus a bundled Shiny dashboard.

## Test environments

* Local Windows 11, R 4.6.0 (release) — 0 errors, 0 warnings, 0 notes
* GitHub Actions:
  - ubuntu-latest (devel, release, oldrel-1)
  - macos-latest (release)
  - windows-latest (release)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

None (first release).

## Notes for the reviewer

* Source size is 0.26 MB; the three packaged datasets total 52 KB on
  disk (compressed `.rda`).
* No external network access at runtime; no system-level dependencies.
* `Suggests:` lists Shiny, plotly, DT, bslib, and scales for the
  bundled dashboard (`run_dashboard()`); none are loaded unless the
  user invokes the dashboard.
* Vignettes are knitted in English and Portuguese.
