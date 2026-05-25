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
