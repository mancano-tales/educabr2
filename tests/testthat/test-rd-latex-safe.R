# Guards against the CRAN pre-test failure of 0.1.0: a Unicode math glyph
# (U+2265, greater-than-or-equal) in roxygen text broke the PDF manual
# because R's Rd->LaTeX converter has no mapping for it. Dashes, accents
# and quotes are fine.

test_that("Rd files contain no math glyphs that LaTeX cannot typeset", {
  # devtools::load_all()'s pkgload shim makes system.file(package=) return
  # inst/, not the package root, so the man/ check below would fail and
  # the test would fall through to scanning a stale installed copy.
  pkg_root <- find.package("educabr2")
  db <- if (dir.exists(file.path(pkg_root, "man"))) {
    tools::Rd_db(dir = pkg_root)          # devtools::load_all() / source tree
  } else {
    tools::Rd_db(package = "educabr2")    # installed package (R CMD check)
  }
  expect_gt(length(db), 0)

  unsafe <- "[\u2265\u2264\u2260\u00d7\u00b1\u2192\u2190\u221e\u2248]"
  txt <- vapply(db, function(rd) paste(as.character(rd), collapse = ""),
                character(1))
  offenders <- names(db)[grepl(unsafe, txt, perl = TRUE)]

  expect(length(offenders) == 0,
         paste("Rd files with LaTeX-unsafe glyphs:", toString(offenders)))
})
