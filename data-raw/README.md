# `data-raw/` — ETL pipeline for educabr

This directory is **not shipped with the installed package** (see
`.Rbuildignore`). It contains the raw source files (Excel/CSV) and the
build scripts that turn them into the canonical tidy tables consumed by
`R/get_*.R`.

## Layout

```
data-raw/
├── _manifest.yaml        # registry of all datasets (built artefacts + provenance)
├── README.md             # this file
├── 01_build_<name>.R     # one build script per dataset
├── 02_build_<name>.R
├── ...
├── 99_zenodo_release.R   # packages raw + processed for Zenodo release (M4)
├── sources/              # raw files, one subdirectory per source key
│   ├── paglayan_2022/
│   ├── pnad_ibge/
│   ├── anuario_ibge/
│   └── ...
└── schemas/              # optional per-dataset validation specs (pointblank)
```

The `source` keys under `sources/` must match keys declared in
`inst/dict/vocabularies/sources.yaml`.

## Build-script gabarito

Every `NN_build_*.R` script follows the same five steps. This keeps the
pipeline grep-friendly and makes a future automation pass straightforward.

```r
# 1. READ ---------------------------------------------------------------
raw <- readxl::read_excel(
  "data-raw/sources/<source_key>/<file>.xlsx",
  sheet = "<sheet>",
  col_types = c("numeric", "text", "numeric")
)

# 2. TIDY ---------------------------------------------------------------
# Reshape to the canonical long schema declared in inst/dict/schema.yaml.
# - one row per observation
# - alternative sources are SEPARATE ROWS, not columns
# - aggregations are explicit factor levels ("total"), not NA
tidy <- raw |>
  tidyr::pivot_longer(...) |>
  dplyr::transmute(
    year, geo_level = "BR", geo_code = "BR", geo_name = "Brasil",
    level = "fundamental", network = "total",
    indicator = "enrollment_rate", value, unit = "percent",
    source = "<source_key>",
    source_note = "<short citation>"
  )

# 3. VALIDATE -----------------------------------------------------------
# Check column types, factor domains, year range, no duplicate keys.
educabr:::validate_against_schema(tidy)  # to be implemented in M2

# 4. ANNOTATE -----------------------------------------------------------
attr(tidy, "educabr_meta") <- list(
  build_script = "data-raw/<this file>.R",
  built_at = Sys.time(),
  raw_sha256 = digest::digest(file = "data-raw/sources/<...>", algo = "sha256")
)

# 5. WRITE --------------------------------------------------------------
# Embedded dataset (small, ships with the package):
<dataset_name> <- tidy
usethis::use_data(<dataset_name>, overwrite = TRUE, compress = "xz")

# Or, for release-only datasets (large):
# saveRDS(tidy, "data-release/<dataset_name>.rds", compress = "xz")
```

After running the script, **update `_manifest.yaml`** with the dataset
entry (or refresh sha256 of raw files).
