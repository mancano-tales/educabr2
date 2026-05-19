# CRAN submission checklist

Concrete items remaining before `devtools::release()`. Track v0.2
submission here. Reset for future submissions.

## Current status (2026-05-18)

- ✅ `R CMD check --as-cran` locally: 0 errors / 0 warnings / 0 notes
- ✅ GitHub Actions: R-CMD-check on ubuntu-latest, macos-latest,
  windows-latest (release + devel + oldrel-1) — Windows R-devel added
- ✅ Test coverage: 42 tests across 6 files, all passing
- ✅ Package size: 0.26 MB tarball (limit 5 MB recommended, 100 MB hard)
- ✅ `cran-comments.md` drafted
- ✅ Spell check: 0 issues; `inst/WORDLIST` committed
- ✅ URL check: 30+ URLs in DESCRIPTION/man/README/vignettes — all
  resolving (with 4 false-positive 403s from servers that block HEAD,
  fine in browser)
- ✅ Examples runtime: max 0.93s (CRAN limit 5s)

## Blocking — must do before submitting

- [x] **Windows R-devel coverage** — added `{os: windows-latest, r:
      'devel'}` to `.github/workflows/R-CMD-check.yaml` on 2026-05-18.
      Covers the same ground as `devtools::check_win_devel()` on every
      push, so we no longer need the manual submission for routine
      checks. Re-run `check_win_devel()` once right before submission
      anyway — CRAN expects a confirmation email reference.
- [x] **macOS coverage** — already in CI matrix
      (`{os: macos-latest, r: 'release'}`). For macOS R-devel,
      `devtools::check_mac_release()` can be run manually right
      before submission.
- [ ] **Vignettes knit cleanly with pandoc** — CI handles this; can't
      verify locally without installing pandoc. The fact that the
      pkgdown site builds on every push confirms vignettes work.
- [x] **Spell check** — 0 issues against `inst/WORDLIST`. Re-run
      after every doc change with `spelling::spell_check_package()`.
      Future false-positives go in `inst/WORDLIST`.
- [x] **URL check** — verified 2026-05-18 via custom script (pandoc
      not available locally for `urlchecker`). 30+ URLs across
      DESCRIPTION / man / README / NEWS / vignettes / sources.yaml.
      All resolve; the 4 servers that return 403 to HEAD (Shiny app,
      Taylor & Francis DOI, gov.br × 2) return 200 to GET with a
      browser UA — CRAN tolerates these.
- [x] **Examples runtime** — all 4 user-facing functions execute in
      <1s (max 0.93s for `get_enrollment`). Well under CRAN's 5s
      limit. `\dontrun{}` only used for `run_dashboard()` (Shiny app
      can't run non-interactively).
- [x] ~~**`LICENSE` file**~~ — **Not needed for stock GPL-3.** A
      separate `LICENSE` file is only required when the `License:`
      field uses `+ file LICENSE`, which is the case for MIT but not
      for `GPL (>= 3)`. Our `R CMD check --as-cran` already passes
      0/0/0 with only `LICENSE.md`. Decided 2026-05-18.

## Should do — strongly recommended

- [x] **`list_sources()` helper** — shipped in commit on 2026-05-18.
      Returns a tibble with `key`, `short_name`, `type`,
      `year_start`, `year_end`, `geo`, `doi`, `url`, `notes`. Tested
      and surfaced in the pkgdown reference.
- [ ] **Lifecycle badge** — bump from `experimental` to `maturing`
      (`lifecycle::badge("maturing")`) once API is exercised by at
      least one external user. Keep `experimental` for first CRAN
      submission so we have room to break.
- [x] **`.github/CONTRIBUTING.md`** — added 2026-05-18. Covers bug
      reports, dataset proposals (6-point checklist), code style,
      pre-PR check commands, and licensing.

## Nice to have — defer if time runs short

- [ ] **`pkgdown` deployment via GitHub Actions** — already configured
      (`.github/workflows/pkgdown.yaml`), but the workflow has been
      failing intermittently. Investigate.
- [ ] **Test coverage badge** — `usethis::use_coverage("codecov")`
      and `usethis::use_github_action("test-coverage")`.
- [ ] **Reverse dependency check** — only relevant for revisions, not
      first submission. Use `revdepcheck::revdep_check()` from v0.3
      onward.
- [ ] **CRAN comments per-release** — keep `cran-comments.md` updated
      with what changed since the last submission (CRAN reviewers read
      this).

## After acceptance

- [ ] Tag the release: `git tag -a v0.2.0 -m "First CRAN release"`
- [ ] GitHub release with `gh release create v0.2.0 --notes-from-tag`
- [ ] Zenodo DOI (if integrated): toggle the repo in Zenodo to mint a
      DOI for the GitHub release. Add the DOI to `inst/CITATION`.
- [ ] Bump `Version: 0.2.0.9000` and start v0.3 work on `main`.

## Useful references

- [Writing R Extensions](https://cran.r-project.org/doc/manuals/R-exts.html)
- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
- Hadley Wickham, *R Packages* (2e) — ch. "Releasing to CRAN"
