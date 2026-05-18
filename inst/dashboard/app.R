# educabr dashboard — v0.4
#
# Three-theme navbar (UI in English):
#   * Enrollment (Kang fundamental/medio/superior, simple)
#   * Tertiary Education (multi-source comparison, 1907-2024)
#   * Educational Attainment (Walter & Kang mean years of schooling)
# Consumes only the public API: get_enrollment() and get_schooling().
#
# INSTALLATION
#   educabr is not on CRAN. Install from GitHub before running locally:
#     remotes::install_github("mancano-tales/educabr")
#   global.R handles this automatically on shinyapps.io and fresh clones.

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

# ---- enrollment choices ----------------------------------------------

ENR_LEVEL_CHOICES <- c(
  "Fundamental (total)"             = "fundamental",
  "Fundamental — primary grades"    = "fundamental_anos_iniciais",
  "Fundamental — lower secondary"   = "fundamental_anos_finais",
  "Upper secondary (médio)"         = "medio",
  "Tertiary (superior)"             = "superior"
)
ENR_IND_CHOICES <- c("Gross rate (%)" = "rate", "Enrollment (n)" = "count")
ENR_DIM_CHOICES <- c("Total (no breakdown)" = "none", "By race/colour" = "race")

# ---- tertiary education (multi-source) choices -----------------------

TER_NETWORK_CHOICES <- c(
  "Total (all)"                                    = "total",
  "Public (aggregate)"                             = "publica",
  "Public — Federal"                               = "federal",
  "Public — State"                                 = "estadual",
  "Public — Municipal"                             = "municipal",
  "Private (aggregate)"                            = "privada",
  "Private — Particular"                           = "privada_particular",
  "Private — Community/Confessional/Philanthropic" = "privada_comunitaria_confessional_filantropica",
  "Private — For-profit"                           = "privada_lucrativa",
  "Private — Non-profit"                           = "privada_nao_lucrativa",
  "Especial"                                       = "especial"
)

TER_INST_CHOICES <- c(
  "Total (no breakdown)"               = "total",
  "University"                         = "university",
  "University Center"                  = "university_center",
  "Faculty"                            = "faculty",
  "Faculty/School/Institute"           = "faculty_school_institute",
  "Integrated Faculty"                 = "integrated_faculty",
  "Integrated Faculty/Univ. Center"    = "integrated_faculty_university_center",
  "Technology Center"                  = "technology_center",
  "Technology Center / Tech. Faculty"  = "technology_center_fat",
  "CEFET/IFET"                         = "cefet_ifet",
  "Isolated Establishment"             = "isolated_establishment"
)

TER_MOD_CHOICES <- c(
  "Total (no breakdown)" = "total",
  "In-person"            = "presencial",
  "Distance (EAD)"       = "ead"
)

TER_SOURCE_CHOICES <- c(
  "Kang, Paese & Felix (2021)"          = "kang_paese_felix_2021",
  "Kang & Menetrier (2024)"             = "kang_menetrier_2024",
  "Kang, Menetrier & Comim (2024)"      = "kang_menetrier_comim_2024",
  "Durham (2005)"                       = "durham_2005",
  "Maduro Junior (2007)"                = "maduro_junior_2007",
  "IBGE Statistics of the 20th Century" = "ibge_seculo_xx",
  "INEP CENSUP Synopsis (1995-2008)"    = "inep_sinopse_censup",
  "INEP CENSUP Microdata (2009-2024)"   = "inep_microdados_censup",
  "INEP CENSUP Power BI (2010-2024)"    = "inep_censup_powerbi"
)

TER_COLOR_BY_CHOICES <- c(
  "Source"            = "source",
  "Network"           = "network",
  "Institution type"  = "institution_type",
  "Modality"          = "modality"
)

# Each source gets a distinct ggplot2 plotting symbol for redundant
# (color + shape) encoding — inspired by Mançano (2026) thesis plots.
TER_SOURCE_SHAPES <- c(
  "kang_paese_felix_2021"     = 17,  # solid up-triangle
  "kang_menetrier_2024"       = 2,   # open up-triangle
  "kang_menetrier_comim_2024" = 25,  # solid down-triangle
  "durham_2005"               = 18,  # solid diamond
  "maduro_junior_2007"        = 5,   # open diamond
  "ibge_seculo_xx"            = 15,  # solid square
  "inep_sinopse_censup"       = 22,  # crossed square
  "inep_microdados_censup"    = 16,  # solid circle
  "inep_censup_powerbi"       = 1    # open circle
)

# Modality drives the line dash pattern (solid for in-person & total,
# dashed for EAD), again echoing the convention in the reference plots.
TER_MODALITY_LINETYPES <- c(
  "total"      = "solid",
  "presencial" = "solid",
  "ead"        = "dashed"
)

# Hand-picked categorical palettes per dimension — high contrast,
# colour-blind-friendly, inspired by ColorBrewer Set1 and the
# semantic conventions in the Mançano (2026) reference plots
# (public ~ blue family; private ~ warm / red family; etc.).

TER_SOURCE_COLORS <- c(
  "kang_paese_felix_2021"     = "#e41a1c",  # red
  "kang_menetrier_2024"       = "#984ea3",  # purple
  "kang_menetrier_comim_2024" = "#f781bf",  # pink
  "durham_2005"               = "#377eb8",  # blue
  "maduro_junior_2007"        = "#4daf4a",  # green
  "ibge_seculo_xx"            = "#a65628",  # brown
  "inep_sinopse_censup"       = "#ff7f00",  # orange
  "inep_microdados_censup"    = "#000000",  # black
  "inep_censup_powerbi"       = "#999999"   # gray
)

TER_NETWORK_COLORS <- c(
  "total"                                         = "#1f2937",  # near-black
  "publica"                                       = "#1d4ed8",  # blue 700
  "federal"                                       = "#1e3a8a",  # blue 900
  "estadual"                                      = "#2563eb",  # blue 600
  "municipal"                                     = "#93c5fd",  # blue 300
  "privada"                                       = "#991b1b",  # red 800
  "privada_particular"                            = "#dc2626",  # red 600
  "privada_comunitaria_confessional_filantropica" = "#be185d",  # pink 700
  "privada_lucrativa"                             = "#ea580c",  # orange 600
  "privada_nao_lucrativa"                         = "#7e22ce",  # purple 700
  "especial"                                      = "#6b7280"   # gray
)

TER_INST_COLORS <- c(
  "total"                                = "#1f2937",
  "university"                           = "#1d4ed8",
  "university_center"                    = "#2563eb",
  "faculty"                              = "#16a34a",
  "faculty_school_institute"             = "#15803d",
  "integrated_faculty"                   = "#ca8a04",
  "integrated_faculty_university_center" = "#a16207",
  "technology_center"                    = "#dc2626",
  "technology_center_fat"                = "#991b1b",
  "cefet_ifet"                           = "#7e22ce",
  "isolated_establishment"               = "#525252"
)

TER_MODALITY_COLORS <- c(
  "total"      = "#1f2937",  # near-black
  "presencial" = "#1d4ed8",  # blue
  "ead"        = "#ea580c"   # orange
)

# --- helpers for the interaction-based palette --------------------------
#
# Each line is coloured by the interaction (chosen_dim × modality):
#   - total      → darker  shade of the base hue
#   - presencial → the base hue itself
#   - ead        → lighter shade of the base hue
# This reproduces the Mançano (2026) reference-plot convention where
# the COLOUR FAMILY identifies the main dimension and the SHADE
# identifies the modality, so every line has a unique colour.

.hex_shade <- function(hex, amount) {
  # amount > 0 → lighten (blend with white); < 0 → darken (blend with black)
  rgb_vals <- grDevices::col2rgb(hex)[, 1] / 255
  if (amount > 0) {
    rgb_vals <- rgb_vals + (1 - rgb_vals) * amount
  } else {
    rgb_vals <- rgb_vals * (1 + amount)
  }
  rgb_vals <- pmin(pmax(rgb_vals, 0), 1)
  grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3])
}

build_interaction_palette <- function(base_palette,
                                      shade_total = -0.35,
                                      shade_ead   = +0.50) {
  out <- character()
  for (key in names(base_palette)) {
    base <- base_palette[[key]]
    out[paste(key, "total",      sep = "·")] <- .hex_shade(base, shade_total)
    out[paste(key, "presencial", sep = "·")] <- base
    out[paste(key, "ead",        sep = "·")] <- .hex_shade(base, shade_ead)
  }
  out
}

# ---- educational attainment choices ----------------------------------

SCH_DIM_CHOICES <- c(
  "Total (no breakdown)" = "none",
  "By race/colour"       = "race",
  "By sex"               = "sex"
)

# ---- code-generation helpers -----------------------------------------
#
# Each tab gets a "View R code" button that opens a modal showing the
# exact `educabr::get_*()` + ggplot2 call needed to reproduce the chart
# the user is currently looking at. This bridges interactive
# exploration with reproducible analysis — a key academic-transparency
# feature.

fmt_r_arg <- function(name, value) {
  if (is.null(value) || length(value) == 0L) return(NULL)
  if (is.logical(value)) {
    rep <- if (isTRUE(value)) "TRUE" else "FALSE"
  } else if (is.character(value)) {
    rep <- if (length(value) == 1L) sprintf('"%s"', value)
           else sprintf('c(%s)',
                        paste(sprintf('"%s"', value), collapse = ", "))
  } else if (is.numeric(value)) {
    rep <- if (length(value) == 1L) format(value, scientific = FALSE)
           else sprintf('c(%s)',
                        paste(format(value, scientific = FALSE), collapse = ", "))
  } else {
    rep <- as.character(value)
  }
  sprintf("  %s = %s", name, rep)
}

build_r_call <- function(fn_name, args_list) {
  parts <- Filter(Negate(is.null),
                  lapply(names(args_list),
                         function(n) fmt_r_arg(n, args_list[[n]])))
  if (length(parts) == 0L) return(paste0(fn_name, "()"))
  paste0(fn_name, "(\n",
         paste(parts, collapse = ",\n"),
         "\n)")
}

show_code_modal <- function(title, code_text) {
  showModal(modalDialog(
    title = title,
    tags$p(tags$small(
      style = "color: #555;",
      "Copy the snippet below into your R session to reproduce the chart locally. ",
      "The code uses only the public {educabr} API and ggplot2.")),
    tags$pre(
      style = paste(
        "background:#f6f8fa; padding:14px; border-radius:6px;",
        "max-height:60vh; overflow:auto; font-size:12px;",
        "white-space:pre; tab-size:2;"
      ),
      tags$code(class = "language-r", code_text)
    ),
    easyClose = TRUE,
    size      = "l",
    footer    = tagList(modalButton("Close"))
  ))
}

# ---- helper ----------------------------------------------------------

sources_card_ui <- function(source_keys, yaml_path) {
  if (!nzchar(yaml_path)) return(tags$p("Source catalogue unavailable."))
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
          tags$a(href = meta$url, "Source link", target = "_blank"),
        if (!is.null(meta$coverage))
          tags$p(tags$strong("Coverage: "),
                 sprintf("%s–%s, %s",
                         meta$coverage$years[[1]] %||% "?",
                         meta$coverage$years[[2]] %||% "present",
                         paste(meta$coverage$geo, collapse = ", ")))
      )
    )
  })
  do.call(tagList, cards)
}

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

# ---- UI --------------------------------------------------------------

ui <- bslib::page_navbar(
  title           = "educabr — Brazilian Education",
  theme           = bslib::bs_theme(version = 5),
  navbar_options  = bslib::navbar_options(bg = "#2d6a4f"),
  selected        = "Tertiary Education",  # opens here on first load

  # ---- Enrollment ----
  bslib::nav_panel(
    title = "Enrollment",
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        width = 320,
        radioButtons("enr_geo_level", "Geographic level",
                     choices = c("Brazil" = "BR", "States (UF)" = "UF"),
                     selected = "BR", inline = TRUE),
        conditionalPanel(
          condition = "input.enr_geo_level == 'UF'",
          selectizeInput("enr_geo", "State(s)", choices = UF_CHOICES,
                         multiple = TRUE, selected = c("SP","BA","AM","RS"),
                         options = list(plugins = list("remove_button")))
        ),
        selectizeInput("enr_level", "Level", choices = ENR_LEVEL_CHOICES,
                       multiple = TRUE, selected = "fundamental",
                       options = list(plugins = list("remove_button"))),
        radioButtons("enr_indicator", "Indicator", ENR_IND_CHOICES,
                     selected = "rate", inline = TRUE),
        radioButtons("enr_dimension", "Breakdown", ENR_DIM_CHOICES,
                     selected = "none"),
        sliderInput("enr_year", "Years",
                    min = 1871, max = 2010, value = c(1933, 2010),
                    sep = "", step = 1),
        hr(),
        downloadButton("enr_download", "Download CSV", class = "btn-primary w-100"),
        actionButton("enr_show_code", "View R code",
                     class = "btn-outline-secondary w-100 mt-2",
                     icon  = icon("code"))
      ),
      bslib::navset_card_tab(
        bslib::nav_panel(
          "Series",
          plotly::plotlyOutput("enr_plot", height = "520px"),
          tags$small(textOutput("enr_caption"))
        ),
        bslib::nav_panel(
          "Table",
          DT::DTOutput("enr_table")
        ),
        bslib::nav_panel(
          "Sources",
          uiOutput("enr_sources")
        )
      )
    )
  ),

  # ---- Tertiary Education (multi-source) ----
  bslib::nav_panel(
    title = "Tertiary Education",
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        width = 360,
        sliderInput("ter_year", "Years",
                    min = 1907, max = 2024, value = c(1933, 2024),
                    sep = "", step = 1),
        selectizeInput("ter_network", "Network(s)",
                       choices = TER_NETWORK_CHOICES, multiple = TRUE,
                       selected = c("total", "publica", "privada"),
                       options = list(plugins = list("remove_button"))),
        selectizeInput("ter_inst", "Institution type",
                       choices = TER_INST_CHOICES, multiple = TRUE,
                       selected = "total",
                       options = list(plugins = list("remove_button"))),
        selectizeInput("ter_modality", "Modality",
                       choices = TER_MOD_CHOICES, multiple = TRUE,
                       selected = c("total", "presencial", "ead"),
                       options = list(plugins = list("remove_button"))),
        selectizeInput("ter_source", "Source(s) — select to compare",
                       choices = TER_SOURCE_CHOICES, multiple = TRUE,
                       selected = c("kang_paese_felix_2021",
                                    "maduro_junior_2007",
                                    "ibge_seculo_xx",
                                    "inep_sinopse_censup",
                                    "inep_microdados_censup",
                                    "inep_censup_powerbi"),
                       options = list(plugins = list("remove_button"))),
        radioButtons("ter_color_by", "Colour lines by",
                     choices = TER_COLOR_BY_CHOICES,
                     selected = "network", inline = FALSE),
        checkboxInput("ter_derived",
                      "Include reconstructed totals (In-person + EAD, 2000-2008)",
                      value = TRUE),
        hr(),
        downloadButton("ter_download", "Download CSV", class = "btn-primary w-100"),
        actionButton("ter_show_code", "View R code",
                     class = "btn-outline-secondary w-100 mt-2",
                     icon  = icon("code"))
      ),
      bslib::navset_card_tab(
        bslib::nav_panel(
          "Series",
          plotly::plotlyOutput("ter_plot", height = "520px"),
          tags$small(textOutput("ter_caption"))
        ),
        bslib::nav_panel(
          "Table",
          DT::DTOutput("ter_table")
        ),
        bslib::nav_panel(
          "Sources",
          uiOutput("ter_sources")
        )
      )
    )
  ),

  # ---- Educational Attainment ----
  bslib::nav_panel(
    title = "Educational Attainment",
    bslib::layout_sidebar(
      sidebar = bslib::sidebar(
        width = 320,
        radioButtons("sch_geo_level", "Geographic level",
                     choices = c("Brazil"      = "BR",
                                 "Macroregion" = "region",
                                 "States (UF)" = "UF"),
                     selected = "BR", inline = FALSE),
        conditionalPanel(
          condition = "input.sch_geo_level == 'UF'",
          selectizeInput("sch_geo_uf", "State(s)", choices = UF_CHOICES,
                         multiple = TRUE, selected = c("SP","BA","AM","RS"),
                         options = list(plugins = list("remove_button")))
        ),
        conditionalPanel(
          condition = "input.sch_geo_level == 'region'",
          selectizeInput("sch_geo_reg", "Region(s)", choices = REGION_CHOICES,
                         multiple = TRUE,
                         selected = c("N","NE","SE","S"),
                         options = list(plugins = list("remove_button")))
        ),
        radioButtons("sch_dimension", "Breakdown", SCH_DIM_CHOICES,
                     selected = "none"),
        sliderInput("sch_year", "Years",
                    min = 1925, max = 2015, value = c(1950, 2015),
                    sep = "", step = 1),
        hr(),
        downloadButton("sch_download", "Download CSV", class = "btn-primary w-100"),
        actionButton("sch_show_code", "View R code",
                     class = "btn-outline-secondary w-100 mt-2",
                     icon  = icon("code"))
      ),
      bslib::navset_card_tab(
        bslib::nav_panel(
          "Series",
          plotly::plotlyOutput("sch_plot", height = "520px"),
          tags$small(textOutput("sch_caption"))
        ),
        bslib::nav_panel(
          "Table",
          DT::DTOutput("sch_table")
        ),
        bslib::nav_panel(
          "Sources",
          uiOutput("sch_sources")
        )
      )
    )
  ),

  bslib::nav_spacer(),
  bslib::nav_panel(
    title = "About",
    tags$div(
      class = "container py-4",
      tags$h4(tags$strong("educabr")),
      tags$p("Harmonised historical series on Brazilian education. Data",
             " curated from official and academic sources into a single",
             " tidy schema with explicit provenance."),
      tags$p("Themes available in this dashboard:"),
      tags$ul(
        tags$li(tags$strong("Enrollment"), " — enrollment counts and gross rates by level, race and state (1871–2010, Kang/FGV-IBRE)."),
        tags$li(tags$strong("Tertiary Education"), " — higher-education enrollment 1907–2024, multi-source compilation (IBGE 20th-Century Statistics, Durham, Maduro Junior, Kang et al., INEP Synopsis, INEP Microdata, INEP Power BI). Lets you compare estimates from different sources side by side."),
        tags$li(tags$strong("Educational Attainment"), " — mean years of schooling by sex, race and state (1925–2015, Walter & Kang).")
      ),
      tags$p("Data accessible from R: ",
             tags$code("educabr::get_enrollment()"), " and ",
             tags$code("educabr::get_schooling()"), "."),
      tags$p(tags$a(href = "https://github.com/mancano-tales/educabr",
                    "GitHub repository", target = "_blank"))
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
      lang      = "en"
    )
  })

  output$enr_plot <- plotly::renderPlotly({
    d <- enr_data()
    validate(need(nrow(d) > 0, "Sem dados para os filtros selecionados."))

    color_var <- if (input$enr_dimension == "race") "dim_race" else "level"

    d$hover_text <- paste0(
      "<b>Year:</b> ", d$year, "<br>",
      "<b>", d[[color_var]], "</b><br>",
      if (input$enr_indicator == "rate")
        paste0("<b>Rate:</b> ", sprintf("%.1f%%", d$value))
      else
        paste0("<b>Enrollment:</b> ", format(round(d$value), big.mark = ",", scientific = FALSE))
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
        y = if (input$enr_indicator == "rate") "Gross enrollment rate (%)" else "Enrollment",
        title = paste0(
          if (input$enr_indicator == "rate") "Enrollment rate" else "Enrollment",
          " — ", if (input$enr_geo_level == "BR") "Brazil" else "States"
        )
      )

    if (input$enr_indicator == "rate") {
      g <- g + ggplot2::scale_y_continuous(
        labels = function(x) paste0(round(x, 1), "%"))
    } else {
      g <- g + ggplot2::scale_y_continuous(
        labels = scales::label_number(big.mark = ","))
    }

    if (input$enr_geo_level == "UF" && length(unique(d$geo_code)) > 1)
      g <- g + ggplot2::facet_wrap(~ geo_name, scales = "free_y")

    plotly::ggplotly(g, tooltip = "text") |>
      plotly::layout(legend = list(orientation = "h", y = -0.15))
  })

  output$enr_caption <- renderText({
    d <- enr_data()
    if (!nrow(d)) return("")
    sprintf("Source(s): %s. %d observations.",
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
      indicator        = "count",   # tertiary panel is enrollment counts;
                                    # excludes Kang's enrollment_rate rows
                                    # that would otherwise plot as ~0 next
                                    # to count values in the millions.
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
    validate(need(nrow(d) > 0, "No data for the selected filters."))

    color_var <- input$ter_color_by

    d$source_lab  <- ter_label("source",           d$source)
    d$network_lab <- ter_label("network",          d$network)
    d$inst_lab    <- ter_label("institution_type", d$institution_type)
    d$mod_lab     <- ter_label("modality",         d$modality)

    d$hover_text <- paste0(
      "<b>Year:</b> ", d$year, "<br>",
      "<b>Source:</b> ", d$source_lab, "<br>",
      "<b>Network:</b> ", d$network_lab, "<br>",
      "<b>Type:</b> ", d$inst_lab, "<br>",
      "<b>Modality:</b> ", d$mod_lab, "<br>",
      "<b>Enrollment:</b> ",
      format(round(d$value), big.mark = ",", scientific = FALSE),
      if (any(d$is_derived))
        ifelse(d$is_derived, " <i>(derived)</i>", "") else ""
    )

    # Base palette + labels for the chosen "Colour lines by" dimension.
    base_pal <- switch(color_var,
      source           = list(col = "source",
                              values = TER_SOURCE_COLORS,
                              labels = setNames(names(TER_SOURCE_CHOICES),
                                                unname(TER_SOURCE_CHOICES))),
      network          = list(col = "network",
                              values = TER_NETWORK_COLORS,
                              labels = setNames(names(TER_NETWORK_CHOICES),
                                                unname(TER_NETWORK_CHOICES))),
      institution_type = list(col = "institution_type",
                              values = TER_INST_COLORS,
                              labels = setNames(names(TER_INST_CHOICES),
                                                unname(TER_INST_CHOICES))),
      modality         = list(col = "modality",
                              values = TER_MODALITY_COLORS,
                              labels = setNames(names(TER_MOD_CHOICES),
                                                unname(TER_MOD_CHOICES)))
    )

    modality_label_lookup <- setNames(names(TER_MOD_CHOICES),
                                      unname(TER_MOD_CHOICES))
    source_label_lookup   <- setNames(names(TER_SOURCE_CHOICES),
                                      unname(TER_SOURCE_CHOICES))

    # If the user is colouring by anything OTHER than modality, fold the
    # modality axis INTO the colour by interaction — each (dim × modality)
    # pair gets its own unique shade, so every line on the chart is
    # uniquely coloured.
    if (color_var != "modality") {
      raw_key           <- paste(d[[base_pal$col]], d$modality, sep = "·")
      color_values_raw  <- build_interaction_palette(base_pal$values)
      color_labels      <- character(length(color_values_raw))
      names(color_labels) <- names(color_values_raw)
      for (k in names(color_values_raw)) {
        parts <- strsplit(k, "·", fixed = TRUE)[[1]]
        dim_disp <- base_pal$labels[[parts[1]]] %||% parts[1]
        mod_disp <- modality_label_lookup[[parts[2]]] %||% parts[2]
        color_labels[k] <- paste(dim_disp, mod_disp, sep = " · ")
      }
      # Pre-translate so plotly uses readable strings as legend entries
      d$color_key  <- unname(color_labels[raw_key])
      color_values <- setNames(unname(color_values_raw), unname(color_labels))
      color_title  <- paste0(
        switch(color_var,
               source           = "Source",
               network          = "Network",
               institution_type = "Institution type"),
        " · Modality")
    } else {
      d$color_key  <- unname(base_pal$labels[d$modality])
      color_values <- setNames(unname(base_pal$values),
                               unname(base_pal$labels[names(base_pal$values)]))
      color_labels <- base_pal$labels
      color_title  <- "Modality"
    }

    g <- ggplot2::ggplot(
      d,
      ggplot2::aes(x = year, y = value,
                   colour   = color_key,
                   shape    = source,
                   linetype = modality,
                   group    = interaction(source, network, institution_type, modality),
                   text     = hover_text)
    ) +
      ggplot2::geom_line(linewidth = 1.0, alpha = 0.95) +
      ggplot2::geom_point(size = 2.6, alpha = 1.0) +
      ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(12)) +
      ggplot2::scale_y_continuous(labels = scales::label_number(big.mark = ",")) +
      ggplot2::scale_colour_manual(
        name   = color_title,
        values = color_values
      ) +
      ggplot2::scale_shape_manual(
        name   = "Source (shape)",
        values = TER_SOURCE_SHAPES,
        labels = source_label_lookup
      ) +
      ggplot2::scale_linetype_manual(
        name   = "Modality (line style)",
        values = TER_MODALITY_LINETYPES,
        labels = modality_label_lookup
      ) +
      ggplot2::theme_minimal(base_size = 13) +
      ggplot2::theme(legend.position = "right",
                     legend.text     = ggplot2::element_text(size = 10),
                     legend.title    = ggplot2::element_text(size = 11, face = "bold"),
                     panel.grid.minor = ggplot2::element_blank()) +
      ggplot2::labs(
        x = NULL, y = "Enrollment",
        title = "Tertiary Education — multi-source comparison"
      ) +
      ggplot2::guides(shape = "none", linetype = "none")

    plotly::ggplotly(g, tooltip = "text") |>
      plotly::layout(
        legend = list(orientation = "v",
                      x = 1.02, y = 1,
                      xanchor = "left", yanchor = "top",
                      bgcolor = "rgba(255,255,255,0.9)",
                      bordercolor = "#cccccc",
                      borderwidth = 1,
                      font = list(size = 10),
                      tracegroupgap = 4),
        margin = list(r = 240)
      )
  })

  output$ter_caption <- renderText({
    d <- ter_data()
    if (!nrow(d)) return("")
    sprintf("%d observations from %d distinct source(s).",
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
      lang      = "en"
    )
  })

  output$sch_plot <- plotly::renderPlotly({
    d <- sch_data()
    validate(need(nrow(d) > 0, "No data for the selected filters."))

    color_var <- switch(input$sch_dimension,
                        race = "dim_race",
                        sex  = "dim_sex",
                        "geo_name")

    d$hover_text <- paste0(
      "<b>Year:</b> ", d$year, "<br>",
      "<b>", d[[color_var]], "</b><br>",
      "<b>Mean years:</b> ", sprintf("%.2f", d$value)
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
        x = NULL, y = "Mean years of schooling",
        title = paste0(
          "Mean years of schooling — ",
          switch(input$sch_geo_level,
                 BR     = "Brazil",
                 region = "Macroregions",
                 UF     = "States")
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
    sprintf("Source(s): %s. %d observations.",
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

  # -- "View R code" buttons -------------------------------------------

  observeEvent(input$enr_show_code, {
    indicator_arg <- if (length(input$enr_indicator)) input$enr_indicator else NULL
    geo_arg       <- if (input$enr_geo_level == "UF") input$enr_geo else NULL
    color_var     <- if (input$enr_dimension == "race") "dim_race" else "level"

    get_call <- build_r_call("get_enrollment", list(
      level     = if (length(input$enr_level)) input$enr_level else NULL,
      year      = input$enr_year,
      geo_level = input$enr_geo_level,
      geo       = geo_arg,
      dimension = input$enr_dimension,
      indicator = indicator_arg,
      lang      = "en"
    ))

    y_lab <- if (input$enr_indicator == "rate") "Gross enrollment rate (%)" else "Enrollment"

    code <- paste0(
      "library(educabr)\n",
      "library(ggplot2)\n\n",
      "data <- ", get_call, "\n\n",
      "ggplot(data, aes(x = year, y = value,\n",
      "                 colour = ", color_var, ",\n",
      "                 group  = interaction(", color_var, ", geo_code))) +\n",
      "  geom_line(linewidth = 0.9, alpha = 0.9) +\n",
      "  geom_point(size = 0.6, alpha = 0.6) +\n",
      "  scale_x_continuous(breaks = scales::pretty_breaks(10)) +\n",
      "  theme_minimal(base_size = 13) +\n",
      "  labs(x = NULL, y = \"", y_lab, "\")"
    )

    show_code_modal("R code — Enrollment chart", code)
  })

  observeEvent(input$ter_show_code, {
    get_call <- build_r_call("get_enrollment", list(
      level            = "superior",
      year             = input$ter_year,
      network          = input$ter_network,
      institution_type = input$ter_inst,
      modality         = input$ter_modality,
      source           = input$ter_source,
      indicator        = "count",
      include_derived  = isTRUE(input$ter_derived),
      lang             = "en"
    ))

    color_var <- input$ter_color_by
    color_expr <- if (color_var == "modality") "modality"
                  else sprintf("interaction(%s, modality, sep = \" \\u00b7 \")", color_var)

    code <- paste0(
      "library(educabr)\n",
      "library(ggplot2)\n\n",
      "data <- ", get_call, "\n\n",
      "# colour = ", color_var, " (with modality shading); shape = source; linetype = modality\n",
      "ggplot(data, aes(x = year, y = value,\n",
      "                 colour   = ", color_expr, ",\n",
      "                 shape    = source,\n",
      "                 linetype = modality,\n",
      "                 group    = interaction(source, network, institution_type, modality))) +\n",
      "  geom_line(linewidth = 1) +\n",
      "  geom_point(size = 2.5) +\n",
      "  scale_x_continuous(breaks = scales::pretty_breaks(12)) +\n",
      "  scale_y_continuous(labels = scales::label_number(big.mark = \",\")) +\n",
      "  theme_minimal(base_size = 13) +\n",
      "  labs(x = NULL, y = \"Enrollment\",\n",
      "       title = \"Tertiary Education \\u2014 multi-source comparison\",\n",
      "       colour = NULL, shape = \"Source\", linetype = \"Modality\")\n"
    )

    show_code_modal("R code — Tertiary Education chart", code)
  })

  observeEvent(input$sch_show_code, {
    geo_arg <- switch(input$sch_geo_level,
                      UF     = input$sch_geo_uf,
                      region = input$sch_geo_reg,
                      NULL)

    get_call <- build_r_call("get_schooling", list(
      year      = input$sch_year,
      geo_level = input$sch_geo_level,
      geo       = geo_arg,
      dimension = input$sch_dimension,
      lang      = "en"
    ))

    color_var <- switch(input$sch_dimension,
                        race = "dim_race",
                        sex  = "dim_sex",
                        "geo_name")

    code <- paste0(
      "library(educabr)\n",
      "library(ggplot2)\n\n",
      "data <- ", get_call, "\n\n",
      "ggplot(data, aes(x = year, y = value,\n",
      "                 colour = ", color_var, ",\n",
      "                 group  = interaction(", color_var, ", geo_code))) +\n",
      "  geom_line(linewidth = 0.9, alpha = 0.9) +\n",
      "  geom_point(size = 0.6, alpha = 0.6) +\n",
      "  scale_x_continuous(breaks = scales::pretty_breaks(10)) +\n",
      "  theme_minimal(base_size = 13) +\n",
      "  labs(x = NULL, y = \"Mean years of schooling\")",
      if (input$sch_geo_level == "UF" && length(geo_arg) > 1L)
        " +\n  facet_wrap(~ geo_name, scales = \"free_y\")"
      else ""
    )

    show_code_modal("R code — Educational Attainment chart", code)
  })
}

shinyApp(ui, server)
