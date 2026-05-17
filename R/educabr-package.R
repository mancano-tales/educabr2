#' educabr: Harmonized Historical Series on Brazilian Education
#'
#' Curated long-run series on Brazilian formal education — enrollment and
#' educational attainment — compiled from heterogeneous official and
#' academic sources into a single tidy schema with explicit provenance.
#'
#' The canonical output schema (one row per observation; sources as
#' separate rows) is documented in `inst/dict/schema.yaml`. Inequality is
#' not a dataset but a *cut* applied to indicators: every `get_*()`
#' function accepts a `dimension` argument that returns the indicator
#' broken down by race, sex, income or location. The helper
#' [compute_gap()] (planned) turns long-format breakdowns into the usual
#' gap/ratio metrics.
#'
#' @section Roadmap:
#' v0 lays out the data schema, ETL pipeline and package skeleton. The
#' first user-facing functions — `get_enrollment()` and `get_schooling()`
#' — and the bundled Shiny dashboard (`run_dashboard()`) are scheduled
#' for the v0.2–v0.4 milestones. See `NEWS.md` once released.
#'
#' @keywords internal
"_PACKAGE"
