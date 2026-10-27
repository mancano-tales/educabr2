# Launch the educabr2 Shiny dashboard

Opens a local Shiny app that explores the data shipped by the package.
The app consumes only the public API
([`get_enrollment()`](https://mancano-tales.github.io/educabr2/reference/get_enrollment.md))
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

## Português

Abre o painel Shiny local, que usa a API pública para explorar os dados
distribuídos com o pacote. Há também um painel público, vinculado no
README.

- `lang`: idioma inicial da interface, `"pt"` (padrão) ou `"en"`. Os
  links Português/English permitem alternar o idioma, reiniciando
  filtros. A URL `?lang=pt` ou `?lang=en` tem precedência sobre o idioma
  inicial.

- `...`: argumentos de
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), como
  `port`, `host` e `launch.browser`.

Inicia a aplicação por efeito colateral e devolve o resultado de
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).
Consultas e downloads preservam chaves canônicas; controles, gráficos,
mensagens e tabelas usam o idioma escolhido.

## Examples

``` r
if (FALSE) { # \dontrun{
run_dashboard(lang = "pt")
run_dashboard(lang = "en")
} # }
```
