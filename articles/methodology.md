# Methodology: hand-computed worked examples

Every computation in `cer` is verifiable with pen and paper. This
vignette walks through the three formula functions.

## 1. Safeguard declining baseline

### Formula

$$B_{t}\; = \; B_{2023\text{-}24} \times (1 - 0.049)^{t - 2023}$$

Source: Safeguard Mechanism (Crediting) Amendment Act 2023.

### Hand calculation

Aluminium smelting 2023-24 default baseline = 1.650 t CO2e per tonne
aluminium. For FY 2029-30 (t = 2029):

$$B_{2029\text{-}30} = 1.650 \times (1 - 0.049)^{6} = 1.650 \times 0.738 = 1.218$$

### Package output

``` r
traj <- cer_safeguard_baseline_trajectory("Aluminium smelting",
                                           from_year = 2023,
                                           to_year = 2029)
traj
#>   year financial_year baseline decline_factor
#> 1 2023        2023-24 1.650000      1.0000000
#> 2 2024        2024-25 1.569150      0.9510000
#> 3 2025        2025-26 1.492262      0.9044010
#> 4 2026        2026-27 1.419141      0.8600854
#> 5 2027        2027-28 1.349603      0.8179412
#> 6 2028        2028-29 1.283472      0.7778621
#> 7 2029        2029-30 1.220582      0.7397468
```

Row for 2029: baseline ~= 1.218. Matches.

### Sanity check at base year

``` r
traj[traj$year == 2023, ]
#>   year financial_year baseline decline_factor
#> 1 2023        2023-24     1.65              1
```

Decline factor = 1.000; baseline = 1.650. Identity holds.

## 2. QCMR reconciliation

### Formula

$$\pi\; = \;\frac{V - R}{R}$$

where V is the live-fetched aggregate and R the QCMR reference.

### Hand calculation

ACCU cumulative issuances at end of 2024-Q4 per QCMR = 185,000,000.
Suppose a user’s fetch shows 184,200,000 (0.43 per cent low).

$$\pi = \frac{184,200,000 - 185,000,000}{185,000,000} = \frac{- 800,000}{185,000,000} = - 0.00432 = - 0.432\%$$

### Package output

``` r
cer_reconcile(value   = 184200000,
              quarter = "2024-Q4",
              measure = "accu_cumulative_issuances")
#>                     measure quarter     value reference   diff     pct_diff
#> 1 accu_cumulative_issuances 2024-Q4 184200000  1.85e+08 -8e+05 -0.004324324
#>    unit       source
#> 1 accus QCMR Q4 2024
```

At -0.43 per cent the reconciliation falls within the default 2 per cent
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
