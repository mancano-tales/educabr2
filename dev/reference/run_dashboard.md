# Launch the educabr2 Shiny dashboard

Opens a local Shiny app that explores the data shipped by the package.
The app consumes only the public API
([`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md))
so any improvement to the data flows through it automatically.

## Usage

``` r
run_dashboard(lang = c("pt", "en"), ...)
```

## Arguments

- lang:

  Default UI language. One of `"pt"` (default) or `"en"`.

- ...:

  Passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html) (e.g.
  `port`, `launch.browser`, `host`).

## Value

Invoked for its side effect (starts the Shiny app). Returns the value of
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html)
invisibly.

## Details

The dashboard is also deployed publicly (link in the README) for users
who prefer not to install R locally.
