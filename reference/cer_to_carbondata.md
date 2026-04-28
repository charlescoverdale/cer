# Remap an ACCU project data frame to the carbondata voluntary- project schema

The `carbondata` R package exposes Verra, Gold Standard, ACR, and CAR
voluntary projects under a unified schema. This function renames ACCU
register columns to match, so an analyst can compare ACCU issuance
patterns against international voluntary markets on a consistent basis.

## Usage

``` r
cer_to_carbondata(x)
```

## Arguments

- x:

  A `cer_tbl` from
  [`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md).

## Value

A data frame with carbondata-style columns: `project_id`,
`project_name`, `methodology`, `project_type`, `country`, `registry`,
`issued_credits_to_date`, `retired_credits_to_date`.

## Details

Schema mapping is lossy: ACCU-specific fields (Chubb flag, permanence
period, crediting-period dates) pass through with original names.

## See also

Other interop:
[`cer_international_comparator()`](https://charlescoverdale.github.io/cer/reference/cer_international_comparator.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
try({
  ccy <- cer_accu_projects()
  carb <- cer_to_carbondata(ccy)
  head(carb)
})
options(op)
# }
```
