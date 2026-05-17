# Declare names referenced via standard evaluation on package data, to
# silence "no visible binding for global variable" notes from R CMD check.
utils::globalVariables(c(
  "enrollment_kang_fgv",
  "schooling_kang_fgv"
))
