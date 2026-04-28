# Reconcile an aggregate against the QCMR headline figure

Compares a scalar or data-frame sum against the CER Quarterly Carbon
Market Report headline for the same quarter and measure. Warns on
absolute percentage gap \> 2% (default). Small gaps (sub-1%) are
expected because ACCU project registers are retroactively revised
between QCMR releases.

## Usage

``` r
cer_reconcile(value, quarter, measure, sum_column = NULL, warn_pct = 0.02)
```

## Arguments

- value:

  Numeric scalar or data frame. If a data frame, pass `sum_column` to
  pick which numeric column to sum.

- quarter:

  Character, e.g. `"2024-Q4"` or `"2023-24"`.

- measure:

  Character, matching a `measure` value in
  [`cer_qcmr_reference()`](https://charlescoverdale.github.io/cer/reference/cer_qcmr_reference.md).
  For example `"accu_cumulative_issuances"`,
  `"safeguard_covered_emissions_mt"`, `"smc_issuances"`.

- sum_column:

  Column name to sum when `value` is a data frame.

- warn_pct:

  Warn if \|pct_diff\| \> this threshold. Default 0.02.

## Value

A one-row data frame: `measure`, `quarter`, `value`, `reference`,
`diff`, `pct_diff`, `unit`, `source`.

## References

Clean Energy Regulator (quarterly). *Quarterly Carbon Market Report*.
<https://cer.gov.au/markets/reports-and-data/quarterly-carbon-market-reports>

## See also

Other reconciliation:
[`cer_qcmr_reference()`](https://charlescoverdale.github.io/cer/reference/cer_qcmr_reference.md)

## Examples

``` r
cer_reconcile(value = 185e6,
              quarter = "2024-Q4",
              measure = "accu_cumulative_issuances")
```
