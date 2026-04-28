# Select NGER columns by scope with explicit errors

Given an NGER corporate-level data frame from
[`cer_nger_corporate()`](https://charlescoverdale.github.io/cer/reference/cer_nger_corporate.md),
select the requested scope columns and error if they are not present.
Avoids the silent-misaggregation failure mode where a user sums a column
that is actually Scope 1+2 combined when they intended Scope 1 only.

## Usage

``` r
cer_nger_scope(
  x,
  scope = c("1_plus_2", "1", "2_market", "2_location"),
  col_pattern = NULL
)
```

## Arguments

- x:

  A `cer_tbl` or data frame from
  [`cer_nger_corporate()`](https://charlescoverdale.github.io/cer/reference/cer_nger_corporate.md).

- scope:

  One of `"1_plus_2"` (default), `"1"`, `"2_market"`, or `"2_location"`.

- col_pattern:

  Optional regex override for the target column.

## Value

A data frame with an `emissions_t_co2e` column populated by the
requested scope and a `scope` column recording which scope was selected.

## Details

Column-name detection is heuristic because NGER renames columns year to
year. Pass `col_pattern` to override.

## See also

Other nger:
[`cer_nger_climate_active()`](https://charlescoverdale.github.io/cer/reference/cer_nger_climate_active.md),
[`cer_nger_corporate()`](https://charlescoverdale.github.io/cer/reference/cer_nger_corporate.md),
[`cer_nger_electricity()`](https://charlescoverdale.github.io/cer/reference/cer_nger_electricity.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
try({
  x <- cer_nger_corporate(2025)
  cer_nger_scope(x, scope = "1")
})
options(op)
# }
```
