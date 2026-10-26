# extract_sinopse_2002.R
#
# The working compilation (data_tertiary_v6_clean.xlsx) has no INEP
# Sinopse for 2002, which left 2002 without Sinopse rows and without a
# reconstructed Presencial + EAD total. This script extracts, from INEP's
# own file, the same two tables used for the other Sinopse years:
#
#   * Tabela 5.1 — presencial enrollment on 30/06 by academic organisation
#     and administrative category (Brasil rows);
#   * Tabela 7.1 — distance-education (EAD) enrollment on 30/06 (Total).
#
# Source: INEP, Sinopse Estatística da Educação Superior 2002
#   https://download.inep.gov.br/download/censo/2002/sinopse/Sinopse_2002_censosuperior.zip
#   (file inside: Sinopse_2002_atualizada.xls)
#
# Output: data-raw/sources/tertiary_multisource/sinopse_2002_inep.csv,
# read by step 5f of data-raw/03_build_enrollment_tertiary.R.
#
# Run from the package root:
#   source("data-raw/sources/tertiary_multisource/extract_sinopse_2002.R")

stopifnot(file.exists("DESCRIPTION"))

url <- "https://download.inep.gov.br/download/censo/2002/sinopse/Sinopse_2002_censosuperior.zip"
# A copy already on disk can be passed via SINOPSE_2002_ZIP (R's default
# downloader fails the INEP TLS handshake on some Windows setups).
tmp <- Sys.getenv("SINOPSE_2002_ZIP")
if (!nzchar(tmp)) {
  tmp <- tempfile(fileext = ".zip")
  utils::download.file(url, tmp, mode = "wb", quiet = TRUE,
                       method = if (nzchar(Sys.which("curl"))) "curl" else "auto")
}
dir <- tempfile()
utils::unzip(tmp, exdir = dir)
xls <- file.path(dir, "Sinopse_2002_atualizada.xls")

num <- function(x) {
  x <- trimws(as.character(x))
  x[x %in% c("-", "")] <- NA
  as.numeric(x)
}

# Tabela 5.1: rows 9-16 are Brasil (total, then categories); the "Total"
# column of each academic organisation is every third column from col 4.
t51 <- as.data.frame(readxl::read_excel(xls, sheet = "5.1", col_names = FALSE,
                                        range = "A9:U16", .name_repair = "minimal"))
stopifnot(trimws(t51[1, 1]) == "Brasil")
networks <- c("total", "publica", "federal", "estadual", "municipal",
              "privada", "privada_particular",
              "privada_comunitaria_confessional_filantropica")
inst_cols <- c(total = 4, university = 7, university_center = 10,
               integrated_faculty = 13, faculty_school_institute = 16,
               technology_center = 19)
pres <- do.call(rbind, lapply(names(inst_cols), function(it) data.frame(
  network = networks, institution_type = it, modality = "presencial",
  value = num(t51[[inst_cols[[it]]]]), table_ref = "CENSUP2002_tabela5_1"
)))
pres <- pres[!is.na(pres$value), ]
stopifnot(pres$value[pres$network == "total" & pres$institution_type == "total"] == 3479913)

# Tabela 7.1: the "Total" row carries the national EAD enrollment.
t71 <- as.data.frame(readxl::read_excel(xls, sheet = "7.1", col_names = FALSE,
                                        range = "A8:K8", .name_repair = "minimal"))
stopifnot(trimws(t71[1, 1]) == "Total")
ead <- data.frame(network = "total", institution_type = "total",
                  modality = "ead", value = num(t71[1, 10]),
                  table_ref = "CENSUP2002_tabela7_1")
stopifnot(ead$value == 40714)

out <- rbind(pres, ead)
out$year <- 2002L
out <- out[, c("year", "network", "institution_type", "modality", "value", "table_ref")]
utils::write.csv(out, "data-raw/sources/tertiary_multisource/sinopse_2002_inep.csv",
                 row.names = FALSE)
cat(sprintf("Wrote %d rows (presencial total %s, EAD %s).\n", nrow(out),
            format(3479913, big.mark = ","), format(ead$value, big.mark = ",")))
