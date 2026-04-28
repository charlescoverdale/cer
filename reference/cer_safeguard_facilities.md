# Safeguard Mechanism facility-level data

Covered emissions, baselines, Safeguard Mechanism Credits (SMCs) issued
or surrendered, and abatement information for facilities above the
100,000 tonne CO2e threshold.

## Usage

``` r
cer_safeguard_facilities(year = 2025)
```

## Source

Clean Energy Regulator, Safeguard data:
<https://cer.gov.au/markets/reports-and-data/safeguard-data>. Licensed
under CC BY 4.0.

## Arguments

- year:

  Integer. Reporting year ending 30 June (e.g. `2025` for 2024-25).
  Defaults to the most recently released year.

## Value

A `cer_tbl` with one row per facility.

## Details

Published annually by the CER on 15 April following each reporting year.
The download URL is resolved dynamically from the CER's Safeguard
landing page, so no slug changes here are required when new years
publish.

## References

Commonwealth of Australia. *National Greenhouse and Energy Reporting Act
2007*.

Commonwealth of Australia. *National Greenhouse and Energy Reporting
(Safeguard Mechanism) Rule 2015* (as amended).

Commonwealth of Australia (2023). *Safeguard Mechanism (Crediting)
Amendment Act 2023*. Introduced declining industry baselines (4.9% p.a.
nominal) and Safeguard Mechanism Credits (SMCs).

Climate Change Authority (2023). *Review of the Safeguard Mechanism*.

## See also

Other safeguard:
[`cer_safeguard_baseline_trajectory()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_baseline_trajectory.md),
[`cer_safeguard_industry_baselines()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_industry_baselines.md),
[`cer_safeguard_teba_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_teba_facilities.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
try({
  f <- cer_safeguard_facilities(year = 2025)
  head(f)
})
options(op)
# }
```
