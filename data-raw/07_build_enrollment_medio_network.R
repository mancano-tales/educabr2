# 07_build_enrollment_medio_network.R
#
# ETL: upper-secondary (ensino medio regular) enrollment by administrative
# dependency, Brasil, 1996-2024 (2003 and 2004 missing).
#
# Reads data-raw/sources/censo_escolar_inep/medio_rede_inep.csv, produced by
# data-raw/sources/censo_escolar_inep/extract_medio_rede.R from:
#   * INEP Sinopses Estatisticas da Educacao Basica, 1996-2006;
#   * INEP Microdados do Censo Escolar, 2007-2024.
# Writes `enrollment_medio_network` to data/enrollment_medio_network.rda.
#
# `publica` is the sum of federal, estadual and municipal within the same
# source and year, so it is not flagged as derived.
#
# Series break: from 2007 the Censo Escolar records each student
# (Educacenso). The level drops between 2006 and 2007 (8.91 to 8.37
# million); the shares by network barely move.
#
# Run from the package root, after devtools::load_all():
#   source("data-raw/07_build_enrollment_medio_network.R")

stopifnot(file.exists("DESCRIPTION"))

src_file <- "data-raw/sources/censo_escolar_inep/medio_rede_inep.csv"

# 1. Read ---------------------------------------------------------------
raw <- utils::read.csv(src_file, stringsAsFactors = FALSE)
stopifnot(all(c("year", "network", "value", "source", "table_ref") %in% names(raw)))

# 2. Tidy ---------------------------------------------------------------
pub <- raw[raw$network %in% c("federal", "estadual", "municipal"), ]
pub <- stats::aggregate(value ~ year + source + table_ref, data = pub, FUN = sum)
pub$network <- "publica"
all_rows <- rbind(raw, pub[, names(raw)])

# Check: publica + privada = total in every year.
wide <- stats::reshape(all_rows[, c("year", "network", "value")],
                       idvar = "year", timevar = "network", direction = "wide")
stopifnot("publica + privada differs from total" =
            all(wide$value.publica + wide$value.privada == wide$value.total))

enrollment_medio_network <- tibble::tibble(
  year             = as.integer(all_rows$year),
  geo_level        = "BR",
  geo_code         = "BR",
  geo_name         = "Brasil",
  level            = "medio",
  network          = all_rows$network,
  institution_type = "total",
  modality         = "total",
  dim_race         = "total",
  age_group        = NA_character_,
  indicator        = "enrollment_count",
  value            = as.numeric(all_rows$value),
  unit             = "count",
  source           = all_rows$source,
  source_note      = ifelse(all_rows$network == "publica",
                            paste0(all_rows$table_ref,
                                   "; publica = federal + estadual + municipal"),
                            all_rows$table_ref),
  is_derived       = FALSE
)
enrollment_medio_network <- enrollment_medio_network[
  order(enrollment_medio_network$year, enrollment_medio_network$network), ]

# 3. Validate -----------------------------------------------------------
educabr2:::validate_against_schema(enrollment_medio_network, theme = "enrollment")

# 4. Annotate -----------------------------------------------------------
attr(enrollment_medio_network, "educabr_meta") <- list(
  build_script    = "data-raw/07_build_enrollment_medio_network.R",
  built_at        = Sys.time(),
  primary_sources = c("inep_sinopse_censo_escolar", "inep_microdados_censo_escolar"),
  raw_file        = src_file,
  notes           = paste(
    "Ensino medio regular by network, Brasil. Sinopses 1996-2006 (no 2003-2004),",
    "microdata 2007-2024. Series break in 2007 (Educacenso)."
  )
)

# 5. Write --------------------------------------------------------------
usethis::use_data(enrollment_medio_network, overwrite = TRUE, compress = "xz")
