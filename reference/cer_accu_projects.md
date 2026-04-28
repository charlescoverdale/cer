# ACCU Scheme project register

Download and parse the Clean Energy Regulator's Australian Carbon Credit
Unit ('ACCU') Scheme project register. Returns one row per project with
proponent, method, state, crediting period, permanence period, and
cumulative ACCUs issued and relinquished.

## Usage

``` r
cer_accu_projects(
  state = NULL,
  method = NULL,
  status = c("active", "revoked", "completed", "all")
)
```

## Source

Clean Energy Regulator, ACCU project and contract register:
<https://cer.gov.au/markets/reports-and-data/accu-project-and-contract-register>.
Licensed under CC BY 4.0.

## Arguments

- state:

  Optional character vector of Australian state codes (e.g. `"NSW"`,
  `c("VIC", "QLD")`) to filter on. `NULL` returns projects across all
  states.

- method:

  Optional character vector of method name substrings (case-insensitive,
  e.g. `"savanna"`, `"landfill"`, `"vegetation"`).

- status:

  Character. One of `"active"` (default), `"revoked"`, `"completed"`, or
  `"all"`.

## Value

A `cer_tbl` (data frame) with one row per ACCU project.

## Details

The register is updated monthly by the CER, usually around the third
week. Downloaded once per R session (or invalidate with
[`cer_clear_cache()`](https://charlescoverdale.github.io/cer/reference/cer_clear_cache.md)).

## References

Commonwealth of Australia. *Carbon Credits (Carbon Farming Initiative)
Act 2011*. Enabling legislation for the ACCU Scheme.

Chubb, I. (2022). *Independent Review of Australian Carbon Credit
Units*. Commonwealth of Australia, Department of Climate Change, Energy,
the Environment and Water.

Climate Change Authority (2024). *2026 Review of the ACCU Scheme: Issues
paper*.

Macintosh, A., Butler, D., Larraondo, P., Evans, M.C., Ansell, D.,
Gibbons, P., Lindenmayer, D., Waschka, M. and Fisher, R. (2022). "The
emperor's new clothes: assessing the integrity of ACCUs." Australian
National University working paper series.

## See also

Other accu:
[`cer_accu_aggregate()`](https://charlescoverdale.github.io/cer/reference/cer_accu_aggregate.md),
[`cer_accu_contracts()`](https://charlescoverdale.github.io/cer/reference/cer_accu_contracts.md),
[`cer_accu_issuances()`](https://charlescoverdale.github.io/cer/reference/cer_accu_issuances.md),
[`cer_accu_methods()`](https://charlescoverdale.github.io/cer/reference/cer_accu_methods.md),
[`cer_accu_relinquishments()`](https://charlescoverdale.github.io/cer/reference/cer_accu_relinquishments.md),
[`cer_method_determination()`](https://charlescoverdale.github.io/cer/reference/cer_method_determination.md),
[`cer_method_integrity()`](https://charlescoverdale.github.io/cer/reference/cer_method_integrity.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
p <- cer_accu_projects(state = "NSW")
head(p)
options(op)
# }
```
