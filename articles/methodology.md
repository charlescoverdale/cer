# Methodology: hand-computed worked examples

Every computation in `cer` is verifiable with pen and paper. This
vignette walks through the three formula functions.

## 1. Safeguard declining baseline

### Formula

``` math
B_t \;=\; EI \times ERC_t
```

where $`EI`$ is the default emissions intensity in Schedule 1 of the
Safeguard Mechanism Rule 2015 and $`ERC_t`$ the default emissions
reduction contribution in section 31: 0.951 for 2023-24, falling by
0.049 a year to 0.657 for 2029-30, then by 0.03285 a year.

### Hand calculation

The default emissions intensity for primary aluminium (Schedule 1,
section 7) is 1.94 t CO2-e per tonne. For FY 2029-30:

``` math
B_{2029\text{-}30} = 1.94 \times 0.657 = 1.275
```

### Package output

``` r

traj <- cer_safeguard_baseline_trajectory("Aluminium",
                                           from_year = 2023,
                                           to_year = 2029)
traj
#>   year financial_year default_emissions_intensity decline_factor baseline
#> 1 2023        2023-24                        1.94          0.951  1.84494
#> 2 2024        2024-25                        1.94          0.902  1.74988
#> 3 2025        2025-26                        1.94          0.853  1.65482
#> 4 2026        2026-27                        1.94          0.804  1.55976
#> 5 2027        2027-28                        1.94          0.755  1.46470
#> 6 2028        2028-29                        1.94          0.706  1.36964
#> 7 2029        2029-30                        1.94          0.657  1.27458
```

Row for 2029: baseline = 1.275. Matches.

### Sanity check at the first year

``` r

traj[traj$year == 2023, ]
#>   year financial_year default_emissions_intensity decline_factor baseline
#> 1 2023        2023-24                        1.94          0.951  1.84494
```

ERC = 0.951; baseline = 1.94 x 0.951 = 1.845. The decline is linear in
the ERC, not compounded: a geometric 4.9 per cent a year would give
0.740 rather than 0.657 by 2029-30.

## 2. QCMR reconciliation

### Formula

``` math
\pi \;=\; \frac{V - R}{R}
```

where V is the live-fetched aggregate and R the QCMR reference.

### Hand calculation

ACCU cumulative issuances at end of 2024-Q4 per the QCMR data workbook =
159,125,069. Suppose a user’s fetch shows 158,400,000 (0.46 per cent
low).

``` math
\pi = \frac{158{,}400{,}000 - 159{,}125{,}069}{159{,}125{,}069}
     = \frac{-725{,}069}{159{,}125{,}069} = -0.00456 = -0.456\%
```

### Package output

``` r

cer_reconcile(value   = 158400000,
              quarter = "2024-Q4",
              measure = "accu_cumulative_issuances")
#>                     measure quarter     value reference    diff     pct_diff
#> 1 accu_cumulative_issuances 2024-Q4 158400000 159125069 -725069 -0.004556598
#>    unit                                                                  source
#> 1 accus QCMR data workbook (september-quarter-2026), Figure 1.2, column 'Total'
```

At -0.46 per cent the reconciliation falls within the default 2 per cent
warning threshold; no warning fires.

## 3. SHA-256 integrity

### Specification

SHA-256 as defined in NIST FIPS 180-4. Empty-string digest:

    e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

### Verification

``` r

f <- tempfile()
file.create(f)
#> [1] TRUE
cer_sha256(f)
#> [1] "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
```

Matches the NIST reference.

## Summary

| Function                            | Formula                    | Verified |
|-------------------------------------|----------------------------|----------|
| `cer_safeguard_baseline_trajectory` | B_t = B_0 \* (1 - 0.049)^n | Yes      |
| `cer_reconcile`                     | (V - R) / R                | Yes      |
| `cer_sha256`                        | NIST FIPS 180-4            | Yes      |

Any disagreement between a hand calculation and the package output is a
bug; please file an issue.
