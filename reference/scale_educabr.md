# educabr2 Color Scales (Okabe-Ito)

Colorblind-safe color scales for `educabr2` plots, based on the
Okabe-Ito palette.

## Usage

``` r
scale_colour_educabr(...)

scale_fill_educabr(...)
```

## Arguments

- ...:

  Arguments passed on to
  [`ggplot2::scale_colour_manual`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
  or
  [`ggplot2::scale_fill_manual`](https://ggplot2.tidyverse.org/reference/scale_manual.html)

## Value

A ggplot2 scale function.

## Português

Escalas discretas de cor (`scale_colour_educabr`) e preenchimento
(`scale_fill_educabr`) com a paleta Okabe-Ito, segura para daltonismo.
`...` passa argumentos a
[`ggplot2::scale_colour_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
ou
[`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html),
como `name`, `labels` e `breaks`. A paleta tem oito cores; mais
categorias geram erro. Prefira facetas ou destaque poucas séries nesses
casos. Retorna uma escala ggplot2.

## Examples

``` r
scale_colour_educabr()
#> <ggproto object: Class ScaleDiscrete, Scale, gg>
#>     aesthetics: colour
#>     axis_order: function
#>     break_info: function
#>     break_positions: function
#>     breaks: waiver
#>     call: call
#>     clone: function
#>     dimension: function
#>     drop: TRUE
#>     expand: waiver
#>     fallback_palette: function
#>     get_breaks: function
#>     get_breaks_minor: function
#>     get_labels: function
#>     get_limits: function
#>     get_transformation: function
#>     guide: legend
#>     is_discrete: function
#>     is_empty: function
#>     labels: waiver
#>     limits: NULL
#>     make_sec_title: function
#>     make_title: function
#>     map: function
#>     map_df: function
#>     minor_breaks: waiver
#>     n.breaks.cache: NULL
#>     na.translate: TRUE
#>     na.value: grey50
#>     name: waiver
#>     palette: function
#>     palette.cache: NULL
#>     position: left
#>     range: environment
#>     rescale: function
#>     reset: function
#>     train: function
#>     train_df: function
#>     transform: function
#>     transform_df: function
#>     super:  <ggproto object: Class ScaleDiscrete, Scale, gg>
scale_fill_educabr()
#> <ggproto object: Class ScaleDiscrete, Scale, gg>
#>     aesthetics: fill
#>     axis_order: function
#>     break_info: function
#>     break_positions: function
#>     breaks: waiver
#>     call: call
#>     clone: function
#>     dimension: function
#>     drop: TRUE
#>     expand: waiver
#>     fallback_palette: function
#>     get_breaks: function
#>     get_breaks_minor: function
#>     get_labels: function
#>     get_limits: function
#>     get_transformation: function
#>     guide: legend
#>     is_discrete: function
#>     is_empty: function
#>     labels: waiver
#>     limits: NULL
#>     make_sec_title: function
#>     make_title: function
#>     map: function
#>     map_df: function
#>     minor_breaks: waiver
#>     n.breaks.cache: NULL
#>     na.translate: TRUE
#>     na.value: grey50
#>     name: waiver
#>     palette: function
#>     palette.cache: NULL
#>     position: left
#>     range: environment
#>     rescale: function
#>     reset: function
#>     train: function
#>     train_df: function
#>     transform: function
#>     transform_df: function
#>     super:  <ggproto object: Class ScaleDiscrete, Scale, gg>
```
