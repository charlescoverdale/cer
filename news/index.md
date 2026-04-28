# Changelog

## cer 0.1.0

CRAN release: 2026-04-28

Initial CRAN submission. First public release. Provides R access to data
published by the Australian Clean Energy Regulator, with a post-Chubb
carbon-integrity layer, Safeguard-reform regime handling, NGER scope
discipline, QCMR reconciliation, and a full reproducibility spine.

### Data-access functions

#### ACCU Scheme (Australian Carbon Credit Units)

- [`cer_accu_projects()`](https://charlescoverdale.github.io/cer/reference/cer_accu_projects.md):
  tidy project register (method, proponent, state, crediting period,
  permanence period, ACCUs issued and relinquished). Attaches a
  post-Chubb `chubb_flag` column via the bundled integrity scorecard;
  warns when the user filters on a suspended or under-review method.
- [`cer_accu_issuances()`](https://charlescoverdale.github.io/cer/reference/cer_accu_issuances.md):
  issuance history by project and method.
- [`cer_accu_contracts()`](https://charlescoverdale.github.io/cer/reference/cer_accu_contracts.md):
  Carbon Abatement Contract register covering Emissions Reduction Fund
  auctions.
- [`cer_accu_methods()`](https://charlescoverdale.github.io/cer/reference/cer_accu_methods.md):
  static lookup of approved ACCU methods across Agriculture, Energy
  Efficiency, Landfill and Waste, Mining / Oil / Gas, and Vegetation
  sectors.
- [`cer_accu_relinquishments()`](https://charlescoverdale.github.io/cer/reference/cer_accu_relinquishments.md):
  voluntary and compliance relinquishments by project.

#### ACCU integrity layer (post-Chubb)

- [`cer_method_integrity()`](https://charlescoverdale.github.io/cer/reference/cer_method_integrity.md):
  bundled 19-method scorecard with integrity tier (high / standard /
  contested), Chubb 2022 affected flag, academic-critique references,
  and Federal Register instrument IDs.
- [`cer_method_determination()`](https://charlescoverdale.github.io/cer/reference/cer_method_determination.md):
  Federal Register URL for a method identifier.
- [`cer_accu_aggregate()`](https://charlescoverdale.github.io/cer/reference/cer_accu_aggregate.md):
  integrity-weighted aggregation that breaks ACCU totals by tier; warns
  when the contested share exceeds 5 per cent of the total.

#### Safeguard Mechanism and NGER

- [`cer_safeguard_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_facilities.md):
  covered emissions, baselines, and Safeguard Mechanism Credits (SMCs)
  for facilities above the 100,000 tonne CO2e threshold. URL resolved
  dynamically from the CER Safeguard landing page so the function
  survives CER slug changes across reporting years. Carries a `regime`
  column (pre-reform vs post-reform for 1 July 2023 transition) and a
  `teba_declared` column joining the bundled Trade-Exposed
  Baseline-Adjusted facility list.
- [`cer_safeguard_baseline_trajectory()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_baseline_trajectory.md):
  4.9 per cent p.a. declining industry-average baseline formula.
- [`cer_safeguard_industry_baselines()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_industry_baselines.md),
  [`cer_safeguard_teba_facilities()`](https://charlescoverdale.github.io/cer/reference/cer_safeguard_teba_facilities.md):
  bundled reference tables.
- [`cer_nger_corporate()`](https://charlescoverdale.github.io/cer/reference/cer_nger_corporate.md):
  corporate-level Scope 1 and 2 emissions from the National Greenhouse
  and Energy Reporting scheme.
- [`cer_nger_electricity()`](https://charlescoverdale.github.io/cer/reference/cer_nger_electricity.md):
  facility-level emissions for electricity generators.
- [`cer_nger_scope()`](https://charlescoverdale.github.io/cer/reference/cer_nger_scope.md):
  explicit Scope 1 / Scope 2 market / Scope 2 location selector with
  clear error when the requested column is absent.
- [`cer_nger_climate_active()`](https://charlescoverdale.github.io/cer/reference/cer_nger_climate_active.md):
  column renaming to a Climate Active carbon-neutral inventory template.

#### Renewable Energy Target

- [`cer_lgc_power_stations()`](https://charlescoverdale.github.io/cer/reference/cer_lgc_power_stations.md):
  accredited power stations eligible to create Large-scale Generation
  Certificates (LGCs).
- [`cer_sres_installations()`](https://charlescoverdale.github.io/cer/reference/cer_sres_installations.md):
  monthly rooftop solar PV, solar water heater, heat pump, and battery
  installation counts and capacity by postcode.

#### Quarterly Carbon Market Report

- [`cer_qcmr()`](https://charlescoverdale.github.io/cer/reference/cer_qcmr.md):
  aggregated certificate volumes, prices (where published), and
  abatement statistics from the CER’s Quarterly Carbon Market Report
  data workbook.
- [`cer_qcmr_reference()`](https://charlescoverdale.github.io/cer/reference/cer_qcmr_reference.md),
  [`cer_reconcile()`](https://charlescoverdale.github.io/cer/reference/cer_reconcile.md):
  diff live-fetched aggregates against QCMR headline totals; warns on
  gaps above 2 per cent.

### Reproducibility spine

- [`cer_snapshot()`](https://charlescoverdale.github.io/cer/reference/cer_snapshot.md):
  pin a session snapshot date, recorded in every `cer_tbl` provenance
  header, manifest entry, and citation.
- [`cer_sha256()`](https://charlescoverdale.github.io/cer/reference/cer_sha256.md) +
  sidecar integrity verification: every cached file is hashed at first
  download and verified on cache hit. Drift emits a warning (critical
  because CER restates retroactively).
- [`cer_manifest()`](https://charlescoverdale.github.io/cer/reference/cer_manifest.md),
  [`cer_manifest_clear()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_clear.md),
  [`cer_manifest_write()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_write.md):
  session registry of every fetch (URL, SHA-256, snapshot pin, R and cer
  versions). Output as data frame, YAML, JSON, or CSV for paper
  appendices.
- [`cer_deposit_zenodo()`](https://charlescoverdale.github.io/cer/reference/cer_deposit_zenodo.md):
  stage or submit a Zenodo deposit for a DOI on a data vintage. Dry run
  by default; call with `upload = TRUE` and a `ZENODO_TOKEN` to mint a
  DOI.
- [`cer_cite()`](https://charlescoverdale.github.io/cer/reference/cer_cite.md):
  text / APA / BibTeX citation with snapshot, SHA-256 digest, and
  optional DOI fields.

### Legislative citation layer

- [`cer_legislative_instrument()`](https://charlescoverdale.github.io/cer/reference/cer_legislative_instrument.md):
  Federal Register URL resolver.
- `@references` section on every exported function citing governing Acts
  (Carbon Farming Initiative Act 2011, NGER Act 2007, Renewable Energy
  (Electricity) Act 2000, Safeguard Mechanism (Crediting) Amendment Act
  2023), the Chubb Review (2022), Macintosh et al. (2022), and Climate
  Change Authority reviews.
- `inst/CITATION` with bibentries for the Chubb Review, Macintosh et
  al., and the `carbondata` companion package.

### International comparator

- [`cer_to_carbondata()`](https://charlescoverdale.github.io/cer/reference/cer_to_carbondata.md):
  remap ACCU projects to the `carbondata` Verra / Gold Standard
  voluntary-project schema for cross-market comparison.
- [`cer_international_comparator()`](https://charlescoverdale.github.io/cer/reference/cer_international_comparator.md):
  bundled indicative ACCU vs EU ETS / NZ ETS / WCI / Verra / Gold
  Standard reference.

### Cache management

- [`cer_cache_info()`](https://charlescoverdale.github.io/cer/reference/cer_cache_info.md):
  inspect the local cache.
- [`cer_clear_cache()`](https://charlescoverdale.github.io/cer/reference/cer_clear_cache.md):
  clear locally cached files.

### Vignettes

- `offsets-integrity-primer`: Chubb Review context and
  integrity-weighted aggregation.
- `safeguard-reform`: pre- vs post-2023 regime handling.
- `nger-scope-reconciliation`: Scope 1 / 2 discipline.
- `ret-compliance-primer`: LGC / SRES primer.
- `methodology`: hand-computed worked examples.

### Data source

Data is published by the Clean Energy Regulator at
<https://cer.gov.au/markets/reports-and-data> under a Creative Commons
Attribution 4.0 International licence. All downloads are cached locally
on first use with SHA-256 integrity verification.
