# cer <img src="man/figures/logo.png" align="right" height="120" alt="" />

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/cer)](https://CRAN.R-project.org/package=cer)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/cer)](https://cran.r-project.org/package=cer)
[![R-CMD-check](https://github.com/charlescoverdale/cer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/charlescoverdale/cer/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Tidy R access to data published by the Australian Clean Energy
Regulator: Australian Carbon Credit Units, Safeguard Mechanism
facilities, renewable energy certificates, and National
Greenhouse and Energy Reporting emissions.

## Installation

``` r
install.packages("cer")

# Development version:
# install.packages("pak")
pak::pak("charlescoverdale/cer")
```

## Quick start

``` r
library(cer)

# Current ACCU project register (one row per project, method,
# proponent, state, crediting period, ACCUs issued, ACCUs
# relinquished)
projects <- cer_accu_projects()
head(projects)

# Safeguard Mechanism facilities (2024-25 reporting year)
facilities <- cer_safeguard_facilities(year = 2025)
sum(facilities$covered_emissions_t_co2e)

# Rooftop solar installations by postcode
solar <- cer_sres_installations(
  technology = "solar_pv",
  postcode   = c("2000", "3000", "4000")
)
```

## What's included

| Family | Functions | Data source |
|---|---|---|
| ACCU Scheme | `cer_accu_projects()`, `cer_accu_issuances()`, `cer_accu_contracts()`, `cer_accu_methods()`, `cer_accu_relinquishments()` | ACCU project and contract register |
| Safeguard and NGER | `cer_safeguard_facilities()`, `cer_nger_corporate()`, `cer_nger_electricity()` | Safeguard and NGER s.24 registers |
| Renewable Energy Target | `cer_lgc_power_stations()`, `cer_sres_installations()` | Historical large-scale renewables, SRES postcode data |
| Quarterly Carbon Market Report | `cer_qcmr()` | QCMR data workbook |
| Cache | `cer_cache_info()`, `cer_clear_cache()` | — |

## Data source and licence

All data is published by the Clean Energy Regulator at
<https://cer.gov.au/markets/reports-and-data> under a Creative
Commons Attribution 4.0 International licence. This package
fetches files on first use and caches them to
`tools::R_user_dir("cer", "cache")`.

Attribution on derivative work: *"Licensed from the Clean Energy
Regulator, Commonwealth of Australia under a Creative Commons
Attribution 4.0 licence."*

## Known limitations

* The REC Registry (<https://rec-registry.gov.au>) is a
  transactional interface; `cer` uses the CER's published
  historical extracts rather than scraping the registry UI.
* NGER facility-level Scope 1 and 2 data is only published for
  the electricity sector. Other sectors report at
  controlling-corporation level.
* CER retroactively updates published tables when NGER revisions
  are received. Cache uses `last-modified` headers; run
  `cer_clear_cache()` to force a refresh.

## Related packages

* [`carbondata`](https://github.com/charlescoverdale/carbondata):
  global carbon markets (EU ETS, UK ETS, RGGI, California,
  Verra, Gold Standard, ACR, CAR)
* [`climatekit`](https://github.com/charlescoverdale/climatekit):
  climate and weather indices (SPI, SPEI, Huglin, Winkler)
* [`readnoaa`](https://github.com/charlescoverdale/readnoaa):
  NOAA weather station data

## Citation

``` r
citation("cer")
```

## Code of Conduct

Please note that the cer project is released with a [Contributor
Code of Conduct](https://contributor-covenant.org/version/2/1/).
By contributing to this project, you agree to abide by its terms.
