# Offsets integrity primer: reading ACCUs after the Chubb Review

Australian Carbon Credit Units (ACCUs) are not fungible after Chubb
(2022). Different methods have different integrity profiles; some
methods are under active review by the Independent Integrity Assurance
Committee; some are suspended. A headline figure like “185 million ACCUs
issued to date” is only meaningful once decomposed by integrity tier.

This vignette walks through the `cer` integrity layer.

## What changed after Chubb (2022)

The Independent Review of Australian Carbon Credit Units (Chubb,
December 2022) identified five ACCU methods for specific attention:

- **Human-Induced Regeneration (HIR).** Recommended replacement by a new
  Integrated Farm and Land Management (IFLM) method.
- **Avoided Deforestation.** Closed to new project registrations.
- **Landfill Gas.** Tightened baseline-crediting expectations.
- **Soil Carbon.** Strengthened Measurement, Reporting, and Verification
  (MRV) requirements.
- **Plantings (2014 method).** Superseded by the 2024 FullCAM method.

Independent academic critique (Macintosh et al. 2022, ANU) was sharper
on HIR specifically. The live debate is continuing.

## Query the integrity scorecard

``` r
library(cer)
cer_snapshot("2026-04-24")

all_methods <- cer_method_integrity()
all_methods[, c("method_short", "status", "integrity_tier", "chubb_affected")]
```

## Filter to contested methods

``` r
contested <- cer_method_integrity(tier = "contested")
contested[, c("method_short", "method_full_name", "status")]
```

## Aggregating ACCUs by integrity tier

``` r
projects <- cer_accu_projects(status = "all")

by_tier <- cer_accu_aggregate(projects,
                               value_col = "accus_issued",
                               warn_contested_pct = 0.05)
by_tier
```

The function emits a warning when contested-integrity methods account
for more than 5 per cent of the total : a signal that a single headline
figure is not appropriate.

## Warnings when querying a suspended method

``` r
# Will emit a post-Chubb integrity warning
ad <- cer_accu_projects(method = "avoided deforestation",
                         status = "all")
```

## Linking to the authoritative determination

``` r
cer_method_determination("HIR")
cer_legislative_instrument("F2019C00664")
```

## Rule of thumb

If your analysis depends on an aggregate ACCU figure, report three
numbers: total, high-integrity share, and contested share. A reviewer
will ask for this breakdown; better to have it in the table than in a
footnote.
