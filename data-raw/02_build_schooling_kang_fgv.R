# 02_build_schooling_kang_fgv.R
#
# ETL: mean years of schooling — Walter & Kang (2023) via FGV-IBRE 2023 compilation.
# Reads data-raw/sources/kang_fgv_ibre_2023/3._anos_estudo_1925_2015_v_abril2023.xlsx
# and produces `schooling_kang_fgv` saved to data/schooling_kang_fgv.rda.
#
# Coverage:
#   * BR total, 1925-2015
#   * BR by sex (male/female), 1925-2015
#   * BR by race, 1925-2015
#   * Macro-region (N, NE, CO, SE, S), 1950-2015
#   * UF, 1950-2015
#
# Run from the package root:
#   source("data-raw/02_build_schooling_kang_fgv.R")

library(dplyr)
library(readxl)

stopifnot(file.exists("DESCRIPTION"))

src_file    <- "data-raw/sources/kang_fgv_ibre_2023/3._anos_estudo_1925_2015_v_abril2023.xlsx"
SOURCE_KEY  <- "walter_kang_2023"
SOURCE_NOTE <- paste(
  "Walter, J., & Kang, T. H. (2023).",
  "A new dataset of average years of schooling in Brazil, 1925-2015.",
  "FGV-IBRE working paper."
)

# ---------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------

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

REGION_NAMES <- c(
  N  = "Norte",
  NE = "Nordeste",
  CO = "Centro-Oeste",
  SE = "Sudeste",
  S  = "Sul"
)

recode_cor <- function(x) {
  x <- tolower(trimws(as.character(x)))
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")
  dplyr::recode(x,
    "branca"   = "white",
    "preta"    = "black",
    "parda"    = "brown",
    "amarela"  = "asian",
    "indigena" = "indigenous",
    .default   = NA_character_
  )
}

recode_genero <- function(x) {
  x <- tolower(trimws(as.character(x)))
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")
  dplyr::recode(x,
    "masculino" = "male",
    "feminino"  = "female",
    .default    = NA_character_
  )
}

base_cols <- function(df) {
  dplyr::mutate(df,
    indicator   = "mean_years_schooling",
    unit        = "years",
    age_group   = NA_character_,
    source      = SOURCE_KEY,
    source_note = SOURCE_NOTE
  )
}

# ---------------------------------------------------------------------
# Sheet 1: Populacao_Total — BR, total (no breakdown)
# ---------------------------------------------------------------------

build_total_br <- function() {
  raw <- readxl::read_excel(src_file, sheet = "Populacao_Total",
                            col_names = FALSE, skip = 1)
  names(raw) <- c("year", "value")
  raw |>
    dplyr::filter(!is.na(year), !is.na(value)) |>
    dplyr::mutate(
      year     = as.integer(year),
      geo_level = "BR", geo_code = "BR", geo_name = "Brasil",
      dim_race  = "total",
      dim_sex   = "total"
    ) |>
    base_cols()
}

# ---------------------------------------------------------------------
# Sheet 2: Genero — BR, by sex
# ---------------------------------------------------------------------

build_bysex_br <- function() {
  raw <- readxl::read_excel(src_file, sheet = "Genero",
                            col_names = FALSE, skip = 1)
  names(raw) <- c("year", "value", "genero")
  raw |>
    dplyr::mutate(
      year    = as.integer(year),
      dim_sex = recode_genero(genero)
    ) |>
    dplyr::filter(!is.na(year), !is.na(value), !is.na(dim_sex)) |>
    dplyr::mutate(
      geo_level = "BR", geo_code = "BR", geo_name = "Brasil",
      dim_race  = "total"
    ) |>
    dplyr::select(-genero) |>
    base_cols()
}

# ---------------------------------------------------------------------
# Sheet 3: Cor — BR, by race
# ---------------------------------------------------------------------

build_byrace_br <- function() {
  raw <- readxl::read_excel(src_file, sheet = "Cor",
                            col_names = FALSE, skip = 1)
  names(raw) <- c("year", "value", "cor")
  raw |>
    dplyr::mutate(
      year     = as.integer(year),
      dim_race = recode_cor(cor)
    ) |>
    dplyr::filter(!is.na(year), !is.na(value), !is.na(dim_race)) |>
    dplyr::mutate(
      geo_level = "BR", geo_code = "BR", geo_name = "Brasil",
      dim_sex   = "total"
    ) |>
    dplyr::select(-cor) |>
    base_cols()
}

# ---------------------------------------------------------------------
# Sheet 4: UF — state level
# ---------------------------------------------------------------------

build_byuf <- function() {
  raw <- readxl::read_excel(src_file, sheet = "UF",
                            col_names = FALSE, skip = 1)
  names(raw) <- c("year", "value", "uf")
  raw |>
    dplyr::mutate(
      year = as.integer(year),
      uf   = toupper(trimws(as.character(uf)))
    ) |>
    dplyr::filter(!is.na(year), !is.na(value), uf %in% names(UF_NAMES)) |>
    dplyr::mutate(
      geo_level = "UF",
      geo_code  = uf,
      geo_name  = unname(UF_NAMES[uf]),
      dim_race  = "total",
      dim_sex   = "total"
    ) |>
    dplyr::select(-uf) |>
    base_cols()
}

# ---------------------------------------------------------------------
# Sheet 5: Macro_Regiao — macro-region level
# ---------------------------------------------------------------------

build_byregion <- function() {
  raw <- readxl::read_excel(src_file, sheet = "Macro_Regiao",
                            col_names = FALSE, skip = 1)
  names(raw) <- c("year", "value", "regiao")
  raw |>
    dplyr::mutate(
      year   = as.integer(year),
      regiao = toupper(trimws(as.character(regiao)))
    ) |>
    dplyr::filter(!is.na(year), !is.na(value), regiao %in% names(REGION_NAMES)) |>
    dplyr::mutate(
      geo_level = "region",
      geo_code  = regiao,
      geo_name  = unname(REGION_NAMES[regiao]),
      dim_race  = "total",
      dim_sex   = "total"
    ) |>
    dplyr::select(-regiao) |>
    base_cols()
}

# ---------------------------------------------------------------------
# Combine, validate, write
# ---------------------------------------------------------------------

schooling_kang_fgv <- dplyr::bind_rows(
  build_total_br(),
  build_bysex_br(),
  build_byrace_br(),
  build_byuf(),
  build_byregion()
) |>
  dplyr::select(
    year, geo_level, geo_code, geo_name,
    dim_race, dim_sex,
    age_group, indicator, value, unit,
    source, source_note
  ) |>
  dplyr::arrange(geo_level, geo_code, dim_race, dim_sex, year) |>
  tibble::as_tibble()

cat("Built rows:", nrow(schooling_kang_fgv), "\n")
print(dplyr::count(schooling_kang_fgv, geo_level, dim_race, dim_sex))

educabr2:::validate_against_schema(schooling_kang_fgv, theme = "schooling")

attr(schooling_kang_fgv, "educabr_meta") <- list(
  build_script   = "data-raw/02_build_schooling_kang_fgv.R",
  built_at       = Sys.time(),
  primary_source = SOURCE_KEY,
  citation       = SOURCE_NOTE,
  raw_files      = "data-raw/sources/kang_fgv_ibre_2023/3._anos_estudo_1925_2015_v_abril2023.xlsx"
)

usethis::use_data(schooling_kang_fgv, overwrite = TRUE, compress = "xz")
