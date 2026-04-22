# CRAN submission comments — cer 0.1.0

## New submission

This is a new package providing R access to data published by the
Australian Clean Energy Regulator ('CER'). Coverage includes:

* Australian Carbon Credit Unit ('ACCU') Scheme project register,
  issuances, contracts, methods, and relinquishments
* Safeguard Mechanism facility-level covered emissions and
  baselines
* National Greenhouse and Energy Reporting ('NGER') scheme
  corporate and electricity facility emissions
* Large-scale Renewable Energy Target ('LRET') power station
  accreditations
* Small-scale Renewable Energy Scheme ('SRES') postcode
  installation data
* Quarterly Carbon Market Report aggregates

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test suite

Network-dependent tests are wrapped in `skip_on_cran()` and
`skip_if_offline()`. A `CER_LIVE_TESTS` environment variable
controls whether optional live-fetch tests run.

## Notes on data access

* All data sources are public and free.
* No authentication required.
* Downloaded data is cached to `tools::R_user_dir("cer", "cache")`
  on first use.
* `\donttest` examples redirect the cache to `tempdir()` via
  `options(cer.cache_dir = ...)` so no files are written to the
  user's home filespace.
* Data is published under a Creative Commons Attribution 4.0
  International licence.

## Downstream dependencies

None.
