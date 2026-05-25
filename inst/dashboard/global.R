# educabr2 is not on CRAN — it must be installed from GitHub.
# This block handles the auto-install so the dashboard works on shinyapps.io
# and when someone clones the repo and runs the app locally.
#
# To install manually:
#   remotes::install_github("mancano-tales/educabr2")
if (!requireNamespace("educabr2", quietly = TRUE)) {
  if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
  remotes::install_github("mancano-tales/educabr2")
}
