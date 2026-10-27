#' Launch the educabr2 Shiny dashboard
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
#' @section Português:
#' Abre o painel Shiny local, que usa a API pública para explorar os dados
#' distribuídos com o pacote. Há também um painel público, vinculado no README.
#'
#' - `lang`: idioma inicial da interface, `"pt"` (padrão) ou `"en"`.
#'   Os links Português/English permitem alternar o idioma, reiniciando filtros.
#'   A URL `?lang=pt` ou `?lang=en` tem precedência sobre o idioma inicial.
#' - `...`: argumentos de `shiny::runApp()`, como `port`, `host` e `launch.browser`.
#'
#' Inicia a aplicação por efeito colateral e devolve o resultado de
#' `shiny::runApp()`. Consultas e downloads preservam chaves canônicas;
#' controles, gráficos, mensagens e tabelas usam o idioma escolhido.
#'
#' @return Invoked for its side effect (starts the Shiny app). Returns
#'   the value of [shiny::runApp()] invisibly.
#' @examples
#' \dontrun{
#' run_dashboard(lang = "pt")
#' run_dashboard(lang = "en")
#' }
#' @export
run_dashboard <- function(lang = c("pt", "en"), ...) {
  lang <- match.arg(lang)

  rlang::check_installed(
    c("shiny", "bslib", "ggplot2", "plotly", "scales", "DT"),
    reason = "to launch the educabr2 dashboard"
  )

  app_dir <- system.file("dashboard", package = "educabr2")
  if (!nzchar(app_dir)) {
    cli::cli_abort(c(
      "Dashboard files not found.",
      i = "If you are developing the package, call {.code shiny::runApp(\"inst/dashboard\")} from the package root."
    ))
  }

  old <- options(educabr2.dashboard.lang = lang)
  on.exit(options(old), add = TRUE)

  shiny::runApp(app_dir, ...)
}
