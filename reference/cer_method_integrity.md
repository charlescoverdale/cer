# ACCU method integrity scorecard

Returns a method-level integrity scorecard for all ACCU methods. Columns
include `integrity_tier` (high / standard / contested), `chubb_affected`
(whether the Chubb 2022 Independent Review flagged the method),
`chubb_recommendation_applies` (whether a specific Chubb recommendation
targets the method), and `federal_register_instrument` (authoritative
legislative instrument ID).

## Usage

``` r
cer_method_integrity(tier = NULL, status = NULL)
```

## Arguments

- tier:

  Optional filter on `integrity_tier`. One or more of `"high"`,
  `"standard"`, `"contested"`.

- status:

  Optional filter on method `status`. One or more of `"active"`,
  `"suspended"`, `"under_review"`, `"superseded"`, `"expired"`.

## Value

A `cer_tbl` with one row per method (19 rows at v0.2.0).

## Details

Use this to filter or weight ACCU aggregates, or to annotate a chart
with integrity context. For example, an analyst reporting "185 million
ACCUs issued to date" should, at minimum, break the total down by
`integrity_tier` and flag the contested share.

## References

Chubb, I. (2022). *Independent Review of Australian Carbon Credit
Units*. Commonwealth of Australia, Department of Climate Change, Energy,
the Environment and Water.

Macintosh, A., Butler, D., Larraondo, P., Evans, M.C., Ansell, D.,
Gibbons, P., Lindenmayer, D., Waschka, M. and Fisher, R. (2022). "The
emperor's new clothes: assessing the integrity of ACCUs." Australian
National University working paper series.

Butler, D., Macintosh, A. and Pouliot, M. (2023). "Response to the Chubb
Review." Australian National University.

Ansell, D. *et al.* (2020). "Contemporary fire regimes of northern
Australia: a review of current patterns, impacts and challenges."
*Environmental Research Reviews*.

## See also

Other accu:
[`cer_accu_aggregate()`](https://charlescoverdale.github.io/cer/reference/cer_accu_aggregate.md),
[`cer_accu_contracts()`](https://charlescoverdale.github.io/cer/reference/cer_accu_contracts.md),
[`cer_accu_issuances()`](https://charlescoverdale.github.io/cer/reference/cer_accu_issuances.md),
[`cer_accu_methods()`](https://charlescoverdale.github.io/cer/reference/cer_accu_methods.md),
[`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md),
[`cer_accu_relinquishments()`](https://charlescoverdale.github.io/cer/reference/cer_accu_relinquishments.md),
[`cer_method_determination()`](https://charlescoverdale.github.io/cer/reference/cer_method_determination.md)

## Examples

``` r
cer_method_integrity()
cer_method_integrity(tier = "contested")
cer_method_integrity(status = "active")
```
