# QCMR headline reference totals

Bundled quarterly Clean Energy Regulator QCMR headline figures for
cross-validation of live-fetched aggregates.

## Usage

``` r
cer_qcmr_reference(quarter = NULL, measure = NULL)
```

## Arguments

- quarter:

  Optional character filter (e.g. `"2024-Q4"`).

- measure:

  Optional character filter (e.g. `"accu_cumulative_issuances"`).

## Value

A `cer_tbl` of reference totals.

## Details

Every value is read from the QCMR data workbook by
`data-raw/qcmr_headline_totals.R`, and the `source` column names the
workbook vintage, figure and column. Measures: `accu_issuances`,
`accu_cumulative_issuances`, `accu_projects_registered`,
`accu_cumulative_projects_registered`, `safeguard_accu_surrenders`,
`safeguard_smc_surrenders`, `lgc_validations`,
`lgc_cumulative_validations`, `sres_solar_installations` and
`sres_cumulative_solar_installations`. Cumulative measures are running
sums of the quarterly figures over the history the workbook covers.

## See also

Other reconciliation:
[`cer_reconcile()`](https://charlescoverdale.github.io/cer/reference/cer_reconcile.md)

## Examples

``` r
cer_qcmr_reference()
cer_qcmr_reference(quarter = "2024-Q4")
```
