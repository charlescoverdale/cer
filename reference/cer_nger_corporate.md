# NGER corporate emissions and energy data

Controlling-corporation-level Scope 1 and Scope 2 emissions and energy
use from the National Greenhouse and Energy Reporting ('NGER') scheme.

## Usage

``` r
cer_nger_corporate(year = 2025)
```

## Source

Clean Energy Regulator, NGER reporting data and registers:
<https://cer.gov.au/markets/reports-and-data/nger-reporting-data-and-registers>.
Licensed under CC BY 4.0.

## Arguments

- year:

  Integer. Reporting year ending 30 June.

## Value

A `cer_tbl` with one row per reporting corporation.

## Details

Published annually by the CER on 28 February. Facility-level Scope 1 and
2 data is only published for the electricity sector; non-electricity
sectors report at this controlling-corporation level only.

## References

Commonwealth of Australia. *National Greenhouse and Energy Reporting Act
2007*; *National Greenhouse and Energy Reporting (Measurement)
Determination 2008* (as amended annually).

Greenhouse Gas Protocol (2004). *A Corporate Accounting and Reporting
Standard (Revised Edition)*. World Resources Institute.

Department of Climate Change, Energy, the Environment and Water
(annual). *NGER Technical Guidelines*. Methodology for Scope 1 and Scope
2 calculations.

## See also

Other nger:
[`cer_nger_climate_active()`](https://charlescoverdale.github.io/cer/reference/cer_nger_climate_active.md),
[`cer_nger_electricity()`](https://charlescoverdale.github.io/cer/reference/cer_nger_electricity.md),
[`cer_nger_scope()`](https://charlescoverdale.github.io/cer/reference/cer_nger_scope.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
try({
  x <- cer_nger_corporate(year = 2025)
  head(x)
})
options(op)
# }
```
