# Compute a declining Safeguard baseline trajectory

Implements the 4.9% per-annum nominal decline in industry-average
default baselines introduced by the 2023 reform. The formula is:

## Usage

``` r
cer_safeguard_baseline_trajectory(industry, from_year = 2023, to_year = 2030)
```

## Arguments

- industry:

  Character scalar matching an `industry` value from
  [`cer_safeguard_industry_baselines()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_industry_baselines.md).

- from_year:

  Start year (default 2023 for FY 2023-24).

- to_year:

  End year (default 2029 for FY 2029-30).

## Value

A data frame with `year`, `financial_year`, `baseline`, and
`decline_factor` columns.

## Details

\$\$B_t = B\_{2023\text{-}24} \times (1 - 0.049)^{t - 2023}\$\$

where `t` is the starting calendar year of the financial year. Default
values are drawn from `inst/extdata/safeguard_industry_baselines.csv`.

## References

Commonwealth of Australia (2023). *Safeguard Mechanism (Crediting)
Amendment Act 2023*. Introduces 4.9% p.a. nominal baseline decline to
2030.

Clean Energy Regulator (annual). *Safeguard Mechanism: declining
baselines*. Methodology notes accompanying annual baseline
determinations.

## See also

Other safeguard:
[`cer_safeguard_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_facilities.md),
[`cer_safeguard_industry_baselines()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_industry_baselines.md),
[`cer_safeguard_teba_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_teba_facilities.md)

## Examples

``` r
cer_safeguard_baseline_trajectory("Aluminium smelting")
cer_safeguard_baseline_trajectory("Cement clinker",
                                   from_year = 2023, to_year = 2030)
```
