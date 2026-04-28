# Translate NGER scope columns to Climate Active categories

Climate Active (Australia's voluntary carbon-neutral certification) uses
a Scope 1 / Scope 2 (market-based and location-based) / Scope 3
taxonomy. NGER publishes Scope 1 and Scope 2 only (Scope 3 is not
NGER-reportable). This helper renames columns so an NGER output flows
into a Climate Active inventory template.

## Usage

``` r
cer_nger_climate_active(x)
```

## Arguments

- x:

  A `cer_tbl` or data frame from
  [`cer_nger_corporate()`](https://charlescoverdale.github.io/cer/reference/cer_nger_corporate.md).

## Value

A data frame with Climate Active-style columns:
`operational_scope_1_t_co2e`, `operational_scope_2_location_t_co2e`,
`operational_scope_2_market_t_co2e`.

## References

Department of Climate Change, Energy, the Environment and Water
(annual). *Climate Active Carbon Neutral Standard for Organisations*.
Commonwealth of Australia.

Greenhouse Gas Protocol (2004). *A Corporate Accounting and Reporting
Standard (Revised Edition)*. World Resources Institute.

## See also

Other nger:
[`cer_nger_corporate()`](https://charlescoverdale.github.io/cer/reference/cer_nger_corporate.md),
[`cer_nger_electricity()`](https://charlescoverdale.github.io/cer/reference/cer_nger_electricity.md),
[`cer_nger_scope()`](https://charlescoverdale.github.io/cer/reference/cer_nger_scope.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
try({
  x <- cer_nger_corporate(2025)
  cer_nger_climate_active(x)
})
options(op)
# }
```
