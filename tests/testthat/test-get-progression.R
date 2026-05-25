make_prog_fixture <- function() {
  data.frame(
    year        = c(1955L, 2010L, 1955L, 1955L, 2010L),
    geo_level   = c("BR","BR","UF","UF","UF"),
    geo_code    = c("BR","BR","SP","BA","SP"),
    geo_name    = c("Brasil","Brasil","São Paulo","Bahia","São Paulo"),
    level       = rep("fundamental_anos_iniciais", 5),
    network     = rep("total", 5),
    dim_race    = rep("total", 5),
    age_group   = rep(NA_character_, 5),
    indicator   = rep("gross_distribution_ratio_grade_6", 5),
    value       = c(0.169, 0.95, 0.301, 0.110, 0.92),
    unit        = rep("ratio", 5),
    source      = rep("kang_paese_felix_2021", 5),
    source_note = rep("fixture", 5),
    stringsAsFactors = FALSE
  )
}

with_prog_fixture <- function(code) {
  env <- new.env(parent = emptyenv())
  assign("progression_kang_fgv", make_prog_fixture(), envir = env)

  orig <- educabr:::.load_progression_panel
  local_panel <- function() orig(env = env)

  unlockBinding(".load_progression_panel", asNamespace("educabr"))
  assign(".load_progression_panel",
         function(env = NULL) local_panel(),
         envir = asNamespace("educabr"))
  on.exit({
    assign(".load_progression_panel", orig, envir = asNamespace("educabr"))
    lockBinding(".load_progression_panel", asNamespace("educabr"))
  }, add = TRUE)

  force(code)
}

test_that("get_progression returns tibble with canonical columns", {
  with_prog_fixture({
    out <- get_progression()
    expect_s3_class(out, "tbl_df")
    expect_true(all(c("year","geo_level","geo_code","geo_name",
                       "level","network","indicator","value","unit",
                       "source") %in% names(out)))
  })
})

test_that("default geo_level is BR", {
  with_prog_fixture({
    out <- get_progression()
    expect_true(all(out$geo_level == "BR"))
  })
})

test_that("geo_level = 'UF' returns UF rows", {
  with_prog_fixture({
    out <- get_progression(geo_level = "UF")
    expect_true(all(out$geo_level == "UF"))
  })
})

test_that("geo filter restricts UF results", {
  with_prog_fixture({
    out <- get_progression(geo_level = "UF", geo = "SP")
    expect_setequal(unique(out$geo_code), "SP")
  })
})

test_that("indicator alias 'gdr6' resolves to the canonical key", {
  with_prog_fixture({
    out <- get_progression(indicator = "gdr6")
    expect_true(all(out$indicator == "gross_distribution_ratio_grade_6"))
  })
})

test_that("year accepts vector and range forms", {
  with_prog_fixture({
    expect_setequal(unique(get_progression(year = 1955)$year), 1955L)
    expect_setequal(unique(get_progression(year = c(1955, 2010))$year),
                    c(1955L, 2010L))
  })
})

test_that("level is always fundamental_anos_iniciais", {
  with_prog_fixture({
    out <- get_progression()
    expect_setequal(unique(out$level), "fundamental_anos_iniciais")
  })
})

test_that("unit is always ratio", {
  with_prog_fixture({
    out <- get_progression()
    expect_setequal(unique(out$unit), "ratio")
  })
})

test_that("lang='pt' translates level labels", {
  with_prog_fixture({
    pt <- get_progression(lang = "pt")
    expect_true(all(pt$level == "Fundamental — anos iniciais"))
  })
})

test_that(".load_progression_panel errors with friendly message when nothing built", {
  empty_env <- new.env(parent = emptyenv())
  expect_error(
    educabr:::.load_progression_panel(env = empty_env),
    "No progression dataset"
  )
})

test_that("requesting unavailable UF emits a coverage warning but still returns", {
  with_prog_fixture({
    expect_warning(
      out <- get_progression(geo_level = "UF", geo = c("SP", "TO")),
      "TO"
    )
    # SP rows are returned; TO is just not in the source so it yields nothing.
    expect_setequal(unique(out$geo_code), "SP")
  })
})

test_that("requesting only covered UFs emits no warning", {
  with_prog_fixture({
    expect_no_warning(
      get_progression(geo_level = "UF", geo = c("SP", "BA"))
    )
  })
})
