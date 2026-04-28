# Quarterly Carbon Market Report data workbook

Aggregate carbon market statistics from the CER's Quarterly Carbon
Market Report, including ACCU issuances, LGC creations, STC volumes,
unit surrenders, and Safeguard Mechanism developments.

## Usage

``` r
cer_qcmr(quarter = "latest", sheet = "Contents")
```

## Source

Clean Energy Regulator, Quarterly Carbon Market Reports:
<https://cer.gov.au/markets/reports-and-data/quarterly-carbon-market-reports>.
Licensed under CC BY 4.0.

## Arguments

- quarter:

  Character. Quarter identifier in `"YYYYqN"` form (e.g. `"2025q4"` for
  the December 2025 quarter). Defaults to `"latest"`, which resolves to
  the most recent release.

- sheet:

  Sheet name or integer index. The CER QCMR workbook contains a
  `Contents` sheet (default) plus one sheet per figure (e.g.
  `"Figure 1.1"`, `"Figure 3.14"`). Pass a figure name to extract that
  figure's data.

## Value

A `cer_tbl` with the requested sheet's contents.

## References

Clean Energy Regulator (quarterly). *Quarterly Carbon Market Report*.
Methodology notes accompany each release.

Clean Energy Regulator (2024). *Carbon Market Indicators: methodology
and data dictionary*.

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
try({
  # Contents sheet lists all available figures
  toc <- cer_qcmr("latest")
  head(toc)
  # Fetch a specific figure
  fig <- cer_qcmr("latest", sheet = "Figure 1.1")
})
options(op)
# }
```
