# Safeguard default emissions intensities by production variable

The default (industry-average) emissions intensity for every production
variable in Schedule 1 of the Safeguard Mechanism Rule 2015 that has
one, read from the Rule by `data-raw/safeguard_industry_baselines.R`.
Production variables whose default is yet to be specified are omitted.

## Usage

``` r
cer_safeguard_industry_baselines()
```

## Value

A `cer_tbl` with columns `section`, `production_variable`,
`default_emissions_intensity`, `unit` (the Rule's wording) and `source`
(section and compilation date).

## See also

Other safeguard:
[`cer_safeguard_baseline_trajectory()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_baseline_trajectory.md),
[`cer_safeguard_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_facilities.md),
[`cer_safeguard_teba_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_teba_facilities.md)

## Examples

``` r
b <- cer_safeguard_industry_baselines()
b[b$production_variable %in% c("Aluminium", "Alumina"), ]
```
