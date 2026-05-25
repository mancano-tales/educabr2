#' List the data sources bundled with educabr2
#'
#' Returns a tibble describing every entry in the controlled source
#' vocabulary
#' (`inst/dict/vocabularies/sources.yaml`). One row per source key,
#' carrying short name, type, temporal/geographic coverage, DOI, URL
#' and free-text notes. Use this to discover which sources are
#' available before calling [educabr_cite()] or filtering
#' [get_enrollment()] / [get_schooling()] with the `source` argument.
#'
#' @return A `tibble` with columns:
#' \describe{
#'   \item{`key`}{the source key used in the `source` column of
#'     [get_enrollment()] / [get_schooling()] output.}
#'   \item{`short_name`}{compact human-readable label.}
#'   \item{`type`}{one of `"academic"`, `"academic_thesis"`,
#'     `"official_survey"`, `"census"`, `"administrative"`,
#'     `"administrative_microdata"`, `"historical_compilation"`.}
#'   \item{`year_start`, `year_end`}{integer; `year_end` is `NA` for
#'     ongoing series.}
#'   \item{`geo`}{character; comma-separated list of geographic
#'     levels covered (`"BR"`, `"region"`, `"UF"`).}
#'   \item{`doi`}{character; `NA` when the source has none.}
#'   \item{`url`}{stable URL for the source.}
#'   \item{`notes`}{free-text remarks from the YAML.}
#' }
#'
#' @examples
#' src <- list_sources()
#' head(src)
#'
#' # Filter to academic papers only
#' src[src$type == "academic", c("key", "short_name", "doi")]
#'
#' # Sources that include UF-level coverage
#' src[grepl("UF", src$geo), c("key", "year_start", "year_end")]
#'
#' @seealso [educabr_cite()], [get_enrollment()], [get_schooling()].
#' @export
list_sources <- function() {
  sources <- .load_sources_vocab()
  if (length(sources) == 0L) {
    return(tibble::tibble(
      key = character(), short_name = character(), type = character(),
      year_start = integer(), year_end = integer(),
      geo = character(), doi = character(), url = character(),
      notes = character()
    ))
  }

  rows <- lapply(names(sources), function(k) {
    s <- sources[[k]]
    cov <- s$coverage %||% list()
    years <- cov$years %||% list(NA, NA)
    geo <- cov$geo %||% character()

    tibble::tibble(
      key        = k,
      short_name = .scalar_chr(s$short_name) %||% NA_character_,
      type       = .scalar_chr(s$type)       %||% NA_character_,
      year_start = .as_int_or_na(years[[1]]),
      year_end   = .as_int_or_na(if (length(years) >= 2L) years[[2]] else NA),
      geo        = if (length(geo)) paste(geo, collapse = ", ")
                   else NA_character_,
      doi        = .scalar_chr(s$doi)        %||% NA_character_,
      url        = .scalar_chr(s$url)        %||% NA_character_,
      notes      = .collapse_ws(s$notes)
    )
  })

  do.call(rbind, rows)
}

#' @noRd
.scalar_chr <- function(x) {
  if (is.null(x)) return(NULL)
  v <- as.character(x)
  v <- .collapse_ws(v)
  if (!nzchar(v)) NULL else v
}

#' @noRd
.as_int_or_na <- function(x) {
  if (is.null(x)) return(NA_integer_)
  out <- suppressWarnings(as.integer(x))
  if (length(out) == 0L) NA_integer_ else out
}
