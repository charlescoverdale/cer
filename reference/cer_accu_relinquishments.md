# ACCU relinquishments by project

Returns projects with non-zero ACCU relinquishments. Useful for tracking
voluntary cancellations and compliance obligations.

## Usage

``` r
cer_accu_relinquishments(project_id = NULL)
```

## Source

Clean Energy Regulator ACCU project register (CC BY 4.0).

## Arguments

- project_id:

  Optional character vector of project IDs.

## Value

A `cer_tbl` with one row per project with `accus_relinquished > 0`.

## See also

Other accu:
[`cer_accu_aggregate()`](https://charlescoverdale.github.io/cer/reference/cer_accu_aggregate.md),
[`cer_accu_contracts()`](https://charlescoverdale.github.io/cer/reference/cer_accu_contracts.md),
[`cer_accu_issuances()`](https://charlescoverdale.github.io/cer/reference/cer_accu_issuances.md),
[`cer_accu_methods()`](https://charlescoverdale.github.io/cer/reference/cer_accu_methods.md),
[`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md),
[`cer_method_determination()`](https://charlescoverdale.github.io/cer/reference/cer_method_determination.md),
[`cer_method_integrity()`](https://charlescoverdale.github.io/cer/reference/cer_method_integrity.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
cer_accu_relinquishments()
options(op)
# }
```
