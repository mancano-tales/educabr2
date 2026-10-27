# Package index

## Acesso aos dados / Data access

API das séries harmonizadas; cada função retorna um tibble no esquema
comum de `inst/dict/schema.yaml`. / Harmonized-series API; each function
returns a tibble following the common schema in `inst/dict/schema.yaml`.

- [`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md)
  : Brazilian school-enrollment series
- [`get_schooling()`](https://mancano-tales.github.io/educabr2/reference/get_schooling.md)
  : Brazilian mean years of schooling
- [`get_expenditure()`](https://mancano-tales.github.io/educabr2/reference/get_expenditure.md)
  : Brazilian public expenditure on education
- [`get_progression()`](https://mancano-tales.github.io/educabr2/reference/get_progression.md)
  : Brazilian grade-progression series
- [`get_attainment()`](https://mancano-tales.github.io/educabr2/reference/get_attainment.md)
  : Comparative international educational-attainment series

## Citação e proveniência / Citation and provenance

Descubra e cite as fontes originais, além do pacote. / Discover and cite
the original sources as well as the package.

- [`list_sources()`](https://mancano-tales.github.io/educabr2/reference/list_sources.md)
  : List the data sources bundled with educabr2
- [`educabr_cite()`](https://mancano-tales.github.io/educabr2/reference/educabr_cite.md)
  : Generate citations for educabr2 data sources

## Visualização / Visualization

Tema ggplot2, paleta Okabe-Ito segura para daltonismo e eixo de anos
para séries históricas. / A ggplot2 theme, colourblind-safe Okabe-Ito
palette and year axis for historical series.

- [`theme_educabr()`](https://mancano-tales.github.io/educabr2/reference/theme_educabr.md)
  : educabr2 Visualization Theme
- [`scale_colour_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_educabr.md)
  [`scale_fill_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_educabr.md)
  : educabr2 Color Scales (Okabe-Ito)
- [`scale_x_year_educabr()`](https://mancano-tales.github.io/educabr2/reference/scale_x_year_educabr.md)
  : Year Axis Scale for Historical Series

## Painel / Dashboard

Abra o painel Shiny local ou consulte o [painel
público](https://qx3hly-tales-man0ano.shinyapps.io/educabr2/). / Launch
the local Shiny app or visit the [public
dashboard](https://qx3hly-tales-man0ano.shinyapps.io/educabr2/).

- [`run_dashboard()`](https://mancano-tales.github.io/educabr2/reference/run_dashboard.md)
  : Launch the educabr2 Shiny dashboard

## Conjuntos de dados / Backing datasets

Objetos distribuídos com o pacote. Prefira as funções `get_*()` para
filtrar, normalizar o esquema e traduzir rótulos. / Objects bundled with
the package. Prefer `get_*()` to filter, normalize the schema and
translate labels.

- [`enrollment_kang_fgv`](https://mancano-tales.github.io/educabr2/reference/enrollment_kang_fgv.md)
  : Enrollment series — Kang / FGV-IBRE 2023 compilation
- [`enrollment_tertiary`](https://mancano-tales.github.io/educabr2/reference/enrollment_tertiary.md)
  : Tertiary (ensino superior) enrollment — multi-source compilation
- [`schooling_kang_fgv`](https://mancano-tales.github.io/educabr2/reference/schooling_kang_fgv.md)
  : Mean years of schooling — Walter & Kang 2024 compilation
- [`expenditure_kang_fgv`](https://mancano-tales.github.io/educabr2/reference/expenditure_kang_fgv.md)
  : Public expenditure on education — Kang & Menetrier 2024 compilation
- [`progression_kang_fgv`](https://mancano-tales.github.io/educabr2/reference/progression_kang_fgv.md)
  : Grade-progression series (GDR6) — Kang, Paese & Felix 2021
  compilation
- [`lee_lee_2016`](https://mancano-tales.github.io/educabr2/reference/lee_lee_2016.md)
  : Comparative international educational attainment — Lee & Lee 2016

## Pacote / Package

- [`educabr2`](https://mancano-tales.github.io/educabr2/reference/educabr2-package.md)
  [`educabr2-package`](https://mancano-tales.github.io/educabr2/reference/educabr2-package.md)
  : educabr2: Harmonized Historical Series on Brazilian Education
