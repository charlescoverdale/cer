# ACCU issuances by project

Derived from the ACCU Scheme project register: returns one row per
project with `accus_issued`, project metadata, and total issuance net of
relinquishments. For method- or period-level issuance tracking, query
[`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md)
directly.

## Usage

``` r
cer_accu_issuances(method = NULL, project_id = NULL, from = NULL, to = NULL)
```

## Source

Clean Energy Regulator ACCU project register (CC BY 4.0).

## Arguments

- method:

  Optional character vector of method substrings.

- project_id:

  Optional character vector of ERF / EOP project identifiers.

- from, to:

  Optional `Date` (or YYYY-MM-DD string) for crediting-period overlap
  filter. `NULL` returns all projects.

## Value

A `cer_tbl` with one row per project.

## See also

Other accu:
[`cer_accu_aggregate()`](https://charlescoverdale.github.io/cer/reference/cer_accu_aggregate.md),
[`cer_accu_contracts()`](https://charlescoverdale.github.io/cer/reference/cer_accu_contracts.md),
[`cer_accu_methods()`](https://charlescoverdale.github.io/cer/reference/cer_accu_methods.md),
[`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md),
[`cer_accu_relinquishments()`](https://charlescoverdale.github.io/cer/reference/cer_accu_relinquishments.md),
[`cer_method_determination()`](https://charlescoverdale.github.io/cer/reference/cer_method_determination.md),
[`cer_method_integrity()`](https://charlescoverdale.github.io/cer/reference/cer_method_integrity.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
i <- cer_accu_issuances(method = "savanna")
head(i)
options(op)
# }
```
