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

## See also

Other reconciliation:
[`cer_reconcile()`](https://charlescoverdale.github.io/cer/reference/cer_reconcile.md)

## Examples

``` r
cer_qcmr_reference()
cer_qcmr_reference(quarter = "2024-Q4")
```
