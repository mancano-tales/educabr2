# 03_build_enrollment_tertiary.R
#
# ETL: tertiary (ensino superior) enrollment, multi-source compilation.
# Reads data-raw/sources/tertiary_multisource/data_tertiary_v6_clean.xlsx
# and produces `enrollment_tertiary` saved to data/enrollment_tertiary.rda.
#
# The xlsx is the user's working compilation built for the MA thesis
# (Mançano, 2026). It harmonises tertiary enrollment from:
#
#   * IBGE Estatísticas do Século XX (Anuários 1908-1980)        — long history
#   * Durham (2005) — dropped in step 5c' (secondary source, inconsistent table)
#   * Maduro Junior (2007, MSc dissertation, FGV/EPGE)
#   * Kang, Paese & Felix (2021) — Late and unequal
#   * INEP Sinopse Estatística CENSUP (1995-2008)
#   * INEP Microdados CENSUP (2009-2024)
#   * INEP CENSUP Power BI panel
#
# Multiple sources for the same (year, level, network) are kept on
# purpose so users can compare/contrast competing estimates via the
# `source` argument of `get_enrollment()`.
#
# Composite enrollment_type strings (e.g. "Public_Federal_University_Presencial")
# are decomposed into orthogonal columns: network + institution_type + modality.
#
# Derived rows (Presencial from one source + EAD from another) are kept
# with `is_derived = TRUE`. Default `get_enrollment(include_derived = FALSE)`
# filters them out.
#
# Run from the package root:
#   source("data-raw/03_build_enrollment_tertiary.R")

library(dplyr)
library(tidyr)
library(stringr)
library(readxl)

stopifnot(file.exists("DESCRIPTION"))

src_file <- "data-raw/sources/tertiary_multisource/data_tertiary_v6_clean.xlsx"

# ---------------------------------------------------------------------
# 1. Read raw v6
# ---------------------------------------------------------------------

raw <- readxl::read_excel(src_file, sheet = "Sheet1")

stopifnot(all(c("year_key", "enrollment_type", "breakdown_type",
                "numbahs", "data_source") %in% names(raw)))

cat("Raw rows:", nrow(raw), "\n")

# ---------------------------------------------------------------------
# 2. Parse composite enrollment_type into (network, institution_type, modality)
# ---------------------------------------------------------------------

# Network prefixes — order matters: longest-match first within each family.
network_prefixes <- list(
  "Public_Federal"                                   = "federal",
  "Public_State"                                     = "estadual",
  "Public_Municipal"                                 = "municipal",
  "Public"                                           = "publica",
  "Private_Community_Confessional_Philanthropic"     = "privada_comunitaria_confessional_filantropica",
  "Private_For_Profit"                               = "privada_lucrativa",
  "Private_Non_Profit"                               = "privada_nao_lucrativa",
  "Private_Particular"                               = "privada_particular",
  "Private"                                          = "privada",
  "Especial"                                         = "especial",
  "Total"                                            = "total"
)

# Institution types — longest first to avoid ambiguity.
institution_types <- c(
  "University_Center"                    = "university_center",
  "University"                           = "university",
  "Faculty_School_Institute"             = "faculty_school_institute",
  "Integrated_Faculty_University_Center" = "integrated_faculty_university_center",
  "Integrated_Faculty"                   = "integrated_faculty",
  "Faculty"                              = "faculty",
  "Technology_Center_FaT"                = "technology_center_fat",
  "Technology_Center"                    = "technology_center",
  "CEFET_IFET"                           = "cefet_ifet",
  "Isolated_Establishment"               = "isolated_establishment"
)

parse_enrollment_type <- function(s) {
  network <- "total"
  institution_type <- "total"
  modality <- "total"

  # Strip modality suffix
  if (endsWith(s, "_EAD")) {
    modality <- "ead"
    s <- substr(s, 1, nchar(s) - 4)
  } else if (endsWith(s, "_Presencial")) {
    modality <- "presencial"
    s <- substr(s, 1, nchar(s) - 11)
  }

  # Match longest network prefix
  for (prefix in names(network_prefixes)) {
    if (s == prefix || startsWith(s, paste0(prefix, "_"))) {
      network <- network_prefixes[[prefix]]
      s <- substr(s, nchar(prefix) + 1, nchar(s))
      if (startsWith(s, "_")) s <- substr(s, 2, nchar(s))
      break
    }
  }

  # Remaining text should match an institution_type
  if (nchar(s) > 0) {
    matched <- FALSE
    for (pat in names(institution_types)) {
      if (s == pat) {
        institution_type <- institution_types[[pat]]
        matched <- TRUE
        break
      }
    }
    if (!matched) {
      warning(sprintf("Unparsed remainder for enrollment_type: '%s'", s))
    }
  }

  c(network, institution_type, modality)
}

parsed <- t(vapply(raw$enrollment_type, parse_enrollment_type,
                   character(3), USE.NAMES = FALSE))
colnames(parsed) <- c("network", "institution_type", "modality")
raw <- cbind(raw, as.data.frame(parsed, stringsAsFactors = FALSE))

# ---------------------------------------------------------------------
# 3. Canonicalise `data_source` to sources.yaml keys
# ---------------------------------------------------------------------

# Returns a list with: source (canonical), source_note (human), is_derived
canonicalise_source <- function(ds) {
  # ---- derived rows ------------------------------------------------
  if (startsWith(ds, "derived_")) {
    # Pattern: derived_Presencial(<X>)+EAD(<Y>)
    m <- regmatches(ds, regexec("^derived_Presencial\\(([^)]+)\\)\\+EAD\\(([^)]+)\\)$", ds))[[1]]
    pres_key <- if (length(m) >= 3) canonicalise_source(m[2])$source else "unknown"
    ead_key  <- if (length(m) >= 3) canonicalise_source(m[3])$source else "unknown"
    return(list(
      source      = paste0(pres_key, "+", ead_key),
      source_note = sprintf(
        "Derived (computed total): Presencial component from '%s'; EAD component from '%s'. The original source did not publish a combined Presencial+EAD figure for this year.",
        m[2], m[3]
      ),
      is_derived  = TRUE
    ))
  }

  # ---- natural rows ------------------------------------------------
  # IBGE Estatísticas do Século XX
  if (grepl("^educacao[0-9]", ds)) {
    note <- sprintf("IBGE Estatísticas do Século XX — referência '%s' (Anuário Estatístico do Brasil).", ds)
    return(list(source = "ibge_seculo_xx", source_note = note, is_derived = FALSE))
  }
  # INEP Sinopse CENSUP (1995-2008)
  # Note: R's grepl defaults to POSIX ERE where `\d` is not a digit class.
  # Use [0-9] for portability.
  if (grepl("^CENSUP(19[0-9]{2}|200[0-8])_tabela", ds, ignore.case = FALSE) ||
      grepl("^Sinopse_CENSUP_", ds)) {
    note <- sprintf("INEP Sinopse Estatística da Educação Superior — referência '%s'.", ds)
    return(list(source = "inep_sinopse_censup", source_note = note, is_derived = FALSE))
  }
  # INEP Microdados (2009-2024)
  if (grepl("^CENSUP[0-9]{4}_microdados$", ds)) {
    year <- as.integer(substr(ds, 7, 10))
    note <- sprintf("INEP Microdados do CENSUP %d (MICRODADOS_CADASTRO_CURSOS_%d.CSV; agregação TP_CATEGORIA_ADMINISTRATIVA × TP_MODALIDADE_ENSINO × QT_MAT).", year, year)
    return(list(source = "inep_microdados_censup", source_note = note, is_derived = FALSE))
  }
  # INEP Power BI
  if (ds == "INEP_Power_BI") {
    return(list(
      source      = "inep_censup_powerbi",
      source_note = paste(
        "INEP CENSUP Power BI — painel consolidado do INEP (anos 2010-2024).",
        "Os valores reproduzem a agregação dos microdados; o painel classifica",
        "a categoria 'Especial' (art. 242 CF) como pública municipal, critério",
        "também aplicado às linhas de microdados deste pacote.",
        "Mantido como estimativa alternativa do INEP."
      ),
      is_derived  = FALSE
    ))
  }
  # Durham (2005), keyed under 2003 in the source file
  if (ds == "Durham2003") {
    return(list(
      source      = "durham_2005",
      source_note = "Durham (2005). Educação superior, pública e privada. In Os desafios da educação no Brasil (Schwartzman, ed.), pp. 191-233.",
      is_derived  = FALSE
    ))
  }
  # Maduro Junior (2007)
  if (ds == "MaduroJunior2007") {
    return(list(
      source      = "maduro_junior_2007",
      source_note = "Maduro Junior (2007). Taxas de matrícula e gastos em educação no Brasil [Diss. MSc, FGV/EPGE]. hdl:10438/110.",
      is_derived  = FALSE
    ))
  }
  # Kang/Paese/Felix
  if (ds == "Kang-Paese-Felix2021_fgv_ibre4") {
    return(list(
      source      = "kang_paese_felix_2021",
      source_note = "Kang, Paese & Felix (2021), RHE 39(2):191-218. doi:10.1017/S0212610921000112. Arquivo 4 da compilação FGV/IBRE 2023.",
      is_derived  = FALSE
    ))
  }

  warning(sprintf("Unmapped data_source: '%s' — falling back to raw string.", ds))
  list(source = ds, source_note = ds, is_derived = FALSE)
}

prov <- lapply(raw$data_source, canonicalise_source)
raw$source      <- vapply(prov, `[[`, character(1), "source")
raw$source_note <- vapply(prov, `[[`, character(1), "source_note")
raw$is_derived  <- vapply(prov, `[[`, logical(1),   "is_derived")

# ---------------------------------------------------------------------
# 4. Assemble final tibble in canonical schema
# ---------------------------------------------------------------------

enrollment_tertiary <- tibble::tibble(
  year             = as.integer(raw$year_key),
  geo_level        = "BR",
  geo_code         = "BR",
  geo_name         = "Brasil",
  level            = "superior",
  network          = raw$network,
  institution_type = raw$institution_type,
  modality         = raw$modality,
  dim_race         = "total",
  age_group        = NA_character_,
  indicator        = "enrollment_count",
  value            = as.numeric(raw$numbahs),
  unit             = "count",
  source           = raw$source,
  source_note      = raw$source_note,
  is_derived       = raw$is_derived
) |>
  dplyr::arrange(year, network, institution_type, modality, source)

cat("Built rows:", nrow(enrollment_tertiary), "\n")
cat("\nRows by source:\n")
print(dplyr::count(enrollment_tertiary, source, sort = TRUE))
cat("\nRows by (network, institution_type, modality) combinations:\n")
print(dplyr::count(enrollment_tertiary, network, institution_type, modality, sort = TRUE) |> head(20))
cat("\nDerived vs natural:\n")
print(dplyr::count(enrollment_tertiary, is_derived))

# ---------------------------------------------------------------------
# 5. Drop exact-duplicate rows (data-quality safeguard for the v6 file)
# ---------------------------------------------------------------------
#
# The v6 xlsx ships with a small set of literal duplicate rows in the
# 2009 microdata layer (likely an artefact of an incremental rebuild of
# the upstream script). We drop them here and log exactly which were
# removed, so the user has a paper trail.

n_before <- nrow(enrollment_tertiary)
dup_mask <- duplicated(enrollment_tertiary)
removed  <- enrollment_tertiary[dup_mask, , drop = FALSE]
enrollment_tertiary <- dplyr::distinct(enrollment_tertiary)
n_after  <- nrow(enrollment_tertiary)

if (n_after < n_before) {
  cat(sprintf("\nRemoved %d exact-duplicate row(s) from the raw v6 file:\n",
              n_before - n_after))
  print(
    removed |>
      dplyr::select(year, source, network, institution_type, modality, value) |>
      dplyr::arrange(year, network, institution_type, modality),
    n = Inf
  )
}

# ---------------------------------------------------------------------
# 5b. Collapse same-source duplicates that differ only in source_note
# ---------------------------------------------------------------------
#
# For 1999 and 2001 the v6 file carries the same INEP Sinopse figures
# twice, once per table reference ('CENSUP<yyyy>_tabela...' and
# 'Sinopse_CENSUP_...'). Identical values for the same cell and source
# are one observation: keep one row and record both references.

obs_key <- c("year", "network", "institution_type", "modality",
             "source", "is_derived", "value")
n_before <- nrow(enrollment_tertiary)
enrollment_tertiary <- enrollment_tertiary |>
  dplyr::group_by(dplyr::across(dplyr::all_of(obs_key))) |>
  dplyr::mutate(source_note = paste(unique(source_note), collapse = " | ")) |>
  dplyr::slice(1) |>
  dplyr::ungroup()
cat(sprintf("\nCollapsed %d same-source row(s) differing only in source_note.\n",
            n_before - nrow(enrollment_tertiary)))

# ---------------------------------------------------------------------
# 5c. Drop the Kang/Paese/Felix series (already in enrollment_kang_fgv)
# ---------------------------------------------------------------------
#
# The v6 file copies the tertiary counts of FGV/IBRE file 4 verbatim.
# That file is bundled as `enrollment_kang_fgv`, so keeping it here made
# get_enrollment(level = "superior") return every 1933-2010 value twice.
# Derived rows that use Kang as the Presencial component are kept.

n_before <- nrow(enrollment_tertiary)
enrollment_tertiary <- enrollment_tertiary |>
  dplyr::filter(!(source == "kang_paese_felix_2021" & !is_derived))
cat(sprintf("Dropped %d kang_paese_felix_2021 row(s) (served by enrollment_kang_fgv).\n",
            n_before - nrow(enrollment_tertiary)))

# ---------------------------------------------------------------------
# 5c'. Drop Durham (2005)
# ---------------------------------------------------------------------
#
# Durham is a secondary source, and its Table 1 is internally
# inconsistent as printed: public + private != total in 1945 (-300),
# 1960 (-6 000), 1965 (+27 014; total 352 096 vs 155 781 in every other
# source) and 2001 (+9 000). Every year it covers is also covered by
# the primary sources it compiles, so it is dropped, together with the
# derived rows that use it as the Presencial component.

n_before <- nrow(enrollment_tertiary)
enrollment_tertiary <- enrollment_tertiary |>
  dplyr::filter(!grepl("(^|\\+)durham_2005(\\+|$)", source))
cat(sprintf("Dropped %d durham_2005 row(s) (natural and derived).\n",
            n_before - nrow(enrollment_tertiary)))

# ---------------------------------------------------------------------
# 5d. Reclassify INEP "especial" institutions in the microdata layer
# ---------------------------------------------------------------------
#
# In the v6 microdata aggregation (2012-2024) institutions of category
# "Especial" (TP_CATEGORIA_ADMINISTRATIVA = 7, art. 242 CF) were summed
# into `privada`, while INEP's own Power BI panel counts them as public
# municipal. That left privada != privada_lucrativa + privada_nao_lucrativa
# and understated publica/municipal by exactly the `especial` value.
# Follow INEP: move `especial` from privada into municipal and publica.
# The `especial` row is kept as an "of which" breakdown of municipal.

mdx <- enrollment_tertiary$source == "inep_microdados_censup" &
  enrollment_tertiary$institution_type == "total" &
  !enrollment_tertiary$is_derived
esp <- enrollment_tertiary[mdx & enrollment_tertiary$network == "especial",
                           c("year", "modality", "value")]
names(esp)[3] <- "esp"

# Municipal rows missing for a (year, modality) that has `especial`
# (e.g. 2012 EAD) are created from the corresponding municipal-less cell.
have_mun <- enrollment_tertiary[mdx & enrollment_tertiary$network == "municipal",
                                c("year", "modality")]
new_mun <- dplyr::anti_join(esp, have_mun, by = c("year", "modality"))
if (nrow(new_mun)) {
  tmpl <- enrollment_tertiary[mdx & enrollment_tertiary$network == "publica", ] |>
    dplyr::semi_join(new_mun, by = c("year", "modality")) |>
    dplyr::mutate(network = "municipal", value = 0)
  enrollment_tertiary <- dplyr::bind_rows(enrollment_tertiary, tmpl)
  mdx <- enrollment_tertiary$source == "inep_microdados_censup" &
    enrollment_tertiary$institution_type == "total" &
    !enrollment_tertiary$is_derived
}

enrollment_tertiary <- enrollment_tertiary |>
  dplyr::mutate(.mdx = mdx) |>
  dplyr::left_join(esp, by = c("year", "modality")) |>
  dplyr::mutate(
    esp   = dplyr::if_else(.mdx & !is.na(esp), esp, 0),
    value = dplyr::case_when(
      network %in% c("municipal", "publica") ~ value + esp,
      network == "privada"                   ~ value - esp,
      TRUE                                   ~ value
    ),
    source_note = dplyr::if_else(
      esp > 0 & network %in% c("municipal", "publica", "privada"),
      paste(source_note,
            "Categoria 'Especial' (art. 242 CF) reclassificada de privada para",
            "municipal/pública, como no painel Power BI do INEP."),
      source_note
    )
  ) |>
  dplyr::select(-esp, -.mdx) |>
  dplyr::arrange(year, network, institution_type, modality, source)
cat(sprintf("Reclassified 'especial' in %d microdata (year, modality) cell(s).\n",
            nrow(esp)))

# ---------------------------------------------------------------------
# 6. Validate
# ---------------------------------------------------------------------

educabr2:::validate_against_schema(enrollment_tertiary, theme = "enrollment")

# ---------------------------------------------------------------------
# 7. Save
# ---------------------------------------------------------------------

attr(enrollment_tertiary, "educabr_meta") <- list(
  build_script    = "data-raw/03_build_enrollment_tertiary.R",
  built_at        = Sys.time(),
  primary_sources = c("ibge_seculo_xx", "maduro_junior_2007",
                      "kang_paese_felix_2021", "inep_sinopse_censup",
                      "inep_microdados_censup", "inep_censup_powerbi"),
  raw_file        = src_file,
  notes           = paste(
    "Multi-source compilation built for academic transparency.",
    "Multiple rows per (year, network) on purpose: compare estimates.",
    "Derived rows flagged via is_derived; excluded by default in get_enrollment()."
  )
)

usethis::use_data(enrollment_tertiary, overwrite = TRUE, compress = "xz")
