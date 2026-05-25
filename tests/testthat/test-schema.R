test_that("schema.yaml loads and exposes columns/constraints", {
  schema <- educabr2:::load_schema()
  expect_type(schema, "list")
  expect_true(all(c("columns", "constraints") %in% names(schema)))
  expect_gt(length(schema$columns), 5)

  has_name <- vapply(schema$columns, function(c) "name" %in% names(c), logical(1))
  expect_true(all(has_name))

  has_type <- vapply(schema$columns, function(c) "type" %in% names(c), logical(1))
  expect_true(all(has_type))
})

test_that("validate_against_schema catches missing required columns", {
  bad <- data.frame(year = 2020L, value = 100)
  expect_error(
    educabr2:::validate_against_schema(bad),
    "Missing required"
  )
})

test_that("validate_against_schema catches undeclared factor levels", {
  ok_required <- data.frame(
    year = 2020L,
    geo_level = "BR",
    geo_code = "BR",
    geo_name = "Brasil",
    indicator = "enrollment_rate",
    value = 95,
    unit = "percent",
    source = "kang_fgv_ibre_2023",
    dim_race = "martian",
    stringsAsFactors = FALSE
  )
  expect_error(
    educabr2:::validate_against_schema(ok_required),
    "undeclared level"
  )
})

test_that("validate_against_schema accepts a minimal valid row", {
  ok <- data.frame(
    year = 2020L,
    geo_level = "BR",
    geo_code = "BR",
    geo_name = "Brasil",
    indicator = "enrollment_rate",
    value = 95,
    unit = "percent",
    source = "kang_fgv_ibre_2023",
    stringsAsFactors = FALSE
  )
  expect_invisible(educabr2:::validate_against_schema(ok))
})
