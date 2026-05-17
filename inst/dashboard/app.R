# educabr dashboard — v0.3
#
# Three-theme navbar:
#   * Matrículas (Kang fundamental/médio/superior, simple)
#   * Ensino Superior (multi-source comparison, 1907-2024)
#   * Escolaridade (Walter & Kang mean years of schooling)
# Consumes only the public API: get_enrollment() and get_schooling().

library(shiny)
library(bslib)
library(ggplot2)

stopifnot(requireNamespace("educabr", quietly = TRUE))

# ---- shared choices --------------------------------------------------

UF_CHOICES <- c(
  AC="Acre", AL="Alagoas", AM="Amazonas", AP="Amapá", BA="Bahia",
  CE="Ceará", DF="Distrito Federal", ES="Espírito Santo", GO="Goiás",
  MA="Maranhão", MG="Minas Gerais", MS="Mato Grosso do Sul",
  MT="Mato Grosso", PA="Pará", PB="Paraíba", PE="Pernambuco",
  PI="Piauí", PR="Paraná", RJ="Rio de Janeiro", RN="Rio Grande do Norte",
  RO="Rondônia", RR="Roraima", RS="Rio Grande do Sul",
  SC="Santa Catarina", SE="Sergipe", SP="São Paulo", TO="Tocantins"
)
UF_CHOICES <- setNames(names(UF_CHOICES), paste0(UF_CHOICES, " (", names(UF_CHOICES), ")"))

REGION_CHOICES <- c(
  "Norte (N)"          = "N",
  "Nordeste (NE)"      = "NE",
  "Centro-Oeste (CO)"  = "CO",
  "Sudeste (SE)"       = "SE",
  "Sul (S)"            = "S"
)

# ---- matrículas choices ----------------------------------------------

ENR_LEVEL_CHOICES <- c(
  "Fundamental (total)"         = "fundamental",
  "Fundamental — anos iniciais" = "fundamental_anos_iniciais",
  "Fundamental — anos finais"   = "fundamental_anos_finais",
  "Médio"                       = "medio",
  "Superior"                    = "superior"
)
ENR_IND_CHOICES <- c("Taxa bruta (%)" = "rate", "Matrículas (n)" = "count")
ENR_DIM_CHOICES <- c("Total (sem recorte)" = "none", "Por raça/cor" = "race")

# ---- ensino superior (multifonte) choices ----------------------------

TER_NETWORK_CHOICES <- c(
  "Total (geral)"                       = "total",
  "Pública (agregada)"                  = "publica",
  "Pública — Federal"                   = "federal",
  "Pública — Estadual"                  = "estadual",
  "Pública — Municipal"                 = "municipal",
  "Privada (agregada)"                  = "privada",
  "Privada — Particular"                = "privada_particular",
  "Privada — Comunit./Confes./Filant."  = "privada_comunitaria_confessional_filantropica",
  "Privada — Com fins lucrativos"       = "privada_lucrativa",
  "Privada — Sem fins lucrativos"       = "privada_nao_lucrativa",
  "Especial"                            = "especial"
)

TER_INST_CHOICES <- c(
  "Total (sem desagregação)"            = "total",
  "Universidade"                        = "university",
  "Centro Universitário"                = "university_center",
  "Faculdade"                           = "faculty",
  "Faculdade/Escola/Instituto"          = "faculty_school_institute",
  "Faculdade Integrada"                 = "integrated_faculty",
  "Faculdade Integ./Centro Univ."       = "integrated_faculty_university_center",
  "Centro de Educação Tecnológica"      = "technology_center",
  "Centro de Ed. Tec./Fac. Tec."        = "technology_center_fat",
  "CEFET/IFET"                          = "cefet_ifet",
  "Estabelecimento Isolado"             = "isolated_establishment"
)

TER_MOD_CHOICES <- c(
  "Total (sem desagregação)" = "total",
  "Presencial"               = "presencial",
  "EAD (Distância)"          = "ead"
)

TER_SOURCE_CHOICES <- c(
  "Kang, Paese & Felix (2021)"          = "kang_paese_felix_2021",
  "Kang & Menetrier (2024)"             = "kang_menetrier_2024",
  "Kang, Menetrier & Comim (2024)"      = "kang_menetrier_comim_2024",
  "Durham (2005)"                       = "durham_2005",
  "Maduro Junior (2007)"                = "maduro_junior_2007",
  "IBGE Estatísticas do Século XX"      = "ibge_seculo_xx",
  "INEP Sinopse CENSUP (1995-2008)"     = "inep_sinopse_censup",
  "INEP Microdados CENSUP (2009-2024)"  = "inep_microdados_censup",
  "INEP CENSUP Power BI (2010-2024)"    = "inep_censup_powerbi"
)

TER_COLOR_BY_CHOICES <- c(
  "Fonte"               = "source",
  "Rede"                = "network",
  "Tipo institucional"  = "institution_type",
  "Modalidade"          = "modality"
)

# ---- escolaridade choices --------------------------------------------

SCH_DIM_CHOICES <- c(
  "Total (sem recorte)" = "none",
  "Por raça/cor"        = "race",
  "Por sexo"            = "sex"
)

# ---- helper ----------------------------------------------------------

sources_card_ui <- function(source_keys, yaml_path) {
  if (!nzchar(yaml_path)) return(tags$p("Catálogo de fontes indisponível."))
  all_sources <- yaml::read_yaml(yaml_path)$sources
  used <- if (length(source_keys)) source_keys else names(all_sources)
  cards <- lapply(used, function(key) {
    meta <- all_sources[[key]]
    if (is.null(meta)) return(NULL)
    bslib::card(
      bslib::card_header(meta$short_name %||% key),
      bslib::card_body(
        tags$p(meta$full_name %||% ""),
        if (!is.null(meta$url))
          tags$a(href = meta$url, "Link da fonte", target = "_blank"),
        if (!is.null(meta$coverage))
          tags$p(tags$strong("Cobertura: "),
                 sprintf("%s–%s, %s",
                         meta$coverage$years[[1]] %||% "?",
                         meta$coverage$years[[2]] %||% "atual",
                         paste(meta$coverage$geo, collapse = ", ")))
      )
    )
  })
  do.call(tagList, cards)
}

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

# ---- UI --------------------------------------------------------------

ui <- bslib::page_navbar(
  title           = "educabr — Educação no Brasil",
  theme           = bslib::bs_theme(version = 5),
  navbar_options  = bslib::navbar_options(bg = "#2d6a4f"),

  # ---- Matrículas ----
  bslib::nav_panel(
    title = "Matrículas",
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        width = 320,
        radioButtons("enr_geo_level", "Granularidade",
                     choices = c("Brasil" = "BR", "Estados (UF)" = "UF"),
                     selected = "BR", inline = TRUE),
        conditionalPanel(
          condition = "input.enr_geo_level == 'UF'",
          selectizeInput("enr_geo", "UF(s)", choices = UF_CHOICES,
                         multiple = TRUE, selected = c("SP","BA","AM","RS"),
                         options = list(plugins = list("remove_button")))
        ),
        selectizeInput("enr_level", "Nível", choices = ENR_LEVEL_CHOICES,
                       multiple = TRUE, selected = "fundamental",
                       options = list(plugins = list("remove_button"))),
        radioButtons("enr_indicator", "Indicador", ENR_IND_CHOICES,
                     selected = "rate", inline = TRUE),
        radioButtons("enr_dimension", "Recorte", ENR_DIM_CHOICES,
                     selected = "none"),
        sliderInput("enr_year", "Anos",
                    min = 1871, max = 2010, value = c(1933, 2010),
                    sep = "", step = 1),
        hr(),
        downloadButton("enr_download", "Baixar CSV", class = "btn-primary w-100")
      ),
      bslib::navset_card_tab(
        bslib::nav_panel(
          "Série",
          plotly::plotlyOutput("enr_plot", height = "520px"),
          tags$small(textOutput("enr_caption"))
        ),
        bslib::nav_panel(
          "Tabela",
          DT::DTOutput("enr_table")
        ),
        bslib::nav_panel(
          "Fontes",
          uiOutput("enr_sources")
        )
      )
    )
  ),

  # ---- Ensino Superior (multi-fonte) ----
  bslib::nav_panel(
    title = "Ensino Superior",
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        width = 360,
        sliderInput("ter_year", "Anos",
                    min = 1907, max = 2024, value = c(1933, 2024),
                    sep = "", step = 1),
        selectizeInput("ter_network", "Rede(s)",
                       choices = TER_NETWORK_CHOICES, multiple = TRUE,
                       selected = "total",
                       options = list(plugins = list("remove_button"))),
        selectizeInput("ter_inst", "Tipo institucional",
                       choices = TER_INST_CHOICES, multiple = TRUE,
                       selected = "total",
                       options = list(plugins = list("remove_button"))),
        selectizeInput("ter_modality", "Modalidade",
                       choices = TER_MOD_CHOICES, multiple = TRUE,
                       selected = "total",
                       options = list(plugins = list("remove_button"))),
        selectizeInput("ter_source", "Fonte(s) — selecione para comparar",
                       choices = TER_SOURCE_CHOICES, multiple = TRUE,
                       selected = c("kang_paese_felix_2021",
                                    "durham_2005",
                                    "maduro_junior_2007",
                                    "inep_microdados_censup",
                                    "ibge_seculo_xx"),
                       options = list(plugins = list("remove_button"))),
        radioButtons("ter_color_by", "Colorir linhas por",
                     choices = TER_COLOR_BY_CHOICES,
                     selected = "source", inline = FALSE),
        checkboxInput("ter_derived", "Incluir linhas derivadas (Presencial+EAD)",
                      value = FALSE),
        hr(),
        downloadButton("ter_download", "Baixar CSV", class = "btn-primary w-100")
      ),
      bslib::navset_card_tab(
        bslib::nav_panel(
          "Série",
          plotly::plotlyOutput("ter_plot", height = "520px"),
          tags$small(textOutput("ter_caption"))
        ),
        bslib::nav_panel(
          "Tabela",
          DT::DTOutput("ter_table")
        ),
        bslib::nav_panel(
          "Fontes",
          uiOutput("ter_sources")
        )
      )
    )
  ),

  # ---- Escolaridade ----
  bslib::nav_panel(
    title = "Escolaridade",
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        width = 320,
        radioButtons("sch_geo_level", "Granularidade",
                     choices = c("Brasil" = "BR",
                                 "Macrorregiões" = "region",
                                 "Estados (UF)" = "UF"),
                     selected = "BR", inline = FALSE),
        conditionalPanel(
          condition = "input.sch_geo_level == 'UF'",
          selectizeInput("sch_geo_uf", "UF(s)", choices = UF_CHOICES,
                         multiple = TRUE, selected = c("SP","BA","AM","RS"),
                         options = list(plugins = list("remove_button")))
        ),
        conditionalPanel(
          condition = "input.sch_geo_level == 'region'",
          selectizeInput("sch_geo_reg", "Região(ões)", choices = REGION_CHOICES,
                         multiple = TRUE,
                         selected = c("N","NE","SE","S"),
                         options = list(plugins = list("remove_button")))
        ),
        radioButtons("sch_dimension", "Recorte", SCH_DIM_CHOICES,
                     selected = "none"),
        sliderInput("sch_year", "Anos",
                    min = 1925, max = 2015, value = c(1950, 2015),
                    sep = "", step = 1),
        hr(),
        downloadButton("sch_download", "Baixar CSV", class = "btn-primary w-100")
      ),
      bslib::navset_card_tab(
        bslib::nav_panel(
          "Série",
          plotly::plotlyOutput("sch_plot", height = "520px"),
          tags$small(textOutput("sch_caption"))
        ),
        bslib::nav_panel(
          "Tabela",
          DT::DTOutput("sch_table")
        ),
        bslib::nav_panel(
          "Fontes",
          uiOutput("sch_sources")
        )
      )
    )
  ),

  bslib::nav_spacer(),
  bslib::nav_panel(
    title = "Sobre",
    tags$div(
      class = "container py-4",
      tags$h4(tags$strong("educabr")),
      tags$p("Séries históricas tratadas de educação brasileira.",
             " Dados compilados de fontes oficiais e acadêmicas em",
             " um schema tidy canônico com proveniência explícita."),
      tags$p("Temas disponíveis neste painel:"),
      tags$ul(
        tags$li(tags$strong("Matrículas"), " — taxas e contagens por nível, raça e UF (1871–2010, Kang/FGV-IBRE)."),
        tags$li(tags$strong("Ensino Superior"), " — matrículas no ensino superior 1907–2024, compilação multi-fonte (IBGE Século XX, Durham, Maduro Junior, Kang, INEP Sinopse, INEP Microdados, INEP Power BI). Permite comparação direta entre fontes para o mesmo período."),
        tags$li(tags$strong("Escolaridade"), " — anos médios de estudo por sexo, raça e UF (1925–2015, Walter & Kang).")
      ),
      tags$p("Dados acessíveis via R: ",
             tags$code("educabr::get_enrollment()"), " e ",
             tags$code("educabr::get_schooling()"), "."),
      tags$p(tags$a(href = "https://github.com/mancano-tales/educabr",
                    "Repositório no GitHub", target = "_blank"))
    )
  )
)

# ---- server ----------------------------------------------------------

server <- function(input, output, session) {

  sources_path <- system.file("dict/vocabularies/sources.yaml", package = "educabr")

  # -- enrollment reactives --------------------------------------------

  enr_data <- reactive({
    educabr::get_enrollment(
      level     = input$enr_level,
      year      = input$enr_year,
      geo_level = input$enr_geo_level,
      geo       = if (input$enr_geo_level == "UF") input$enr_geo else NULL,
      dimension = input$enr_dimension,
      indicator = input$enr_indicator,
      wide      = FALSE,
      lang      = "pt"
    )
  })

  output$enr_plot <- plotly::renderPlotly({
    d <- enr_data()
    validate(need(nrow(d) > 0, "Sem dados para os filtros selecionados."))

    color_var <- if (input$enr_dimension == "race") "dim_race" else "level"

    d$hover_text <- paste0(
      "<b>Ano:</b> ", d$year, "<br>",
      "<b>", d[[color_var]], "</b><br>",
      if (input$enr_indicator == "rate")
        paste0("<b>Taxa:</b> ", sprintf("%.1f%%", d$value))
      else
        paste0("<b>Matrículas:</b> ", format(round(d$value), big.mark = ".", scientific = FALSE))
    )

    g <- ggplot2::ggplot(
      d,
      ggplot2::aes(x = year, y = value,
                   colour = .data[[color_var]],
                   group  = interaction(.data[[color_var]], geo_code),
                   text   = hover_text)
    ) +
      ggplot2::geom_line(linewidth = 0.9, alpha = 0.9) +
      ggplot2::geom_point(size = 0.6, alpha = 0.6) +
      ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(10)) +
      ggplot2::theme_minimal(base_size = 13) +
      ggplot2::theme(legend.position = "bottom",
                     legend.title    = ggplot2::element_blank(),
                     panel.grid.minor = ggplot2::element_blank()) +
      ggplot2::labs(
        x = NULL,
        y = if (input$enr_indicator == "rate") "Taxa bruta (%)" else "Matrículas",
        title = paste0(
          if (input$enr_indicator == "rate") "Taxa de matrícula" else "Matrículas",
          " — ", if (input$enr_geo_level == "BR") "Brasil" else "Estados"
        )
      )

    if (input$enr_indicator == "rate") {
      g <- g + ggplot2::scale_y_continuous(
        labels = function(x) paste0(round(x, 1), "%"))
    } else {
      g <- g + ggplot2::scale_y_continuous(
        labels = scales::label_number(big.mark = "."))
    }

    if (input$enr_geo_level == "UF" && length(unique(d$geo_code)) > 1)
      g <- g + ggplot2::facet_wrap(~ geo_name, scales = "free_y")

    plotly::ggplotly(g, tooltip = "text") |>
      plotly::layout(legend = list(orientation = "h", y = -0.15))
  })

  output$enr_caption <- renderText({
    d <- enr_data()
    if (!nrow(d)) return("")
    sprintf("Fonte(s): %s. %d observações.",
            paste(sort(unique(d$source)), collapse = ", "), nrow(d))
  })

  output$enr_table <- DT::renderDT({
    DT::datatable(enr_data(), rownames = FALSE, filter = "top",
                  options = list(pageLength = 25, scrollX = TRUE))
  })

  output$enr_sources <- renderUI({
    sources_card_ui(unique(enr_data()$source), sources_path)
  })

  output$enr_download <- downloadHandler(
    filename = function()
      sprintf("educabr_enrollment_%s.csv", format(Sys.time(), "%Y%m%d_%H%M")),
    content = function(file)
      utils::write.csv(enr_data(), file, row.names = FALSE, fileEncoding = "UTF-8")
  )

  # -- ensino superior reactives ---------------------------------------

  ter_data <- reactive({
    educabr::get_enrollment(
      level            = "superior",
      network          = input$ter_network,
      institution_type = input$ter_inst,
      modality         = input$ter_modality,
      year             = input$ter_year,
      source           = input$ter_source,
      include_derived  = isTRUE(input$ter_derived),
      lang             = "en"   # keep raw keys; we re-label for display
    )
  })

  # PT-BR labels for legend display (without translating the underlying data).
  ter_label <- function(col, vals) {
    map <- switch(col,
      source           = setNames(names(TER_SOURCE_CHOICES),  unname(TER_SOURCE_CHOICES)),
      network          = setNames(names(TER_NETWORK_CHOICES), unname(TER_NETWORK_CHOICES)),
      institution_type = setNames(names(TER_INST_CHOICES),    unname(TER_INST_CHOICES)),
      modality         = setNames(names(TER_MOD_CHOICES),     unname(TER_MOD_CHOICES))
    )
    out <- map[as.character(vals)]
    ifelse(is.na(out), as.character(vals), unname(out))
  }

  output$ter_plot <- plotly::renderPlotly({
    d <- ter_data()
    validate(need(nrow(d) > 0, "Sem dados para os filtros selecionados."))

    color_var <- input$ter_color_by

    d$source_lab  <- ter_label("source",           d$source)
    d$network_lab <- ter_label("network",          d$network)
    d$inst_lab    <- ter_label("institution_type", d$institution_type)
    d$mod_lab     <- ter_label("modality",         d$modality)

    color_col_map <- c(source = "source_lab", network = "network_lab",
                       institution_type = "inst_lab", modality = "mod_lab")
    color_col <- color_col_map[[color_var]]

    d$hover_text <- paste0(
      "<b>Ano:</b> ", d$year, "<br>",
      "<b>Fonte:</b> ", d$source_lab, "<br>",
      "<b>Rede:</b> ", d$network_lab, "<br>",
      "<b>Tipo:</b> ", d$inst_lab, "<br>",
      "<b>Modalidade:</b> ", d$mod_lab, "<br>",
      "<b>Matrículas:</b> ",
      format(round(d$value), big.mark = ".", scientific = FALSE),
      if (any(d$is_derived))
        ifelse(d$is_derived, " <i>(derivada)</i>", "") else ""
    )

    g <- ggplot2::ggplot(
      d,
      ggplot2::aes(x = year, y = value,
                   colour = .data[[color_col]],
                   group  = interaction(source, network, institution_type, modality),
                   text   = hover_text)
    ) +
      ggplot2::geom_line(linewidth = 0.7, alpha = 0.85) +
      ggplot2::geom_point(size = 1.0, alpha = 0.7) +
      ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(12)) +
      ggplot2::scale_y_continuous(labels = scales::label_number(big.mark = ".")) +
      ggplot2::theme_minimal(base_size = 13) +
      ggplot2::theme(legend.position = "bottom",
                     legend.title    = ggplot2::element_blank(),
                     panel.grid.minor = ggplot2::element_blank()) +
      ggplot2::labs(
        x = NULL, y = "Matrículas",
        title = "Ensino Superior — comparação multi-fonte"
      )

    plotly::ggplotly(g, tooltip = "text") |>
      plotly::layout(legend = list(orientation = "h", y = -0.15))
  })

  output$ter_caption <- renderText({
    d <- ter_data()
    if (!nrow(d)) return("")
    sprintf("%d observações de %d fonte(s) distintas.",
            nrow(d), length(unique(d$source)))
  })

  output$ter_table <- DT::renderDT({
    DT::datatable(
      ter_data() |>
        dplyr::select(year, source, network, institution_type, modality,
                      value, is_derived, source_note),
      rownames = FALSE, filter = "top",
      options = list(pageLength = 25, scrollX = TRUE)
    )
  })

  output$ter_sources <- renderUI({
    # Strip the "+" composite source values so the cards only show the
    # canonical primary sources (derived rows then receive both component
    # cards via the underlying source keys).
    raw_sources <- unique(ter_data()$source)
    expanded    <- unique(unlist(strsplit(raw_sources, "+", fixed = TRUE)))
    sources_card_ui(expanded, sources_path)
  })

  output$ter_download <- downloadHandler(
    filename = function()
      sprintf("educabr_tertiary_%s.csv", format(Sys.time(), "%Y%m%d_%H%M")),
    content = function(file)
      utils::write.csv(ter_data(), file, row.names = FALSE, fileEncoding = "UTF-8")
  )

  # -- schooling reactives ---------------------------------------------

  sch_geo <- reactive({
    switch(input$sch_geo_level,
           UF     = input$sch_geo_uf,
           region = input$sch_geo_reg,
           NULL)
  })

  sch_data <- reactive({
    educabr::get_schooling(
      year      = input$sch_year,
      geo_level = input$sch_geo_level,
      geo       = sch_geo(),
      dimension = input$sch_dimension,
      lang      = "pt"
    )
  })

  output$sch_plot <- plotly::renderPlotly({
    d <- sch_data()
    validate(need(nrow(d) > 0, "Sem dados para os filtros selecionados."))

    color_var <- switch(input$sch_dimension,
                        race = "dim_race",
                        sex  = "dim_sex",
                        "geo_name")

    d$hover_text <- paste0(
      "<b>Ano:</b> ", d$year, "<br>",
      "<b>", d[[color_var]], "</b><br>",
      "<b>Anos médios:</b> ", sprintf("%.2f", d$value)
    )

    g <- ggplot2::ggplot(
      d,
      ggplot2::aes(x = year, y = value,
                   colour = .data[[color_var]],
                   group  = interaction(.data[[color_var]], geo_code),
                   text   = hover_text)
    ) +
      ggplot2::geom_line(linewidth = 0.9, alpha = 0.9) +
      ggplot2::geom_point(size = 0.6, alpha = 0.6) +
      ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(10)) +
      ggplot2::theme_minimal(base_size = 13) +
      ggplot2::theme(legend.position = "bottom",
                     legend.title    = ggplot2::element_blank(),
                     panel.grid.minor = ggplot2::element_blank()) +
      ggplot2::labs(
        x = NULL, y = "Anos médios de estudo",
        title = paste0(
          "Escolaridade média — ",
          switch(input$sch_geo_level,
                 BR     = "Brasil",
                 region = "Macrorregiões",
                 UF     = "Estados")
        )
      )

    if (input$sch_geo_level == "UF" && length(unique(d$geo_code)) > 1)
      g <- g + ggplot2::facet_wrap(~ geo_name, scales = "free_y")

    plotly::ggplotly(g, tooltip = "text") |>
      plotly::layout(legend = list(orientation = "h", y = -0.15))
  })

  output$sch_caption <- renderText({
    d <- sch_data()
    if (!nrow(d)) return("")
    sprintf("Fonte(s): %s. %d observações.",
            paste(sort(unique(d$source)), collapse = ", "), nrow(d))
  })

  output$sch_table <- DT::renderDT({
    DT::datatable(sch_data(), rownames = FALSE, filter = "top",
                  options = list(pageLength = 25, scrollX = TRUE))
  })

  output$sch_sources <- renderUI({
    sources_card_ui(unique(sch_data()$source), sources_path)
  })

  output$sch_download <- downloadHandler(
    filename = function()
      sprintf("educabr_schooling_%s.csv", format(Sys.time(), "%Y%m%d_%H%M")),
    content = function(file)
      utils::write.csv(sch_data(), file, row.names = FALSE, fileEncoding = "UTF-8")
  )
}

shinyApp(ui, server)
