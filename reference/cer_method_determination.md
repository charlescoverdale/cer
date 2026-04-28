# Federal Register URL for an ACCU method determination

Given a method short name (e.g. `"HIR"`, `"Savanna_2026"`), return the
authoritative legislative instrument URL on the Federal Register of
Legislation. This is the technical determination document that defines
measurement, monitoring, baseline, and permanence rules for the method.

## Usage

``` r
cer_method_determination(method_short)
```

## Arguments

- method_short:

  Character scalar matching a `method_short` value from
  [`cer_method_integrity()`](https://charlescoverdale.github.io/cer/reference/cer_method_integrity.md).

## Value

A length-1 character URL, or `NA_character_` if not found.

## See also

Other accu:
[`cer_accu_aggregate()`](https://charlescoverdale.github.io/cer/reference/cer_accu_aggregate.md),
[`cer_accu_contracts()`](https://charlescoverdale.github.io/cer/reference/cer_accu_contracts.md),
[`cer_accu_issuances()`](https://charlescoverdale.github.io/cer/reference/cer_accu_issuances.md),
[`cer_accu_methods()`](https://charlescoverdale.github.io/cer/reference/cer_accu_methods.md),
[`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md),
[`cer_accu_relinquishments()`](https://charlescoverdale.github.io/cer/reference/cer_accu_relinquishments.md),
[`cer_method_integrity()`](https://charlescoverdale.github.io/cer/reference/cer_method_integrity.md)

## Examples

``` r
cer_method_determination("HIR")
cer_method_determination("Savanna_2026")
```
