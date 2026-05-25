# educabr2: Harmonized Historical Series on Brazilian Education

Curated long-run series on Brazilian formal education — enrollment and
educational attainment — compiled from heterogeneous official and
academic sources into a single tidy schema with explicit provenance.

## Details

The canonical output schema (one row per observation; sources as
separate rows) is documented in `inst/dict/schema.yaml`. Inequality is
not a dataset but a *cut* applied to indicators: every `get_*()`
function accepts a `dimension` argument that returns the indicator
broken down by race, sex, income or location. A `compute_gap()` helper
for turning long-format breakdowns into the usual gap/ratio metrics is
on the roadmap for a future release.

## Roadmap

v0 lays out the data schema, ETL pipeline and package skeleton. The
first user-facing functions —
[`get_enrollment()`](https://mancano-tales.github.io/educabr/dev/reference/get_enrollment.md)
and
[`get_schooling()`](https://mancano-tales.github.io/educabr/dev/reference/get_schooling.md)
— and the bundled Shiny dashboard
([`run_dashboard()`](https://mancano-tales.github.io/educabr/dev/reference/run_dashboard.md))
are scheduled for the v0.2–v0.4 milestones. See `NEWS.md` once released.

## See also

Useful links:

- <https://github.com/mancano-tales/educabr>

- <https://mancano-tales.github.io/educabr/>

- Report bugs at <https://github.com/mancano-tales/educabr/issues>

## Author

**Maintainer**: Tales Mançano <mancano.tales@usp.br>
([ORCID](https://orcid.org/0000-0001-5923-9743))

Authors:

- Tales Mançano <mancano.tales@usp.br>
  ([ORCID](https://orcid.org/0000-0001-5923-9743))

Other contributors:

- Victor Alcantara <victorgalcantara@usp.br>
  ([ORCID](https://orcid.org/0000-0001-8846-9652)) \[contributor\]

- Artur Damião <artur.cardoso@usp.br>
  ([ORCID](https://orcid.org/0000-0002-8628-1653)) \[contributor\]
