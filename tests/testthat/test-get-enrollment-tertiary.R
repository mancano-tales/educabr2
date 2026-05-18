# Tests for the tertiary-panel features of get_enrollment():
#   - institution_type filter
#   - modality filter
#   - include_derived toggle
#   - new private-network subcategories
# Uses the same fixture-injection pattern as test-get-enrollment.R.

make_ter_fixture <- function() {
  data.frame(
    year             = c(2010L, 2010L, 2010L, 2010L, 2010L, 2010L,
                         2015L, 2015L, 2020L,
                         2008L),
    geo_level        = rep("BR", 10),
    geo_code         = rep("BR", 10),
    geo_name         = rep("Brasil", 10),
    level            = rep("superior", 10),
    network          = c("total",  "total",  "publica", "privada_particular",
                         "privada_lucrativa", "privada_nao_lucrativa",
                         "federal", "federal",
                         "total",
                         "total"),
    institution_type = c("total",  "university", "total", "total",
                         "total", "total",
                         "university", "faculty",
                         "total",
                         "total"),
    modality         = c("total",  "presencial", "presencial", "ead",
                         "presencial", "ead",
                         "total", "presencial",
                         "ead",
                         "total"),
    dim_race         = rep("total", 10),
    age_group        = rep(NA_character_, 10),
    indicator        = rep("enrollment_count", 10),
    value            = c(6e6, 4e6, 1.5e6, 8e5,
                         2e6, 5e5,
                         9e5, 3e5,
                         1e6,
                         5.5e6),
    unit             = rep("count", 10),
    source           = c(rep("inep_microdados_censup", 9),
                         "kang_paese_felix_2021+inep_sinopse_censup"),
    source_note      = rep("fixture", 10),
    is_derived       = c(rep(FALSE, 9), TRUE),
    stringsAsFactors = FALSE
  )
}

# Inject the fixture into a fresh env that mimics the package namespace
# so `.load_enrollment_panel()` finds `enrollment_tertiary` there.
with_ter_fixture <- function(code) {
  env <- new.env(parent = emptyenv())
  assign("enrollment_tertiary", make_ter_fixture(), envir = env)
  local_panel <- function() educabr:::.load_enrollment_panel(env = env)

  orig <- educabr:::.load_enrollment_panel
  unlockBinding(".load_enrollment_panel", asNamespace("educabr"))
  assign(".load_enrollment_panel",
         function(env = NULL) local_panel(),
         envir = asNamespace("educabr"))
  on.exit({
    assign(".load_enrollment_panel", orig, envir = asNamespace("educabr"))
    lockBinding(".load_enrollment_panel", asNamespace("educabr"))
  }, add = TRUE)

  force(code)
}

test_that("institution_type filter narrows rows", {
  with_ter_fixture({
    out <- get_enrollment(level = "superior", institution_type = "university")
    expect_true(all(out$institution_type == "university"))
    expect_true(nrow(out) >= 2L)
  })
})

test_that("modality filter accepts multiple values", {
  with_ter_fixture({
    out <- get_enrollment(level = "superior",
                          modality = c("presencial", "ead"))
    expect_true(all(out$modality %in% c("presencial", "ead")))
    expect_false(any(out$modality == "total"))
  })
})

test_that("new private network subcategories are accepted", {
  with_ter_fixture({
    for (nw in c("privada_particular",
                 "privada_lucrativa",
                 "privada_nao_lucrativa")) {
      out <- get_enrollment(level = "superior", network = nw)
      expect_true(all(out$network == nw),
                  info = sprintf("network = %s", nw))
    }
  })
})

test_that("include_derived = FALSE (default) excludes derived rows", {
  with_ter_fixture({
    out <- get_enrollment(level = "superior")
    expect_false(any(out$is_derived))
  })
})

test_that("include_derived = TRUE keeps derived rows", {
  with_ter_fixture({
    out <- get_enrollment(level = "superior", include_derived = TRUE)
    expect_true(any(out$is_derived))
  })
})

test_that("source filter matches composite derived keys exactly", {
  with_ter_fixture({
    out <- get_enrollment(level = "superior",
                          source = "kang_paese_felix_2021+inep_sinopse_censup",
                          include_derived = TRUE)
    expect_equal(nrow(out), 1L)
    expect_true(out$is_derived)
  })
})

test_that("loader normalises a dataset that lacks the new optional columns", {
  # Simulates an older .rda where institution_type/modality/is_derived
  # are absent. The loader should fill them with documented defaults
  # ("total" / FALSE) so downstream filters still work.
  env <- new.env(parent = emptyenv())
  legacy <- make_ter_fixture()[, c("year","geo_level","geo_code","geo_name",
                                    "level","network","dim_race",
                                    "age_group","indicator","value","unit",
                                    "source","source_note")]
  assign("enrollment_tertiary", legacy, envir = env)

  orig <- educabr:::.load_enrollment_panel
  unlockBinding(".load_enrollment_panel", asNamespace("educabr"))
  assign(".load_enrollment_panel",
         function(env = NULL) educabr:::.normalise_enrollment_piece(
           get("enrollment_tertiary", envir = env)),
         envir = asNamespace("educabr"))
  on.exit({
    assign(".load_enrollment_panel", orig, envir = asNamespace("educabr"))
    lockBinding(".load_enrollment_panel", asNamespace("educabr"))
  }, add = TRUE)

  panel <- educabr:::.load_enrollment_panel(env = env)
  expect_true(all(c("institution_type","modality","is_derived") %in% names(panel)))
  expect_true(all(panel$institution_type == "total"))
  expect_true(all(panel$modality == "total"))
  expect_false(any(panel$is_derived))
})
