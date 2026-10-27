if (.Platform$OS.type == "windows") {
  Sys.setenv(LC_ALL = "English_United States.utf8")
  Sys.setlocale("LC_CTYPE", "English_United States.utf8")
}
options(encoding = "UTF-8")
if (!"--site-only" %in% commandArgs(trailingOnly = TRUE)) {
  devtools::document()
  devtools::test(stop_on_failure = TRUE)
  devtools::unload()
}
pkgdown::build_site(preview = FALSE, new_process = FALSE, install = TRUE)
