# extract_microdados_org.R
#
# The microdata layer of enrollment_tertiary (2009-2024) is broken down by
# administrative category and modality only; `institution_type` stays at
# "total". This script adds the academic organisation, aggregating the
# same INEP course files:
#
#   QT_MAT by NU_ANO_CENSO x TP_ORGANIZACAO_ACADEMICA x
#   TP_CATEGORIA_ADMINISTRATIVA x TP_MODALIDADE_ENSINO
#
# Academic organisation (TP_ORGANIZACAO_ACADEMICA): 1 = universidade,
# 2 = centro universitário, 3 = faculdade, 4 = instituto federal (IF),
# 5 = CEFET. IF and CEFET share one level, `cefet_ifet`, as in the Sinopse
# taxonomy of 2008.
#
# Networks follow step 5d of 03_build_enrollment_tertiary.R: category 7
# ("Especial", art. 242 CF) counts as municipal public. Only the public
# breakdown (federal/estadual/municipal) and the private total are
# produced; the private sub-categories change in 2010 and stay at the
# national level of detail already in the package.
#
# Source: INEP, Microdados do Censo da Educação Superior 2009-2024,
#   MICRODADOS_CADASTRO_CURSOS_<ano>.CSV (one folder per year).
# Set CENSUP_MICRODADOS_DIR to the folder holding <ano>/dados/.
#
# Output: data-raw/sources/tertiary_multisource/microdados_censup_org.csv,
# read by step 5g of data-raw/03_build_enrollment_tertiary.R.
#
# Run from the package root:
#   source("data-raw/sources/tertiary_multisource/extract_microdados_org.R")

stopifnot(file.exists("DESCRIPTION"))

base_dir <- Sys.getenv("CENSUP_MICRODADOS_DIR")
stopifnot("Set CENSUP_MICRODADOS_DIR" = nzchar(base_dir), dir.exists(base_dir))

org_map <- c("1" = "university", "2" = "university_center", "3" = "faculty",
             "4" = "cefet_ifet", "5" = "cefet_ifet")
net_map <- c("1" = "federal", "2" = "estadual", "3" = "municipal",
             "7" = "municipal", "4" = "privada", "5" = "privada",
             "6" = "privada", "8" = "privada", "9" = "privada")
mod_map <- c("1" = "presencial", "2" = "ead")

agg <- lapply(2009:2024, function(ano) {
  f <- list.files(file.path(base_dir, ano, "dados"),
                  pattern = "CADASTRO_CURSOS.*\\.(CSV|csv)$", full.names = TRUE)
  stopifnot(length(f) == 1)
  d <- data.table::fread(f, sep = ";", encoding = "Latin-1",
                         select = c("TP_ORGANIZACAO_ACADEMICA",
                                    "TP_CATEGORIA_ADMINISTRATIVA",
                                    "TP_MODALIDADE_ENSINO", "QT_MAT"))
  d <- d[!is.na(QT_MAT)]
  out <- d[, .(value = sum(QT_MAT)),
           by = .(org = TP_ORGANIZACAO_ACADEMICA,
                  cat = TP_CATEGORIA_ADMINISTRATIVA,
                  mod = TP_MODALIDADE_ENSINO)]
  stopifnot(all(as.character(out$org) %in% names(org_map)),
            all(as.character(out$cat) %in% names(net_map)),
            all(as.character(out$mod) %in% names(mod_map)))
  data.frame(year = ano,
             institution_type = unname(org_map[as.character(out$org)]),
             network = unname(net_map[as.character(out$cat)]),
             modality = unname(mod_map[as.character(out$mod)]),
             value = out$value,
             file = basename(f))
})
agg <- do.call(rbind, agg)

# Roll up: networks (adding publica and total) and modality (adding total).
roll <- function(d, col, from, to) {
  x <- d[d[[col]] %in% from, ]
  x[[col]] <- to
  stats::aggregate(value ~ ., data = x, FUN = sum)
}
base <- stats::aggregate(value ~ ., data = agg, FUN = sum)
base <- rbind(base,
              roll(base, "network", c("federal", "estadual", "municipal"), "publica"),
              roll(base, "network", c("federal", "estadual", "municipal", "privada"),
                   "total"))
base <- rbind(base, roll(base, "modality", c("presencial", "ead"), "total"))
base <- base[order(base$year, base$network, base$institution_type, base$modality), ]

utils::write.csv(base[, c("year", "network", "institution_type", "modality",
                          "value", "file")],
                 "data-raw/sources/tertiary_multisource/microdados_censup_org.csv",
                 row.names = FALSE)
cat(sprintf("Wrote %d rows for %d years.\n", nrow(base), length(unique(base$year))))
