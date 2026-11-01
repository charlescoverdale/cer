# Default Safeguard baseline emissions intensity trajectory

Returns the baseline emissions intensity, per unit of a production
variable, for a facility whose baseline is set at the default emissions
intensity in Schedule 1 of the Safeguard Mechanism Rule 2015 and the
default emissions reduction contribution (ERC) in section 31:

## Usage

``` r
cer_safeguard_baseline_trajectory(industry, from_year = 2023, to_year = 2030)
```

## Arguments

- industry:

  Character scalar: a `production_variable` from
  [`cer_safeguard_industry_baselines()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_industry_baselines.md)
  (case-insensitive), or its Schedule 1 section number, e.g. `"7"` for
  aluminium.

- from_year:

  Start year (default 2023 for FY 2023-24).

- to_year:

  End year (default 2030 for FY 2030-31).

## Value

A data frame with `year`, `financial_year`,
`default_emissions_intensity`, `decline_factor` (the default ERC) and
`baseline` (t CO2-e per unit of the production variable).

## Details

\$\$B_t = EI \times ERC_t\$\$

where `ERC` is 0.951 for FY 2023-24 and falls by 0.049 a year (a linear
decline of 4.9 percent of the default intensity) to 0.657 for FY
2029-30, then by 0.03285 a year, never below zero. Facilities using
site-specific emissions intensities, and trade-exposed baseline-adjusted
facilities (see
[`cer_safeguard_teba_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_teba_facilities.md)),
have different baselines.

## References

Commonwealth of Australia. *National Greenhouse and Energy Reporting
(Safeguard Mechanism) Rule 2015* (F2015L01637), compilation of 31 August
2024: sections 31 to 33 and Schedule 1.

## See also

Other safeguard:
[`cer_safeguard_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_facilities.md),
[`cer_safeguard_industry_baselines()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_industry_baselines.md),
[`cer_safeguard_teba_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_teba_facilities.md)

## Examples

``` r
cer_safeguard_baseline_trajectory("Aluminium")
cer_safeguard_baseline_trajectory("63", from_year = 2023, to_year = 2035)
```
