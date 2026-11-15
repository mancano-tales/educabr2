# Declare names referenced via standard evaluation on package data, to
# silence "no visible binding for global variable" notes from R CMD check.
utils::globalVariables(c(
  "enrollment_kang_fgv",
  "enrollment_tertiary",
  "enrollment_medio_network",
  "schooling_kang_fgv",
  "expenditure_kang_fgv",
  "progression_kang_fgv",
  "lee_lee_2016"
))
