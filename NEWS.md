# cer 0.2.0

Carbon-integrity upgrade. Eight phases of the academic-audit
improvement plan addressing the post-Chubb ACCU integrity gap,
the Safeguard 2023 regime break, NGER scope discipline, and
reproducibility for retroactively-revised data.

## Reproducibility spine
* `cer_snapshot()`, `cer_manifest()`, `cer_manifest_clear()`,
  `cer_manifest_write()`: session-level snapshot pin and manifest
  registry capturing URL + SHA-256 + CKAN-equivalent metadata.
* `cer_sha256()` + sidecar integrity verification: every cached
  file hashed at first download, verified on cache hit, drift
  emits a warning (matters because CER restates retroactively).
* `cer_deposit_zenodo()`: stage or submit a Zenodo deposit for DOI
  minting of a data vintage.
* `cer_cite()` (new): text / APA / BibTeX citation with snapshot,
  SHA-256, and optional DOI fields.

## ACCU integrity layer (post-Chubb)
* `cer_method_integrity()`: bundled 19-method scorecard with
  integrity tier (high / standard / contested), Chubb 2022
  affected flag, academic-critique references, and Federal
  Register instrument IDs.
* `cer_method_determination()`: Federal Register URL for a
  method identifier.
* `cer_accu_aggregate()`: integrity-weighted aggregation that
  breaks ACCU totals by tier; warns when contested share exceeds
  5 per cent of the total.
* `chubb_flag` column added to `cer_accu_projects()` output.
* Warning emitted when user filters on a suspended or under-review
  method.

## Safeguard reform handling (1 July 2023)
* `regime` column (`pre_reform` vs `post_reform`) on every
  `cer_safeguard_facilities()` record.
* `teba_declared` column joining the bundled Trade-Exposed
  Baseline-Adjusted facility list.
* `cer_safeguard_baseline_trajectory()`: 4.9 per cent p.a.
  declining industry-average baseline formula.
* `cer_safeguard_industry_baselines()`, `cer_safeguard_teba_facilities()`:
  bundled reference tables.

## NGER scope discipline
* `cer_nger_scope()`: explicit Scope 1 / Scope 2 market /
  Scope 2 location selector with error when the requested
  column is absent.
* `cer_nger_climate_active()`: column renaming to a Climate
  Active carbon-neutral inventory template.

## QCMR reconciliation
* `cer_qcmr_reference()`, `cer_reconcile()`: diff live-fetched
  aggregates against Quarterly Carbon Market Report headline
  totals; warns on gaps above 2 per cent.

## Legislative citation layer
* `cer_legislative_instrument()`: Federal Register URL resolver.
* `@references` added to every exported function citing governing
  Acts (Carbon Farming Initiative Act 2011, NGER Act 2007,
  Renewable Energy (Electricity) Act 2000, Safeguard Mechanism
  (Crediting) Amendment Act 2023), Chubb (2022) Independent Review,
  Macintosh et al. (2022) ANU critique, Climate Change Authority
  reviews.
* `inst/CITATION` enriched with bibentries for Chubb Review,
  Macintosh et al., and the carbondata companion package.

## International comparator
* `cer_to_carbondata()`: remap ACCU projects to the carbondata
  Verra / Gold Standard voluntary-project schema for cross-market
  comparison.
* `cer_international_comparator()`: bundled indicative ACCU vs
  EU ETS / NZ ETS / WCI / Verra / Gold Standard reference.

## Vignettes (five new)
* offsets-integrity-primer
* safeguard-reform
* nger-scope-reconciliation
* ret-compliance-primer
* methodology (hand-computed worked examples)

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
