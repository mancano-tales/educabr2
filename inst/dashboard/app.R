# educabr dashboard — v0.2
#
# Two-theme navbar: Matrículas (enrollment) + Escolaridade (schooling).
# Each theme has its own sidebar, plot, table, and sources tab.
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
          plotOutput("enr_plot", height = "520px"),
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
          plotOutput("sch_plot", height = "520px"),
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
        tags$li(tags$strong("Matrículas"), " — taxas e contagens por nível, raça e UF (1871–2010)."),
        tags$li(tags$strong("Escolaridade"), " — anos médios de estudo por sexo, raça e UF (1925–2015).")
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

  output$enr_plot <- renderPlot({
    d <- enr_data()
    validate(need(nrow(d) > 0, "Sem dados para os filtros selecionados."))

    color_var <- if (input$enr_dimension == "race") "dim_race" else "level"

    g <- ggplot2::ggplot(
      d,
      ggplot2::aes(x = year, y = value,
                   colour = .data[[color_var]],
                   group  = interaction(.data[[color_var]], geo_code))
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

    g
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

  output$sch_plot <- renderPlot({
    d <- sch_data()
    validate(need(nrow(d) > 0, "Sem dados para os filtros selecionados."))

    color_var <- switch(input$sch_dimension,
                        race = "dim_race",
                        sex  = "dim_sex",
                        "geo_name")

    g <- ggplot2::ggplot(
      d,
      ggplot2::aes(x = year, y = value,
                   colour = .data[[color_var]],
                   group  = interaction(.data[[color_var]], geo_code))
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

    g
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
