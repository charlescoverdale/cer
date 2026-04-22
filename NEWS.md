# cer 0.1.0

Initial CRAN submission. First public release.

## New functions

### ACCU Scheme (Australian Carbon Credit Units)

* `cer_accu_projects()`: tidy project register (method, proponent,
  state, crediting period, permanence period, ACCUs issued and
  relinquished).
* `cer_accu_issuances()`: issuance history by project and method.
* `cer_accu_contracts()`: Carbon Abatement Contract register
  covering Emissions Reduction Fund auctions.
* `cer_accu_methods()`: static lookup of approved ACCU methods
  across Agriculture, Energy Efficiency, Landfill and Waste,
  Mining/Oil/Gas, and Vegetation sectors.
* `cer_accu_relinquishments()`: voluntary and compliance
  relinquishments by project.

### Safeguard Mechanism and NGER

* `cer_safeguard_facilities()`: covered emissions, baselines, and
  Safeguard Mechanism Credits (SMCs) issued or surrendered for
  facilities above the 100,000 tonne CO2e threshold.
* `cer_nger_corporate()`: corporate-level Scope 1 and 2 emissions
  from the National Greenhouse and Energy Reporting scheme.
* `cer_nger_electricity()`: facility-level emissions for
  electricity generators.

### Renewable Energy Target

* `cer_lgc_power_stations()`: accredited power stations eligible
  to create Large-scale Generation Certificates (LGCs).
* `cer_sres_installations()`: monthly rooftop solar PV, solar
  water heater, heat pump, and battery installation counts and
  capacity by postcode.

### Quarterly Carbon Market Report

* `cer_qcmr()`: aggregated certificate volumes, prices (where
  published), and abatement statistics from the CER's Quarterly
  Carbon Market Report data workbook.

### Cache management

* `cer_cache_info()`: inspect the local cache.
* `cer_clear_cache()`: clear locally cached files.

## Data source

Data is published by the Clean Energy Regulator at
<https://cer.gov.au/markets/reports-and-data> under a Creative
Commons Attribution 4.0 International licence. All downloads are
cached locally on first use to minimise repeat requests.
