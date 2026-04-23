# cer

[![CRAN status](https://www.r-pkg.org/badges/version/cer)](https://CRAN.R-project.org/package=cer) [![CRAN downloads](https://cranlogs.r-pkg.org/badges/cer)](https://cran.r-project.org/package=cer) [![Total Downloads](https://cranlogs.r-pkg.org/badges/grand-total/cer)](https://CRAN.R-project.org/package=cer) [![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

An R package for accessing data published by the [Clean Energy Regulator](https://cer.gov.au). Carbon credits, safeguard mechanism emissions, renewable energy certificates, and greenhouse gas reporting.

## What is the Clean Energy Regulator?

The Clean Energy Regulator (CER) is the Australian Government agency responsible for administering the country's main climate and clean energy schemes. It sits at the intersection of four policy instruments that together cover roughly half of Australia's emissions and all of its large-scale renewable generation.

The scale is substantial. The **Australian Carbon Credit Unit (ACCU) Scheme** has issued around 185 million credits since 2012 (Carbon Farming Initiative Act 2011, first issuances 2012-13), each representing one tonne of CO2-equivalent avoided or sequestered. The **Safeguard Mechanism** was reformed in July 2023 and now requires every facility above 100,000 tonnes of CO2e a year to reduce emissions on a declining baseline that falls at 4.9% per year to 2030: the 2024-25 compliance year covered 208 facilities and roughly 30% of national emissions, with an aggregate cumulative budget of 1,233 Mt over 2020 to 2030. The **Large-scale Renewable Energy Target (LRET)** and **Small-scale Renewable Energy Scheme (SRES)** have unlocked more than AUD 20 billion in renewables investment since 2001 (Climate Change Authority estimate). And the **National Greenhouse and Energy Reporting (NGER) scheme** compiles emissions for every corporation above 50 kt CO2e (Scope 1+2) or 200 TJ energy, plus every facility above 25 kt or 100 TJ.

Facilities below their Safeguard baseline can be issued **Safeguard Mechanism Credits (SMCs)** that are freely bankable to 2030 and tradeable with other covered facilities; facilities above their baseline must surrender ACCUs or SMCs to return to compliance. In 2024-25 the CER issued 6.7 million SMCs to 54 facilities and recorded 13.4 million units surrendered (ACCUs plus SMCs combined), achieving 98.6% compliance.

The CER publishes data from all four schemes under a Creative Commons Attribution 4.0 licence. That data is the authoritative public record of Australia's carbon and renewables markets, and it is watched closely by policy analysts, investigative journalists, project developers, and compliance teams at every Safeguard-covered facility. The Chubb Review (January 2023) found the scheme "essentially sound" but triggered three governance changes that continue to shape the market: the Emissions Reduction Assurance Committee (ERAC) was abolished in favour of the **Carbon Abatement Integrity Committee (CAIC)**; the **Avoided Deforestation method** was suspended for new projects; and the **Human-Induced Regeneration (HIR) method** is under review, with the proposed **Integrated Farm and Land Management (IFLM) method** delivered to CAIC at end-2025. The **Climate Change Authority's 2026 ACCU Scheme Review** (public consultation open at time of writing) is likely to reshape the method supply from 2027.

## Why does this package exist?

The CER's data is scattered across half a dozen landing pages, published as XLSX or CSV, with URLs that get overwritten in place when new releases drop. There is no API. The REC Registry sits behind a session cookie wall. NGER schema drifts year to year as reporting categories evolve. Facility-level Scope 1 and 2 emissions are only published for the electricity sector, while other sectors report at controlling-corporation level: a detail you have to know before you build a join.

Getting any of this into R required knowing the right landing page, spotting the current year's `/document/<slug>` link, downloading the XLSX or CSV, navigating heterogeneous header rows, and cleaning column names one release at a time. You did it every quarter.

```r
# Without this package
landing <- "https://cer.gov.au/markets/reports-and-data/safeguard-data"
html    <- rvest::read_html(landing)
hrefs   <- rvest::html_attr(rvest::html_elements(html, "a"), "href")
slug    <- grep("2024-25.*safeguard", hrefs, value = TRUE)[1]
url     <- paste0("https://cer.gov.au", slug)
path    <- tempfile(fileext = ".xlsx")
download.file(url, path)
raw     <- readxl::read_excel(path, sheet = 1)
# ... rename columns, strip punctuation, parse emissions figures, ...

# With this package
library(cer)
cer_safeguard_facilities(year = 2025)
```

Download URLs are resolved at runtime by scraping the CER landing pages, so the package doesn't break when the CER reposts a file with a new `/document/<slug>` suffix. Column names are cleaned to snake_case on ingestion. Data frames carry provenance (source URL, retrieval date, licence) in a lightweight `cer_tbl` S3 class. Results are cached locally so subsequent calls are instant.

## How does cer fit with carbondata?

The [`carbondata`](https://github.com/charlescoverdale/carbondata) package covers global carbon markets: EU ETS, UK ETS, RGGI, California, plus voluntary registries (Verra, Gold Standard, ACR, CAR via Berkeley VROD and CarbonPlan OffsetsDB). It deliberately excludes ACCUs and the Safeguard Mechanism because those require CER-specific scraping logic that doesn't generalise.

`cer` is the Australian-specific companion. It handles ACCUs, Safeguard, LRET, SRES, NGER, and the Quarterly Carbon Market Report. Together they give you the full global carbon markets picture with Australian granularity, using the same `*_cache_info()` / `*_clear_cache()` idioms and the same provenance-aware print methods.

| Package | Covers |
|---|---|
| **carbondata** | Global ETS (EU, UK, RGGI, California) + voluntary (Verra, Gold Standard, ACR, CAR) |
| **cer** | Australian carbon: ACCUs, Safeguard, NGER, LRET, SRES, QCMR |

## Installation

```r
install.packages("cer")

# Or install the development version from GitHub
# install.packages("devtools")
devtools::install_github("charlescoverdale/cer")
```

## Quick start

```r
library(cer)

# Current ACCU project register (issuances, methods, proponents, relinquishments)
projects <- cer_accu_projects()
head(projects)

# Safeguard Mechanism 2024-25 facility emissions and baselines
facilities <- cer_safeguard_facilities(year = 2025)
sum(facilities$covered_emissions, na.rm = TRUE)

# Rooftop solar installations by postcode
solar <- cer_sres_installations(
  technology = "solar_pv",
  postcode   = c("2000", "3000", "4000")
)
```

## Functions

| Function | Description | Coverage |
|---|---|---|
| `cer_accu_projects()` | ACCU project register with method, proponent, state, crediting period, ACCUs issued and relinquished | 2012 - present |
| `cer_accu_issuances()` | Per-project issuance summary with optional method and date filters | 2012 - present |
| `cer_accu_contracts()` | Carbon Abatement Contract register (Emissions Reduction Fund auctions) | 2015 - present |
| `cer_accu_methods()` | Static lookup of approved ACCU methods across Agriculture, Energy Efficiency, Landfill and Waste, Mining, Oil and Gas, Vegetation, Savanna, Blue Carbon | Live + flagged superseded |
| `cer_accu_relinquishments()` | Projects with non-zero ACCU relinquishments (voluntary plus compliance) | 2012 - present |
| `cer_safeguard_facilities()` | Covered emissions, baselines, SMCs issued or surrendered for facilities above 100,000 t CO2e | 2016-17 - present |
| `cer_nger_corporate()` | Controlling-corporation Scope 1 and 2 emissions above the 50 kt / 200 TJ reporting threshold | 2008-09 - present |
| `cer_nger_electricity()` | Facility-level Scope 1 emissions and generation for electricity sector above the 25 kt / 100 TJ facility threshold | 2008-09 - present |
| `cer_lgc_power_stations()` | Accredited LRET power stations (technology, state, capacity, commissioning) | 2001 - present |
| `cer_sres_installations()` | Monthly rooftop solar PV, solar water heater, heat pump, and battery installations by postcode | 2011 - present |
| `cer_qcmr()` | Quarterly Carbon Market Report data workbook (certificate volumes, unit surrenders, Safeguard developments) | 2014 Q3 - present |
| `cer_cache_info()` | Inspect the local cache | - |
| `cer_clear_cache()` | Clear locally cached files | - |

## Examples

### ACCU issuances by method

```r
library(cer)

# All active projects
p <- cer_accu_projects(status = "active")

# Savanna fire management projects in the Northern Territory
p_savanna <- cer_accu_projects(state = "NT", method = "savanna")
head(p_savanna[, c("project_name", "method", "accus_issued")])

# Share of ACCUs by method
by_method <- aggregate(accus_issued ~ method, data = p,
                        FUN = sum, na.rm = TRUE)
by_method <- by_method[order(-by_method$accus_issued), ]
head(by_method, 10)
```

### Safeguard Mechanism covered emissions

```r
# Facility-level covered emissions for 2024-25
s <- cer_safeguard_facilities(year = 2025)

# Total covered emissions (Mt CO2e)
sum(s$covered_emissions, na.rm = TRUE) / 1e6

# Ten largest Safeguard facilities
top10 <- s[order(-s$covered_emissions), c("facility_name", "covered_emissions")]
head(top10, 10)
```

### Rooftop solar trends by state

```r
library(cer)

inst <- cer_sres_installations(technology = "solar_pv",
                                measure = "installations")

# Aggregate to state by year (schema varies: inspect names(inst) first)
head(inst)
```

### Quarterly Carbon Market Report

```r
# Table of contents for the latest QCMR data workbook
toc <- cer_qcmr("latest")
head(toc)

# Fetch a specific figure
fig <- cer_qcmr("latest", sheet = "Figure 1.1")
```

## Data source and licence

All data is published by the Clean Energy Regulator at <https://cer.gov.au/markets/reports-and-data> under a Creative Commons Attribution 4.0 International licence. Downloads are cached locally to `tools::R_user_dir("cer", "cache")` and re-used on subsequent calls.

The CER specifies two forms of attribution depending on what you do with the data:

- **Verbatim use:** *Licensed from the Clean Energy Regulator, Commonwealth of Australia under a Creative Commons Attribution 4.0 licence.*
- **Derivative or adapted data** (the usual case when you clean, join, filter, or reshape): *Based on Clean Energy Regulator material licensed under a Creative Commons Attribution 4.0 licence.*

The package returns cleaned snake_case tables so most use falls under the second form.

## Known limitations

- **No facility-level Scope 1 and 2 across all sectors.** NGER publishes facility-level data only for electricity generators. Every other sector reports at controlling-corporation level. Use `cer_nger_corporate()` for those.
- **REC Registry isn't scraped.** The transactional registry (<https://rec-registry.gov.au>) has session cookies and CAPTCHAs on some views. `cer` uses the CER's published historical extracts of the same data instead.
- **Files overwrite in place.** The CER has no versioned URL history. If a release is silently corrected, the cached file diverges from the live one until you run `cer_clear_cache()`.
- **LGC and STC spot prices aren't in this package.** The CER does not publish spot prices. The `cer_qcmr()` function returns the volume-weighted quarterly averages that the CER does publish, but tick-level price history sits with private exchanges.
- **ACCU methods are embedded.** Each ACCU method is published as a PDF determination on the Federal Register of Legislation. `cer_accu_methods()` returns a curated table embedded in the package. The current table includes the Savanna Fire Management 2026 methods, the Environmental Plantings 2024 FullCAM method (replacing the 2014 method, which expired 30 September 2024), and flags Avoided Deforestation as suspended for new projects post-Chubb. The Human-Induced Regeneration method is flagged as under review pending the IFLM replacement.

## Related packages

| Package | Description |
|---|---|
| [`carbondata`](https://github.com/charlescoverdale/carbondata) | Global carbon markets (EU ETS, UK ETS, RGGI, California, Verra, Gold Standard, ACR, CAR) |
| [`aemo`](https://github.com/charlescoverdale/aemo) | Australian Energy Market Operator (NEM prices, demand, dispatch, FCAS, gas) |
| [`climatekit`](https://github.com/charlescoverdale/climatekit) | 35 climate indices (temperature, precipitation, drought) |
| [`readnoaa`](https://github.com/charlescoverdale/readnoaa) | NOAA climate and weather data |
| [`readaec`](https://github.com/charlescoverdale/readaec) | Australian Electoral Commission |
| [`readabs`](https://github.com/mattcowgill/readabs) | Australian Bureau of Statistics |
| [`readrba`](https://github.com/mattcowgill/readrba) | Reserve Bank of Australia |

## Citation

```r
citation("cer")
```
