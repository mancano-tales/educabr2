#' Brazilian school-enrollment series
#'
#' Returns harmonized school-enrollment counts and rates at the national
#' or state level, optionally broken down by color/race. The bundled
#' data comes from the Kang/FGV-IBRE (2023) compilation; additional
#' sources are added in later milestones.
#'
#' @param level Character vector with one or more stage codes:
#'   `"fundamental_anos_iniciais"`, `"fundamental_anos_finais"`,
#'   `"fundamental"`, `"medio"`, `"superior"`. `NULL` (default) means
#'   no filter.
#' @param network Character vector with administrative-network codes.
#'   The bundled data currently covers only `"total"`. `NULL` (default)
#'   means no filter.
#' @param year Integer vector or two-element `c(min, max)` range. `NULL`
#'   for all years.
#' @param geo_level One of `"BR"` (national, default) or `"UF"` (state).
#' @param geo Character vector of 2-letter UF codes when
#'   `geo_level = "UF"`. `NULL` (default) returns all UFs.
#' @param dimension Inequality breakdown. One of `"none"` (default,
#'   totals only) or `"race"`. Future versions add `"sex"`, `"income"`,
#'   `"location"`.
#' @param indicator Character vector. `"count"` for counts, `"rate"`
#'   for gross enrollment rates. `NULL` returns both.
#' @param source Character vector of source keys (see [list_sources()];
#'   forthcoming). `NULL` returns all available sources.
#' @param wide Logical. If `TRUE`, pivots the `indicator` column to
#'   wide form (one column per indicator). Default `FALSE` returns the
#'   canonical long schema.
#' @param lang One of `"en"` (default) or `"pt"`. When `"pt"`, factor
#'   levels are translated using `inst/dict/i18n.yaml`.
#'
#' @return A tibble. In long form, follows the canonical schema in
#'   `inst/dict/schema.yaml`. In wide form, the `indicator` and `unit`
#'   columns are dropped and replaced by one column per indicator.
#'
#' @examplesIf FALSE
#' # National series, ensino fundamental, all years
#' get_enrollment(level = "fundamental", geo_level = "BR")
#'
#' # By race, rates only, 1960-2010
#' get_enrollment(dimension = "race", indicator = "rate",
#'                year = c(1960, 2010))
#'
#' # State-level enrollment rates for a handful of UFs
#' get_enrollment(geo_level = "UF", geo = c("SP", "BA", "AM"),
#'                level = "fundamental", indicator = "rate")
#'
#' @export
get_enrollment <- function(level = NULL,
                           network = NULL,
                           year = NULL,
                           geo_level = c("BR", "UF"),
                           geo = NULL,
                           dimension = c("none", "race"),
                           indicator = NULL,
                           source = NULL,
                           wide = FALSE,
                           lang = c("en", "pt")) {
  geo_level <- match.arg(geo_level)
  dimension <- match.arg(dimension)
  lang      <- match.arg(lang)

  data <- .load_enrollment_panel()
  data <- .filter_enrollment(
    data,
    level = level, network = network, year = year,
    geo_level = geo_level, geo = geo,
    dimension = dimension, indicator = indicator, source = source
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
.enrollment_datasets <- function() {
  # Registry of datasets that contribute rows to `get_enrollment()`.
  # Update this constant when adding a new source.
  c("enrollment_kang_fgv")
}

#' @noRd
.load_enrollment_panel <- function(env = NULL) {
  if (is.null(env)) env <- asNamespace("educabr")
  names_ <- .enrollment_datasets()

  pieces <- list()
  for (nm in names_) {
    if (exists(nm, envir = env, inherits = FALSE)) {
      pieces[[nm]] <- get(nm, envir = env, inherits = FALSE)
    } else {
      # Try data() loader for the unlikely case the dataset is not lazy-loaded.
      tmp <- new.env()
      try(utils::data(list = nm, package = "educabr", envir = tmp), silent = TRUE)
      if (exists(nm, envir = tmp, inherits = FALSE)) {
        pieces[[nm]] <- get(nm, envir = tmp, inherits = FALSE)
      }
    }
  }

  if (length(pieces) == 0) {
    cli::cli_abort(c(
      "No enrollment dataset is available in the installed package.",
      i = "Run {.code source(\"data-raw/01_build_enrollment_kang_fgv.R\")} from the package root, then reinstall."
    ))
  }

  # Same canonical schema across all pieces — base rbind is safe.
  do.call(rbind, unname(pieces))
}

#' @noRd
.filter_enrollment <- function(data,
                               level, network, year,
                               geo_level, geo,
                               dimension, indicator, source) {
  data <- data[data$geo_level == geo_level, , drop = FALSE]

  if (geo_level == "UF" && !is.null(geo)) {
    geo <- toupper(as.character(geo))
    data <- data[data$geo_code %in% geo, , drop = FALSE]
  }

  if (!is.null(level)) {
    data <- data[data$level %in% as.character(level), , drop = FALSE]
  }

  if (!is.null(network)) {
    data <- data[data$network %in% as.character(network), , drop = FALSE]
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
    data <- data[data$dim_race == "total", , drop = FALSE]
  } else if (dimension == "race") {
    data <- data[data$dim_race != "total", , drop = FALSE]
  }

  if (!is.null(indicator)) {
    keys <- paste0("enrollment_", as.character(indicator))
    data <- data[data$indicator %in% keys, , drop = FALSE]
  }

  if (!is.null(source)) {
    data <- data[data$source %in% as.character(source), , drop = FALSE]
  }

  data
}

#' @noRd
.translate_labels <- function(df, lang = "pt") {
  i18n <- .load_i18n()
  if (is.null(i18n$levels)) return(df)

  for (col in intersect(names(df), names(i18n$levels))) {
    mapping <- i18n$levels[[col]]
    if (length(mapping)) {
      lookup <- unlist(mapping, use.names = TRUE)
      df[[col]] <- ifelse(df[[col]] %in% names(lookup),
                          unname(lookup[df[[col]]]),
                          df[[col]])
    }
  }
  df
}

#' @noRd
.load_i18n <- function() {
  path <- system.file("dict", "i18n.yaml", package = "educabr")
  if (!nzchar(path)) {
    path <- file.path("inst", "dict", "i18n.yaml")
  }
  if (!file.exists(path)) {
    return(list(levels = list()))
  }
  yaml::read_yaml(path)
}

#' @noRd
.pivot_wider_indicator <- function(df) {
  if (!nrow(df) || !"indicator" %in% names(df)) return(df)

  id_cols <- setdiff(names(df), c("indicator", "value", "unit"))
  ind_vals <- unique(df$indicator)

  out <- unique(df[, id_cols, drop = FALSE])
  for (ind in ind_vals) {
    sub <- df[df$indicator == ind, c(id_cols, "value"), drop = FALSE]
    names(sub)[ncol(sub)] <- ind
    out <- merge(out, sub, by = id_cols, all.x = TRUE, sort = FALSE)
  }
  out
}
