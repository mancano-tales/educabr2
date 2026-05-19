#' Generate citations for educabr data sources
#'
#' Builds [utils::bibentry()] objects for the primary sources whose data
#' is harmonised in `educabr`. Use this whenever you publish analyses
#' built on a `get_*()` call — cite the originating source(s), not only
#' the package itself.
#'
#' Citation metadata is read from
#' `inst/dict/vocabularies/sources.yaml`, the same controlled vocabulary
#' that backs the `source` column of [get_enrollment()] and
#' [get_schooling()].
#'
#' @param source_key Character vector of source keys (e.g.
#'   `"kang_paese_felix_2021"`, `"walter_kang_2023"`). `NULL` (default)
#'   returns citations for **all** sources. To discover which sources
#'   contributed rows to a particular query, inspect the `source` column
#'   of the tibble returned by [get_enrollment()] or [get_schooling()].
#' @param style One of:
#'   * `"bibentry"` (default) — a [utils::bibentry()] object you can
#'     further format via [utils::toBibtex()] or [format()];
#'   * `"text"` — APA-style prose (one character string per source);
#'   * `"bibtex"` — a [utils::toBibtex()] result ready to paste into a
#'     `.bib` file.
#'
#' @return A `bibentry` object (default), a character vector, or a
#'   `Bibtex` object — see `style`. Length is 1 per requested source.
#'
#' @examples
#' # A single source (default returns a bibentry)
#' educabr_cite("kang_paese_felix_2021")
#'
#' # Plain APA-style prose
#' educabr_cite("walter_kang_2023", style = "text")
#'
#' # BibTeX entry, ready to paste into a .bib file
#' educabr_cite("paglayan_2022", style = "bibtex")
#'
#' # All bundled sources at once
#' educabr_cite()
#'
#' # Typical workflow: query, then cite only what you used
#' \dontrun{
#' d   <- get_enrollment(level = "fundamental", indicator = "rate")
#' src <- unique(d$source)
#' educabr_cite(src, style = "text")
#' }
#'
#' @seealso [get_enrollment()], [get_schooling()],
#'   [utils::bibentry()], [utils::toBibtex()].
#'
#' @export
educabr_cite <- function(source_key = NULL,
                         style = c("bibentry", "text", "bibtex")) {
  style   <- match.arg(style)
  sources <- .load_sources_vocab()

  if (is.null(source_key)) source_key <- names(sources)
  source_key <- as.character(source_key)

  unknown <- setdiff(source_key, names(sources))
  if (length(unknown)) {
    cli::cli_abort(c(
      "Unknown source key{?s}: {.val {unknown}}",
      i = "Available keys: {.val {names(sources)}}",
      i = "See {.file inst/dict/vocabularies/sources.yaml}."
    ))
  }

  entries <- lapply(source_key,
                    function(k) .source_to_bibentry(k, sources[[k]]))
  out <- Reduce(c, entries)

  switch(style,
         bibentry = out,
         text     = format(out, style = "text"),
         bibtex   = utils::toBibtex(out))
}

# ----------------------------------------------------------------------
# Internal helpers
# ----------------------------------------------------------------------

#' @noRd
.source_to_bibentry <- function(key, s) {
  prose <- .collapse_ws(s$full_name)
  year  <- .extract_year(prose)

  # bibentry(bibtype = "Misc") only requires `title`. We use the full
  # citation prose as the title so the printed bibentry renders as a
  # complete APA-style reference; DOI / URL come from the YAML.
  args <- list(
    bibtype = "Misc",
    key     = key,
    title   = prose
  )
  if (!is.null(year))  args$year <- year
  if (!is.null(s$doi)) args$doi  <- s$doi
  if (!is.null(s$url)) args$url  <- s$url

  do.call(utils::bibentry, args)
}

#' @noRd
.collapse_ws <- function(x) {
  if (is.null(x)) return("")
  trimws(gsub("\\s+", " ", x))
}

#' @noRd
.extract_year <- function(prose) {
  m <- regmatches(prose, regexpr("\\b(18|19|20)\\d{2}\\b", prose))
  if (length(m)) m[[1]] else NULL
}

#' @noRd
.load_sources_vocab <- function() {
  path <- system.file("dict", "vocabularies", "sources.yaml",
                      package = "educabr")
  if (!nzchar(path)) {
    path <- file.path("inst", "dict", "vocabularies", "sources.yaml")
  }
  if (!file.exists(path)) {
    cli::cli_abort("Source vocabulary not found at expected paths.")
  }
  y <- yaml::read_yaml(path)
  if (is.null(y$sources)) list() else y$sources
}
