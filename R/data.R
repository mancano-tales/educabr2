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
#'   BR — primário (anos iniciais)    \tab 1871–1932    \tab count          \cr
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

#' Tertiary (ensino superior) enrollment — multi-source compilation
#'
#' National-level (BR) Brazilian higher-education enrollment from 1907
#' to 2024, harmonised across seven different primary sources. The
#' dataset is consumed by [get_enrollment()] when `level = "superior"`.
#' Multiple sources for the same `(year, network)` are kept on purpose
#' so users can compare competing estimates — pass `source = "..."`
#' to lock in a specific series.
#'
#' @format A tibble with approximately 1 350 rows and 16 columns
#'   matching the canonical schema (`inst/dict/schema.yaml`). The
#'   tertiary-specific columns are:
#' \describe{
#'   \item{level}{Always `"superior"`.}
#'   \item{network}{Administrative dependency: `federal`, `estadual`,
#'     `municipal`, `publica`, `privada`, plus the private sub-categories
#'     (`privada_particular` / `privada_comunitaria_confessional_filantropica`
#'     pre-2009, `privada_lucrativa` / `privada_nao_lucrativa` post-2009),
#'     `especial`, `total`.}
#'   \item{institution_type}{INEP/MEC institutional category:
#'     `university`, `university_center`, `faculty`,
#'     `faculty_school_institute`, `integrated_faculty`,
#'     `integrated_faculty_university_center`, `technology_center`,
#'     `technology_center_fat`, `cefet_ifet`, `isolated_establishment`,
#'     `total`.}
#'   \item{modality}{`presencial`, `ead`, or `total` (available from
#'     2000 onwards).}
#'   \item{is_derived}{`TRUE` when the row is a **reconstructed total**
#'     — a computed total combining the in-person enrollment from one
#'     source with the EAD enrollment from INEP, used to fix the
#'     2000-2008 transition gap where the original sources excluded
#'     EAD from their nominal totals. Filtered out by
#'     `get_enrollment()` unless `include_derived = TRUE`.}
#' }
#'
#' @section Primary sources:
#' \itemize{
#'   \item `ibge_seculo_xx` — Anuários Estatísticos 1908-1980.
#'   \item `durham_2005` — Durham (2005).
#'   \item `maduro_junior_2007` — Maduro Junior MSc dissertation.
#'   \item `kang_paese_felix_2021` — Kang, Paese & Felix RHE paper.
#'   \item `inep_sinopse_censup` — INEP Sinopse 1995-2008.
#'   \item `inep_microdados_censup` — INEP microdata 2009-2024.
#'   \item `inep_censup_powerbi` — INEP Power BI panel.
#' }
#' For derived rows the `source` column is the concatenation
#' `"<presencial_key>+<ead_key>"`; the exact composition is documented
#' in `source_note`.
#'
#' @source Compilation curated by the package author (Mançano, 2026)
#'   from publicly available sources. Raw file:
#'   `data-raw/sources/tertiary_multisource/data_tertiary_v6_clean.xlsx`.
#'   ETL: `data-raw/03_build_enrollment_tertiary.R`.
"enrollment_tertiary"

#' Mean years of schooling — Walter & Kang 2023 compilation
#'
#' Long-run Brazilian mean years of schooling reconstructed by Walter &
#' Kang (2023) from Censuses and household surveys. The dataset is the
#' internal backing store consumed by [get_schooling()]; end-users
#' should call that function rather than loading this object directly.
#'
#' @format A tibble with approximately 2 300 rows and 12 columns:
#' \describe{
#'   \item{year}{`integer`. Reference year (1925–2015). BR-level series
#'     starts in 1925; region and UF series start in 1950.}
#'   \item{geo_level}{`character`. `"BR"`, `"region"`, or `"UF"`.}
#'   \item{geo_code}{`character`. `"BR"` for national; IBGE single/double-
#'     letter macro-region code (`"N"`, `"NE"`, `"CO"`, `"SE"`, `"S"`);
#'     or IBGE 2-letter UF code.}
#'   \item{geo_name}{`character`. Human-readable geographic name in
#'     Portuguese.}
#'   \item{dim_race}{`character`. Race/colour dimension: `"white"`,
#'     `"black"`, `"brown"`, `"asian"`, `"indigenous"`, or `"total"`.
#'     Race breakdown available at BR level only.}
#'   \item{dim_sex}{`character`. Sex: `"male"`, `"female"`, or `"total"`.
#'     Sex breakdown available at BR level only.}
#'   \item{age_group}{`character`. Always `NA` in this dataset; included
#'     for schema compatibility.}
#'   \item{indicator}{`character`. Always `"mean_years_schooling"`.}
#'   \item{value}{`double`. Mean years of schooling of the adult
#'     population.}
#'   \item{unit}{`character`. Always `"years"`.}
#'   \item{source}{`character`. Always `"walter_kang_2023"`.}
#'   \item{source_note}{`character`. Inline bibliographic reference.}
#' }
#'
#' @section Coverage:
#' \tabular{lll}{
#'   **Scope**               \tab **Years**  \tab **Breakdowns**  \cr
#'   BR — total              \tab 1925–2015  \tab —               \cr
#'   BR — by sex             \tab 1925–2015  \tab male, female    \cr
#'   BR — by race            \tab 1925–2015  \tab 4 categories    \cr
#'   Macro-region (5 regiões)\tab 1950–2015  \tab —               \cr
#'   UF (27 estados)         \tab 1950–2015  \tab —               \cr
#' }
#'
#' @source Walter, J., & Kang, T. H. (2023). A new dataset of average
#'   years of schooling in Brazil, 1925-2015. FGV-IBRE working paper.
#'   ETL script: `data-raw/02_build_schooling_kang_fgv.R`.
"schooling_kang_fgv"

#' Public expenditure on education — Kang & Menetrier 2024 compilation
#'
#' Long-run Brazilian public expenditure on education, compiled by Kang
#' & Menetrier (2024) from a combination of national-accounts sources
#' (Anuário Estatístico, IPEA, FGV-IBRE) and educational statistics. The
#' dataset is the internal backing store consumed by [get_expenditure()];
#' end-users should call that function rather than loading this object
#' directly.
#'
#' @format A tibble with approximately 1 170 rows and 13 columns:
#' \describe{
#'   \item{year}{`integer`. Reference year (1933–2010).}
#'   \item{geo_level}{`character`. Always `"BR"`.}
#'   \item{geo_code}{`character`. Always `"BR"`.}
#'   \item{geo_name}{`character`. Always `"Brasil"`.}
#'   \item{level}{`character`. Education stage:
#'     `"fundamental_anos_iniciais"`, `"fundamental_anos_finais"`,
#'     `"fundamental"`, `"medio"`, `"fundamental_medio"` (EF+EM combined,
#'     i.e. educação básica regular), `"superior"`, or `"total"`. The
#'     two "double ratio" indicators carry `level = "total"` because
#'     they are system-wide ratios rather than per-stage values.}
#'   \item{network}{`character`. Always `"publica"` — these are
#'     public-sector expenditure indicators.}
#'   \item{dim_race}{`character`. Always `"total"`.}
#'   \item{age_group}{`character`. Always `NA`.}
#'   \item{indicator}{`character`. One of `"expenditure_share_gdp"`,
#'     `"expenditure_per_student_pct_gdp_pc"`,
#'     `"expenditure_double_ratio_es_ef1"`,
#'     `"expenditure_double_ratio_es_ef_em"`.}
#'   \item{value}{`double`.}
#'   \item{unit}{`character`. One of `"percent_gdp"`,
#'     `"percent_gdp_per_capita"`, or `"ratio"` (for the double ratios).}
#'   \item{source}{`character`. Always `"kang_menetrier_2024"`.}
#'   \item{source_note}{`character`. Inline bibliographic reference.}
#' }
#'
#' @section Coverage:
#' \tabular{lll}{
#'   **Indicator**                                  \tab **Stages**                  \tab **Years**    \cr
#'   `expenditure_share_gdp`                        \tab EF1/EF2/EF/EM/EF+EM/ES/total \tab 1933–2010    \cr
#'   `expenditure_per_student_pct_gdp_pc`           \tab EF1/EF2/EF/EM/EF+EM/ES       \tab 1933–2010    \cr
#'   `expenditure_double_ratio_es_ef1`              \tab —                           \tab 1933–2010    \cr
#'   `expenditure_double_ratio_es_ef_em`            \tab —                           \tab 1933–2010    \cr
#' }
#'
#' @source Kang, T. H., & Menetrier, I. (2024). Políticas elitistas e
#'   despesas públicas em educação no Brasil, 1933-2010. *Estudos
#'   Econômicos (São Paulo)*, 54(3), e53575434.
#'   \doi{10.1590/1980-53575434tkim}. Compilation: FGV/IBRE (April 2023
#'   revision). ETL script: `data-raw/04_build_expenditure_kang_fgv.R`.
"expenditure_kang_fgv"

#' Grade-progression series (GDR6) — Kang, Paese & Felix 2021 compilation
#'
#' Long-run Brazilian grade-progression ratio reconstructed by Kang,
#' Paese & Felix (2021). The bundled indicator is **GDR6** (Gross
#' Distribution Ratio for grade 6, defined as the ratio of enrollment
#' in grades 4-6 to enrollment in grades 1-3 of the old eight-year
#' primary system), reported for BR and 20 federation units, 1955-2010.
#' The dataset is the internal backing store consumed by
#' [get_progression()].
#'
#' @format A tibble with approximately 1 090 rows and 13 columns:
#' \describe{
#'   \item{year}{`integer`. Reference year (1955–2010).}
#'   \item{geo_level}{`character`. `"BR"` or `"UF"`.}
#'   \item{geo_code}{`character`. `"BR"` or 2-letter IBGE UF code.}
#'   \item{geo_name}{`character`. Human-readable geographic name.}
#'   \item{level}{`character`. Always `"fundamental_anos_iniciais"`.}
#'   \item{network}{`character`. Always `"total"`.}
#'   \item{dim_race}{`character`. Always `"total"`.}
#'   \item{age_group}{`character`. Always `NA`.}
#'   \item{indicator}{`character`. Always
#'     `"gross_distribution_ratio_grade_6"`.}
#'   \item{value}{`double`. Unitless ratio (typically in the 0.1–1.0
#'     range).}
#'   \item{unit}{`character`. Always `"ratio"`.}
#'   \item{source}{`character`. Always `"kang_paese_felix_2021"`.}
#'   \item{source_note}{`character`. Inline bibliographic reference.}
#' }
#'
#' @section UF coverage:
#' Kang, Paese & Felix's compilation covers 20 federation units
#' (AL, AM, BA, CE, ES, GO, MA, MG, MT, PA, PB, PE, PI, PR, RJ, RN, RS,
#' SC, SE, SP). Newer or territorial-origin UFs (AC, AP, DF, MS, RO,
#' RR, TO) are not covered by the source. National BR series has gaps
#' at 1988, 1989, 1990 and 1994 reflecting transitions in the official
#' grade structure.
#'
#' @source Kang, T. H., Paese, L. H. Z., & Felix, N. F. A. (2021). Late
#'   and unequal: Enrolments and retention in Brazilian education,
#'   1933-2010. *Revista de Historia Económica*, 39(2), 191–218.
#'   \doi{10.1017/S0212610921000112}. Compilation: FGV/IBRE (April 2023
#'   revision). ETL script: `data-raw/05_build_progression_kang_fgv.R`.
"progression_kang_fgv"
