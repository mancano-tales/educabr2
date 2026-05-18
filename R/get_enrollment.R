#' Brazilian school-enrollment series
#'
#' Returns harmonized school-enrollment counts and rates, optionally
#' broken down by color/race, administrative network, institutional
#' type, or teaching modality. Series are pulled from all enrollment
#' datasets shipped with the package and concatenated into the canonical
#' long-format schema.
#'
#' @param level Character vector with one or more stage codes:
#'   `"fundamental_anos_iniciais"`, `"fundamental_anos_finais"`,
#'   `"fundamental"`, `"medio"`, `"superior"`. `NULL` (default) means
#'   no filter.
#' @param network Character vector with administrative-network codes
#'   (`"federal"`, `"estadual"`, `"municipal"`, `"publica"`,
#'   `"privada"`, plus the post-2009 private subcategories
#'   `"privada_particular"`, `"privada_comunitaria_confessional_filantropica"`,
#'   `"privada_lucrativa"`, `"privada_nao_lucrativa"`, `"especial"`,
#'   `"total"`). `NULL` (default) means no filter.
#' @param institution_type Character vector restricting the
#'   institutional category (only meaningful for `level = "superior"`).
#'   See `inst/dict/schema.yaml` for the controlled vocabulary. `NULL`
#'   (default) means no filter; pass `"total"` to keep only rows that
#'   aggregate across institutional types.
#' @param modality Character vector: `"presencial"`, `"ead"`,
#'   `"total"`. `NULL` (default) means no filter.
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
#' @param source Character vector of source keys (see
#'   `inst/dict/vocabularies/sources.yaml`). `NULL` returns all
#'   available sources. **Tip:** when the same `(year, level, network)`
#'   is covered by multiple sources (common in the tertiary panel),
#'   pass `source = "..."` to lock down a single series.
#' @param include_derived Logical. If `FALSE` (default), excludes the
#'   so-called **reconstructed totals** — rows where the value was
#'   computed by combining components from different sources (typically
#'   the in-person enrollment from a single-source paper plus the EAD
#'   enrollment from INEP, for 2000-2008 where the original sources
#'   under-reported the combined total). Set to `TRUE` to include them.
#'   The composition is documented in `source_note`; the `source`
#'   column for these rows carries the composite key
#'   `"<presencial_source>+<ead_source>"`. Has no effect on datasets
#'   that do not carry an `is_derived` flag.
#' @param wide Logical. If `TRUE`, pivots the `indicator` column to
#'   wide form (one column per indicator). Default `FALSE`.
#' @param lang One of `"en"` (default) or `"pt"`. When `"pt"`, factor
#'   levels are translated using `inst/dict/i18n.yaml`.
#'
#' @return A tibble following the canonical schema in
#'   `inst/dict/schema.yaml`. Optional columns (`institution_type`,
#'   `modality`, `is_derived`) are present whenever any of the loaded
#'   datasets carries them; for rows coming from datasets without that
#'   column the value defaults to `"total"` (or `FALSE` for
#'   `is_derived`).
#'
#' @examplesIf FALSE
#' # National series, ensino fundamental, all years
#' get_enrollment(level = "fundamental", geo_level = "BR")
#'
#' # Tertiary enrollment, all sources, compare them
#' get_enrollment(level = "superior", network = "total", modality = "total")
#'
#' # Tertiary private particular only, post-2000
#' get_enrollment(level = "superior", network = "privada_particular",
#'                year = c(2000, 2024))
#'
#' # Compare with derived rows included
#' get_enrollment(level = "superior", network = "total",
#'                year = c(2000, 2008), include_derived = TRUE)
#'
#' @export
get_enrollment <- function(level            = NULL,
                           network          = NULL,
                           institution_type = NULL,
                           modality         = NULL,
                           year             = NULL,
                           geo_level        = c("BR", "UF"),
                           geo              = NULL,
                           dimension        = c("none", "race"),
                           indicator        = NULL,
                           source           = NULL,
                           include_derived  = FALSE,
                           wide             = FALSE,
                           lang             = c("en", "pt")) {
  geo_level <- match.arg(geo_level)
  dimension <- match.arg(dimension)
  lang      <- match.arg(lang)

  data <- .load_enrollment_panel()
  data <- .filter_enrollment(
    data,
    level = level, network = network,
    institution_type = institution_type, modality = modality,
    year = year, geo_level = geo_level, geo = geo,
    dimension = dimension, indicator = indicator, source = source,
    include_derived = include_derived
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
  c("enrollment_kang_fgv", "enrollment_tertiary")
}

# Canonical column order produced by .load_enrollment_panel().
.ENR_CANONICAL_COLS <- c(
  "year", "geo_level", "geo_code", "geo_name",
  "level", "network", "institution_type", "modality",
  "dim_race", "age_group",
  "indicator", "value", "unit",
  "source", "source_note", "is_derived"
)

# Defaults applied to columns missing in a particular dataset.
.ENR_DEFAULTS <- list(
  institution_type = "total",
  modality         = "total",
  dim_race         = "total",
  age_group        = NA_character_,
  is_derived       = FALSE,
  source_note      = NA_character_
)

#' @noRd
.load_enrollment_panel <- function(env = NULL) {
  # When `env` is supplied (test fixtures), look there only — no fallback
  # to the installed package. Production callers leave it NULL and get
  # the data() fallback as a safety net.
  env_provided <- !is.null(env)
  if (is.null(env)) env <- asNamespace("educabr")
  names_ <- .enrollment_datasets()

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
      "No enrollment dataset is available in the installed package.",
      i = "Run the ETL scripts in {.path data-raw/} and reinstall."
    ))
  }

  # Normalise each piece so they all share the canonical column set
  # (datasets that pre-date a given column get the documented default).
  pieces <- lapply(pieces, .normalise_enrollment_piece)
  do.call(rbind, unname(pieces))
}

#' @noRd
.normalise_enrollment_piece <- function(df) {
  for (col in .ENR_CANONICAL_COLS) {
    if (!col %in% names(df)) {
      df[[col]] <- if (col %in% names(.ENR_DEFAULTS))
        .ENR_DEFAULTS[[col]] else NA
    }
  }
  df[, .ENR_CANONICAL_COLS, drop = FALSE]
}

#' @noRd
.filter_enrollment <- function(data,
                               level, network,
                               institution_type, modality,
                               year, geo_level, geo,
                               dimension, indicator, source,
                               include_derived) {
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

  if (!is.null(institution_type)) {
    data <- data[data$institution_type %in% as.character(institution_type), , drop = FALSE]
  }

  if (!is.null(modality)) {
    data <- data[data$modality %in% as.character(modality), , drop = FALSE]
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
    src_match <- data$source %in% as.character(source)
    if (isTRUE(include_derived)) {
      # Derived rows carry a composite source key (e.g. "a+b") that won't
      # match any single-source entry — exempt them from this filter so
      # include_derived = TRUE actually works.
      src_match <- src_match | isTRUE_vec(data$is_derived)
    }
    data <- data[src_match, , drop = FALSE]
  }

  if (!isTRUE(include_derived)) {
    data <- data[!isTRUE_vec(data$is_derived), , drop = FALSE]
  }

  data
}

#' @noRd
isTRUE_vec <- function(x) {
  out <- as.logical(x)
  out[is.na(out)] <- FALSE
  out
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
