## Resubmission

This is a resubmission of `educabr2` (now version 0.1.1) after the
incoming pre-test of 0.1.0 (2026-09-13) reported 1 ERROR, 1 WARNING
and NOTEs. Changes in response:

* **PDF manual (ERROR/WARNING on both flavours).** Two Rd files
  contained the Unicode glyph U+2265 ("greater than or equal"), which
  the Rd-to-LaTeX converter cannot map. Replaced with ASCII `>=` in the
  roxygen sources; a regression test now scans the Rd database for
  LaTeX-unsafe math glyphs. `R CMD Rd2pdf` and `R CMD check --as-cran`
  (with manual) now pass locally.
* **Invalid file URI `LICENSE.md` from `README.md` (NOTE).** The README
  now links to <https://www.gnu.org/licenses/gpl-3.0.html>; the local
  `LICENSE.md` is excluded from the tarball by `.Rbuildignore`.
* **Non-standard file `educabr2-manual.tex` (NOTE, Debian).** Left
  behind by the failed manual build; resolved by the fix above.
* **Possibly misspelled words in DESCRIPTION (NOTE).** All flagged words
  are proper nouns: Brazilian statistical sources and institutions
  (Censo Escolar, PNAD, Censo Demográfico, Anuário Estatístico, IBGE,
  INEP, CENSUP, FGV, IBRE) and author surnames (Kang). The Windows
  flavour additionally reports fragments ("fico", "rio", "stico") that
  are the same accented words split at the non-ASCII character.
* Authorship: one contributor was removed at his own request.

## Test environments

* Local Windows 11, R 4.6.0 (release), `R CMD check --as-cran` with
  the PDF manual — 0 errors, 0 warnings, 0 notes
* GitHub Actions:
  - ubuntu-latest (devel, release, oldrel-1)
  - macos-latest (release)
  - windows-latest (devel, release)

## R CMD check results

0 errors | 0 warnings | 0 notes

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
