# LRET accredited power stations

Power stations accredited under the Large-scale Renewable Energy Target
('LRET') and eligible to create Large-scale Generation Certificates
('LGCs').

## Usage

``` r
cer_lgc_power_stations(technology = NULL, state = NULL)
```

## Source

Clean Energy Regulator, Historical large-scale renewable energy supply
data:
<https://cer.gov.au/markets/reports-and-data/large-scale-renewable-energy-data/historical-large-scale-renewable-energy-supply-data>.
Licensed under CC BY 4.0.

## Arguments

- technology:

  Optional character vector of technology substrings (e.g. `"solar"`,
  `"wind"`, `"hydro"`, `"bioenergy"`).

- state:

  Optional character vector of Australian state codes (e.g.
  `c("VIC", "SA")`).

## Value

A `cer_tbl` with one row per accredited power station, including
accreditation date, technology, capacity (MW), and state.

## References

Commonwealth of Australia. *Renewable Energy (Electricity) Act 2000*.
Establishes the Renewable Energy Target (RET), the LGC (Large-scale
Generation Certificate) and the shortfall charge mechanism.

Clean Energy Regulator (annual). *LRET: Accreditation and eligibility
guidelines for power stations*.

Australian Energy Market Commission (2023). *Integrated System Plan
2024* reference on renewable capacity expansion.

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
s <- cer_lgc_power_stations(technology = "solar", state = "VIC")
head(s)
options(op)
# }
```
