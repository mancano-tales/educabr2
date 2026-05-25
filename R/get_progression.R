#' Brazilian grade-progression series
#'
#' Returns harmonised series of grade-progression indicators in the
#' Brazilian school system. The bundled indicator is **GDR6** (Gross
#' Distribution Ratio for grade 6), defined as enrollment in grades 4-6
#' of the old eight-year primary system divided by enrollment in grades
#' 1-3. Higher values indicate fewer drop-outs and repeaters in the
#' early grades of primary education.
#'
#' GDR6 was reconstructed by Kang, Paese & Felix (2021) for the BR
#' national level and for 20 federation units (UFs), 1955-2010. The
#' dataset behind this function is [progression_kang_fgv].
#'
#' @param indicator Character vector of indicator keys. Currently only
#'   `"gross_distribution_ratio_grade_6"` is available; the alias
#'   `"gdr6"` is also accepted. `NULL` (default) returns all indicators.
#' @param year Integer vector or two-element `c(min, max)` range. `NULL`
#'   for all years.
#' @param geo_level One of `"BR"` (national, default) or `"UF"` (state).
#' @param geo Character vector of 2-letter UF codes when
#'   `geo_level = "UF"`. `NULL` (default) returns all UFs available for
#'   the indicator. **Coverage note:** the source covers 20 UFs, not
#'   all 27 — newer / territorial-origin federation units (`AC`, `AP`,
#'   `DF`, `MS`, `RO`, `RR`, `TO`) are not in Kang's compilation.
#'   Passing one of those codes emits a warning explaining the gap
#'   and returns the remaining (covered) UFs only.
#' @param source Character vector of source keys. `NULL` returns all
#'   available sources (currently only `"kang_paese_felix_2021"`).
#' @param wide Logical. If `TRUE`, pivots to wide form. For this
#'   indicator the effect is minimal (only one indicator column today),
#'   but the parameter is provided for API consistency. Default `FALSE`.
#' @param lang One of `"en"` (default) or `"pt"`. When `"pt"`, factor
#'   levels and indicator labels are translated via
#'   `inst/dict/i18n.yaml`.
#'
#' @return A tibble in the canonical educabr2 long schema (see
#'   `inst/dict/schema.yaml`). Columns: `year`, `geo_level`, `geo_code`,
#'   `geo_name`, `level`, `network`, `dim_race`, `age_group`,
#'   `indicator`, `value`, `unit`, `source`, `source_note`. `level` is
#'   always `"fundamental_anos_iniciais"` and `unit` is always
#'   `"ratio"`.
#'
#' @examplesIf FALSE
#' # National series, all years
#' get_progression()
#'
#' # GDR6 for São Paulo and Bahia, post-1980
#' get_progression(geo_level = "UF", geo = c("SP", "BA"),
#'                 year = c(1980, 2010))
#'
#' # Compare BR and the Northeast states
#' get_progression(geo_level = "UF",
#'                 geo = c("BA", "PE", "CE", "PB", "MA", "PI", "RN", "AL", "SE"))
#'
#' @export
get_progression <- function(indicator = NULL,
                            year      = NULL,
                            geo_level = c("BR", "UF"),
                            geo       = NULL,
                            source    = NULL,
                            wide      = FALSE,
                            lang      = c("en", "pt")) {
  geo_level <- match.arg(geo_level)
  lang      <- match.arg(lang)

  data <- .load_progression_panel()
  data <- .filter_progression(data,
    indicator = indicator, year = year,
    geo_level = geo_level, geo = geo, source = source
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
.progression_datasets <- function() {
  c("progression_kang_fgv")
}

#' @noRd
.load_progression_panel <- function(env = NULL) {
  env_provided <- !is.null(env)
  if (is.null(env)) env <- asNamespace("educabr2")
  names_ <- .progression_datasets()

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
      "No progression dataset is available in the installed package.",
      i = "Run {.code source(\"data-raw/05_build_progression_kang_fgv.R\")} from the package root, then reinstall."
    ))
  }

  do.call(rbind, unname(pieces))
}

.PROGRESSION_ALIASES <- c(
  gdr6 = "gross_distribution_ratio_grade_6"
)

# UFs that Kang, Paese & Felix's compilation does NOT cover (mostly newer
# / territorial-origin states). Warned about — not silently dropped — so
# the user knows the empty result is a source-data limitation rather
# than a typo or filter mistake.
.PROGRESSION_UNAVAILABLE_UF <- c("AC", "AP", "DF", "MS", "RO", "RR", "TO")

#' @noRd
.filter_progression <- function(data, indicator, year, geo_level, geo, source) {
  data <- data[data$geo_level == geo_level, , drop = FALSE]

  if (geo_level == "UF" && !is.null(geo)) {
    geo <- toupper(as.character(geo))
    missing_uf <- intersect(geo, .PROGRESSION_UNAVAILABLE_UF)
    if (length(missing_uf)) {
      cli::cli_warn(c(
        "UF{?s} not covered by the GDR6 source: {.val {missing_uf}}",
        i = "Kang, Paese & Felix's (2021) compilation covers 20 of the 27 federation units.",
        i = "Missing (not a bug in {.pkg educabr2}): AC, AP, DF, MS, RO, RR, TO."
      ))
    }
    data <- data[data$geo_code %in% geo, , drop = FALSE]
  }

  if (!is.null(indicator)) {
    keys <- as.character(indicator)
    keys <- ifelse(keys %in% names(.PROGRESSION_ALIASES),
                   unname(.PROGRESSION_ALIASES[keys]),
                   keys)
    data <- data[data$indicator %in% keys, , drop = FALSE]
  }

  if (!is.null(year)) {
    yr <- suppressWarnings(as.integer(year))
    if (length(yr) == 2L && !any(is.na(yr)) && yr[1] <= yr[2]) {
      data <- data[data$year >= yr[1] & data$year <= yr[2], , drop = FALSE]
    } else {
      data <- data[data$year %in% yr, , drop = FALSE]
    }
  }

  if (!is.null(source)) {
    data <- data[data$source %in% as.character(source), , drop = FALSE]
  }

  data
}
