#' Source-key aliases (canonical name -> legacy key carried by the data)
#'
#' Walter & Kang circulated as a 2023 FGV-IBRE working paper when the
#' internal key was minted, but the peer-reviewed article came out in 2024
#' (Economic History of Developing Regions). Until the physical rename of
#' the .rda/ETL key (post-defense), both spellings must resolve to the
#' legacy key that the data rows still carry.
#' @noRd
.SOURCE_KEY_ALIASES <- c(
  "walter_kang_2024" = "walter_kang_2023"
)

#' Normalise user-supplied source keys to the keys carried by the data.
#'
#' Accepts the canonical (new) spelling of aliased keys and maps it to the
#' legacy key present in the bundled datasets, leaving all other keys
#' untouched. `NULL` passes through so "no source filter" keeps meaning
#' "all sources".
#' @noRd
.normalise_source_keys <- function(source) {
  if (is.null(source)) return(NULL)
  source <- as.character(source)
  hits <- source %in% names(.SOURCE_KEY_ALIASES)
  source[hits] <- unname(.SOURCE_KEY_ALIASES[source[hits]])
  unique(source)
}

#' Load the canonical educabr2 schema.
#'
#' Reads `inst/dict/schema.yaml` and returns the parsed content. Falls
#' back to the source-tree path when called during package development
#' (where `system.file()` returns an empty string).
#'
#' @return A list with elements `columns`, `constraints`, `conventions`.
#' @keywords internal
#' @noRd
load_schema <- function() {
  path <- system.file("dict", "schema.yaml", package = "educabr2")
  if (!nzchar(path)) {
    path <- file.path("inst", "dict", "schema.yaml")
  }
  if (!file.exists(path)) {
    rlang::abort(sprintf("Schema file not found at %s", path))
  }
  yaml::read_yaml(path)
}

#' Validate a data frame against the canonical schema.
#'
#' Minimal v0 checks executed before `usethis::use_data()`:
#'   * required columns present;
#'   * declared factor levels respected;
#'   * `year` within the declared domain;
#'   * no duplicates over the primary-key columns that exist in `df`.
#'
#' @param df A data frame.
#' @param theme Optional theme name (currently unused; reserved for
#'   per-theme indicator restrictions added in later milestones).
#'
#' @return Invisibly returns `df`. Aborts on failure with a single
#'   cli message listing every problem found.
#' @keywords internal
#' @noRd
validate_against_schema <- function(df, theme = NULL) {
  schema <- load_schema()
  cols <- schema$columns
  problems <- character()

  required <- vapply(cols, function(c) isTRUE(c$required), logical(1))
  required_names <- vapply(cols[required], `[[`, character(1), "name")
  missing_req <- setdiff(required_names, names(df))
  if (length(missing_req)) {
    problems <- c(problems,
      sprintf("Missing required column(s): %s",
              paste(missing_req, collapse = ", ")))
  }

  for (c in cols) {
    if (!is.null(c$levels) && c$name %in% names(df)) {
      vals <- unique(stats::na.omit(df[[c$name]]))
      bad <- setdiff(as.character(vals), as.character(c$levels))
      if (length(bad)) {
        problems <- c(problems,
          sprintf("Column '%s' has undeclared level(s): %s",
                  c$name, paste(bad, collapse = ", ")))
      }
    }
  }

  if ("year" %in% names(df)) {
    yr <- schema$constraints$domain$year
    if (!is.null(yr)) {
      out <- df$year[!is.na(df$year) & (df$year < yr$min | df$year > yr$max)]
      if (length(out)) {
        problems <- c(problems,
          sprintf("Year(s) outside [%d, %d]: %s",
                  yr$min, yr$max,
                  paste(utils::head(unique(out)), collapse = ", ")))
      }
    }
  }

  if ("value" %in% names(df)) {
    n_na <- sum(is.na(df$value))
    if (n_na) {
      problems <- c(problems, sprintf("%d row(s) with NA `value`.", n_na))
    }
    if (isFALSE(schema$constraints$domain$value$allow_negative)) {
      n_neg <- sum(df$value < 0, na.rm = TRUE)
      if (n_neg) {
        problems <- c(problems, sprintf("%d row(s) with negative `value`.", n_neg))
      }
    }
  }

  pk <- intersect(unlist(schema$constraints$primary_key), names(df))
  if (length(pk)) {
    dups <- duplicated(df[, pk, drop = FALSE])
    if (any(dups)) {
      problems <- c(problems,
        sprintf("Duplicate primary key (%s) on %d row(s).",
                paste(pk, collapse = "+"), sum(dups)))
    }
  }

  if (length(problems)) {
    cli::cli_abort(c(
      "Schema validation failed:",
      stats::setNames(problems, rep("x", length(problems)))
    ))
  }
  invisible(df)
}
