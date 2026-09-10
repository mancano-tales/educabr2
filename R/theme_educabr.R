#' educabr2 Visualization Theme
#'
#' A standardized visualization system for the `educabr2` package, heavily inspired by
#' Kieran Healy's "Data Visualization: A Practical Introduction" (2018/2026).
#' This theme is designed to produce beautiful, standardized, and colorblind-safe
#' (Okabe-Ito palette) graphics. It is structurally compatible with the ongoing
#' MA Thesis by Tales Mançano (2026), ensuring that plots generated via this
#' package meet rigorous academic presentation standards.
#'
#' @section Font Registration:
#' The theme attempts to automatically load and register the LaTeX-standard
#' **Latin Modern Roman** font family to match academic publishing standards.
#' It queries the system's local TinyTeX installation (checking standard directories in
#' `%APPDATA%` on Windows and `~/.Library` on Unix/macOS). If the font files
#' (e.g. `lmroman10-regular.otf`) are found and the `showtext` and `sysfonts` packages are
#' installed, it registers them dynamically. If the font files are not found or packages
#' are missing, the theme falls back gracefully to the system's default `"serif"` family.
#'
#' @param base_size Base font size.
#' @param base_family Base font family. Defaults to "serif" if Latin Modern is unavailable.
#' @param plot_titles Logical. If `TRUE` (default), standard titles, subtitles, and captions
#'   are styled and displayed inside the plot image. If `FALSE`, titles, subtitles, and captions
#'   are completely removed (`element_blank()`). This is highly recommended for academic papers,
#'   LaTeX, or Quarto documents where captions and source notes are managed in the main markdown/TeX
#'   text (e.g., using `fig-cap` or `fignote` environments) rather than baked into the graphic file.
#'
#' @return A ggplot2 theme object.
#'
#' @references
#' Healy, K. (2018). *Data Visualization: A Practical Introduction*. Princeton University Press.
#' \url{https://socviz.co/}
#'
#' Mançano, T. (2026). *The Politics of Reforming Tertiary Education* (MA Thesis in progress).
#'
#' Okabe, M., & Ito, K. (2008). *Color Universal Design (CUD): How to make figures and presentations that are friendly to Colorblind people*. \url{https://jfly.uni-koeln.de/color/}
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(ggplot2)
#' library(educabr2)
#'
#' df <- get_enrollment(level = "superior", dimension = "race")
#'
#' # Standard plot with titles inside the image (default)
#' ggplot(df, aes(x = year, y = value, fill = dim_race)) +
#'   geom_area() +
#'   labs(title = "Higher Education by Race", subtitle = "1960-2010") +
#'   theme_educabr(plot_titles = TRUE) +
#'   scale_fill_educabr()
#'
#' # Academic plot without titles inside the image
#' ggplot(df, aes(x = year, y = value, fill = dim_race)) +
#'   geom_area() +
#'   theme_educabr(plot_titles = FALSE) +
#'   scale_fill_educabr()
#' }
theme_educabr <- function(base_size = 9.5, base_family = "serif", plot_titles = TRUE) {
  # Attempt to dynamically load and register Latin Modern Roman from TinyTeX
  if (requireNamespace("showtext", quietly = TRUE) && requireNamespace("sysfonts", quietly = TRUE)) {
    if (!"LM Roman" %in% sysfonts::font_families()) {
      # Try to locate TinyTeX's opentype fonts on Windows/Linux/macOS
      lm_dir <- file.path(Sys.getenv("APPDATA"), "TinyTeX", "texmf-dist",
                          "fonts", "opentype", "public", "lm")
      
      # Alternative path check (e.g. Linux / macOS standard tinytex)
      if (!dir.exists(lm_dir)) {
        lm_dir <- file.path(Sys.getenv("HOME"), ".Library", "TinyTeX", "texmf-dist",
                            "fonts", "opentype", "public", "lm")
      }
      
      lm_reg <- file.path(lm_dir, "lmroman10-regular.otf")
      if (file.exists(lm_reg)) {
        tryCatch({
          sysfonts::font_add("LM Roman",
            regular    = lm_reg,
            bold       = sub("regular", "bold",       lm_reg, fixed = TRUE),
            italic     = sub("regular", "italic",     lm_reg, fixed = TRUE),
            bolditalic = sub("regular", "bolditalic", lm_reg, fixed = TRUE)
          )
          showtext::showtext_auto()
          base_family <- "LM Roman"
        }, error = function(e) {
          # Silently fall back to serif if registration fails
        })
      }
    } else {
      base_family <- "LM Roman"
    }
  }

  theme_obj <- ggplot2::`%+replace%`(
    ggplot2::theme_minimal(base_size = base_size, base_family = base_family),
    ggplot2::theme(
      plot.title         = ggplot2::element_text(face = "bold",
                                                 size = base_size + 1.5,
                                                 margin = ggplot2::margin(b = 4)),
      plot.subtitle      = ggplot2::element_text(size = base_size - 0.5,
                                                 colour = "#555555",
                                                 margin = ggplot2::margin(b = 6)),
      plot.caption       = ggplot2::element_text(size = base_size - 2,
                                                 colour = "#666666",
                                                 hjust = 0,
                                                 margin = ggplot2::margin(t = 10)),
      axis.title         = ggplot2::element_text(size = base_size),
      axis.text          = ggplot2::element_text(size = base_size - 1),
      axis.ticks         = ggplot2::element_line(colour = "#CCCCCC"),
      panel.grid.major   = ggplot2::element_line(colour = "#EEEEEE", linewidth = 0.3),
      panel.grid.minor   = ggplot2::element_blank(),
      panel.background   = ggplot2::element_rect(fill = "white", colour = NA),
      strip.text         = ggplot2::element_text(face = "bold", size = base_size),
      strip.background   = ggplot2::element_rect(fill = "#F0F0F0", colour = NA),
      legend.position    = "bottom",
      legend.text        = ggplot2::element_text(size = base_size - 1),
      legend.key.size    = ggplot2::unit(0.9, "lines"),
      legend.title       = ggplot2::element_text(size = base_size - 1, face = "bold"),
      plot.margin        = ggplot2::margin(8, 8, 8, 8)
    )
  )

  # Strip title, subtitle, and caption if plot_titles is FALSE
  if (!plot_titles) {
    theme_obj <- theme_obj + ggplot2::theme(
      plot.title    = ggplot2::element_blank(),
      plot.subtitle = ggplot2::element_blank(),
      plot.caption  = ggplot2::element_blank()
    )
  }

  return(theme_obj)
}

# The Okabe-Ito colorblind-safe palette
.educabr_palette <- c(
  "#E69F00",  # orange
  "#56B4E9",  # skyblue
  "#009E73",  # green
  "#0072B2",  # blue
  "#D55E00",  # vermillion
  "#CC79A7",  # reddish purple
  "#F0E442",  # yellow
  "#000000"   # black
)

#' Year Axis Scale for Historical Series
#'
#' A continuous x-axis scale for integer-year time series that picks break
#' spacing according to the span of the data, so that century-long historical
#' series (the norm in `educabr2`) get readable, evenly spaced year labels.
#' The first and last years actually present in the series are always
#' labelled, and any grid break that would collide with those extremes is
#' dropped in their favour.
#'
#' Break spacing by span of the series: more than 60 years, every 20 years;
#' 25 to 60 years, every 10 years; under 25 years, `pretty()` breaks. Labels
#' are always four-digit years.
#'
#' @param years Numeric vector with the years actually plotted (typically
#'   `data$year`). Used to compute the span and anchor the first/last labels.
#' @param ... Additional arguments passed on to [ggplot2::scale_x_continuous()].
#'
#' @return A ggplot2 continuous position scale.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(ggplot2)
#' library(educabr2)
#'
#' df <- get_enrollment(level = "superior", network = "total",
#'                      modality = "total", indicator = "count")
#'
#' ggplot(df, aes(x = year, y = value, colour = source)) +
#'   geom_line() +
#'   scale_x_year_educabr(df$year) +
#'   theme_educabr()
#' }
scale_x_year_educabr <- function(years, ...) {
  years <- years[!is.na(years)]
  min_y <- as.integer(min(years))
  max_y <- as.integer(max(years))
  span  <- max_y - min_y

  if (span > 60) {
    step <- 20
  } else if (span >= 25) {
    step <- 10
  } else {
    step <- NULL
  }

  if (is.null(step)) {
    grid <- pretty(c(min_y, max_y))
    grid <- grid[grid == floor(grid)]
  } else {
    grid <- seq(ceiling(min_y / step) * step, floor(max_y / step) * step,
                by = step)
  }

  # The extremes are always labelled; a grid break too close to an extreme is
  # dropped in its favour so the labels never collide. "Too close" scales
  # with the span (4% of it, at least 2 years) because on a century-long axis
  # even labels 4 years apart overlap physically.
  tol  <- max(2, span * 0.04)
  grid <- grid[abs(grid - min_y) > tol & abs(grid - max_y) > tol]

  breaks <- sort(unique(c(grid, min_y, max_y)))

  ggplot2::scale_x_continuous(
    breaks = breaks,
    labels = function(x) sprintf("%d", as.integer(x)),
    ...
  )
}

#' educabr2 Color Scales (Okabe-Ito)
#'
#' Colorblind-safe color scales for `educabr2` plots, based on the Okabe-Ito palette.
#'
#' @param ... Arguments passed on to `ggplot2::scale_colour_manual` or `ggplot2::scale_fill_manual`
#'
#' @return A ggplot2 scale function.
#'
#' @export
#' @rdname scale_educabr
scale_colour_educabr <- function(...) {
  ggplot2::scale_colour_manual(values = .educabr_palette, ...)
}

#' @export
#' @rdname scale_educabr
scale_fill_educabr <- function(...) {
  ggplot2::scale_fill_manual(values = .educabr_palette, ...)
}
