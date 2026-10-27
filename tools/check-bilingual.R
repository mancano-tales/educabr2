options(encoding = "UTF-8")
if (.Platform$OS.type == "windows") Sys.setlocale("LC_CTYPE", "English_United States.utf8")
pkgload::load_all(quiet = TRUE)
withr::with_dir("inst/dashboard", {
  env <- new.env()
  source("app.R", local = env, encoding = "UTF-8")
  stopifnot(env$dashboard_language("?lang=pt") == "pt",
            env$dashboard_language("?lang=en") == "en",
            env$dashboard_language("?lang=invalid") == "pt")
  for (lang in c("pt", "en")) {
    html <- as.character(env$dashboards[[lang]]$ui)
    expected <- if (lang == "pt") c("Visão geral", "Ver código R", "Ensino superior") else
      c("Overview", "View R code", "Tertiary Education")
    stopifnot(all(vapply(expected, grepl, logical(1), x = html, fixed = TRUE)))
    stopifnot(grepl("?lang=pt", html, fixed = TRUE), grepl("?lang=en", html, fixed = TRUE))
    cat("Dashboard UI:", lang, "OK\n")
  }
  stopifnot(env$dashboard_translate("%.1f million\n(%d)", "pt") == "%.1f milhões\n(%d)")
  # Canonical values and downloaded data must not change with UI language.
  pt <- environment(env$dashboards$pt$server)
  en <- environment(env$dashboards$en$server)
  stopifnot(identical(unname(pt$TER_NETWORK_CHOICES), unname(en$TER_NETWORK_CHOICES)))
  stopifnot(identical(pt$OV_TOTAL, en$OV_TOTAL))
  for (lang in c("pt", "en")) {
    shiny::testServer(env$dashboards[[lang]]$server, {
      session$setInputs(
        enr_geo_level = "BR", enr_level = "fundamental", enr_indicator = "rate",
        enr_dimension = "race", enr_year = c(1960, 2010),
        ter_year = c(1933, 2024), ter_network = c("total", "publica", "privada"),
        ter_inst = "total", ter_modality = c("total", "presencial", "ead"),
        ter_source = c("inep_sinopse_censup", "inep_microdados_censup"),
        ter_color_by = "network", ter_derived = TRUE,
        sch_geo_level = "BR", sch_dimension = "sex", sch_year = c(1925, 2015),
        exp_indicator = "share_gdp", exp_level = c("fundamental", "medio", "superior"),
        exp_year = c(1933, 2010), prog_geo_level = "BR", prog_year = c(1955, 2010),
        att_level = c("primary", "secondary", "tertiary"), att_geo = c("BRA", "ARG"),
        att_dimension = "sex", att_year = c(1900, 2010)
      )
      for (tab in c("enr", "ter", "sch", "exp", "prog", "att")) {
        stopifnot(length(output[[paste0(tab, "_plot")]]) > 0L)
        stopifnot(length(output[[paste0(tab, "_table")]]) > 0L)
        caption <- output[[paste0(tab, "_caption")]]
        stopifnot(grepl(if (lang == "pt") "observações" else "observations",
                        caption, fixed = TRUE))
      }
    })
    cat("Dashboard server:", lang, "OK\n")
  }
})
cat("Bilingual checks passed\n")
