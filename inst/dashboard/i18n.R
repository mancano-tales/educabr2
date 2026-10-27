# UI language is selected per request/session, never via a mutable global option.
# Both local run_dashboard(lang=...) and hosted ?lang=pt / ?lang=en are supported.
dashboard_language <- function(search = NULL) {
  query <- shiny::parseQueryString(if (is.null(search)) "" else search)
  requested <- query$lang
  if (length(requested) == 1L && requested %in% c("pt", "en")) return(requested)
  default <- getOption("educabr2.dashboard.lang", "pt")
  if (length(default) == 1L && default %in% c("pt", "en")) default else "pt"
}

dashboard_translate <- local({
  dictionary <- unlist(yaml::read_yaml("i18n.yaml"), use.names = TRUE)
  function(text, lang = "pt") {
    if (lang == "en") return(text)
    translated <- unname(dictionary[text])
    translated[is.na(translated)] <- text[is.na(translated)]
    names(translated) <- names(text)
    translated
  }
})

dashboard_value_labels <- local({
  vocab <- yaml::read_yaml(system.file("dict/i18n.yaml", package = "educabr2"))$levels
  function(values, column, lang) {
    if (lang == "en" || is.null(vocab[[column]])) return(values)
    labels <- unname(unlist(vocab[[column]])[as.character(values)])
    labels[is.na(labels)] <- as.character(values)[is.na(labels)]
    labels
  }
})

dashboard_datatable <- function(data, lang, ...) {
  if (lang == "pt") {
    for (column in names(data)) {
      data[[column]] <- dashboard_value_labels(data[[column]], column, lang)
    }
  }
  columns <- c(year = "Ano", geo_level = "Nível geográfico", geo_code = "Código geográfico",
               geo_name = "Nome geográfico", level = "Etapa", network = "Rede",
               institution_type = "Organização acadêmica", modality = "Modalidade",
               dim_race = "Raça/cor", dim_sex = "Sexo", age_group = "Faixa etária",
               indicator = "Indicador", value = "Valor", unit = "Unidade",
               source = "Fonte", source_note = "Nota da fonte", is_derived = "Derivado")
  headings <- names(data)
  if (lang == "pt") {
    found <- headings %in% names(columns)
    headings[found] <- columns[headings[found]]
  }
  # Inline DataTables translations keep the dashboard usable offline.
  language <- if (lang == "pt") list(
    search = "Pesquisar:", lengthMenu = "Mostrar _MENU_ linhas",
    info = "Mostrando _START_ a _END_ de _TOTAL_ linhas",
    infoEmpty = "Nenhuma linha", infoFiltered = "(filtrado de _MAX_ linhas)",
    zeroRecords = "Nenhum resultado", emptyTable = "Nenhum dado disponível",
    loadingRecords = "Carregando...", processing = "Processando...",
    paginate = list(first = "Primeira", previous = "Anterior", "next" = "Próxima", last = "Última"),
    aria = list(sortAscending = ": ordenar crescente", sortDescending = ": ordenar decrescente")
  ) else list()
  DT::datatable(data, colnames = headings, ...,
                options = list(pageLength = 25, scrollX = TRUE, language = language))
}
