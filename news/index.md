# Changelog

## educabr2 0.1.2

### 2026-09-26 — Governança comum do ecossistema (v2026-09-26c)

Aplicado o bloco de governança comum mantido no hub
(`mancano-tales/mancano-repo-hub`, `tools/governanca-comum/`): planos
com issue (`tools/plano_issue.py`), aprovação só no chat e no plano,
mensagens de agentes como pedido, cabeçalho de agente, branch/PR
opcionais, `NEWS.md` junto com a mudança, **datas sem hora** e
**exportar conversa só quando o autor pedir**. O bloco fica entre
marcadores no `AGENTS.md`; o que é específico deste repositório foi
preservado.

**Metadados de Execução**: - **Data**: 2026-09-26 - **Agente**: Claude
Code / Claude Opus 5.5 / Claude Code on the web, via
`tools/sync_governanca.py` do hub - **Mensagem do Commit**:
“docs(governance): governanca comum v2026-09-26c” - **Arquivos
afetados**: AGENTS.md, CLAUDE.md, NEWS.md, tools/plano_issue.py,
.claude/settings.json

### 2026-09-26 — Hook de lembrete de issue (governança comum)

O `.gitignore` impedia versionar `.claude/settings.json`, então o hook
de lembrete de issue do pacote de governança comum não tinha entrado.
Corrigido: a regra `.claude/` virou `.claude/*` +
`!.claude/settings.json` (arquivos locais como `settings.local.json`
seguem ignorados); o hook `PostToolUse` (`tools/plano_issue.py hook`)
foi acrescentado.

**Metadados de Execução**: - **Data**: 2026-09-26 - **Agente**: Claude
Code / Claude Opus 5.5 / desktop (hub) - **Mensagem do Commit**:
“chore(governance): versiona .claude/settings.json e hook de issue” -
**Arquivos afetados**: .gitignore, .claude/settings.json, NEWS.md

### 2026-09-26 — Governança comum do ecossistema (v2026-09-26)

Aplicado o bloco de governança comum mantido no hub
(`mancano-tales/mancano-repo-hub`, `tools/governanca-comum/`): planos
com issue (`tools/plano_issue.py`), aprovação só no chat e no plano,
mensagens de agentes como pedido, cabeçalho de agente, branch/PR
opcionais, `NEWS.md` junto com a mudança e **datas sem hora**. O bloco
fica entre marcadores no `AGENTS.md`; o que é específico deste
repositório foi preservado.

- .claude/settings.json ignorado pelo .gitignore do repo; hook não
  aplicado

**Metadados de Execução**: - **Data**: 2026-09-26 - **Agente**: Claude
Code / Claude Opus 5.5 / desktop, via `tools/sync_governanca.py` do
hub - **Mensagem do Commit**: “docs(governance): governanca comum
v2026-09-26” - **Arquivos afetados**: AGENTS.md, CLAUDE.md, NEWS.md,
tools/plano_issue.py, .claude/settings.json

### Bug fixes

- `lee_lee_2016` (and therefore
  [`get_attainment()`](https://mancano-tales.github.io/educabr2/reference/get_attainment.md))
  overstated the primary and secondary attainment shares for every
  country, year and sex. The build script treated Lee & Lee’s
  “completed” columns (`lpc`, `lsc`, `lhc`) as categories separate from
  the highest-level-attended shares (`lp`, `ls`, `lh`), when they are
  subsets of them, so completers were counted twice. Shares are now
  computed as primary = `lpc + ls + lh`, secondary = `lsc + lh`,
  tertiary = `lhc`. Tertiary values are unchanged. Some countries
  previously showed values above 100; all values now lie in \[0, 100\].
  For Brazil (total, 15-64) primary in 1990/2000/2010 falls from
  63.6/92.2/118.6 to 52.6/70.6/83.7, and secondary from 16.4/28.2/44.7
  to 12.9/23.9/38.2.
- The build script now checks that `lu + lp + ls + lh` sums to 100 and
  that every built share is in \[0, 100\]; a new test asserts the bounds
  and that primary \>= secondary \>= tertiary.
- `get_enrollment(level = "superior")` returned every 1933-2010 value
  from Kang, Paese & Felix (2021) twice: the series was bundled both in
  `enrollment_kang_fgv` and in `enrollment_tertiary`. It now lives only
  in `enrollment_kang_fgv`; `enrollment_tertiary` keeps Kang only as the
  in-person component of derived rows.
- Kang’s tertiary counts for 2000-2008 cover in-person enrollment only
  (they match INEP Sinopse’s presencial figures exactly). These rows in
  `enrollment_kang_fgv` now carry `modality = "presencial"` instead of
  `"total"`.
- `enrollment_tertiary` repeated the INEP Sinopse figures for 1999 and
  2001 under two table references. The repeated rows are merged, with
  both references kept in `source_note`. The 2001 duplicate had halved
  the EAD share shown in the dashboard’s Overview tab.
- INEP microdata rows for 2012-2024 counted “Especial” institutions
  (art. 242 CF) as private. INEP’s Power BI panel counts them as public
  municipal. They are now moved to `municipal` and `publica`, so
  `privada = privada_lucrativa + privada_nao_lucrativa` holds and the
  microdata agree with the Power BI panel cell by cell (e.g. public
  enrollment in 2012 rises from 1 775 359 to 1 897 818).
- Durham (2005) is no longer bundled in `enrollment_tertiary`. It is a
  secondary source whose Table 1 does not add up as printed (public +
  private != total in 1945, 1960, 1965 and 2001; the 1965 total, 352
  096, is more than twice every other source’s 155 781), and every year
  it covers is also covered by the primary sources it compiles. Derived
  rows built on Durham were dropped with it, and the `durham_2005` key
  was removed from the source vocabulary.
- `validate_against_schema()` now rejects `NA` and negative values. New
  tests assert that the enrollment panel has no duplicate observations
  and that INEP tertiary networks add up.
- Documentation: `schooling_kang_fgv` covers 20 UFs, not 27; the
  `enrollment_kang_fgv` page now lists its 16 columns and its three real
  source keys.

## educabr2 0.1.1

CRAN resubmission after the 0.1.0 incoming pre-test.

- Fixed the PDF manual build: two roxygen comments used the Unicode
  glyph `≥` (U+2265), which R’s Rd-to-LaTeX converter cannot map;
  replaced with ASCII `>=`. A new test (`test-rd-latex-safe.R`) scans
  the Rd database for LaTeX-unsafe math glyphs so this cannot recur.
- README now links the licence to the GPL-3 page instead of the
  `LICENSE.md` file that `.Rbuildignore` excludes from the tarball (CRAN
  flagged the dangling relative URI).
- Authorship: Artur Damião is no longer listed as a contributor; the
  README citation block was updated accordingly.
- `DESCRIPTION` now cites the four academic compilations in CRAN’s
  `authors (year) <doi:...>` form, and the `enrollment_kang_fgv` help
  page points to the correct DOI for Kang, Paese & Felix (2021).

## educabr2 0.1.0

First CRAN release. Six themes (enrollment, tertiary enrollment,
schooling, expenditure, progression, attainment), the visualization
toolkit
([`theme_educabr()`](https://mancano-tales.github.io/educabr2/reference/theme_educabr.md),
Okabe-Ito scales,
[`scale_x_year_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_x_year_educabr.md)),
citation helpers
([`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md),
[`list_sources()`](https://mancano-tales.github.io/educabr2/reference/list_sources.md)),
and the bundled Shiny dashboard.

### Overview tab and documentation corrections (2026-07-12)

- New curated **Overview** tab in the Shiny dashboard, now the landing
  tab: four fixed story charts for non-technical audiences (secular
  expansion 1908-2024; public vs. private networks with the 1997/2005
  regulatory landmarks annotated; the EAD share reaching majority in
  2024; the 1983 gender reversal in schooling), with active titles,
  direct line labels, and no controls. The exploratory apparatus remains
  in the six thematic tabs.
- Documentation correction (fact-checked against Walter & Kang 2024,
  Economic History of Developing Regions): the mean-years-of-schooling
  series refers to the population **aged 15 to 64** (not 25+);
  [`get_schooling()`](https://mancano-tales.github.io/educabr2/reference/get_schooling.md)
  and `schooling_kang_fgv` docs updated, and the state/region coverage
  (1950-2015) made explicit.

### CI and documentation convergence (2026-07-11, second round)

- Fixed the failing CI: `showtext` and `sysfonts` (used conditionally by
  [`theme_educabr()`](https://mancano-tales.github.io/educabr2/reference/theme_educabr.md))
  are now declared in Suggests; `ggplot2` was promoted from Suggests to
  Imports (the visualization components are public API); the
  `%+replace%` operator is now namespace-qualified.
- Fixed the failing pkgdown build: the visualization functions
  (`theme_educabr`, `scale_educabr`, `scale_x_year_educabr`) are now
  listed in a “Visualization” group of the reference index.
- New vignette `visualization.Rmd` documenting the plotting toolkit
  (theme, `plot_titles`, Okabe-Ito scales, historical year axis, palette
  reference).
- Vignettes updated to match the current package: five-function API
  (with
  [`get_attainment()`](https://mancano-tales.github.io/educabr2/reference/get_attainment.md)
  and a new international-comparison case), six dashboard tabs, the
  deduplication hierarchy, the `dimension` asymmetries,
  [`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md)
  demos, and the correct version.
- README: six dashboard tabs, deduplication hierarchy and validation
  notes, fixed moved/404 URLs; dashboard About now points to the
  documentation site and mentions the visualization system and citation
  helpers.

### Visualization system (2026-07-11)

- New exported scale
  [`scale_x_year_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_x_year_educabr.md)
  — a year-axis scale for the century-long historical series that are
  the norm in the package. Break spacing follows the span of the data
  plotted (every 20 years beyond six decades, every 10 years for spans
  of 25–60 years, [`pretty()`](https://rdrr.io/r/base/pretty.html)
  breaks below that); the first and last year present in the series are
  always labelled, and grid breaks that would collide with those
  extremes are dropped (tolerance proportional to the span).
- The Shiny dashboard (live charts and the “View R code” snippets) now
  uses the package’s own visualization system —
  [`theme_educabr()`](https://mancano-tales.github.io/educabr2/reference/theme_educabr.md),
  [`scale_colour_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_educabr.md)
  (Okabe-Ito, applied where the colour dimension has at most 8 levels),
  and
  [`scale_x_year_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_x_year_educabr.md)
  — instead of
  [`theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
  and generic pretty breaks.

### Source-key aliases (2026-07-11)

- `walter_kang_2024` is now accepted everywhere `walter_kang_2023` is
  (all `get_*()` source filters and
  [`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md)),
  resolving to the same source. The peer-reviewed article is Walter &
  Kang (2024, *Economic History of Developing Regions*); the legacy
  `2023` key — minted when the source was still an FGV-IBRE working
  paper — remains the key carried by the data until the physical rename
  planned in `planning/cran-checklist.md`.

### CI / build

- Renamed vignettes from `01-introduction.Rmd` / `02-introducao-pt.Rmd`
  to `introduction.Rmd` / `introducao-pt.Rmd` — the numeric-prefix
  pattern triggered an `R CMD check --as-cran` WARNING about invalid
  file names in `inst/doc`, which had been breaking the CI matrix since
  the dashboard-tabs push.
  [`vignette("introduction", "educabr2")`](https://mancano-tales.github.io/educabr2/articles/introduction.md)
  and
  [`vignette("introducao-pt", "educabr2")`](https://mancano-tales.github.io/educabr2/articles/introducao-pt.md)
  are now the canonical entry points (the pkgdown URLs follow the new
  names too).
- `inst/WORDLIST` extended with the new technical vocabulary (`GDR6`,
  `regressivity`, `Unitless`, …) and the PT-BR terms introduced in Case
  5 / Case 6 of the vignettes — spell check is clean again.

### New themes & datasets

- `expenditure_kang_fgv` — 1,170 rows. Public expenditure on education,
  Brazil, 1933-2010 (Kang & Menetrier 2024). Four indicators:
  `expenditure_share_gdp`, `expenditure_per_student_pct_gdp_pc`, and the
  two “double ratio” indicators of fiscal regressivity
  (`expenditure_double_ratio_es_ef1`,
  `expenditure_double_ratio_es_ef_em`).
- `progression_kang_fgv` — 1,090 rows. Grade-progression ratio GDR6
  (enrollment in grades 4-6 / grades 1-3 of the old eight-year primary
  system), BR + 20 UFs, 1955-2010 (Kang, Paese & Felix 2021).

### New public API

- [`get_expenditure()`](https://mancano-tales.github.io/educabr2/reference/get_expenditure.md)
  — long-format access to the public-expenditure series. Supports
  indicator aliases (`"share_gdp"`, `"per_student"`,
  `"double_ratio_es_ef1"`, `"double_ratio_es_ef_em"`).
- [`get_progression()`](https://mancano-tales.github.io/educabr2/reference/get_progression.md)
  — long-format access to grade-progression indicators. Supports
  indicator alias `"gdr6"`. Filters by `geo_level` / `geo` like
  [`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md).

### Schema additions (additive only)

- New `level` value: `fundamental_medio` (EF + EM combined; appears in
  expenditure data).
- New `unit` values: `percent_gdp` and `percent_gdp_per_capita`
  (alongside the existing `percent`, `ratio`, `years`, `count`).
- `inst/dict/vocabularies/indicators.yaml` gains entries for every
  indicator emitted by the new datasets, with PT-BR translations
  surfaced in `inst/dict/i18n.yaml`.

### Dashboard

- Two new navbar tabs: **Public Expenditure** and **Grade Progression**,
  built on top of
  [`get_expenditure()`](https://mancano-tales.github.io/educabr2/reference/get_expenditure.md)
  and
  [`get_progression()`](https://mancano-tales.github.io/educabr2/reference/get_progression.md).
  Each tab carries the standard educabr2 layout — sidebar filters,
  series plot (plotly), table view (DT), source cards, CSV download, and
  a “View R code” modal that emits a reproducible educabr2 + ggplot2 +
  plotly snippet.

### Other changes

- [`list_sources()`](https://mancano-tales.github.io/educabr2/reference/list_sources.md)
  — new helper returning a tibble of every entry in the source
  vocabulary (key, short_name, type, coverage, DOI, URL, notes).
  Discovery counterpart to
  [`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md).
- [`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
  /
  [`get_schooling()`](https://mancano-tales.github.io/educabr2/reference/get_schooling.md):
  examples now run during `R CMD check` (previously skipped with
  `@examplesIf FALSE`).
- CI: added `windows-latest, r: 'devel'` to the R-CMD-check matrix —
  covers what `check_win_devel()` does, on every push.
- Docs: `.github/CONTRIBUTING.md`, `inst/WORDLIST` for clean spell
  checks, abbreviation “anos inic.” → “anos iniciais” in
  `enrollment_kang_fgv` Rd table for readability.

## educabr2 0.1.0

First public release. Initial set of harmonised long-run series on
Brazilian education plus a bundled Shiny dashboard.

### Datasets

- `enrollment_kang_fgv` — 6,238 rows. Brazilian school enrollment counts
  and gross rates by stage (EF1, EF2, EF, EM, ES), 1933-2010 at national
  level and 1955-2010 at UF level, with breakdown by colour/race
  1960-2010. Per-paper source attribution (`kang_paese_felix_2021`,
  `kang_menetrier_2024`, `kang_menetrier_comim_2024`).

- `enrollment_tertiary` — 1,341 rows. Brazilian tertiary enrollment
  1907-2024 compiled across seven primary sources: IBGE *Estatísticas do
  Século XX*, Durham (2005), Maduro Junior (2007), Kang/Paese/Felix
  (2021), INEP CENSUP Synopsis (1995-2008), INEP CENSUP Microdata
  (2009-2024), and the INEP CENSUP Power BI panel. Multiple sources per
  year-network are kept on purpose to support cross-source comparison.
  Includes 25 *reconstructed total* rows (`is_derived = TRUE`) that fill
  the 2000-2008 transition period where INEP published in-person and EAD
  enrollment separately.

- `schooling_kang_fgv` — 2,287 rows. Mean years of schooling for the
  adult population, 1925-2015 (BR), 1950-2015 (region, UF), with sex and
  race breakdowns at BR level (Walter & Kang 2024).

### API

- [`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
  — long-format access to enrollment series with filters for `level`,
  `network`, `institution_type`, `modality`, `year`, `geo_level`/`geo`,
  `dimension`, `indicator`, `source`, `include_derived`. Returns the
  canonical schema with English labels (`lang = "en"`) or PT-BR labels
  (`lang = "pt"`).

- [`get_schooling()`](https://mancano-tales.github.io/educabr2/reference/get_schooling.md)
  — long-format access to the mean-years-of-schooling series with
  filters for `year`, `geo_level`/`geo`, `dimension`, `source`, `lang`.

- [`run_dashboard()`](https://mancano-tales.github.io/educabr2/reference/run_dashboard.md)
  — launches the bundled Shiny dashboard locally.

- [`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md)
  — builds `bibentry` objects (or APA-style prose, or BibTeX) for any of
  the harmonised data sources, driven by the controlled vocabulary in
  `inst/dict/vocabularies/sources.yaml`.

- [`list_sources()`](https://mancano-tales.github.io/educabr2/reference/list_sources.md)
  — returns a tibble describing every entry in the source vocabulary
  (key, type, temporal/geographic coverage, DOI, URL). Discovery
  counterpart to
  [`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md).

### Dashboard

- Three-theme navbar (English UI): Enrollment, Tertiary Education,
  Educational Attainment.
- Tertiary Education tab features multi-source comparison with
  interaction-based colour palette (each source × modality combination
  gets a unique colour shade), shape-by-source, and linetype-by-modality
  encoding.
- “View R code” button on every tab generates a self-contained,
  copy-pasteable R snippet (educabr2 + ggplot2) that reproduces the
  current chart locally.

### Schema

- Canonical *tidy-long* schema documented in `inst/dict/schema.yaml`
  with primary-key constraints, year domain, controlled vocabularies for
  factor levels, and conventions for missing values.
- 13 primary source entries documented in
  `inst/dict/vocabularies/sources.yaml` with DOIs, URLs, and coverage
  metadata.
- PT-BR labels for every factor level in `inst/dict/i18n.yaml`.

### Build pipeline

- `data-raw/01_build_enrollment_kang_fgv.R` — Kang/FGV-IBRE 2023
  compilation (4 xlsx files → enrollment_kang_fgv.rda).
- `data-raw/02_build_schooling_kang_fgv.R` — Walter & Kang 2024 series
  (1 xlsx file → schooling_kang_fgv.rda).
- `data-raw/03_build_enrollment_tertiary.R` — multi-source tertiary
  compilation, with canonicalisation of 69 raw source strings into 7
  canonical keys and 4 composite derived-row keys, plus exact-duplicate
  deduplication.

### Tests

- 9 tests for
  [`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
  (core filters and pivots).
- 9 tests for
  [`get_schooling()`](https://mancano-tales.github.io/educabr2/reference/get_schooling.md).
- 7 tests for the tertiary-specific arguments (`institution_type`,
  `modality`, `include_derived`, composite source keys, loader
  normalisation of legacy datasets).
