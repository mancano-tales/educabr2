# 06_build_lee_lee_2016.R
#
# ETL: Lee & Lee (2016) Long-Run Education Dataset.
# Source URL: https://barrolee.github.io/BarroLeeDataSet/LeeLee/LeeLee_v1.dta
# Documentation: https://barrolee.github.io/BarroLeeDataSet/DataLeeLee.html
#
# Produces `lee_lee_2016` saved to data/lee_lee_2016.rda.
#
# Coverage:
#   * 111 countries, every 5 years from 1820 to 2010
#   * Sex: Total (MF), Male (M), Female (F)
#   * Reference population: aged 15-64 (Lee & Lee paper)
#
# Output indicator: `attainment_share_completed` — the cumulative share
# of the population aged 15-64 who completed at least the level
# indicated by `level` (primary / secondary / tertiary). Lee & Lee
# publish *non-cumulative* shares (highest-attained = X); we sum the
# upper categories to express the more conventional "share who reached
# at least X" used in cross-country comparative work.
#
# Run from the package root (requires internet on first run; subsequent
# runs reuse the in-memory tibble if you keep the session open):
#   source("data-raw/06_build_lee_lee_2016.R")

library(dplyr)
library(tidyr)
library(haven)
library(countrycode)

stopifnot(file.exists("DESCRIPTION"))

SRC_URL    <- "https://barrolee.github.io/BarroLeeDataSet/LeeLee/LeeLee_v1.dta"
SOURCE_KEY <- "lee_lee_2016"
SOURCE_NOTE <- paste(
  "Lee, J.-W., & Lee, H. (2016).",
  "Human capital in the long run.",
  "Journal of Development Economics, 122, 147-169.",
  "doi:10.1016/j.jdeveco.2016.05.006"
)

# ---------------------------------------------------------------------
# READ
# ---------------------------------------------------------------------

raw <- haven::read_dta(SRC_URL)

cat("Raw dimensions: ", paste(dim(raw), collapse = " x "), "\n", sep = "")

# ---------------------------------------------------------------------
# TIDY
# ---------------------------------------------------------------------

# Keep only the columns we need to build the three cumulative completion
# indicators. Lee-Lee's non-cumulative split:
#   lu  = % no schooling
#   lp  = % some primary
#   lpc = % primary complete (highest)
#   ls  = % some secondary
#   lsc = % secondary complete (highest)
#   lh  = % some tertiary
#   lhc = % tertiary complete (highest)
# These seven columns sum to ~100 per country-year-sex.
#
# Cumulative "completed at least X":
#   primary   = lpc + ls + lsc + lh + lhc
#   secondary = lsc + lh + lhc
#   tertiary  = lhc

cum <- raw |>
  dplyr::select(country, year, sex, lp, lpc, ls, lsc, lh, lhc) |>
  dplyr::filter(!is.na(lpc) | !is.na(lsc) | !is.na(lhc)) |>
  dplyr::mutate(
    primary   = lpc + ls + lsc + lh + lhc,
    secondary =       lsc + lh + lhc,
    tertiary  =                  lhc
  ) |>
  dplyr::select(country, year, sex, primary, secondary, tertiary)

long <- cum |>
  tidyr::pivot_longer(
    cols      = c(primary, secondary, tertiary),
    names_to  = "level",
    values_to = "value"
  ) |>
  dplyr::filter(!is.na(value))

# Recode sex to canonical educabr2 vocabulary
long <- long |>
  dplyr::mutate(
    dim_sex = dplyr::recode(sex,
      "MF" = "total",
      "M"  = "male",
      "F"  = "female"
    )
  ) |>
  dplyr::select(-sex)

# Map country names -> ISO 3166-1 alpha-3.
iso_lookup <- long |>
  dplyr::distinct(country) |>
  dplyr::mutate(
    geo_code = suppressWarnings(
      countrycode::countrycode(country,
                               origin      = "country.name",
                               destination = "iso3c")
    )
  )
stopifnot(all(!is.na(iso_lookup$geo_code)))

long <- long |>
  dplyr::left_join(iso_lookup, by = "country") |>
  dplyr::rename(geo_name = country)

# ---------------------------------------------------------------------
# ANNOTATE
# ---------------------------------------------------------------------

lee_lee_2016 <- long |>
  dplyr::mutate(
    year        = as.integer(year),
    geo_level   = "country",
    indicator   = "attainment_share_completed",
    unit        = "percent",
    age_group   = "15-64",
    source      = SOURCE_KEY,
    source_note = SOURCE_NOTE
  ) |>
  dplyr::select(
    year, geo_level, geo_code, geo_name,
    level, dim_sex, age_group,
    indicator, value, unit,
    source, source_note
  ) |>
  dplyr::arrange(geo_code, level, dim_sex, year) |>
  tibble::as_tibble()

cat("Built rows: ", nrow(lee_lee_2016), "\n", sep = "")
print(dplyr::count(lee_lee_2016, level, dim_sex))
cat("Year range: ", paste(range(lee_lee_2016$year), collapse = "-"), "\n", sep = "")
cat("Countries: ", length(unique(lee_lee_2016$geo_code)), "\n", sep = "")

# ---------------------------------------------------------------------
# VALIDATE
# ---------------------------------------------------------------------

educabr2:::validate_against_schema(lee_lee_2016, theme = "attainment_comparative")

# ---------------------------------------------------------------------
# WRITE
# ---------------------------------------------------------------------

attr(lee_lee_2016, "educabr_meta") <- list(
  build_script   = "data-raw/06_build_lee_lee_2016.R",
  built_at       = Sys.time(),
  primary_source = SOURCE_KEY,
  citation       = SOURCE_NOTE,
  raw_files      = SRC_URL
)

usethis::use_data(lee_lee_2016, overwrite = TRUE, compress = "xz")
