# Guards against the CRAN pre-test failure of 0.1.0: a Unicode math glyph
# (U+2265 "≥") in roxygen text broke the PDF manual because R's Rd->LaTeX
# converter has no mapping for it. Dashes, accents and quotes are fine.

test_that("Rd files contain no math glyphs that LaTeX cannot typeset", {
  pkg_root <- find.package("educabr2")
  db <- if (dir.exists(file.path(pkg_root, "man"))) {
    tools::Rd_db(dir = pkg_root)          # devtools::load_all() / source tree
  } else {
    tools::Rd_db(package = "educabr2")    # installed package (R CMD check)
  }
  expect_gt(length(db), 0)

  unsafe <- "[≥≤≠×±→←∞≈]"
  txt <- vapply(db, function(rd) paste(as.character(rd), collapse = ""),
                character(1))
  offenders <- names(db)[grepl(unsafe, txt, perl = TRUE)]

  expect_length(offenders, 0)
  if (length(offenders)) {
    message("Rd files with LaTeX-unsafe glyphs: ",
            paste(offenders, collapse = ", "))
  }
})
