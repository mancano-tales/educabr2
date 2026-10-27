# Integration analysis: Sidney Bissoli's `educabR`

## Decisão vigente / Current decision — 2026-10-27

**PT.** Por decisão do autor no chat, a proposta externa foi retirada:
SidneyBissoli/educabR#29 está fechada e seu corpo foi substituído por uma
nota curta de retirada. O planejamento fica na
[issue #8 do educabr2](https://github.com/mancano-tales/educabr2/issues/8).
O texto original permanece no rascunho versionado e no comentário histórico
da issue #8. Fechar uma issue não remove seu histórico público.

O objetivo imediato é melhorar a cobertura e a qualidade das séries que o
autor já organizou e entregá-las pelas funções existentes. A construção de
um importador geral das sinopses originais não é pré-requisito. O catálogo
do INEP mistura XLS, PDF e ZIP; a extração reproduzida de 2002 cobre um
recorte de duas tabelas e não demonstra cobertura automática de 1995–2008.
O ETL principal já parte da compilação tratada do autor.

Os seis arquivos de `data/` somam 176.468 bytes no checkout inspecionado.
Manter esses dados pequenos e estáveis embutidos no pacote é a recomendação
atual: consultas offline, versão fixada e nenhuma nova infraestrutura.
Esses arquivos são uma entrega versionada, não um cache descartável.

Se o volume ou a frequência de atualização justificarem, avaliar uma
publicação separada dos dados tratados (CSV comprimido e/ou RDS), com
manifesto, esquema, versão, checksum, proveniência, citação e arquivamento.
Só nesse caso um cache local do usuário passa a ser necessário. A consulta
comum não deve baixar novamente os documentos oficiais; a atualização de
dados deve ser explícita e preservar versões fixadas.

A ampliação deve passar pelos registros internos e funções `get_*()`
pertinentes, sem criar uma função apenas para nomear cada fonte. Proveniência,
transformações manuais, unidades, sobreposições e totais derivados continuam
explícitos. Uma futura integração ao educabR deve preservar a granularidade:
agregados históricos não podem ser misturados silenciosamente a microdados.

Primeiro preparar uma entrega local testada e documentada em PT/EN; depois
avaliar uma proposta concreta ao Sidney. Conversar com o INEP sobre formatos
e acesso melhores é uma possibilidade futura, sem bloquear a entrega e sem
contato iniciado nesta rodada. Não há compromisso aprovado de nova função,
mudança de licença, fusão ou manutenção upstream.

**EN.** At the author's request in this chat, the external proposal was
withdrawn: SidneyBissoli/educabR#29 is closed and its body is now a short
withdrawal note. Planning moves to
[educabr2 issue #8](https://github.com/mancano-tales/educabr2/issues/8).
The original text is preserved in the versioned draft and an issue comment.
Closing an issue does not remove its public history.

Improve the coverage and quality of the author's existing curated series
and deliver them through existing functions. A general importer of original
synopses is not a prerequisite. INEP's catalogue mixes XLS, PDF and ZIP;
the reproduced 2002 extraction covers parts of two tables, not all of
1995–2008. The main ETL already starts from the curated compilation.

The six `data/` files total 176,468 bytes in the inspected checkout. Keeping
small, stable data bundled is the current recommendation: offline access,
pinned versions and no additional infrastructure. These are versioned
package data, not a disposable cache.

If size or update frequency warrants it, assess a separate distribution of
curated data (compressed CSV and/or RDS), with manifest, schema, version,
checksum, provenance, citation and archiving. Only then is a persistent user
cache needed. Routine queries should not download the original documents;
updates should be explicit and preserve pinned versions.

Extend the relevant internal registries and `get_*()` functions without
adding a new function for each source. Preserve provenance, manual
transformations, units, overlaps and derived totals. Future integration
with educabR must preserve granularity: do not silently mix historical
aggregates with microdata.

First deliver tested, documented work in PT/EN, then consider a concrete
proposal to Sidney. A future INEP discussion about formats and access may
be useful, but does not block delivery and no contact was initiated here.
No new function, license change, merger or upstream maintenance obligation
is approved by this decision.

> As análises abaixo são históricas e ficam superadas onde conflitarem com
> esta decisão. / The analyses below are historical and superseded where
> they conflict with this decision.

> **Reassessment, 2026-10-26** (supersedes the scenarios below where they
> conflict; the original 2026-05 analysis is kept underneath).

## 2026-10 reassessment: contributing to `educabR` instead of competing

### What changed since May

- `educabR` is now **1.2.0 on CRAN** (lifecycle *stable*, codecov, Zenodo
  DOI 10.5281/zenodo.19410201), with a single, responsive maintainer:
  issues are answered and closed within days (#18 accepted a README
  credit to an older package; #21 became a fix in a week).
- Its scope statement is explicit: *data comes straight from the agencies
  at call time*; column names and values stay in Portuguese, as the agency
  publishes them. The repository has **no `data/` directory**: every
  function downloads, caches and parses.
- `educabr2` 0.1.2 is ready for CRAN (the 2026-09-24 review is answered),
  but it is still a new package with one letter of difference from a
  stable package aimed at the same users.

### Why the earlier "architectures are incompatible" verdict was too strong

It assumed a **code merge**: one namespace, one schema, every function
rewritten. That is costly and nobody needs it. The two packages can be
joined at the **data** level instead, along the line `educabR` already
draws (download at call time):

1. **Agency data I built for the thesis goes into `educabR` as ordinary
   `educabR` functions**, in Sidney's style (Portuguese names, download +
   cache). The obvious first one is the *Sinopse Estatística da Educação
   Superior* 1995–2008: `get_censo_superior()` starts in 2009, and the
   Sinopse xlsx files are on INEP's site. Other candidates must pass the
   same test (published by INEP, FNDE, CAPES or STN): e.g. federal
   higher-education spending (`2026-10_Gasto-Federal-ES`).
2. **The harmonised long-run series become a dataset with a DOI**
   (versioned GitHub release + Zenodo), built by this repository's
   `data-raw/` ETL. `educabR` gets one function, e.g.
   `get_series_historicas(tema = "matriculas")`, that downloads and caches
   that release — exactly how it treats an INEP file. No bundled data, no
   new heavy dependency, no change to its architecture.
3. **This repository stays** as the place where the series are built,
   tested and documented (ETL, schema validation, decision log, dashboard).
   Whether it also goes to CRAN becomes optional.

### What this costs and what it buys

| | Stay separate (CRAN `educabr2`) | Contribute to `educabR` |
|---|---|---|
| Reach | New package, zero installs | Users who already have `educabR` |
| Naming confusion | `educabR` vs `educabr2` persists | Gone |
| Maintenance | Two CRAN packages for one field | One; I become `ctb`/`aut` |
| Control | Full | Sidney decides scope, style, release dates |
| Credit | Package of my own | Author role in an established package + DOI for the data |
| Schema | Canonical English tidy-long | Must follow `educabR` conventions (Portuguese) in the functions he hosts; the DOI dataset can keep the canonical schema |

**Licence** is no longer a blocker: I own the `educabr2` code and can
license what I contribute as MIT (check with Victor Alcantara for any code
he wrote). The real constraint is the **data**: the Kang et al.
compilations are redistributed either way, so their terms need to be
checked once, for both paths.

### Risks

- Sidney may decline: curated academic reconstructions are outside his
  stated scope ("straight from the agencies"). Item 2 is the one most
  likely to be refused; item 1 is squarely in scope.
- Depending on someone else's release calendar near the thesis deposit.
- The dashboard does not fit in `educabR`; it stays here.

### Recommended sequence

1. Open an issue on `SidneyBissoli/educabR` (in Portuguese) proposing
   items 1 and 2, with this table and an offer to write and maintain the
   code. **Needs the author's go-ahead** (outward-facing).
2. In parallel, keep `educabr2` 0.1.2 ready to resubmit. If Sidney accepts
   item 2, CRAN becomes optional; if he declines or does not answer in
   about two weeks, resubmit.
3. Whatever the answer, start item 1 (Sinopse 1995–2008) as a PR to
   `educabR`: it is useful to him in any scenario and opens the
   collaboration with working code rather than a proposal.

> **Repo**: <https://github.com/SidneyBissoli/educabR>
> **CRAN**: <https://CRAN.R-project.org/package=educabR>
> **Version inspected**: 0.9.0 (2026-05)
> **License**: MIT

This document compares `mancano-tales/educabr2` (this package) with
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
