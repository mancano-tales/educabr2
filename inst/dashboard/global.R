# The app never installs packages itself (CRAN policy). shinyapps.io
# installs educabr2 from the deployment manifest written by rsconnect; to
# run the app locally, install the package first, e.g.
#   remotes::install_github("mancano-tales/educabr2")
if (!requireNamespace("educabr2", quietly = TRUE)) {
  stop("The educabr2 package is required to run this dashboard. ",
       "Install it first, e.g. remotes::install_github(\"mancano-tales/educabr2\").",
       call. = FALSE)
}
