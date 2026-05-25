# Datasets wishlist

Candidate data sources to incorporate, ranked by **(1) value added to
the harmonised series**, **(2) licensing clarity**, **(3) maintenance
cost**.

For each candidate, the format is:

> **Source**
> - **Adds**: what new coverage / breakdown / period
> - **License**: free-to-redistribute? attribution?
> - **Ingestion**: bundled `.rda` vs on-demand fetcher
> - **Status**: not-started / scoped / in-progress / shipped

---

## Tier 1 — high value, low friction

### PNAD Contínua (IBGE) via `PNADcIBGE`

- **Adds**: extends `schooling_kang_fgv` (which ends in 2015) up to
  the present quarter. Brings literacy, age-at-grade, NEET back as
  optional indicators.
- **License**: PNADc microdata is public domain; CC0-equivalent.
- **Ingestion**: on-demand via `PNADcIBGE::get_pnadc()` (CRAN). First
  non-bundled data path for the package.
- **Status**: scoped — see [`integration-pnadc.md`](integration-pnadc.md).

### PNAD (legacy, 1967-2015) via `PNADIBGE`

- **Adds**: closes the gap between the Kang historical series and PNAD
  Contínua with comparable household-survey methodology.
- **License**: same as PNADc.
- **Ingestion**: on-demand via `PNADIBGE::get_pnad()`.
- **Status**: not-started.

### Censo Demográfico (IBGE) — 1872, 1890, 1900, ..., 2010, 2022

- **Adds**: long-run literacy and schooling-attainment at high
  geographic granularity (municipality level for recent waves).
  Authoritative for inequality cuts (race × sex × urban-rural).
- **License**: public domain.
- **Ingestion**: hybrid — historical waves (pre-2000) ship as bundled
  `.rda` (IBGE compilations); 2010/2022 via SIDRA API (`sidrar`).
- **Status**: not-started. Tooling exists (`sidrar` is on CRAN), but
  series harmonisation across 150 years is non-trivial.

---

## Tier 2 — useful, medium friction

### IDEB (INEP) via `educabR::get_ideb()`

- **Adds**: school-quality indicator 2017-onward; complements the
  enrollment-volume focus of `educabr2` with a learning-outcome axis.
- **License**: INEP public data.
- **Ingestion**: via Sidney Bissoli's `educabR` (CRAN) as a Suggested
  dependency — avoids reimplementing download/parse logic.
- **Status**: not-started. Needs a decision on whether to wrap or to
  cite `educabR` as a sibling. See
  [`integration-educabR.md`](integration-educabR.md).

### Censo Escolar (INEP) — agregados anuais

- **Adds**: continuous annual coverage of enrollment by network /
  modality / dependency at municipality level, 1995-onward. Currently
  the package's tertiary panel uses CENSUP (higher ed only); Censo
  Escolar would mirror that for basic education.
- **License**: INEP public data (CC BY).
- **Ingestion**: via `educabR::get_censo_escolar()` (microdata, large)
  + aggregation step shipped with `educabr2`.
- **Status**: not-started.

### SAEB (INEP)

- **Adds**: learning assessment by school/year/subject, 2011-onward.
- **License**: INEP public data.
- **Ingestion**: via `educabR::get_saeb()` or direct download +
  aggregation.
- **Status**: not-started.

---

## Tier 3 — speculative / aspirational

### Paglayan (2022) — historical primary enrollment

- **Adds**: alternative historical series for cross-validation
  against Kang. Already referenced in `sources.yaml`
  (`paglayan_2022`) but no rows in the bundled datasets.
- **License**: Harvard Dataverse, CC0.
- **Ingestion**: bundled `.rda`.
- **Status**: source documented, data not ingested.

### Lee & Lee (2016) — cross-country schooling

- **Adds**: international comparators for mean years of schooling.
- **License**: research use; check redistribution terms.
- **Ingestion**: bundled `.rda` (small dataset).
- **Status**: not-started. Probably out of scope for a Brazil-focused
  package, but useful for a vignette comparing Brazil to peers.

### FNDE / FUNDEB — education funding

- **Adds**: financing axis (currently absent). Per-student spending
  by network and UF.
- **License**: STN / FNDE public data.
- **Ingestion**: via `educabR::get_fundeb_*()` or direct.
- **Status**: not-started.

---

## How to propose a new dataset

1. Open a GitHub issue with the source name in the title.
2. Fill in the four bullets above (Adds / License / Ingestion / Status).
3. Reference any existing R packages or APIs that already wrap it.
4. If accepted, add an entry here and link the issue.

Quality bar: every dataset must come with **provenance** (DOI or stable
URL), a **bibliographic citation** (added to `sources.yaml`), and a
clear **licence** statement (so we can document redistribution in
`LICENSE.md`).
