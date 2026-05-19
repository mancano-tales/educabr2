test_that("educabr_cite returns a bibentry for a known source", {
  out <- educabr_cite("kang_paese_felix_2021")
  expect_s3_class(out, "bibentry")
  expect_length(out, 1L)
})

test_that("educabr_cite returns all bundled sources by default", {
  out <- educabr_cite()
  expect_s3_class(out, "bibentry")
  expect_gt(length(out), 1L)
})

test_that("educabr_cite accepts multiple source keys", {
  out <- educabr_cite(c("kang_paese_felix_2021", "walter_kang_2023"))
  expect_length(out, 2L)
})

test_that("educabr_cite errors on unknown key with helpful message", {
  expect_error(educabr_cite("not_a_real_source"), "Unknown source")
})

test_that("educabr_cite carries DOI when the YAML has one", {
  bib <- educabr_cite("kang_paese_felix_2021")
  expect_equal(bib$doi, "10.1017/S0212610921000112")
})

test_that("educabr_cite extracts year from the prose", {
  bib <- educabr_cite("walter_kang_2023")
  expect_equal(bib$year, "2024")  # full_name says "(2024)"
})

test_that("educabr_cite style='text' returns character with author surname", {
  txt <- educabr_cite("kang_paese_felix_2021", style = "text")
  expect_type(txt, "character")
  expect_match(txt[[1]], "Kang", fixed = FALSE)
})

test_that("educabr_cite style='bibtex' returns a Bibtex object", {
  bib <- educabr_cite("kang_paese_felix_2021", style = "bibtex")
  expect_s3_class(bib, "Bibtex")
  expect_true(any(grepl("@Misc", bib)))
})
