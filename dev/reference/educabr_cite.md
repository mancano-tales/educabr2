# Generate citations for educabr2 data sources

Builds [`utils::bibentry()`](https://rdrr.io/r/utils/bibentry.html)
objects for the primary sources whose data is harmonised in `educabr2`.
Use this whenever you publish analyses built on a `get_*()` call — cite
the originating source(s), not only the package itself.

## Usage

``` r
educabr_cite(source_key = NULL, style = c("bibentry", "text", "bibtex"))
```

## Arguments

- source_key:

  Character vector of source keys (e.g. `"kang_paese_felix_2021"`,
  `"walter_kang_2023"`). `NULL` (default) returns citations for **all**
  sources. To discover which sources contributed rows to a particular
  query, inspect the `source` column of the tibble returned by
  [`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
  or
  [`get_schooling()`](https://mancano-tales.github.io/educabr/dev/reference/get_schooling.md).

- style:

  One of:

  - `"bibentry"` (default) — a
    [`utils::bibentry()`](https://rdrr.io/r/utils/bibentry.html) object
    you can further format via
    [`utils::toBibtex()`](https://rdrr.io/r/utils/toLatex.html) or
    [`format()`](https://rdrr.io/r/base/format.html);

  - `"text"` — APA-style prose (one character string per source);

  - `"bibtex"` — a
    [`utils::toBibtex()`](https://rdrr.io/r/utils/toLatex.html) result
    ready to paste into a `.bib` file.

## Value

A `bibentry` object (default), a character vector, or a `Bibtex` object
— see `style`. Length is 1 per requested source.

## Details

Citation metadata is read from `inst/dict/vocabularies/sources.yaml`,
the same controlled vocabulary that backs the `source` column of
[`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
and
[`get_schooling()`](https://mancano-tales.github.io/educabr/dev/reference/get_schooling.md).

## See also

[`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md),
[`get_schooling()`](https://mancano-tales.github.io/educabr/dev/reference/get_schooling.md),
[`utils::bibentry()`](https://rdrr.io/r/utils/bibentry.html),
[`utils::toBibtex()`](https://rdrr.io/r/utils/toLatex.html).

## Examples

``` r
# A single source (default returns a bibentry)
educabr_cite("kang_paese_felix_2021")
#> (2021). “Kang, T. H., Paese, L. H. Z., & Felix, N. F. A. (2021). Late
#> and unequal: Enrolments and retention in Brazilian education,
#> 1933-2010. Revista de Historia Económica / Journal of Iberian and Latin
#> American Economic History, 39(2), 191–218.”
#> doi:10.1017/S0212610921000112
#> <https://doi.org/10.1017/S0212610921000112>.
#> <https://doi.org/10.1017/S0212610921000112>.

# Plain APA-style prose
educabr_cite("walter_kang_2023", style = "text")
#> [1] "(2024). “Walter, J. R., & Kang, T. H. (2024). A new dataset of average\nyears of schooling in Brazil, 1925–2015. Economic History of Developing\nRegions, 39(3), 307–336. [Originally circulated as FGV-IBRE working\npaper, 2023.].” doi:10.1080/20780389.2024.2417268\n<https://doi.org/10.1080/20780389.2024.2417268>.\n<https://doi.org/10.1080/20780389.2024.2417268>."

# BibTeX entry, ready to paste into a .bib file
educabr_cite("paglayan_2022", style = "bibtex")
#> @Misc{paglayan_2022,
#>   title = {Paglayan, A. S. (2022). Education or Indoctrination? The Violent Origins of Public Schooling.},
#>   year = {2022},
#>   doi = {10.7910/DVN/LKE1WQ},
#>   url = {https://doi.org/10.7910/DVN/LKE1WQ},
#> }

# All bundled sources at once
educabr_cite()
#> (2022). “Paglayan, A. S. (2022). Education or Indoctrination? The
#> Violent Origins of Public Schooling.” doi:10.7910/DVN/LKE1WQ
#> <https://doi.org/10.7910/DVN/LKE1WQ>.
#> <https://doi.org/10.7910/DVN/LKE1WQ>.
#> 
#> (????). “Pesquisa Nacional por Amostra de Domicílios. Instituto
#> Brasileiro de Geografia e Estatística (IBGE).”
#> <https://www.ibge.gov.br/estatisticas/sociais/educacao/9127-pesquisa-nacional-por-amostra-de-domicilios.html>.
#> 
#> (????). “Pesquisa Nacional por Amostra de Domicílios Contínua. IBGE.”
#> <https://www.ibge.gov.br/estatisticas/sociais/trabalho/9171-pesquisa-nacional-por-amostra-de-domicilios-continua-mensal.html>.
#> 
#> (????). “Censo Demográfico. IBGE.”
#> <https://www.ibge.gov.br/estatisticas/sociais/populacao/22827-censo-demografico-2022.html>.
#> 
#> (????). “Censo Escolar da Educação Básica. INEP/MEC.”
#> <https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/censo-escolar>.
#> 
#> (????). “Anuário Estatístico do Brasil. IBGE.”
#> <https://biblioteca.ibge.gov.br/biblioteca-catalogo?id=720&view=detalhes>.
#> 
#> (2021). “Kang, T. H., Paese, L. H. Z., & Felix, N. F. A. (2021). Late
#> and unequal: Enrolments and retention in Brazilian education,
#> 1933-2010. Revista de Historia Económica / Journal of Iberian and Latin
#> American Economic History, 39(2), 191–218.”
#> doi:10.1017/S0212610921000112
#> <https://doi.org/10.1017/S0212610921000112>.
#> <https://doi.org/10.1017/S0212610921000112>.
#> 
#> (2024). “Kang, T. H., & Menetrier, I. (2024). Políticas elitistas e
#> despesas públicas em educação no Brasil, 1933-2010. Estudos Econômicos
#> (São Paulo), 54(3), e53575434.” doi:10.1590/1980-53575434tkim
#> <https://doi.org/10.1590/1980-53575434tkim>.
#> <https://doi.org/10.1590/1980-53575434tkim>.
#> 
#> (2024). “Kang, T. H., Menetrier, I., & Comim, F. (2024). The side
#> effects of a big push growth strategy: Export incentives and primary
#> education under military rule in Brazil, 1967–1985. Revista de Historia
#> Económica / Journal of Iberian and Latin American Economic History,
#> 42(3), 387–414.” doi:10.1017/S0212610924000120
#> <https://doi.org/10.1017/S0212610924000120>.
#> <https://doi.org/10.1017/S0212610924000120>.
#> 
#> (2005). “Durham, E. R. (2005). Educação superior, pública e privada. In
#> S. Schwartzman (Ed.), Os desafios da educação no Brasil (pp. 191–233).
#> Rio de Janeiro: Nova Fronteira.”
#> 
#> (2007). “Maduro Junior, P. R. R. M. (2007). Taxas de matrícula e gastos
#> em educação no Brasil [Dissertação de Mestrado, Fundação Getulio
#> Vargas, Escola de Pós-Graduação em Economia – EPGE].”
#> <https://hdl.handle.net/10438/110>.
#> 
#> (2007). “IBGE (2007). Estatísticas do Século XX. Rio de Janeiro:
#> Instituto Brasileiro de Geografia e Estatística.”
#> <https://seculoxx.ibge.gov.br/>.
#> 
#> (1995). “INEP/MEC. Sinopse Estatística da Educação Superior (anos
#> 1995-2008).”
#> <https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/censo-da-educacao-superior>.
#> 
#> (2009). “INEP/MEC. Microdados do Censo da Educação Superior (anos
#> 2009-2024).”
#> <https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/censo-da-educacao-superior>.
#> 
#> (????). “INEP/MEC. Painel Power BI do Censo da Educação Superior.”
#> <https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/censo-da-educacao-superior>.
#> 
#> (2024). “Walter, J. R., & Kang, T. H. (2024). A new dataset of average
#> years of schooling in Brazil, 1925–2015. Economic History of Developing
#> Regions, 39(3), 307–336. [Originally circulated as FGV-IBRE working
#> paper, 2023.].” doi:10.1080/20780389.2024.2417268
#> <https://doi.org/10.1080/20780389.2024.2417268>.
#> <https://doi.org/10.1080/20780389.2024.2417268>.

# Typical workflow: query, then cite only what you used
if (FALSE) { # \dontrun{
d   <- get_enrollment(level = "fundamental", indicator = "rate")
src <- unique(d$source)
educabr_cite(src, style = "text")
} # }
```
