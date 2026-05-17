#' Enrollment series — Kang / FGV-IBRE 2023 compilation
#'
#' Long-run Brazilian school enrollment data compiled and harmonized by
#' Kang, Paese & Felix (2021) and refreshed by FGV/IBRE in April 2023.
#' The dataset is the internal backing store consumed by
#' [get_enrollment()]; end-users should call that function rather than
#' loading this object directly, as it applies filters, label
#' translation, and optional pivoting.
#'
#' @format A tibble with 6 238 rows and 13 columns:
#' \describe{
#'   \item{year}{`integer`. Reference year of the observation (1871–2010).}
#'   \item{geo_level}{`character`. Geographic aggregation level:
#'     `"BR"` (national) or `"UF"` (state).}
#'   \item{geo_code}{`character`. Geographic code: `"BR"` for national;
#'     IBGE 2-letter UF abbreviation (e.g. `"SP"`, `"BA"`) for states.}
#'   \item{geo_name}{`character`. Human-readable geographic name in
#'     Portuguese (e.g. `"Brasil"`, `"São Paulo"`).}
#'   \item{level}{`character`. Education stage using the educabr vocabulary:
#'     `"fundamental_anos_iniciais"`, `"fundamental_anos_finais"`,
#'     `"fundamental"`, `"medio"`, `"superior"`.}
#'   \item{network}{`character`. Administrative dependency.
#'     Always `"total"` in this source (no network breakdown available).}
#'   \item{dim_race}{`character`. Race/colour dimension using the educabr
#'     vocabulary (`"white"`, `"black"`, `"brown"`, `"asian"`,
#'     `"indigenous"`). `"total"` when not disaggregated. Race breakdown
#'     is available at BR level for 1960–2010 only.}
#'   \item{age_group}{`character`. Reference age bracket of the rate
#'     indicator (e.g. `"7-14"`, `"15-17"`, `"18-24"`). `NA` for count
#'     indicators, which are headcounts not tied to a population bracket.}
#'   \item{indicator}{`character`. Indicator key: `"enrollment_count"`
#'     (absolute headcount) or `"enrollment_rate"` (gross enrollment rate,
#'     0–100 scale).}
#'   \item{value}{`double`. Numeric value of the indicator.}
#'   \item{unit}{`character`. Unit of measurement: `"count"` or
#'     `"percent"`.}
#'   \item{source}{`character`. Compact source key: `"kang_fgv_ibre_2023"`.
#'     Full metadata in `inst/dict/vocabularies/sources.yaml`.}
#'   \item{source_note}{`character`. Inline bibliographic reference.}
#' }
#'
#' @section Coverage:
#' \tabular{lll}{
#'   **Scope**                        \tab **Years**    \tab **Indicators** \cr
#'   BR — ensino primário/anos inic.  \tab 1871–1932    \tab count          \cr
#'   BR — all stages (EF, EM, ES)     \tab 1933–2010    \tab count, rate    \cr
#'   BR — by race (EF, EM, ES)        \tab 1960–2010    \tab count, rate    \cr
#'   UF — ensino fundamental          \tab 1955–2010    \tab count, rate    \cr
#' }
#'
#' @section Schema:
#' Column definitions, primary-key constraints, and unit conventions are
#' specified in `inst/dict/schema.yaml`. The dataset is validated against
#' that schema every time it is rebuilt (see
#' `data-raw/01_build_enrollment_kang_fgv.R`).
#'
#' @source Kang, T., Paese, A., & Felix, R. (2021). Late and Unequal:
#'   Historical Enrollment Rates in Brazil, 1871–2010. *Revista de
#'   Historia Económica*, 39(2), 191–218.
#'   \doi{10.1017/S0212610920000099}.
#'   Data compilation: FGV/IBRE (April 2023 revision).
#'   ETL script: `data-raw/01_build_enrollment_kang_fgv.R`.
"enrollment_kang_fgv"
