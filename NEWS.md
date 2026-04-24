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
