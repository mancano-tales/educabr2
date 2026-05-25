make_attainment_fixture <- function() {
  data.frame(
    year        = c(1950L, 2010L, 1950L, 2010L, 1950L, 2010L,
                    1950L, 2010L, 1950L, 2010L),
    geo_level   = rep("country", 10),
    geo_code    = c("BRA","BRA","BRA","BRA","BRA","BRA",
                    "USA","USA","ARG","ARG"),
    geo_name    = c("Brazil","Brazil","Brazil","Brazil","Brazil","Brazil",
                    "USA","USA","Argentina","Argentina"),
    level       = c("primary","primary","secondary","secondary","tertiary","tertiary",
                    "primary","primary","primary","primary"),
    dim_sex     = c("total","total","total","total","total","total",
                    "male","female","total","total"),
    age_group   = rep("15-64", 10),
    indicator   = rep("attainment_share_completed", 10),
    value       = c(15.3, 78.2, 4.1, 50.5, 0.5, 18.4,
                    65.0, 82.1, 25.7, 90.3),
    unit        = rep("percent", 10),
    source      = rep("lee_lee_2016", 10),
    source_note = rep("fixture", 10),
    stringsAsFactors = FALSE
  )
}

with_attainment_fixture <- function(code) {
  env <- new.env(parent = emptyenv())
  assign("lee_lee_2016", make_attainment_fixture(), envir = env)

  orig <- educabr2:::.load_attainment_panel
  local_panel <- function() orig(env = env)

  unlockBinding(".load_attainment_panel", asNamespace("educabr2"))
  assign(".load_attainment_panel",
         function(env = NULL) local_panel(),
         envir = asNamespace("educabr2"))
  on.exit({
    assign(".load_attainment_panel", orig, envir = asNamespace("educabr2"))
    lockBinding(".load_attainment_panel", asNamespace("educabr2"))
  }, add = TRUE)

  force(code)
}

test_that("get_attainment returns tibble with canonical columns", {
  with_attainment_fixture({
    out <- get_attainment()
    expect_s3_class(out, "tbl_df")
    expect_true(all(c("year","geo_level","geo_code","geo_name",
                      "level","dim_sex","age_group",
                      "indicator","value","unit",
                      "source") %in% names(out)))
  })
})

test_that("default geo_level is country", {
  with_attainment_fixture({
    out <- get_attainment()
    expect_true(all(out$geo_level == "country"))
  })
})

test_that("default dimension drops sex breakdowns", {
  with_attainment_fixture({
    out <- get_attainment()
    expect_setequal(unique(out$dim_sex), "total")
  })
})

test_that("dimension = 'sex' returns male/female rows only", {
  with_attainment_fixture({
    out <- get_attainment(dimension = "sex")
    expect_true(all(out$dim_sex %in% c("male", "female")))
    expect_false(any(out$dim_sex == "total"))
  })
})

test_that("geo filter restricts countries (ISO3, case-insensitive)", {
  with_attainment_fixture({
    out <- get_attainment(geo = c("bra", "arg"))
    expect_setequal(unique(out$geo_code), c("BRA", "ARG"))
  })
})

test_that("level filter restricts education levels", {
  with_attainment_fixture({
    out <- get_attainment(level = "tertiary")
    expect_setequal(unique(out$level), "tertiary")
  })
})

test_that("year accepts vector and range forms", {
  with_attainment_fixture({
    expect_setequal(unique(get_attainment(year = 1950)$year), 1950L)
    expect_setequal(unique(get_attainment(year = c(1950, 2010))$year),
                    c(1950L, 2010L))
  })
})

test_that("age_group is always 15-64", {
  with_attainment_fixture({
    out <- get_attainment()
    expect_setequal(unique(out$age_group), "15-64")
  })
})

test_that("unit is always percent", {
  with_attainment_fixture({
    out <- get_attainment()
    expect_setequal(unique(out$unit), "percent")
  })
})

test_that("lang='pt' translates level labels", {
  with_attainment_fixture({
    pt <- get_attainment(level = "tertiary", lang = "pt")
    expect_true(all(pt$level == "Educação terciária (ISCED)"))
  })
})

test_that(".load_attainment_panel errors with friendly message when nothing built", {
  empty_env <- new.env(parent = emptyenv())
  expect_error(
    educabr2:::.load_attainment_panel(env = empty_env),
    "No attainment dataset"
  )
})
