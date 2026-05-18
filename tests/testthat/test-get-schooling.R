make_sch_fixture <- function() {
  data.frame(
    year        = c(1925L, 1925L, 1925L, 1925L, 1960L, 1960L, 1960L, 1950L, 1950L),
    geo_level   = c("BR","BR","BR","BR","BR","BR","BR","UF","region"),
    geo_code    = c("BR","BR","BR","BR","BR","BR","BR","SP","SE"),
    geo_name    = c("Brasil","Brasil","Brasil","Brasil","Brasil","Brasil","Brasil","São Paulo","Sudeste"),
    dim_race    = c("total","white","black","total","total","total","brown","total","total"),
    dim_sex     = c("total","total","total","male","female","total","total","total","total"),
    age_group   = rep(NA_character_, 9),
    indicator   = rep("mean_years_schooling", 9),
    value       = c(1.13, 1.52, 0.41, 1.34, 2.80, 2.80, 1.10, 3.50, 3.20),
    unit        = rep("years", 9),
    source      = rep("walter_kang_2023", 9),
    source_note = rep("fixture", 9),
    stringsAsFactors = FALSE
  )
}

with_sch_fixture <- function(code) {
  env <- new.env(parent = emptyenv())
  assign("schooling_kang_fgv", make_sch_fixture(), envir = env)

  # Capture the ORIGINAL before replacing it in the namespace — otherwise
  # the closure below would call the replacement and recurse infinitely.
  orig <- educabr:::.load_schooling_panel
  local_panel <- function() orig(env = env)

  unlockBinding(".load_schooling_panel", asNamespace("educabr"))
  assign(".load_schooling_panel",
         function(env = NULL) local_panel(),
         envir = asNamespace("educabr"))
  on.exit({
    assign(".load_schooling_panel", orig, envir = asNamespace("educabr"))
    lockBinding(".load_schooling_panel", asNamespace("educabr"))
  }, add = TRUE)

  force(code)
}

test_that("get_schooling returns tibble with canonical columns", {
  with_sch_fixture({
    out <- get_schooling()
    expect_s3_class(out, "tbl_df")
    expect_true(all(c("year","geo_level","geo_code","geo_name",
                       "dim_race","dim_sex","indicator","value","unit",
                       "source") %in% names(out)))
  })
})

test_that("geo_level filter is exclusive", {
  with_sch_fixture({
    expect_true(all(get_schooling(geo_level = "BR")$geo_level == "BR"))
    expect_true(all(get_schooling(geo_level = "UF")$geo_level == "UF"))
    expect_true(all(get_schooling(geo_level = "region")$geo_level == "region"))
  })
})

test_that("geo filter restricts UF results", {
  with_sch_fixture({
    out <- get_schooling(geo_level = "UF", geo = "SP")
    expect_setequal(unique(out$geo_code), "SP")
  })
})

test_that("year accepts vector and range forms", {
  with_sch_fixture({
    expect_setequal(unique(get_schooling(year = 1925)$year), 1925L)
    expect_setequal(unique(get_schooling(year = c(1925, 1960))$year),
                    c(1925L, 1960L))
  })
})

test_that("dimension='none' returns only total×total rows", {
  with_sch_fixture({
    out <- get_schooling(dimension = "none")
    expect_true(all(out$dim_race == "total"))
    expect_true(all(out$dim_sex  == "total"))
  })
})

test_that("dimension='race' returns race breakdown with sex=total", {
  with_sch_fixture({
    out <- get_schooling(dimension = "race")
    expect_true(all(out$dim_race != "total"))
    expect_true(all(out$dim_sex  == "total"))
  })
})

test_that("dimension='sex' returns sex breakdown with race=total", {
  with_sch_fixture({
    out <- get_schooling(dimension = "sex")
    expect_true(all(out$dim_sex  != "total"))
    expect_true(all(out$dim_race == "total"))
  })
})

test_that("lang='pt' translates dim_sex and dim_race", {
  with_sch_fixture({
    pt <- get_schooling(dimension = "sex", lang = "pt")
    expect_true(any(pt$dim_sex %in% c("Masculino", "Feminino")))

    en <- get_schooling(dimension = "sex", lang = "en")
    expect_true(any(en$dim_sex %in% c("male", "female")))
  })
})

test_that(".load_schooling_panel errors with friendly message when nothing built", {
  empty_env <- new.env(parent = emptyenv())
  expect_error(
    educabr:::.load_schooling_panel(env = empty_env),
    "No schooling dataset"
  )
})
