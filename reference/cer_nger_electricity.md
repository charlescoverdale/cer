# NGER electricity sector facility emissions

Facility-level Scope 1 emissions and generated electricity for
facilities in the electricity generation sector that met the NGER
reporting threshold.

## Usage

``` r
cer_nger_electricity(year = 2025, facility = NULL)
```

## Source

Clean Energy Regulator, National Greenhouse and Energy Register:
<https://cer.gov.au/markets/reports-and-data/nger-reporting-data-and-registers>.
Licensed under CC BY 4.0.

## Arguments

- year:

  Integer. Reporting year ending 30 June.

- facility:

  Optional character vector of facility name substrings
  (case-insensitive).

## Value

A `cer_tbl` with one row per generator facility.

## See also

Other nger:
[`cer_nger_climate_active()`](https://charlescoverdale.github.io/cer/reference/cer_nger_climate_active.md),
[`cer_nger_corporate()`](https://charlescoverdale.github.io/cer/reference/cer_nger_corporate.md),
[`cer_nger_scope()`](https://charlescoverdale.github.io/cer/reference/cer_nger_scope.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
try({
  e <- cer_nger_electricity(year = 2025, facility = "Bayswater")
  head(e)
})
options(op)
# }
```
