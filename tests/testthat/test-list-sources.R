test_that("list_sources returns a tibble with the canonical columns", {
  out <- list_sources()
  expect_s3_class(out, "tbl_df")
  expect_true(all(c("key", "short_name", "type",
                    "year_start", "year_end",
                    "geo", "doi", "url", "notes") %in% names(out)))
  expect_gt(nrow(out), 5L)
})

test_that("list_sources returns the expected types", {
  out <- list_sources()
  expect_type(out$key,        "character")
  expect_type(out$short_name, "character")
  expect_type(out$type,       "character")
  expect_type(out$year_start, "integer")
  expect_type(out$year_end,   "integer")
})

test_that("every source key returned by list_sources is citable", {
  keys <- list_sources()$key
  # educabr_cite() should accept any key list_sources() advertises
  expect_no_error(educabr_cite(keys))
})

test_that("list_sources carries DOIs for the academic entries", {
  out <- list_sources()
  acad <- out[out$type == "academic", , drop = FALSE]
  expect_gt(nrow(acad), 0L)
  expect_true(any(!is.na(acad$doi)))
})

test_that("list_sources captures NA year_end for ongoing series", {
  out <- list_sources()
  # PNADc is the canonical ongoing series in our vocabulary
  pnadc <- out[out$key == "pnadc_ibge", ]
  expect_equal(nrow(pnadc), 1L)
  expect_true(is.na(pnadc$year_end))
})
