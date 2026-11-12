# Tests for enrollment_medio_network (ensino medio by network, INEP).

test_that("enrollment_medio_network follows the schema and adds up", {
  d <- educabr2::enrollment_medio_network
  expect_silent(educabr2:::validate_against_schema(d, theme = "enrollment"))
  expect_true(all(d$level == "medio"))
  expect_setequal(unique(d$network),
                  c("federal", "estadual", "municipal", "publica", "privada", "total"))
  expect_false(any(d$year %in% c(2003L, 2004L)))
  expect_equal(range(d$year), c(1996L, 2024L))

  w <- stats::reshape(as.data.frame(d[, c("year", "network", "value")]),
                      idvar = "year", timevar = "network", direction = "wide")
  expect_equal(w$value.publica + w$value.privada, w$value.total)
  expect_equal(w$value.federal + w$value.estadual + w$value.municipal,
               w$value.publica)
})

test_that("enrollment_medio_network matches the published INEP tables", {
  d <- educabr2::enrollment_medio_network
  v <- function(y, n) d$value[d$year == y & d$network == n]
  # Sinopse 1996, tabela 1.7 (Brasil row).
  expect_equal(v(1996L, "total"), 5739077)
  expect_equal(v(1996L, "privada"), 1176519)
  # Sinopse 1998 (PDF), tabela 1.31.
  expect_equal(v(1998L, "total"), 6968531)
  # Sinopse 2006, tabela 1.43.
  expect_equal(v(2006L, "estadual"), 7584391)
  expect_equal(unique(d$source[d$year <= 2006L]), "inep_sinopse_censo_escolar")
  expect_equal(unique(d$source[d$year >= 2007L]), "inep_microdados_censo_escolar")
})

test_that("get_enrollment() serves medio by network", {
  x <- get_enrollment(level = "medio", network = "privada",
                      source = "inep_microdados_censo_escolar")
  expect_gt(nrow(x), 0)
  expect_true(all(x$network == "privada"))
})
