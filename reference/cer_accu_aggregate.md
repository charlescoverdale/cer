# Integrity-weighted ACCU aggregation

Takes an `ato_tbl` or data frame of ACCU project records (from
[`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md)),
joins the method integrity scorecard, and aggregates by integrity tier.
Emits a warning if contested or under-review methods contribute
materially to the total so the analyst cannot silently aggregate them
into a single headline figure.

## Usage

``` r
cer_accu_aggregate(x, value_col = "accus_issued", warn_contested_pct = 0.05)
```

## Arguments

- x:

  A `cer_tbl` or data frame with columns `method` and (typically)
  `accus_issued`.

- value_col:

  Column to sum. Default `"accus_issued"`.

- warn_contested_pct:

  Warn if the contested tier exceeds this share of the total. Default
  `0.05` (5%).

## Value

A data frame with one row per integrity tier and columns
`integrity_tier`, `projects`, `accus_issued_sum`, `share_pct`.

## See also

Other accu:
[`cer_accu_contracts()`](https://charlescoverdale.github.io/cer/reference/cer_accu_contracts.md),
[`cer_accu_issuances()`](https://charlescoverdale.github.io/cer/reference/cer_accu_issuances.md),
[`cer_accu_methods()`](https://charlescoverdale.github.io/cer/reference/cer_accu_methods.md),
[`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md),
[`cer_accu_relinquishments()`](https://charlescoverdale.github.io/cer/reference/cer_accu_relinquishments.md),
[`cer_method_determination()`](https://charlescoverdale.github.io/cer/reference/cer_method_determination.md),
[`cer_method_integrity()`](https://charlescoverdale.github.io/cer/reference/cer_method_integrity.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
try({
  p <- cer_accu_projects()
  cer_accu_aggregate(p)
})
options(op)
# }
```
