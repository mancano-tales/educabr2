# extract_medio_rede.R
#
# Upper-secondary (ensino medio regular) enrollment by administrative
# dependency, Brasil, from two INEP layers:
#
#   * Sinopses Estatisticas da Educacao Basica, 1996-2006 (Brasil row of
#     the table "Matricula no Ensino Medio por Dependencia Administrativa").
#     2003 and 2004 are missing: INEP publishes them only as PDFs whose
#     tables are images.
#   * Microdados do Censo Escolar, 2007-2024 (school file, QT_MAT_MED by
#     TP_DEPENDENCIA: 1 federal, 2 estadual, 3 municipal, 4 privada),
#     read through educabR::get_censo_escolar().
#
# Output: data-raw/sources/censo_escolar_inep/medio_rede_inep.csv, read by
# data-raw/07_build_enrollment_medio_network.R.
#
# Inputs are not versioned (the microdata are several GB). Set:
#   SINOPSES_EB_DIR   folder with the sinopse files below (downloaded here
#                     when missing);
#   EDUCABR_CACHE     educabR cache folder with the Censo Escolar microdata.
#
# Run from the package root:
#   source("data-raw/sources/censo_escolar_inep/extract_medio_rede.R")

stopifnot(file.exists("DESCRIPTION"))

sin_dir <- Sys.getenv("SINOPSES_EB_DIR", tempfile("sinopses_eb_"))
dir.create(sin_dir, showWarnings = FALSE, recursive = TRUE)

base_new <- "https://download.inep.gov.br/informacoes_estatisticas/sinopses_estatisticas/sinopses_educacao_basica/"
base_old <- "https://download.inep.gov.br/download/censo/"

# year, url, file inside the zip (NA = not zipped), sheet or PDF table,
# column order of the Brasil row after the label: positions of
# total/federal/estadual/municipal/privada.
sinopses <- list(
  list(year = 1996, url = paste0(base_new, "sinopse_educacao_basica_1996.xls"),
       file = NA, table = "1.7", cols = c(2, 4, 6, 8, 10)),
  list(year = 1997, url = paste0(base_old, "1997/basica/Censo_97.zip"),
       file = "Censo_97.xls", table = "1.11", cols = 2:6),
  list(year = 1998, url = paste0(base_old, "1998/basica/censo-miolo-98.zip"),
       file = "censo-miolo-98.pdf", table = "1.31", cols = 1:5),
  list(year = 1999, url = paste0(base_old, "1999/basica/SINOPSE_1999.zip"),
       file = "SINOPSE 1999.xls", table = "1.36", cols = 2:6),
  list(year = 2000, url = paste0(base_old, "2000/basica/sinopse2000.zip"),
       file = "sinopse2000.xls", table = "1.36", cols = 2:6),
  list(year = 2001, url = paste0(base_old, "2001/sinopse/Sinopse_2001_26_05_02.zip"),
       file = "Sinopse 2001(26_05_02).xls", table = "1.36", cols = 2:6),
  list(year = 2002, url = paste0(base_old, "2002/sinopse/sinopse_2002.zip"),
       file = "sinopse 2002.xls", table = "1.36", cols = 2:6),
  list(year = 2005, url = paste0(base_old, "2005/Censo2005.zip"),
       file = "Censo2005/Censo Escolar 2005.xls", table = "1.43", cols = 2:6),
  list(year = 2006, url = paste0(base_old, "2006/resultados_censo_escolar2006.zip"),
       file = "Resultados Censo Escolar 2006.xls", table = "1.43", cols = 2:6)
)

fetch <- function(url) {
  dest <- file.path(sin_dir, basename(url))
  if (!file.exists(dest)) {
    utils::download.file(url, dest, mode = "wb", quiet = TRUE,
                         method = if (nzchar(Sys.which("curl"))) "curl" else "auto")
  }
  dest
}

num <- function(x) as.numeric(gsub("[^0-9]", "", as.character(x)))

brasil_row_xls <- function(path, sheet, cols) {
  x <- suppressMessages(readxl::read_excel(path, sheet = sheet, col_names = FALSE))
  i <- which(apply(x, 1, function(r) any(grepl("^\\s*Brasil\\s*$", r))))[1]
  stopifnot(!is.na(i))
  vals <- num(unlist(x[i, ]))
  vals[cols]
}

brasil_row_pdf <- function(path, table) {
  txt <- unlist(strsplit(pdftools::pdf_text(path), "\n"))
  head_i <- grep(paste0("^\\s*", gsub(".", "\\.", table, fixed = TRUE), " - Matr"), txt)
  head_i <- head_i[length(head_i)]  # the table itself, not the table of contents
  b <- grep("^\\s*Brasil\\s", txt)
  b <- b[b > head_i][1]
  vals <- num(strsplit(trimws(sub("Brasil", "", txt[b])), "\\s+")[[1]])
  vals[1:5]
}

rows <- list()
for (s in sinopses) {
  src <- fetch(s$url)
  if (!is.na(s$file)) {
    ex <- file.path(sin_dir, paste0("x", s$year))
    utils::unzip(src, exdir = ex)
    path <- file.path(ex, s$file)
  } else {
    path <- src
  }
  v <- if (grepl("\\.pdf$", path)) brasil_row_pdf(path, s$table)
       else brasil_row_xls(path, s$table, s$cols)
  names(v) <- c("total", "federal", "estadual", "municipal", "privada")
  stopifnot("sinopse: networks do not add up to the total" =
              v[["total"]] == sum(v[c("federal", "estadual", "municipal", "privada")]))
  rows[[length(rows) + 1]] <- data.frame(
    year = s$year, network = names(v), value = unname(v),
    source = "inep_sinopse_censo_escolar",
    table_ref = sprintf("Sinopse Estatistica da Educacao Basica %d, tabela %s",
                        s$year, s$table))
}

cache <- Sys.getenv("EDUCABR_CACHE")
if (nzchar(cache)) educabR::set_cache_dir(cache)
for (a in 2007:2024) {
  x <- educabR::get_censo_escolar(a, quiet = TRUE)
  dep <- as.integer(x$tp_dependencia)
  med <- as.numeric(x$qt_mat_med)
  v <- c(federal = sum(med[dep == 1], na.rm = TRUE),
         estadual = sum(med[dep == 2], na.rm = TRUE),
         municipal = sum(med[dep == 3], na.rm = TRUE),
         privada = sum(med[dep == 4], na.rm = TRUE))
  v <- c(total = sum(v), v)
  rows[[length(rows) + 1]] <- data.frame(
    year = a, network = names(v), value = unname(v),
    source = "inep_microdados_censo_escolar",
    table_ref = sprintf("Microdados do Censo Escolar %d, arquivo de escolas, QT_MAT_MED por TP_DEPENDENCIA", a))
  rm(x); gc(verbose = FALSE)
}

out <- do.call(rbind, rows)
utils::write.csv(out, "data-raw/sources/censo_escolar_inep/medio_rede_inep.csv",
                 row.names = FALSE)
cat("Wrote", nrow(out), "rows.\n")
