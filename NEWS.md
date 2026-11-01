# cer 0.2.0

Data-correctness release. A live audit found functions returning web
pages and truncated files as data, and three bundled reference tables
whose values did not match their stated sources. Every bundled table is
now built by a script in `data-raw/` from the published source, and
records that source row by row.

## Functions that returned the wrong data

* `cer_nger_corporate()` and `cer_nger_electricity()` returned the CER
  home page parsed as a one-column data frame. The CER moved each NGER
  reporting year to its own page, so the link search found nothing, and
  the link scraper then returned the site's base URL because `paste0()`
  recycles an empty vector. The scraper now returns nothing when nothing
  matches, the NGER functions look on the per-year pages, and
  `cer_fetch_auto()` refuses any download that is an HTML page.

* The 2024-25 NGER files are Windows-1252, not UTF-8. `read.csv()` with
  `fileEncoding = "UTF-8"` stopped at the first non-UTF-8 byte with only
  a warning: `cer_nger_corporate(2025)` returned 7 of 398 rows and
  `cer_nger_electricity(2025)` 273 of 809. Downloaded CSVs are now
  decoded explicitly, falling back to Windows-1252.

* `cer_nger_corporate()` could not reach 2008-09 to 2011-12: those files
  are named without "registered-corporation". All years from 2008-09
  load; column names follow the CER's wording for each year.

* `cer_safeguard_facilities()` failed for 2016-17 to 2021-22 (the CER
  renamed those files `safeguard-facility-data-<year>`) and for 2023-24
  (`<year>-baselines-and-emissions-table`). All years from 2016-17 load.

* Quantities with thousands separators ("30,439,497") were returned as
  text, and `cer_nger_scope()` coerced them with `as.numeric()`, giving
  `NA`. Columns made up entirely of plain or comma-grouped numbers are
  now numeric; identifier-like columns (postcodes, ABNs) are untouched.

* The method-integrity layer classified nothing. The ACCU project
  register names each method by its full legal title ("Carbon Credits
  (Carbon Farming Initiative-Landfill Gas) Methodology Determination
  2015"), and `cer_accu_aggregate()` and the `chubb_flag` column of
  `cer_accu_projects()` joined it exactly against the scorecard's short
  names, which matched none of the register's 75 methods. Every project
  was "unclassified", so the contested-share warning could never fire.
  The scorecard now carries a `register_pattern` per method, which
  assigns 38 of the 75 register methods (86% of ACCUs issued); the rest
  (among them the 2015 savanna and 2021 soil carbon methods, which the
  scorecard does not cover) stay "unclassified". Contested methods
  account for 75% of all ACCUs issued.

* `cer_accu_aggregate()` summed `accus_issued` by default, a column the
  register does not have, so on `cer_accu_projects()` output it fell
  back to counting projects (with a warning) and reported shares of
  projects, not of ACCUs. It now sums `accus_total_units_issued`, and
  `cer_to_carbondata()` maps that column to `issued_credits_to_date`.

## Bundled reference tables rebuilt from their sources

* **`cer_qcmr_reference()`** did not match the Quarterly Carbon Market
  Report: it gave 161 million cumulative ACCU issuances for 2023-Q4 and
  185 million for 2024-Q4, where the QCMR data workbook gives 140.3
  million and 159.1 million. It is now read from the September quarter
  2026 workbook and covers every quarter in it: ACCU issuances and
  registrations, Safeguard ACCU and SMC surrenders, LGC validations and
  rooftop solar installations, each quarterly and cumulative. Measures
  the workbook does not publish (spot prices, active projects, covered
  emissions, SMC issuance, STC surrenders) are no longer bundled. The
  `source` column names the workbook, figure and column for every value.

* **`cer_safeguard_industry_baselines()`** listed 20 industries whose
  default intensities did not match Schedule 1 of the Safeguard Rule
  (aluminium 1.650 against the Rule's 1.94; alumina 0.800 against
  0.545; ammonia 1.600 against 1.87). It now returns all 81 production
  variables in Schedule 1 that have a default, with section number, the
  Rule's unit wording, and the compilation date. The unsourced ANZSIC
  column is dropped.

* **`cer_safeguard_baseline_trajectory()`** compounded a 4.9 per cent
  decline from a 2023-24 factor of 1. Section 31 of the Rule sets a
  linear emissions reduction contribution: 0.951 in 2023-24, falling
  by 0.049 a year to 0.657 in 2029-30, then by 0.03285 a year to zero.
  The old formula overstated the 2029-30 baseline by 13 per cent. The
  function now applies the Rule's ERC to the Schedule 1 intensity,
  accepts a production variable name or section number, and runs past
  2030.

* **`cer_safeguard_teba_facilities()`** listed 13 facilities, including
  one that closed in 2022, that did not match the CER's register. It now
  holds the CER's 24 TEBA determinations with their dates and ERCs, and
  `cer_safeguard_facilities()` flags `teba_declared` only when a
  determination covers that financial year.

# cer 0.1.0

Initial CRAN submission. First public release. Provides R access
to data published by the Australian Clean Energy Regulator, with
a post-Chubb carbon-integrity layer, Safeguard-reform regime
handling, NGER scope discipline, QCMR reconciliation, and a full
reproducibility spine.

## Data-access functions

### ACCU Scheme (Australian Carbon Credit Units)

* `cer_accu_projects()`: tidy project register (method,
  proponent, state, crediting period, permanence period, ACCUs
  issued and relinquished). Attaches a post-Chubb `chubb_flag`
  column via the bundled integrity scorecard; warns when the
  user filters on a suspended or under-review method.
* `cer_accu_issuances()`: issuance history by project and
  method.
* `cer_accu_contracts()`: Carbon Abatement Contract register
  covering Emissions Reduction Fund auctions.
* `cer_accu_methods()`: static lookup of approved ACCU methods
  across Agriculture, Energy Efficiency, Landfill and Waste,
  Mining / Oil / Gas, and Vegetation sectors.
* `cer_accu_relinquishments()`: voluntary and compliance
  relinquishments by project.

### ACCU integrity layer (post-Chubb)

* `cer_method_integrity()`: bundled 19-method scorecard with
  integrity tier (high / standard / contested), Chubb 2022
  affected flag, academic-critique references, and Federal
  Register instrument IDs.
* `cer_method_determination()`: Federal Register URL for a
  method identifier.
* `cer_accu_aggregate()`: integrity-weighted aggregation that
  breaks ACCU totals by tier; warns when the contested share
  exceeds 5 per cent of the total.

### Safeguard Mechanism and NGER

* `cer_safeguard_facilities()`: covered emissions, baselines,
  and Safeguard Mechanism Credits (SMCs) for facilities above
  the 100,000 tonne CO2e threshold. URL resolved dynamically
  from the CER Safeguard landing page so the function survives
  CER slug changes across reporting years. Carries a `regime`
  column (pre-reform vs post-reform for 1 July 2023 transition)
  and a `teba_declared` column joining the bundled
  Trade-Exposed Baseline-Adjusted facility list.
* `cer_safeguard_baseline_trajectory()`: 4.9 per cent p.a.
  declining industry-average baseline formula.
* `cer_safeguard_industry_baselines()`,
  `cer_safeguard_teba_facilities()`: bundled reference tables.
* `cer_nger_corporate()`: corporate-level Scope 1 and 2
  emissions from the National Greenhouse and Energy Reporting
  scheme.
* `cer_nger_electricity()`: facility-level emissions for
  electricity generators.
* `cer_nger_scope()`: explicit Scope 1 / Scope 2 market /
  Scope 2 location selector with clear error when the
  requested column is absent.
* `cer_nger_climate_active()`: column renaming to a Climate
  Active carbon-neutral inventory template.

### Renewable Energy Target

* `cer_lgc_power_stations()`: accredited power stations
  eligible to create Large-scale Generation Certificates
  (LGCs).
* `cer_sres_installations()`: monthly rooftop solar PV, solar
  water heater, heat pump, and battery installation counts
  and capacity by postcode.

### Quarterly Carbon Market Report

* `cer_qcmr()`: aggregated certificate volumes, prices (where
  published), and abatement statistics from the CER's
  Quarterly Carbon Market Report data workbook.
* `cer_qcmr_reference()`, `cer_reconcile()`: diff live-fetched
  aggregates against QCMR headline totals; warns on gaps above
  2 per cent.

## Reproducibility spine

* `cer_snapshot()`: pin a session snapshot date, recorded in
  every `cer_tbl` provenance header, manifest entry, and
  citation.
* `cer_sha256()` + sidecar integrity verification: every
  cached file is hashed at first download and verified on
  cache hit. Drift emits a warning (critical because CER
  restates retroactively).
* `cer_manifest()`, `cer_manifest_clear()`,
  `cer_manifest_write()`: session registry of every fetch
  (URL, SHA-256, snapshot pin, R and cer versions). Output as
  data frame, YAML, JSON, or CSV for paper appendices.
* `cer_deposit_zenodo()`: stage or submit a Zenodo deposit for
  a DOI on a data vintage. Dry run by default; call with
  `upload = TRUE` and a `ZENODO_TOKEN` to mint a DOI.
* `cer_cite()`: text / APA / BibTeX citation with snapshot,
  SHA-256 digest, and optional DOI fields.

## Legislative citation layer

* `cer_legislative_instrument()`: Federal Register URL
  resolver.
* `@references` section on every exported function citing
  governing Acts (Carbon Farming Initiative Act 2011, NGER
  Act 2007, Renewable Energy (Electricity) Act 2000,
  Safeguard Mechanism (Crediting) Amendment Act 2023), the
  Chubb Review (2022), Macintosh et al. (2022), and Climate
  Change Authority reviews.
* `inst/CITATION` with bibentries for the Chubb Review,
  Macintosh et al., and the `carbondata` companion package.

## International comparator

* `cer_to_carbondata()`: remap ACCU projects to the
  `carbondata` Verra / Gold Standard voluntary-project schema
  for cross-market comparison.
* `cer_international_comparator()`: bundled indicative ACCU vs
  EU ETS / NZ ETS / WCI / Verra / Gold Standard reference.

## Cache management

* `cer_cache_info()`: inspect the local cache.
* `cer_clear_cache()`: clear locally cached files.

## Vignettes

* `offsets-integrity-primer`: Chubb Review context and
  integrity-weighted aggregation.
* `safeguard-reform`: pre- vs post-2023 regime handling.
* `nger-scope-reconciliation`: Scope 1 / 2 discipline.
* `ret-compliance-primer`: LGC / SRES primer.
* `methodology`: hand-computed worked examples.

## Data source

Data is published by the Clean Energy Regulator at
<https://cer.gov.au/markets/reports-and-data> under a Creative
Commons Attribution 4.0 International licence. All downloads
are cached locally on first use with SHA-256 integrity
verification.
