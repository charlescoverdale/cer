# SRES small-scale installations by postcode

Monthly Small-scale Renewable Energy Scheme ('SRES') installation counts
or capacity by postcode. Covers rooftop solar PV, solar water heaters,
air-source heat pumps, and small batteries.

## Usage

``` r
cer_sres_installations(
  technology = c("solar_pv", "swh", "heat_pump", "battery"),
  postcode = NULL,
  measure = c("installations", "capacity")
)
```

## Source

Clean Energy Regulator, Small-scale installation postcode data:
<https://cer.gov.au/markets/reports-and-data/small-scale-installation-postcode-data>.
Licensed under CC BY 4.0.

## Arguments

- technology:

  Character. One of `"solar_pv"` (default), `"swh"` (solar water
  heater), `"heat_pump"`, or `"battery"`.

- postcode:

  Optional character vector of 4-digit Australian postcodes to filter
  on.

- measure:

  Character. `"installations"` (default, counts) or `"capacity"` (total
  kW installed).

## Value

A `cer_tbl`. For `measure = "installations"` columns include postcode
and per-month install counts. For `measure = "capacity"`, per-month kW
capacity.

## References

Commonwealth of Australia. *Renewable Energy (Electricity) Act 2000*,
Small-scale Renewable Energy Scheme provisions.

Australian Energy Market Operator (2024). *Distributed PV Forecasting
Methodology*. AEMO uses SRES installation data as input to ISP and ESOO
forecasts.

Best, R., Burke, P.J. and Nishitateno, S. (2019). "Understanding the
determinants of rooftop solar installation: evidence from household
surveys in Australia." *Australian Journal of Agricultural and Resource
Economics*, 63(4), 922-939.
[doi:10.1111/1467-8489.12319](https://doi.org/10.1111/1467-8489.12319)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
inst <- cer_sres_installations(postcode = c("2000", "3000"))
head(inst)
options(op)
# }
```
