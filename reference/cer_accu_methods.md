# Approved ACCU Scheme methods

A static table of ACCU Scheme methods grouped by sector (Agriculture,
Energy Efficiency, Landfill and Waste, Mining/Oil/Gas, Vegetation,
Savanna, Blue Carbon, Transport). Built from the CER methods index at
build time.

## Usage

``` r
cer_accu_methods()
```

## Source

Clean Energy Regulator ACCU Scheme methods index
<https://cer.gov.au/schemes/australian-carbon-credit-unit-scheme/accu-scheme-methods>.

## Value

A `cer_tbl` with columns `method`, `sector`, `short_name`, `status`,
`commenced`, and `source_url`.

## Details

Because the CER publishes methods as per-method PDFs on the Federal
Register of Legislation rather than a machine-readable index, this
function returns a package-embedded lookup. The `status` column captures
post-Chubb Review changes: methods are flagged as `"active"`,
`"expired"`, `"suspended"`, or `"under_review"`. Run
[`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md)
then `unique(x$method)` to cross-check against currently-registered
projects.

## See also

Other accu:
[`cer_accu_aggregate()`](https://charlescoverdale.github.io/cer/reference/cer_accu_aggregate.md),
[`cer_accu_contracts()`](https://charlescoverdale.github.io/cer/reference/cer_accu_contracts.md),
[`cer_accu_issuances()`](https://charlescoverdale.github.io/cer/reference/cer_accu_issuances.md),
[`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md),
[`cer_accu_relinquishments()`](https://charlescoverdale.github.io/cer/reference/cer_accu_relinquishments.md),
[`cer_method_determination()`](https://charlescoverdale.github.io/cer/reference/cer_method_determination.md),
[`cer_method_integrity()`](https://charlescoverdale.github.io/cer/reference/cer_method_integrity.md)

## Examples

``` r
m <- cer_accu_methods()
head(m)
```
