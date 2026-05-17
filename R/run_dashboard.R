#' Launch the educabr Shiny dashboard
#'
#' Opens a local Shiny app that explores the data shipped by the
#' package. The app consumes only the public API ([get_enrollment()])
#' so any improvement to the data flows through it automatically.
#'
#' The dashboard is also deployed publicly (link in the README) for
#' users who prefer not to install R locally.
#'
#' @param lang Default UI language. One of `"pt"` (default) or `"en"`.
#' @param ... Passed to [shiny::runApp()] (e.g. `port`, `launch.browser`,
#'   `host`).
#'
#' @return Invoked for its side effect (starts the Shiny app). Returns
#'   the value of [shiny::runApp()] invisibly.
#' @export
run_dashboard <- function(lang = c("pt", "en"), ...) {
  lang <- match.arg(lang)

  rlang::check_installed(
    c("shiny", "bslib", "ggplot2", "plotly", "scales", "DT"),
    reason = "to launch the educabr dashboard"
  )

  app_dir <- system.file("dashboard", package = "educabr")
  if (!nzchar(app_dir)) {
    cli::cli_abort(c(
      "Dashboard files not found.",
      i = "If you are developing the package, call {.code shiny::runApp(\"inst/dashboard\")} from the package root."
    ))
  }

  old <- options(educabr.dashboard.lang = lang)
  on.exit(options(old), add = TRUE)

  shiny::runApp(app_dir, ...)
}
