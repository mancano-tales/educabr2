#' Comparative international educational-attainment series
#'
#' Returns harmonised series of educational attainment for ~111 countries,
#' every 5 years from 1870 to 2010, broken down by sex. The bundled data
#' comes from Lee & Lee (2016), *Human capital in the long run* (JDE 122,
#' 147–169) — a widely used cross-country dataset that reconstructs
#' attainment back to the 19th century.
#'
#' The indicator is the **cumulative** share of the population aged 15–64
#' that has completed at least the level indicated by `level`. Lee & Lee
#' publish the data in non-cumulative form ("highest attained level =
#' primary/secondary/tertiary"); the bundled dataset sums the upper
#' categories so that, for any (country, year, sex):
#'
#' - `level = "primary"` ≥ `level = "secondary"` ≥ `level = "tertiary"`.
#'
#' This matches the conventional "share of adults who reached at least
#' X" reported in comparative work.
#'
#' Coverage is comparative-international: ISCED-style `primary` /
#' `secondary` / `tertiary` levels, intentionally distinct from the
#' Brazilian `fundamental` / `medio` / `superior` levels in
#' [get_enrollment()] and [get_schooling()] because the underlying
#' definitions differ.
#'
#' @param level Character vector of education levels. One or more of
#'   `"primary"`, `"secondary"`, `"tertiary"`. `NULL` (default) returns
#'   all three.
#' @param year Integer vector or two-element `c(min, max)` range. `NULL`
#'   for all years (1870–2010 in 5-year steps).
#' @param geo_level Always `"country"` for this dataset (kept for API
#'   consistency with other `get_*()` functions).
#' @param geo Character vector of ISO 3166-1 alpha-3 country codes (e.g.
#'   `"BRA"`, `"USA"`, `"ARG"`). `NULL` (default) returns all 111
#'   countries available in Lee & Lee (2016).
#' @param dimension Sex breakdown. One of:
#'   - `"none"` (default) — sex totals only (`dim_sex = "total"`);
#'   - `"sex"` — break down by sex (`male`, `female`), drops the total.
#' @param source Character vector of source keys. `NULL` returns all
#'   available sources (currently only `"lee_lee_2016"`).
#' @param wide Logical. If `TRUE`, pivots the result to wide form (one
#'   column per indicator key). Default `FALSE`.
#' @param lang One of `"en"` (default) or `"pt"`. When `"pt"`, factor
#'   levels and indicator labels are translated via
#'   `inst/dict/i18n.yaml`. Country names (`geo_name`) are left in
#'   English regardless — they come from the upstream source.
#'
#' @return A tibble in the canonical educabr2 long schema (see
#'   `inst/dict/schema.yaml`). Columns: `year`, `geo_level`, `geo_code`,
#'   `geo_name`, `level`, `dim_sex`, `age_group`, `indicator`, `value`,
#'   `unit`, `source`, `source_note`. `geo_level` is always `"country"`,
#'   `unit` is always `"percent"` (0–100), `age_group` is always
#'   `"15-64"`.
#'
#' @examples
#' # Tertiary completion in Brazil over time
#' get_attainment(level = "tertiary", geo = "BRA")
#'
#' # Primary completion across Latin America, post-1950
#' get_attainment(level = "primary",
#'                geo   = c("BRA", "ARG", "CHL", "MEX", "URY"),
#'                year  = c(1950, 2010))
#'
#' # Compare male vs female secondary completion in Brazil
#' get_attainment(level = "secondary", geo = "BRA", dimension = "sex")
#'
#' @export
get_attainment <- function(level     = NULL,
                           year      = NULL,
                           geo_level = c("country"),
                           geo       = NULL,
                           dimension = c("none", "sex"),
                           source    = NULL,
                           wide      = FALSE,
                           lang      = c("en", "pt")) {
  geo_level <- match.arg(geo_level)
  dimension <- match.arg(dimension)
  lang      <- match.arg(lang)

  data <- .load_attainment_panel()
  data <- .filter_attainment(data,
    level = level, year = year, geo_level = geo_level, geo = geo,
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
.attainment_datasets <- function() {
  c("lee_lee_2016")
}

#' @noRd
.load_attainment_panel <- function(env = NULL) {
  env_provided <- !is.null(env)
  if (is.null(env)) env <- asNamespace("educabr2")
  names_ <- .attainment_datasets()

  pieces <- list()
  for (nm in names_) {
    if (exists(nm, envir = env, inherits = FALSE)) {
      pieces[[nm]] <- get(nm, envir = env, inherits = FALSE)
    } else if (!env_provided) {
      tmp <- new.env()
      try(utils::data(list = nm, package = "educabr2", envir = tmp), silent = TRUE)
      if (exists(nm, envir = tmp, inherits = FALSE)) {
        pieces[[nm]] <- get(nm, envir = tmp, inherits = FALSE)
      }
    }
  }

  if (length(pieces) == 0) {
    cli::cli_abort(c(
      "No attainment dataset is available in the installed package.",
      i = "Run {.code source(\"data-raw/06_build_lee_lee_2016.R\")} from the package root, then reinstall."
    ))
  }

  do.call(rbind, unname(pieces))
}

#' @noRd
.filter_attainment <- function(data,
                               level, year, geo_level, geo,
                               dimension, source) {
  data <- data[data$geo_level == geo_level, , drop = FALSE]

  if (!is.null(geo)) {
    geo <- toupper(as.character(geo))
    data <- data[data$geo_code %in% geo, , drop = FALSE]
  }

  if (!is.null(level)) {
    data <- data[data$level %in% as.character(level), , drop = FALSE]
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
    data <- data[data$dim_sex == "total", , drop = FALSE]
  } else if (dimension == "sex") {
    data <- data[data$dim_sex != "total", , drop = FALSE]
  }

  if (!is.null(source)) {
    data <- data[data$source %in% as.character(source), , drop = FALSE]
  }

  data
}
