#' educabr2: Harmonized Historical Series on Brazilian Education
#'
#' Curated long-run series on Brazilian formal education: enrollment,
#' schooling, public expenditure, grade progression and international
#' educational attainment, compiled from official and academic sources
#' into a single tidy schema with observation-level provenance.
#'
#' The canonical output schema (one row per observation; sources as
#' separate rows) is documented in `inst/dict/schema.yaml`. Inequality is
#' not a dataset but a *cut* applied to indicators: the available
#' `dimension` filters expose race or sex breakdowns where supported
#' by the function and source. A `compute_gap()`
#' helper for turning long-format breakdowns into the usual gap/ratio
#' metrics is on the roadmap for a future release.
#'
#' @section Available features / Funcionalidades disponíveis:
#' Five data-access functions ([get_enrollment()], [get_schooling()],
#' [get_expenditure()], [get_progression()], [get_attainment()]) query six
#' bundled datasets offline. [list_sources()] and [educabr_cite()] support
#' discovery and citation. [run_dashboard()] launches the interactive app.
#'
#' Cinco funções de acesso consultam seis conjuntos de dados offline:
#' matrículas, escolaridade, despesa pública, progressão escolar e conclusão
#' educacional internacional. [list_sources()] e [educabr_cite()] permitem
#' descobrir e citar as fontes; [run_dashboard()] abre o painel interativo.
#'
#' @section Português:
#' Séries históricas harmonizadas da educação brasileira: matrículas
#' (1871–2024), escolaridade (1925–2015), despesa pública (1933–2010),
#' progressão escolar (1955–2010) e conclusão educacional em 111 países
#' (1870–2010). Cada observação registra sua fonte; estimativas concorrentes
#' permanecem em linhas separadas. O esquema está em `inst/dict/schema.yaml`.
#' As dimensões disponíveis variam por função e fonte: raça/cor nas matrículas,
#' raça/cor e sexo na escolaridade, sexo na conclusão internacional. O argumento
#' `lang = "pt"` traduz rótulos de saída; filtros, colunas e chaves de fonte
#' usam identificadores canônicos. Nomes geográficos preservam a fonte.
#' Um auxiliar `compute_gap()` permanece como proposta para versão futura.
#'
#' @section Related work:
#' `educabr2` ships a curated, static long-run panel — not a live
#' connection to INEP. For current-year microdata (IDEB, ENEM, Censo
#' Escolar, SAEB, and other INEP indicators fetched and cached on
#' demand), see the sibling package
#' [educabR](https://CRAN.R-project.org/package=educabR) by Sidney
#' Bissoli. The two packages are complementary — organised along
#' different axes (by theme and historical series here; by official
#' source there) — and can be used side by side. If you use both, cite
#' both: `citation("educabR")` and `citation("educabr2")`.
#'
#' O pacote complementar [educabR](https://CRAN.R-project.org/package=educabR),
#' de Sidney Bissoli, baixa dados oficiais sob demanda e preserva os leiautes
#' das agências; aqui o acesso é por tema e série histórica harmonizada.
#' Se usar ambos, cite ambos. A compatibilidade dos esquemas é acompanhada na
#' [issue 8](https://github.com/mancano-tales/educabr2/issues/8): primeiro
#' aprimorar e validar os dados tratados nas funções existentes; depois avaliar
#' colaboração. A proposta externa anterior foi retirada. As séries pequenas
#' continuam embutidas no pacote, com acesso offline.
#' Planning now focuses on improving and validating curated data through
#' existing functions before proposing collaboration. The earlier external
#' proposal was withdrawn; small series remain bundled for offline access.
#'
#' @keywords internal
"_PACKAGE"
