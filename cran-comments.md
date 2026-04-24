# CRAN submission comments: cer 0.1.0

## New submission

First public release. Provides R access to data published by
the Australian Clean Energy Regulator (CER).

### Scope

* ACCU Scheme (Australian Carbon Credit Units): project
  register, issuances, Carbon Abatement Contract auctions,
  methods, relinquishments.
* ACCU integrity layer (post-Chubb): 19-method integrity
  scorecard, integrity-weighted aggregation with contested-
  share warning, Federal Register determination URLs.
* Safeguard Mechanism facility-level data: covered emissions,
  baselines, Safeguard Mechanism Credits (SMCs), pre- /
  post-reform regime flag, Trade-Exposed Baseline-Adjusted
  (TEBA) facility list, 4.9 per cent declining baseline
  trajectory.
* NGER (National Greenhouse and Energy Reporting): corporate
  Scope 1 and 2, electricity sector Scope 1 facilities,
  explicit scope selector, Climate Active template
  compatibility.
* Renewable Energy Target: Large-scale power station
  accreditations, Small-scale PV / solar water heater / heat
  pump / battery installations by postcode.
* Quarterly Carbon Market Report aggregates with
  reconciliation against live data.
* Reproducibility spine: snapshot pinning, SHA-256 cache
  integrity (critical because CER restates retroactively),
  session manifest, optional Zenodo deposit, cite helper.
* International comparator: remap ACCUs to the carbondata
  Verra / Gold Standard schema plus bundled indicative
  reference table (ACCU vs EU ETS / NZ ETS / WCI / Verra /
  Gold Standard).
* Legislative citation layer: Federal Register URL resolver
  and `@references` citing Carbon Farming Initiative Act
  2011, NGER Act 2007, Renewable Energy (Electricity) Act
  2000, Safeguard Mechanism (Crediting) Amendment Act 2023,
  Chubb (2022), Macintosh et al. (2022), Climate Change
  Authority reviews.

## R CMD check results

0 errors | 0 warnings | 0 notes on Mac ARM64, R 4.5.2.

## Test suite

Network-dependent tests are wrapped in `skip_on_cran()` and
`skip_if_offline()`. A `CER_LIVE_TESTS` environment variable
controls whether optional live-fetch tests run.

## Notes on data access

* All data sources are public and free. No authentication.
* Downloaded data is cached to `tools::R_user_dir("cer", "cache")`
  on first use.
* `\donttest` examples redirect the cache to `tempdir()` via
  `options(cer.cache_dir = ...)` so no files are written to
  the user's home filespace.
* Data is published by the Clean Energy Regulator under
  Creative Commons Attribution 4.0 International.
* CER publishes annual datasets with slug conventions that
  change between reporting years.
  `cer_safeguard_facilities()` and the NGER helpers resolve
  the per-year download URL by scraping the CER landing page
  rather than hard-coding the slug, so they survive CER URL
  changes without a package update.
* SHA-256 sidecar verification on cache hits surfaces
  retroactive data restatements.

## Downstream dependencies

None.
