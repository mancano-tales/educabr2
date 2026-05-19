# 04_build_expenditure_kang_fgv.R
#
# ETL: public education expenditure series from the Kang/FGV-IBRE 2023
# compilation. Reads data-raw/sources/kang_fgv_ibre_2023/5._despesa_pub_educ_
# 1933_2010_v_abril2023.xlsx (sheet `dados_valores`) and produces a single
# tibble `expenditure_kang_fgv` saved to data/expenditure_kang_fgv.rda.
#
# Coverage produced:
#   * BR national, public expenditure as share of GDP, 1933-2010
#     (EF1, EF2, EF, EM, fundamental+medio, ES, total)
#   * BR national, per-student public expenditure as share of GDP per capita,
#     1933-2010 (EF1, EF2, EF, EM, fundamental+medio, ES)
#   * BR national, "double ratio" between per-student ES and per-student
#     EF1 (and between ES and EF+EM), 1933-2010
#
# Run from the package root:
#   source("data-raw/04_build_expenditure_kang_fgv.R")

library(dplyr)
library(tidyr)
library(readxl)

stopifnot(file.exists("DESCRIPTION"))

src_file <- "data-raw/sources/kang_fgv_ibre_2023/5._despesa_pub_educ_1933_2010_v_abril2023.xlsx"

SOURCE_KEY  <- "kang_menetrier_2024"
SOURCE_NOTE <- "Kang & Menetrier (2024). Estudos Econômicos 54(3). doi:10.1590/1980-53575434tkim"

# ---------------------------------------------------------------------
# READ
# ---------------------------------------------------------------------

raw <- readxl::read_excel(
  src_file,
  sheet     = "dados_valores",
  col_names = FALSE,
  skip      = 1
)

# Column order (left to right) — taken from row 1 of `dados_valores`.
names(raw) <- c(
  "year",
  "share_gdp_ef1", "share_gdp_ef2", "share_gdp_ef", "share_gdp_em",
  "share_gdp_fundmed", "share_gdp_es", "share_gdp_total",
  "per_student_ef1", "per_student_ef2", "per_student_ef", "per_student_em",
  "per_student_fundmed", "per_student_es",
  "double_ratio_es_ef1", "double_ratio_es_fundmed"
)

raw <- raw |>
  dplyr::filter(!is.na(year)) |>
  dplyr::mutate(year = as.integer(year))

# ---------------------------------------------------------------------
# TIDY: split into three blocks — one per indicator family — pivot to
# long, recode level codes to the educabr vocabulary.
# ---------------------------------------------------------------------

level_recode <- c(
  ef1     = "fundamental_anos_iniciais",
  ef2     = "fundamental_anos_finais",
  ef      = "fundamental",
  em      = "medio",
  fundmed = "fundamental_medio",
  es      = "superior",
  total   = "total"
)

# share of GDP — has a "total" (educação total) column
share_gdp <- raw |>
  dplyr::select(year, dplyr::starts_with("share_gdp_")) |>
  tidyr::pivot_longer(-year, names_to = "key", values_to = "value",
                      values_drop_na = TRUE) |>
  dplyr::mutate(
    level     = unname(level_recode[sub("^share_gdp_", "", key)]),
    indicator = "expenditure_share_gdp",
    unit      = "percent_gdp"
  ) |>
  dplyr::select(-key)

# per-student spending — there is no system-wide "total" series
per_student <- raw |>
  dplyr::select(year, dplyr::starts_with("per_student_")) |>
  tidyr::pivot_longer(-year, names_to = "key", values_to = "value",
                      values_drop_na = TRUE) |>
  dplyr::mutate(
    level     = unname(level_recode[sub("^per_student_", "", key)]),
    indicator = "expenditure_per_student_pct_gdp_pc",
    unit      = "percent_gdp_per_capita"
  ) |>
  dplyr::select(-key)

# double ratios — system-wide comparisons; level = "total"
double_ratio <- raw |>
  dplyr::select(year, double_ratio_es_ef1, double_ratio_es_fundmed) |>
  tidyr::pivot_longer(c(double_ratio_es_ef1, double_ratio_es_fundmed),
                      names_to = "key", values_to = "value",
                      values_drop_na = TRUE) |>
  dplyr::mutate(
    level     = "total",
    indicator = dplyr::recode(key,
      double_ratio_es_ef1     = "expenditure_double_ratio_es_ef1",
      double_ratio_es_fundmed = "expenditure_double_ratio_es_ef_em"
    ),
    unit = "ratio"
  ) |>
  dplyr::select(-key)

expenditure_kang_fgv <- dplyr::bind_rows(share_gdp, per_student, double_ratio) |>
  dplyr::mutate(
    geo_level   = "BR",
    geo_code    = "BR",
    geo_name    = "Brasil",
    network     = "publica",     # public-sector expenditure only
    dim_race    = "total",
    age_group   = NA_character_,
    source      = SOURCE_KEY,
    source_note = SOURCE_NOTE
  ) |>
  dplyr::select(
    year, geo_level, geo_code, geo_name,
    level, network, dim_race, age_group,
    indicator, value, unit,
    source, source_note
  ) |>
  dplyr::arrange(indicator, level, year) |>
  tibble::as_tibble()

# ---------------------------------------------------------------------
# VALIDATE
# ---------------------------------------------------------------------

cat("Built rows:", nrow(expenditure_kang_fgv), "\n")
print(dplyr::count(expenditure_kang_fgv, indicator, level))

educabr:::validate_against_schema(expenditure_kang_fgv, theme = "expenditure")

# ---------------------------------------------------------------------
# ANNOTATE + WRITE
# ---------------------------------------------------------------------

attr(expenditure_kang_fgv, "educabr_meta") <- list(
  build_script   = "data-raw/04_build_expenditure_kang_fgv.R",
  built_at       = Sys.time(),
  primary_source = SOURCE_KEY,
  citation       = SOURCE_NOTE,
  raw_files      = src_file
)

usethis::use_data(expenditure_kang_fgv, overwrite = TRUE, compress = "xz")
