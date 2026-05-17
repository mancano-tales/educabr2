# educabr dashboard — minimal v0
#
# Consumes the public API of the educabr package (`get_enrollment()`),
# so any change to the data flows through automatically.
#
# UI strings are currently in PT-BR; a full bilingual pass via
# `inst/dict/i18n.yaml` is planned for M5b.

library(shiny)
library(bslib)
library(ggplot2)

stopifnot(requireNamespace("educabr", quietly = TRUE))

# --- choices ----------------------------------------------------------

LEVEL_CHOICES <- c(
  "Fundamental (total)"        = "fundamental",
  "Fundamental — anos iniciais"= "fundamental_anos_iniciais",
  "Fundamental — anos finais"  = "fundamental_anos_finais",
  "Médio"                      = "medio",
  "Superior"                   = "superior"
)

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

INDICATOR_CHOICES <- c("Taxa bruta (%)" = "rate", "Matrículas (n)" = "count")
DIM_CHOICES       <- c("Total (sem recorte)" = "none", "Por raça/cor" = "race")

# --- UI ---------------------------------------------------------------

ui <- bslib::page_sidebar(
  title = "educabr — Matrículas no Brasil",
  theme = bslib::bs_theme(version = 5),
  sidebar = bslib::sidebar(
    width = 320,
    radioButtons(
      "geo_level", "Granularidade",
      choices = c("Brasil" = "BR", "Estados (UF)" = "UF"),
      selected = "BR", inline = TRUE
    ),
    conditionalPanel(
      condition = "input.geo_level == 'UF'",
      selectizeInput(
        "geo", "UF(s)",
        choices = UF_CHOICES, multiple = TRUE,
        selected = c("SP", "BA", "AM", "RS"),
        options = list(plugins = list("remove_button"))
      )
    ),
    selectizeInput(
      "level", "Nível",
      choices = LEVEL_CHOICES, multiple = TRUE,
      selected = "fundamental",
      options = list(plugins = list("remove_button"))
    ),
    radioButtons("indicator", "Indicador", INDICATOR_CHOICES,
                 selected = "rate", inline = TRUE),
    radioButtons("dimension", "Recorte", DIM_CHOICES,
                 selected = "none", inline = FALSE),
    sliderInput("year", "Anos",
                min = 1871, max = 2010, value = c(1933, 2010),
                sep = "", step = 1),
    hr(),
    downloadButton("download_csv", "Baixar CSV", class = "btn-primary w-100")
  ),
  bslib::navset_card_tab(
    bslib::nav_panel(
      title = "Série",
      icon = bslib::bs_icon("graph-up"),
      plotOutput("series_plot", height = "520px"),
      tags$small(textOutput("series_caption"))
    ),
    bslib::nav_panel(
      title = "Tabela",
      icon = bslib::bs_icon("table"),
      DT::DTOutput("series_table")
    ),
    bslib::nav_panel(
      title = "Fontes",
      icon = bslib::bs_icon("book"),
      uiOutput("sources_ui")
    ),
    bslib::nav_panel(
      title = "Sobre",
      icon = bslib::bs_icon("info-circle"),
      tags$div(
        tags$p(tags$strong("educabr"), " — séries históricas tratadas de educação brasileira."),
        tags$p("Os dados consumidos por este painel vêm da função ",
               tags$code("educabr::get_enrollment()"), ". ",
               "Qualquer melhoria nos dados aparece automaticamente aqui."),
        tags$p("Em desenvolvimento ativo (v0). Veja o ",
               tags$a(href = "https://github.com/mancano-tales/educabr", "repositório", target = "_blank"),
               " para o roadmap.")
      )
    )
  )
)

# --- server -----------------------------------------------------------

server <- function(input, output, session) {

  data_filtered <- reactive({
    educabr::get_enrollment(
      level     = input$level,
      year      = input$year,
      geo_level = input$geo_level,
      geo       = if (input$geo_level == "UF") input$geo else NULL,
      dimension = input$dimension,
      indicator = input$indicator,
      wide      = FALSE,
      lang      = "pt"
    )
  })

  output$series_plot <- renderPlot({
    d <- data_filtered()
    validate(need(nrow(d) > 0, "Sem dados para os filtros selecionados."))

    # Color: by race when breaking down by race; otherwise by level
    color_var <- if (input$dimension == "race") "dim_race" else "level"

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
      ggplot2::theme(
        legend.position = "bottom",
        legend.title    = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank()
      ) +
      ggplot2::labs(
        x = NULL,
        y = if (input$indicator == "rate") "Taxa bruta (%)" else "Matrículas",
        title = paste0(
          if (input$indicator == "rate") "Taxa de matrícula" else "Matrículas",
          " — ", if (input$geo_level == "BR") "Brasil" else "Estados"
        )
      )

    if (input$indicator == "rate") {
      g <- g + ggplot2::scale_y_continuous(
        labels = function(x) paste0(round(x, 1), "%")
      )
    } else {
      g <- g + ggplot2::scale_y_continuous(labels = scales::label_number(big.mark = "."))
    }

    if (input$geo_level == "UF" && length(unique(d$geo_code)) > 1) {
      g <- g + ggplot2::facet_wrap(~ geo_name, scales = "free_y")
    }

    g
  })

  output$series_caption <- renderText({
    d <- data_filtered()
    if (!nrow(d)) return("")
    sprintf("Fonte(s): %s. %d observações.",
            paste(sort(unique(d$source)), collapse = ", "),
            nrow(d))
  })

  output$series_table <- DT::renderDT({
    DT::datatable(
      data_filtered(),
      rownames = FALSE,
      filter = "top",
      options = list(pageLength = 25, scrollX = TRUE)
    )
  })

  output$sources_ui <- renderUI({
    path <- system.file("dict/vocabularies/sources.yaml", package = "educabr")
    if (!nzchar(path)) return(tags$p("Catálogo de fontes indisponível."))
    sources <- yaml::read_yaml(path)$sources

    used <- unique(data_filtered()$source)
    if (length(used) == 0) used <- names(sources)

    cards <- lapply(used, function(key) {
      meta <- sources[[key]]
      if (is.null(meta)) return(NULL)
      bslib::card(
        bslib::card_header(meta$short_name %||% key),
        bslib::card_body(
          tags$p(meta$full_name %||% ""),
          if (!is.null(meta$url)) tags$a(href = meta$url, "Link da fonte", target = "_blank"),
          if (!is.null(meta$coverage)) tags$p(
            tags$strong("Cobertura: "),
            sprintf("%s–%s, %s",
                    meta$coverage$years[[1]] %||% "?",
                    meta$coverage$years[[2]] %||% "atual",
                    paste(meta$coverage$geo, collapse = ", "))
          )
        )
      )
    })
    do.call(tagList, cards)
  })

  output$download_csv <- downloadHandler(
    filename = function() {
      sprintf("educabr_enrollment_%s.csv", format(Sys.time(), "%Y%m%d_%H%M"))
    },
    content = function(file) {
      utils::write.csv(data_filtered(), file, row.names = FALSE, fileEncoding = "UTF-8")
    }
  )
}

# Small null-coalescer (avoids importing rlang into the dashboard).
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

shinyApp(ui, server)
