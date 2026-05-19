#' Brazilian mean years of schooling
#'
#' Returns harmonized series of average years of schooling at the
#' national, macro-region, or state level, optionally broken down by
#' color/race or sex. The bundled data comes from Walter & Kang (2023),
#' a FGV-IBRE working paper that reconstructs the series from 1925 to
#' 2015.
#'
#' @param year Integer vector or two-element `c(min, max)` range. `NULL`
#'   for all years.
#' @param geo_level One of `"BR"` (national, default), `"region"`
#'   (macro-region), or `"UF"` (state). Region and UF series start in
#'   1950.
#' @param geo Character vector of geographic codes. For `geo_level =
#'   "UF"`, 2-letter IBGE UF abbreviations (e.g. `"SP"`, `"BA"`). For
#'   `geo_level = "region"`, one or more of `"N"`, `"NE"`, `"CO"`,
#'   `"SE"`, `"S"`. `NULL` (default) returns all geographies at that
#'   level.
#' @param dimension Inequality breakdown. One of:
#'   - `"none"` (default) — national totals only (no race or sex split);
#'   - `"race"` — breakdown by IBGE color/race (`white`, `black`,
#'     `brown`, `asian`, `indigenous`), totals across sex;
#'   - `"sex"` — breakdown by sex (`male`, `female`), totals across race.
#'   Race and sub-national breakdowns are only available at `geo_level =
#'   "BR"`.
#' @param source Character vector of source keys. `NULL` returns all
#'   available sources (currently only `"walter_kang_2023"`).
#' @param wide Logical. If `TRUE`, pivots the result to wide form. For
#'   this indicator the effect is minimal (only one indicator column),
#'   but the parameter is provided for API consistency with
#'   [get_enrollment()]. Default `FALSE`.
#' @param lang One of `"en"` (default) or `"pt"`. When `"pt"`, factor
#'   levels are translated via `inst/dict/i18n.yaml`.
#'
#' @return A tibble following the canonical schema in
#'   `inst/dict/schema.yaml`. Columns: `year`, `geo_level`, `geo_code`,
#'   `geo_name`, `dim_race`, `dim_sex`, `age_group`, `indicator`,
#'   `value`, `unit`, `source`, `source_note`. The `level` and `network`
#'   columns are omitted (not applicable to population-level attainment
#'   averages).
#'
#' @examples
#' # National series, all years
#' get_schooling()
#'
#' # By race, 1960-2015
#' get_schooling(dimension = "race", year = c(1960, 2015))
#'
#' # By sex across states
#' get_schooling(dimension = "sex", geo_level = "UF", geo = c("SP", "BA"))
#'
#' @export
get_schooling <- function(year      = NULL,
                          geo_level = c("BR", "region", "UF"),
                          geo       = NULL,
                          dimension = c("none", "race", "sex"),
                          source    = NULL,
                          wide      = FALSE,
                          lang      = c("en", "pt")) {
  geo_level <- match.arg(geo_level)
  dimension <- match.arg(dimension)
  lang      <- match.arg(lang)

  data <- .load_schooling_panel()
  data <- .filter_schooling(data,
    year = year, geo_level = geo_level, geo = geo,
    dimension = dimension, source = source
  )

  if (lang == "pt") {
    data <- .translate_labels(data, lang = "pt")
  }

  if (isTRUE(wide)) {
    data <- .pivot_wider_indicator(data)
  }

  tibble::as_tibble(data)
}

# ----------------------------------------------------------------------
# Internal helpers
# ----------------------------------------------------------------------

#' @noRd
.schooling_datasets <- function() {
  c("schooling_kang_fgv")
}

#' @noRd
.load_schooling_panel <- function(env = NULL) {
  # When `env` is supplied (test fixtures), look there only — no fallback
  # to the installed package. Production callers leave it NULL and get
  # the data() fallback as a safety net.
  env_provided <- !is.null(env)
  if (is.null(env)) env <- asNamespace("educabr")
  names_ <- .schooling_datasets()

  pieces <- list()
  for (nm in names_) {
    if (exists(nm, envir = env, inherits = FALSE)) {
      pieces[[nm]] <- get(nm, envir = env, inherits = FALSE)
    } else if (!env_provided) {
      tmp <- new.env()
      try(utils::data(list = nm, package = "educabr", envir = tmp), silent = TRUE)
      if (exists(nm, envir = tmp, inherits = FALSE)) {
        pieces[[nm]] <- get(nm, envir = tmp, inherits = FALSE)
      }
    }
  }

  if (length(pieces) == 0) {
    cli::cli_abort(c(
      "No schooling dataset is available in the installed package.",
      i = "Run {.code source(\"data-raw/02_build_schooling_kang_fgv.R\")} from the package root, then reinstall."
    ))
  }

  do.call(rbind, unname(pieces))
}

#' @noRd
.filter_schooling <- function(data,
                              year, geo_level, geo,
                              dimension, source) {
  data <- data[data$geo_level == geo_level, , drop = FALSE]

  if (!is.null(geo)) {
    geo <- toupper(as.character(geo))
    data <- data[data$geo_code %in% geo, , drop = FALSE]
  }

  if (!is.null(year)) {
    yr <- suppressWarnings(as.integer(year))
    if (length(yr) == 2L && !any(is.na(yr)) && yr[1] <= yr[2]) {
      data <- data[data$year >= yr[1] & data$year <= yr[2], , drop = FALSE]
    } else {
      data <- data[data$year %in% yr, , drop = FALSE]
    }
  }

  if (dimension == "none") {
    data <- data[data$dim_race == "total" & data$dim_sex == "total", , drop = FALSE]
  } else if (dimension == "race") {
    data <- data[data$dim_race != "total" & data$dim_sex == "total", , drop = FALSE]
  } else if (dimension == "sex") {
    data <- data[data$dim_race == "total" & data$dim_sex != "total", , drop = FALSE]
  }

  if (!is.null(source)) {
    data <- data[data$source %in% as.character(source), , drop = FALSE]
  }

  data
}
