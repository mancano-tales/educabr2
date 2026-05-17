# 01_build_enrollment_kang_fgv.R
#
# ETL: enrollment series from the Kang/FGV-IBRE 2023 compilation.
# Reads four xlsx files under data-raw/sources/kang_fgv_ibre_2023/ and
# produces a single tibble `enrollment_kang_fgv` saved to
# data/enrollment_kang_fgv.rda.
#
# Coverage produced:
#   * BR national, ensino primário (anos iniciais), 1871-2010 — counts only.
#   * BR national, all stages (EF1, EF2, EF, EM, ES), 1933-2010 — counts and rates.
#   * BR national, all stages broken down by color/race, 1960-2010 — counts and rates.
#   * UF level, ensino fundamental (EF1, EF2, EF), 1955-2010 — counts and rates.
#
# Run from the package root:
#   source("data-raw/01_build_enrollment_kang_fgv.R")
#
# Requires the package itself to be installed (or loaded via
# `devtools::load_all()`) so that `educabr:::validate_against_schema()`
# is available.

library(dplyr)
library(tidyr)
library(readxl)

stopifnot(file.exists("DESCRIPTION"))  # run from package root

src_dir     <- "data-raw/sources/kang_fgv_ibre_2023"
SOURCE_KEY  <- "kang_fgv_ibre_2023"
SOURCE_NOTE <- paste(
  "Kang, Paese & Felix (2021), Late and Unequal,",
  "Revista de Historia Económica 39(2):191-218.",
  "FGV/IBRE compilation refreshed Apr 2023."
)

# ---------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------

# Canonical IBGE UF code -> Portuguese name (used to fill geo_name when
# the source carries only the 2-letter code).
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

# IBGE color/race PT label -> canonical English level used in the schema.
recode_cor <- function(x) {
  x <- tolower(trimws(as.character(x)))
  # Strip accents so "indígena" and "indigena" both work.
  x <- iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")
  dplyr::recode(x,
    "branca"    = "white",
    "preta"     = "black",
    "parda"     = "brown",
    "amarela"   = "asian",
    "indigena"  = "indigenous",
    .default    = NA_character_
  )
}

# ---------------------------------------------------------------------
# File 1 — National primary enrollment 1871-2010 (counts only)
# ---------------------------------------------------------------------

build_primary_br <- function() {
  raw <- readxl::read_excel(
    file.path(src_dir, "1._matricula_primario_1871_2010_v_abril2023.xlsx"),
    sheet = "dados_matricula",
    col_types = c("numeric", "numeric")
  )
  names(raw) <- c("year", "value")

  raw |>
    dplyr::filter(!is.na(year), !is.na(value)) |>
    dplyr::mutate(
      year        = as.integer(year),
      geo_level   = "BR", geo_code = "BR", geo_name = "Brasil",
      level       = "fundamental_anos_iniciais",
      network     = "total",
      dim_race    = "total",
      age_group   = NA_character_,
      indicator   = "enrollment_count",
      unit        = "count",
      source      = SOURCE_KEY,
      source_note = paste(
        SOURCE_NOTE,
        "Sheet `dados_matricula`: ensino primário histórico (~anos iniciais)."
      )
    )
}

# ---------------------------------------------------------------------
# File 4 — National enrollment by stage 1933-2010
# Columns (15): year + 5 counts (EF1, EF2, EF, EM, ES) +
#                       6 rates (EF1 7-10, EF1 7-11, EF2, EF, EM, ES) +
#                       3 pops (7-10, 7-11, 11-14).
# ---------------------------------------------------------------------

build_stages_br <- function() {
  raw <- readxl::read_excel(
    file.path(src_dir, "4._matricula_txmatriculas_1933_2010_v_abril2023.xlsx"),
    sheet = "dados_matricula",
    col_names = FALSE,
    skip = 1
  )
  names(raw) <- c(
    "year",
    "count_ef1", "count_ef2", "count_ef", "count_em", "count_es",
    "rate_ef1_7_10", "rate_ef1_7_11", "rate_ef2", "rate_ef", "rate_em", "rate_es",
    "pop_7_10", "pop_7_11", "pop_11_14"
  )

  counts <- raw |>
    dplyr::select(year, dplyr::starts_with("count_")) |>
    tidyr::pivot_longer(-year, names_to = "key", values_to = "value",
                        values_drop_na = TRUE) |>
    dplyr::mutate(
      level = dplyr::recode(key,
        count_ef1 = "fundamental_anos_iniciais",
        count_ef2 = "fundamental_anos_finais",
        count_ef  = "fundamental",
        count_em  = "medio",
        count_es  = "superior"
      ),
      indicator = "enrollment_count",
      unit      = "count",
      age_group = NA_character_
    ) |>
    dplyr::select(-key)

  rates <- raw |>
    dplyr::select(year, dplyr::starts_with("rate_")) |>
    tidyr::pivot_longer(-year, names_to = "key", values_to = "value",
                        values_drop_na = TRUE) |>
    dplyr::mutate(
      level = dplyr::recode(key,
        rate_ef1_7_10 = "fundamental_anos_iniciais",
        rate_ef1_7_11 = "fundamental_anos_iniciais",
        rate_ef2      = "fundamental_anos_finais",
        rate_ef       = "fundamental",
        rate_em       = "medio",
        rate_es       = "superior"
      ),
      age_group = dplyr::recode(key,
        rate_ef1_7_10 = "7-10",
        rate_ef1_7_11 = "7-11",
        rate_ef2      = "11-14",
        rate_ef       = "7-14",
        rate_em       = "15-17",
        rate_es       = "18-24"
      ),
      indicator = "enrollment_rate",
      unit      = "percent"
    ) |>
    # Kang uses 0 to denote "not computed for this year/age bracket"
    # (e.g. EF1 7-11 only exists from 1940 onward). We drop those.
    dplyr::filter(value > 0) |>
    dplyr::select(-key)

  dplyr::bind_rows(counts, rates) |>
    dplyr::mutate(
      year        = as.integer(year),
      geo_level   = "BR", geo_code = "BR", geo_name = "Brasil",
      network     = "total", dim_race = "total",
      source      = SOURCE_KEY,
      source_note = SOURCE_NOTE
    )
}

# ---------------------------------------------------------------------
# File 2 — National enrollment by color/race 1960-2010
# Sheet has a merged section-header row 1; the actual column names live
# in row 2 (anos, cor, count EF/EM/ES, pop 7-14/15-17/18-24, rate EF/EM/ES).
# ---------------------------------------------------------------------

build_byrace_br <- function() {
  raw <- readxl::read_excel(
    file.path(src_dir, "2._matriculas_txmatriculas_porcor_1960_2010_v_abril2023.xlsx"),
    sheet = "Matriculas_TxMatriculas_por_Cor",
    col_names = FALSE,
    skip = 2
  )
  names(raw) <- c(
    "year", "cor",
    "count_ef", "count_em", "count_es",
    "pop_7_14", "pop_15_17", "pop_18_24",
    "rate_ef", "rate_em", "rate_es"
  )

  raw <- raw |>
    dplyr::mutate(
      year = suppressWarnings(as.integer(year)),
      dim_race = recode_cor(cor)
    ) |>
    dplyr::filter(!is.na(year), !is.na(dim_race))

  counts <- raw |>
    dplyr::select(year, dim_race, count_ef, count_em, count_es) |>
    tidyr::pivot_longer(c(count_ef, count_em, count_es),
                        names_to = "key", values_to = "value",
                        values_drop_na = TRUE) |>
    dplyr::mutate(
      level = dplyr::recode(key,
        count_ef = "fundamental",
        count_em = "medio",
        count_es = "superior"
      ),
      indicator = "enrollment_count",
      unit      = "count",
      age_group = NA_character_
    ) |>
    dplyr::select(-key)

  rates <- raw |>
    dplyr::select(year, dim_race, rate_ef, rate_em, rate_es) |>
    tidyr::pivot_longer(c(rate_ef, rate_em, rate_es),
                        names_to = "key", values_to = "value",
                        values_drop_na = TRUE) |>
    dplyr::mutate(
      level = dplyr::recode(key,
        rate_ef = "fundamental",
        rate_em = "medio",
        rate_es = "superior"
      ),
      age_group = dplyr::recode(key,
        rate_ef = "7-14",
        rate_em = "15-17",
        rate_es = "18-24"
      ),
      indicator = "enrollment_rate",
      unit      = "percent"
    ) |>
    dplyr::filter(value > 0) |>
    dplyr::select(-key)

  dplyr::bind_rows(counts, rates) |>
    dplyr::mutate(
      geo_level   = "BR", geo_code = "BR", geo_name = "Brasil",
      network     = "total",
      source      = SOURCE_KEY,
      source_note = SOURCE_NOTE
    )
}

# ---------------------------------------------------------------------
# File 6 — Enrollment by UF, ensino fundamental 1955-2010
# Columns: year, UF, pop, count_EF1, count_EF2, count_EF (total), rate_EF
# ---------------------------------------------------------------------

build_byuf <- function() {
  raw <- readxl::read_excel(
    file.path(src_dir, "6._matricula_txmatriculas_estado_1955_2010_v_abril2023.xlsx"),
    sheet = "Matriculas_TxMatriculas_por_UF",
    col_names = FALSE,
    skip = 1
  )
  names(raw) <- c("year", "uf", "pop_7_14",
                  "count_ef1", "count_ef2", "count_ef",
                  "rate_ef")

  raw <- raw |>
    dplyr::mutate(
      year = as.integer(year),
      uf   = toupper(trimws(as.character(uf)))
    ) |>
    dplyr::filter(!is.na(year), uf %in% names(UF_NAMES))

  counts <- raw |>
    dplyr::select(year, uf, count_ef1, count_ef2, count_ef) |>
    tidyr::pivot_longer(c(count_ef1, count_ef2, count_ef),
                        names_to = "key", values_to = "value",
                        values_drop_na = TRUE) |>
    dplyr::mutate(
      level = dplyr::recode(key,
        count_ef1 = "fundamental_anos_iniciais",
        count_ef2 = "fundamental_anos_finais",
        count_ef  = "fundamental"
      ),
      indicator = "enrollment_count",
      unit      = "count",
      age_group = NA_character_
    ) |>
    dplyr::select(-key)

  rates <- raw |>
    dplyr::select(year, uf, rate_ef) |>
    dplyr::rename(value = rate_ef) |>
    dplyr::filter(!is.na(value), value > 0) |>
    dplyr::mutate(
      level     = "fundamental",
      indicator = "enrollment_rate",
      unit      = "percent",
      age_group = "7-14"
    )

  dplyr::bind_rows(counts, rates) |>
    dplyr::mutate(
      geo_level   = "UF",
      geo_code    = uf,
      geo_name    = unname(UF_NAMES[uf]),
      network     = "total",
      dim_race    = "total",
      source      = SOURCE_KEY,
      source_note = SOURCE_NOTE
    ) |>
    dplyr::select(-uf)
}

# ---------------------------------------------------------------------
# Combine, validate, write
# ---------------------------------------------------------------------

enrollment_kang_fgv <- dplyr::bind_rows(
  build_primary_br(),
  build_stages_br(),
  build_byrace_br(),
  build_byuf()
) |>
  dplyr::select(
    year, geo_level, geo_code, geo_name,
    level, network, dim_race,
    age_group, indicator, value, unit,
    source, source_note
  ) |>
  dplyr::arrange(geo_level, geo_code, level, dim_race, age_group, indicator, year) |>
  tibble::as_tibble()

cat("Built rows:", nrow(enrollment_kang_fgv), "\n")
print(dplyr::count(enrollment_kang_fgv, geo_level, level, indicator))

# Validate against the canonical schema before saving. Requires
# `devtools::load_all()` to have been run in this session.
educabr:::validate_against_schema(enrollment_kang_fgv, theme = "enrollment")

attr(enrollment_kang_fgv, "educabr_meta") <- list(
  build_script    = "data-raw/01_build_enrollment_kang_fgv.R",
  built_at        = Sys.time(),
  primary_source  = SOURCE_KEY,
  citation        = SOURCE_NOTE,
  raw_files       = c(
    "data-raw/sources/kang_fgv_ibre_2023/1._matricula_primario_1871_2010_v_abril2023.xlsx",
    "data-raw/sources/kang_fgv_ibre_2023/2._matriculas_txmatriculas_porcor_1960_2010_v_abril2023.xlsx",
    "data-raw/sources/kang_fgv_ibre_2023/4._matricula_txmatriculas_1933_2010_v_abril2023.xlsx",
    "data-raw/sources/kang_fgv_ibre_2023/6._matricula_txmatriculas_estado_1955_2010_v_abril2023.xlsx"
  )
)

usethis::use_data(enrollment_kang_fgv, overwrite = TRUE, compress = "xz")
