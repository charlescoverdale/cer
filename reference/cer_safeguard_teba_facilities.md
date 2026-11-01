# Trade-exposed baseline-adjusted (TEBA) facility list

Returns the Clean Energy Regulator's table of trade-exposed
baseline-adjusted (TEBA) determinations, bundled by
`data-raw/safeguard_teba_facilities.R`. A TEBA determination sets a
slower decline in a facility's emissions reduction contribution (ERC)
than the default, for the financial years it covers. A facility appears
once per determination, so a revoked and replaced determination gives
two rows.

## Usage

``` r
cer_safeguard_teba_facilities()
```

## Value

A `cer_tbl` with columns `facility_name`, `responsible_emitter`,
`start_date`, `end_date` (the financial years covered), `facility_type`,
`decline_rate`, `erc_2023_24` to `erc_2026_27` (`NA` where the
determination does not apply), `status` (`"current"` or `"historical"`)
and `historical_reason`.

## References

Clean Energy Regulator. *Trade-exposed baseline-adjusted facility data*.
<https://cer.gov.au/markets/reports-and-data/safeguard-data/trade-exposed-baseline-adjusted-facility-data>

## See also

Other safeguard:
[`cer_safeguard_baseline_trajectory()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_baseline_trajectory.md),
[`cer_safeguard_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_facilities.md),
[`cer_safeguard_industry_baselines()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_industry_baselines.md)

## Examples

``` r
cer_safeguard_teba_facilities()
```
