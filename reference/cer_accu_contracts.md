# ACCU Carbon Abatement Contract register

Government purchase contracts under Emissions Reduction Fund auctions
administered by the CER.

## Usage

``` r
cer_accu_contracts(auction = NULL)
```

## Source

Clean Energy Regulator Carbon Abatement Contract register (CC BY 4.0).

## Arguments

- auction:

  Optional character vector of auction identifiers (e.g.
  `"ERF Auction 18"`).

## Value

A `cer_tbl` with one row per contract.

## See also

Other accu:
[`cer_accu_aggregate()`](https://charlescoverdale.github.io/cer/reference/cer_accu_aggregate.md),
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
cer_accu_contracts()
options(op)
# }
```
