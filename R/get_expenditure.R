#' Brazilian public expenditure on education
#'
#' Returns the harmonised series of public expenditure on education,
#' compiled by Kang & Menetrier (2024) from the long-run Brazilian
#' national accounts and educational statistics. Three indicator
#' families are exposed:
#'
#' \itemize{
#'   \item `expenditure_share_gdp` — total public expenditure on a given
#'     stage, as share of GDP.
#'   \item `expenditure_per_student_pct_gdp_pc` — per-student public
#'     expenditure in the public network, expressed as share of GDP per
#'     capita (a unit-free, cross-country-comparable measure).
#'   \item `expenditure_double_ratio_es_ef1` and
#'     `expenditure_double_ratio_es_ef_em` — Kang & Menetrier's "double
#'     ratio" indicators of fiscal regressivity (per-student spending on
#'     tertiary divided by per-student spending on, respectively, EF1
#'     and EF+EM combined).
#' }
#'
#' All series are national (BR), 1933-2010. The data behind this function
#' is the internal dataset [expenditure_kang_fgv].
#'
#' @param level Character vector of stage codes:
#'   `"fundamental_anos_iniciais"`, `"fundamental_anos_finais"`,
#'   `"fundamental"`, `"medio"`, `"fundamental_medio"`, `"superior"`,
#'   `"total"`. The two "double ratio" indicators are tagged with
#'   `level = "total"`. `NULL` (default) means no filter.
#' @param indicator Character vector. Convenience aliases are accepted:
#'   `"share_gdp"`, `"per_student"`, `"double_ratio_es_ef1"`,
#'   `"double_ratio_es_ef_em"`. Full indicator keys
#'   (`"expenditure_share_gdp"`, etc.) also work. `NULL` (default)
#'   returns all four indicators.
#' @param year Integer vector or two-element `c(min, max)` range. `NULL`
#'   for all years.
#' @param source Character vector of source keys. `NULL` returns all
#'   available sources (currently only `"kang_menetrier_2024"`).
#' @param wide Logical. If `TRUE`, pivots the result to wide form (one
#'   column per indicator). Default `FALSE`.
#' @param lang One of `"en"` (default) or `"pt"`. When `"pt"`, factor
#'   levels and indicator labels are translated via
#'   `inst/dict/i18n.yaml`.
#'
#' @return A tibble in the canonical educabr2 long schema (see
#'   `inst/dict/schema.yaml`). Columns: `year`, `geo_level`, `geo_code`,
#'   `geo_name`, `level`, `network`, `dim_race`, `age_group`,
#'   `indicator`, `value`, `unit`, `source`, `source_note`.
#'   `network` is always `"publica"` (public-sector expenditure only).
#'
#' @examplesIf FALSE
#' # Total public expenditure on education as share of GDP
#' get_expenditure(indicator = "share_gdp", level = "total")
#'
#' # Per-student spending in tertiary education over time
#' get_expenditure(indicator = "per_student", level = "superior")
#'
#' # The fiscal-regressivity "double ratio" — ES vs EF1
#' get_expenditure(indicator = "double_ratio_es_ef1")
#'
#' # All indicators for 1933-1950 in wide form
#' get_expenditure(year = c(1933, 1950), wide = TRUE)
#'
#' @export
get_expenditure <- function(level     = NULL,
                            indicator = NULL,
                            year      = NULL,
                            source    = NULL,
                            wide      = FALSE,
                            lang      = c("en", "pt")) {
  lang <- match.arg(lang)

  data <- .load_expenditure_panel()
  data <- .filter_expenditure(data,
    level = level, indicator = indicator,
    year = year, source = source
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
.expenditure_datasets <- function() {
  c("expenditure_kang_fgv")
}

#' @noRd
.load_expenditure_panel <- function(env = NULL) {
  env_provided <- !is.null(env)
  if (is.null(env)) env <- asNamespace("educabr2")
  names_ <- .expenditure_datasets()

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
      "No expenditure dataset is available in the installed package.",
      i = "Run {.code source(\"data-raw/04_build_expenditure_kang_fgv.R\")} from the package root, then reinstall."
    ))
  }

  do.call(rbind, unname(pieces))
}

# Aliases users typically type vs. canonical indicator keys.
.EXPENDITURE_ALIASES <- c(
  share_gdp             = "expenditure_share_gdp",
  per_student           = "expenditure_per_student_pct_gdp_pc",
  double_ratio_es_ef1   = "expenditure_double_ratio_es_ef1",
  double_ratio_es_ef_em = "expenditure_double_ratio_es_ef_em"
)

#' @noRd
.filter_expenditure <- function(data, level, indicator, year, source) {
  if (!is.null(level)) {
    data <- data[data$level %in% as.character(level), , drop = FALSE]
  }

  if (!is.null(indicator)) {
    keys <- as.character(indicator)
    # Translate aliases; keys that already look canonical pass through.
    keys <- ifelse(keys %in% names(.EXPENDITURE_ALIASES),
                   unname(.EXPENDITURE_ALIASES[keys]),
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
