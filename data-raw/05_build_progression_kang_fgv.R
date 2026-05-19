# 05_build_progression_kang_fgv.R
#
# ETL: grade-progression series (GDR6 — Gross Distribution Ratio for grade
# 6, defined as enrollment in grades 4-6 divided by enrollment in grades
# 1-3 of the old eight-year primary school) from the Kang/FGV-IBRE 2023
# compilation. Reads data-raw/sources/kang_fgv_ibre_2023/7._gdr6_1955_2010_
# v_abril2023.xlsx (sheets `Brasil` and `Estados`) and produces the tibble
# `progression_kang_fgv` saved to data/progression_kang_fgv.rda.
#
# Coverage:
#   * BR national, 1955-2010
#   * UF level (all 27 federation units), 1955-2010
#
# Run from the package root:
#   source("data-raw/05_build_progression_kang_fgv.R")

library(dplyr)
library(readxl)

stopifnot(file.exists("DESCRIPTION"))

src_file <- "data-raw/sources/kang_fgv_ibre_2023/7._gdr6_1955_2010_v_abril2023.xlsx"

SOURCE_KEY  <- "kang_paese_felix_2021"
SOURCE_NOTE <- "Kang, Paese & Felix (2021). RHE 39(2):191-218. doi:10.1017/S0212610921000112"

UF_NAMES <- c(
  AC = "Acre",            AL = "Alagoas",       AM = "Amazonas",
  AP = "Amapá",           BA = "Bahia",         CE = "Ceará",
  DF = "Distrito Federal", ES = "Espírito Santo", GO = "Goiás",
  MA = "Maranhão",        MG = "Minas Gerais",  MS = "Mato Grosso do Sul",
  MT = "Mato Grosso",     PA = "Pará",          PB = "Paraíba",
  PE = "Pernambuco",      PI = "Piauí",         PR = "Paraná",
  RJ = "Rio de Janeiro",  RN = "Rio Grande do Norte",
  RO = "Rondônia",        RR = "Roraima",       RS = "Rio Grande do Sul",
  SC = "Santa Catarina",  SE = "Sergipe",       SP = "São Paulo",
  TO = "Tocantins"
)

base_cols <- function(df) {
  dplyr::mutate(df,
    level       = "fundamental_anos_iniciais",
    network     = "total",
    dim_race    = "total",
    age_group   = NA_character_,
    indicator   = "gross_distribution_ratio_grade_6",
    unit        = "ratio",
    source      = SOURCE_KEY,
    source_note = SOURCE_NOTE
  )
}

# ---------------------------------------------------------------------
# Sheet 'Brasil' — national series
# ---------------------------------------------------------------------

build_br <- function() {
  raw <- readxl::read_excel(src_file, sheet = "Brasil",
                            col_names = FALSE, skip = 1)
  names(raw) <- c("year", "value")
  raw |>
    dplyr::filter(!is.na(year), !is.na(value)) |>
    dplyr::mutate(
      year      = as.integer(year),
      geo_level = "BR",
      geo_code  = "BR",
      geo_name  = "Brasil"
    ) |>
    base_cols()
}

# ---------------------------------------------------------------------
# Sheet 'Estados' — UF-level series
# ---------------------------------------------------------------------

build_uf <- function() {
  raw <- readxl::read_excel(src_file, sheet = "Estados",
                            col_names = FALSE, skip = 1)
  names(raw) <- c("year", "uf", "value")
  raw |>
    dplyr::mutate(
      year = as.integer(year),
      uf   = toupper(trimws(as.character(uf)))
    ) |>
    dplyr::filter(!is.na(year), !is.na(value), uf %in% names(UF_NAMES)) |>
    dplyr::mutate(
      geo_level = "UF",
      geo_code  = uf,
      geo_name  = unname(UF_NAMES[uf])
    ) |>
    dplyr::select(-uf) |>
    base_cols()
}

# ---------------------------------------------------------------------
# Combine, validate, write
# ---------------------------------------------------------------------

progression_kang_fgv <- dplyr::bind_rows(build_br(), build_uf()) |>
  dplyr::select(
    year, geo_level, geo_code, geo_name,
    level, network, dim_race, age_group,
    indicator, value, unit,
    source, source_note
  ) |>
  dplyr::arrange(geo_level, geo_code, year) |>
  tibble::as_tibble()

cat("Built rows:", nrow(progression_kang_fgv), "\n")
print(dplyr::count(progression_kang_fgv, geo_level))

educabr:::validate_against_schema(progression_kang_fgv, theme = "progression")

attr(progression_kang_fgv, "educabr_meta") <- list(
  build_script   = "data-raw/05_build_progression_kang_fgv.R",
  built_at       = Sys.time(),
  primary_source = SOURCE_KEY,
  citation       = SOURCE_NOTE,
  raw_files      = src_file
)

usethis::use_data(progression_kang_fgv, overwrite = TRUE, compress = "xz")
