# Brazilian school-enrollment series

Returns harmonized school-enrollment counts and rates, optionally broken
down by color/race, administrative network, institutional type, or
teaching modality. Series are pulled from all enrollment datasets
shipped with the package and concatenated into the canonical long-format
schema.

## Usage

``` r
get_enrollment(
  level = NULL,
  network = NULL,
  institution_type = NULL,
  modality = NULL,
  year = NULL,
  geo_level = c("BR", "UF"),
  geo = NULL,
  dimension = c("none", "race"),
  indicator = NULL,
  source = NULL,
  include_derived = FALSE,
  wide = FALSE,
  lang = c("en", "pt")
)
```

## Arguments

- level:

  Character vector with one or more stage codes:
  `"fundamental_anos_iniciais"`, `"fundamental_anos_finais"`,
  `"fundamental"`, `"medio"`, `"superior"`. `NULL` (default) means no
  filter.

- network:

  Character vector with administrative-network codes (`"federal"`,
  `"estadual"`, `"municipal"`, `"publica"`, `"privada"`, plus the
  post-2009 private subcategories `"privada_particular"`,
  `"privada_comunitaria_confessional_filantropica"`,
  `"privada_lucrativa"`, `"privada_nao_lucrativa"`, `"especial"`,
  `"total"`). `NULL` (default) means no filter.

- institution_type:

  Character vector restricting the institutional category (only
  meaningful for `level = "superior"`). See `inst/dict/schema.yaml` for
  the controlled vocabulary. `NULL` (default) means no filter; pass
  `"total"` to keep only rows that aggregate across institutional types.

- modality:

  Character vector: `"presencial"`, `"ead"`, `"total"`. `NULL` (default)
  means no filter.

- year:

  Integer vector or two-element `c(min, max)` range. `NULL` for all
  years.

- geo_level:

  One of `"BR"` (national, default) or `"UF"` (state).

- geo:

  Character vector of 2-letter UF codes when `geo_level = "UF"`. `NULL`
  (default) returns all UFs.

- dimension:

  Inequality breakdown. One of `"none"` (default, totals only) or
  `"race"`. Future versions add `"sex"`, `"income"`, `"location"`.

- indicator:

  Character vector. `"count"` for counts, `"rate"` for gross enrollment
  rates. `NULL` returns both.

- source:

  Character vector of source keys (see
  `inst/dict/vocabularies/sources.yaml`). `NULL` returns all available
  sources. **Tip:** when the same `(year, level, network)` is covered by
  multiple sources (common in the tertiary panel), pass `source = "..."`
  to lock down a single series.

- include_derived:

  Logical. If `FALSE` (default), excludes the so-called **reconstructed
  totals** — rows where the value was computed by combining components
  from different sources (typically the in-person enrollment from a
  single-source paper plus the EAD enrollment from INEP, for 2000-2008
  where the original sources under-reported the combined total). Set to
  `TRUE` to include them. The composition is documented in
  `source_note`; the `source` column for these rows carries the
  composite key `"<presencial_source>+<ead_source>"`. Has no effect on
  datasets that do not carry an `is_derived` flag.

- wide:

  Logical. If `TRUE`, pivots the `indicator` column to wide form (one
  column per indicator). Default `FALSE`.

- lang:

  One of `"en"` (default) or `"pt"`. When `"pt"`, factor levels are
  translated using `inst/dict/i18n.yaml`.

## Value

A tibble following the canonical schema in `inst/dict/schema.yaml`.
Optional columns (`institution_type`, `modality`, `is_derived`) are
present whenever any of the loaded datasets carries them; for rows
coming from datasets without that column the value defaults to `"total"`
(or `FALSE` for `is_derived`).

## Examples

``` r
if (FALSE) {
# National series, ensino fundamental, all years
get_enrollment(level = "fundamental", geo_level = "BR")

# Tertiary enrollment, all sources, compare them
get_enrollment(level = "superior", network = "total", modality = "total")

# Tertiary private particular only, post-2000
get_enrollment(level = "superior", network = "privada_particular",
               year = c(2000, 2024))

# Compare with derived rows included
get_enrollment(level = "superior", network = "total",
               year = c(2000, 2008), include_derived = TRUE)
}
```
