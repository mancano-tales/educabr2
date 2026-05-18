make_fixture <- function() {
  data.frame(
    year        = c(1933L, 1933L, 1960L, 1960L, 1960L, 1960L, 1960L, 2010L, 2010L),
    geo_level   = c("BR",  "BR",  "BR",  "BR",  "BR",  "UF",  "UF",  "BR",  "BR"),
    geo_code    = c("BR",  "BR",  "BR",  "BR",  "BR",  "SP",  "BA",  "BR",  "BR"),
    geo_name    = c("Brasil","Brasil","Brasil","Brasil","Brasil","São Paulo","Bahia","Brasil","Brasil"),
    level       = c("fundamental","medio","fundamental","fundamental","medio","fundamental","fundamental","fundamental","fundamental"),
    network     = rep("total", 9),
    dim_race    = c("total","total","white","black","total","total","total","total","total"),
    age_group   = c(NA_character_, NA_character_, "7-14", "7-14", "15-17", "7-14", "7-14", NA_character_, "7-14"),
    indicator   = c("enrollment_count","enrollment_count","enrollment_rate","enrollment_rate","enrollment_rate","enrollment_rate","enrollment_rate","enrollment_count","enrollment_rate"),
    value       = c(2184960, 30964, 65.1, 30.2, 9.1, 70.0, 40.0, 30000000, 95.0),
    unit        = c("count","count","percent","percent","percent","percent","percent","count","percent"),
    source      = rep("kang_fgv_ibre_2023", 9),
    source_note = rep("fixture", 9),
    stringsAsFactors = FALSE
  )
}

# Inject fixture into an isolated env that mimics the package namespace,
# so .load_enrollment_panel() can find `enrollment_kang_fgv` there.
with_fixture <- function(code) {
  env <- new.env(parent = emptyenv())
  assign("enrollment_kang_fgv", make_fixture(), envir = env)

  # Capture the ORIGINAL before replacing it in the namespace — otherwise
  # the closure below would call the replacement and recurse infinitely.
  trace_orig <- educabr:::.load_enrollment_panel
  local_panel <- function() trace_orig(env = env)

  unlockBinding(".load_enrollment_panel", asNamespace("educabr"))
  assign(".load_enrollment_panel",
         function(env = NULL) local_panel(),
         envir = asNamespace("educabr"))
  on.exit({
    assign(".load_enrollment_panel", trace_orig, envir = asNamespace("educabr"))
    lockBinding(".load_enrollment_panel", asNamespace("educabr"))
  }, add = TRUE)

  force(code)
}

test_that("get_enrollment returns long tibble with canonical columns", {
  with_fixture({
    out <- get_enrollment()
    expect_s3_class(out, "tbl_df")
    expect_true(all(c("year","geo_level","geo_code","geo_name","level",
                       "network","dim_race","indicator","value","unit",
                       "source") %in% names(out)))
  })
})

test_that("geo_level filter is exclusive", {
  with_fixture({
    expect_true(all(get_enrollment(geo_level = "BR")$geo_level == "BR"))
    expect_true(all(get_enrollment(geo_level = "UF")$geo_level == "UF"))
  })
})

test_that("geo filter restricts to listed UFs", {
  with_fixture({
    out <- get_enrollment(geo_level = "UF", geo = "SP")
    expect_setequal(unique(out$geo_code), "SP")
  })
})

test_that("year accepts vector and range forms", {
  with_fixture({
    # Single year: exact match
    expect_setequal(unique(get_enrollment(year = 1933)$year), 1933L)
    # Length-2 vector with first <= second is interpreted as [min, max] range
    expect_setequal(unique(get_enrollment(year = c(1933, 1960))$year),
                    c(1933L, 1960L))
    # Length-3+ vector is treated as exact-year membership (not a range)
    expect_setequal(unique(get_enrollment(year = c(1933, 1960, 2010))$year),
                    c(1933L, 1960L, 2010L))
  })
})

test_that("dimension='none' excludes race-broken rows; 'race' keeps only those", {
  with_fixture({
    none <- get_enrollment(dimension = "none")
    expect_true(all(none$dim_race == "total"))

    race <- get_enrollment(dimension = "race")
    expect_true(all(race$dim_race != "total"))
  })
})

test_that("indicator filter maps to enrollment_<key>", {
  with_fixture({
    rate <- get_enrollment(indicator = "rate")
    expect_true(all(rate$indicator == "enrollment_rate"))

    cnt <- get_enrollment(indicator = "count")
    expect_true(all(cnt$indicator == "enrollment_count"))
  })
})

test_that("wide=TRUE pivots indicator to columns and drops unit", {
  with_fixture({
    w <- get_enrollment(geo_level = "BR", dimension = "none", wide = TRUE)
    expect_false("indicator" %in% names(w))
    expect_false("unit" %in% names(w))
    expect_true(any(c("enrollment_count","enrollment_rate") %in% names(w)))
  })
})

test_that("lang='pt' translates level and dim_race", {
  with_fixture({
    pt <- get_enrollment(dimension = "race", lang = "pt")
    expect_true(any(pt$dim_race %in% c("Branca","Preta")))
    # English default unchanged
    en <- get_enrollment(dimension = "race", lang = "en")
    expect_true(any(en$dim_race %in% c("white","black")))
  })
})

test_that(".load_enrollment_panel errors with friendly message when nothing built", {
  empty_env <- new.env(parent = emptyenv())
  expect_error(
    educabr:::.load_enrollment_panel(env = empty_env),
    "No enrollment dataset"
  )
})
