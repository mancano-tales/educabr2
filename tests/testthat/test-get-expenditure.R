make_exp_fixture <- function() {
  data.frame(
    year        = c(1933L, 1933L, 1933L, 1933L, 1950L, 1950L, 2010L),
    geo_level   = rep("BR", 7),
    geo_code    = rep("BR", 7),
    geo_name    = rep("Brasil", 7),
    level       = c("total", "fundamental_anos_iniciais", "superior", "total",
                    "total", "superior", "total"),
    network     = rep("publica", 7),
    dim_race    = rep("total", 7),
    age_group   = rep(NA_character_, 7),
    indicator   = c("expenditure_share_gdp",
                    "expenditure_per_student_pct_gdp_pc",
                    "expenditure_per_student_pct_gdp_pc",
                    "expenditure_double_ratio_es_ef1",
                    "expenditure_share_gdp",
                    "expenditure_per_student_pct_gdp_pc",
                    "expenditure_double_ratio_es_ef_em"),
    value       = c(1.30, 19.24, 1269.75, 65.98, 1.52, 1027.0, 7.78),
    unit        = c("percent_gdp", "percent_gdp_per_capita",
                    "percent_gdp_per_capita", "ratio",
                    "percent_gdp", "percent_gdp_per_capita", "ratio"),
    source      = rep("kang_menetrier_2024", 7),
    source_note = rep("fixture", 7),
    stringsAsFactors = FALSE
  )
}

with_exp_fixture <- function(code) {
  env <- new.env(parent = emptyenv())
  assign("expenditure_kang_fgv", make_exp_fixture(), envir = env)

  orig <- educabr:::.load_expenditure_panel
  local_panel <- function() orig(env = env)

  unlockBinding(".load_expenditure_panel", asNamespace("educabr"))
  assign(".load_expenditure_panel",
         function(env = NULL) local_panel(),
         envir = asNamespace("educabr"))
  on.exit({
    assign(".load_expenditure_panel", orig, envir = asNamespace("educabr"))
    lockBinding(".load_expenditure_panel", asNamespace("educabr"))
  }, add = TRUE)

  force(code)
}

test_that("get_expenditure returns tibble with canonical columns", {
  with_exp_fixture({
    out <- get_expenditure()
    expect_s3_class(out, "tbl_df")
    expect_true(all(c("year","geo_level","geo_code","geo_name",
                       "level","network","indicator","value","unit",
                       "source") %in% names(out)))
  })
})

test_that("indicator aliases translate to canonical keys", {
  with_exp_fixture({
    out <- get_expenditure(indicator = "share_gdp")
    expect_true(all(out$indicator == "expenditure_share_gdp"))

    out <- get_expenditure(indicator = "per_student")
    expect_true(all(out$indicator == "expenditure_per_student_pct_gdp_pc"))

    out <- get_expenditure(indicator = "double_ratio_es_ef1")
    expect_true(all(out$indicator == "expenditure_double_ratio_es_ef1"))

    out <- get_expenditure(indicator = "double_ratio_es_ef_em")
    expect_true(all(out$indicator == "expenditure_double_ratio_es_ef_em"))
  })
})

test_that("canonical indicator keys still work alongside aliases", {
  with_exp_fixture({
    out <- get_expenditure(indicator = "expenditure_share_gdp")
    expect_true(all(out$indicator == "expenditure_share_gdp"))
  })
})

test_that("level filter is honoured", {
  with_exp_fixture({
    out <- get_expenditure(level = "superior")
    expect_setequal(unique(out$level), "superior")
  })
})

test_that("year accepts vector and range forms", {
  with_exp_fixture({
    expect_setequal(unique(get_expenditure(year = 1933)$year), 1933L)
    expect_setequal(unique(get_expenditure(year = c(1933, 1950))$year),
                    c(1933L, 1950L))
  })
})

test_that("double ratios carry level = 'total'", {
  with_exp_fixture({
    out <- get_expenditure(indicator = "double_ratio_es_ef1")
    expect_true(all(out$level == "total"))
  })
})

test_that("lang='pt' translates level labels", {
  with_exp_fixture({
    pt <- get_expenditure(level = "superior", lang = "pt")
    expect_true(any(pt$level == "Ensino superior"))
  })
})

test_that(".load_expenditure_panel errors with friendly message when nothing built", {
  empty_env <- new.env(parent = emptyenv())
  expect_error(
    educabr:::.load_expenditure_panel(env = empty_env),
    "No expenditure dataset"
  )
})
