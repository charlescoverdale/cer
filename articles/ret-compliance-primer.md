# RET compliance primer: LGCs, STCs, and the shortfall charge

The Renewable Energy Target (RET) is Australia’s two-scheme renewable
certificate framework:

- **LRET** (Large-scale): accredited power stations create LGCs
  (Large-scale Generation Certificates). 1 LGC = 1 MWh.
- **SRES** (Small-scale): small-scale systems (rooftop solar, solar
  water heaters, heat pumps) create STCs (Small-scale Technology
  Certificates). STC multipliers vary by system type and zone.

Liable entities (mostly electricity retailers) must surrender LGCs to
meet the annual LRET target and STCs to meet the annual small-scale
percentage. The **shortfall charge** caps the price: AUD 65 per MWh
(pre-tax) for LGCs; AUD 40 per STC.

## LRET: accredited power stations

``` r

library(cer)
cer_snapshot("2026-04-24")

stations <- cer_lgc_power_stations(technology = "solar")
head(stations[, c("accredited_power_station", "state",
                   "capacity_mw", "accreditation_date")])
```

## SRES: postcode installations

``` r

sres <- cer_sres_installations(measure = "installations")
head(sres[, 1:8])
```

## Quick compliance check

A retailer with 10 TWh (= 10,000,000 MWh) of liable acquisitions and an
LRET target of 18 per cent must surrender 1,800,000 LGCs. If they
surrender 1,700,000 and no grandfathered arrangements apply, the
shortfall is 100,000 LGCs, and the shortfall charge is AUD 6.5m
(pre-tax).

``` r

liable_mwh <- 10e6
target_pct <- 0.18
lgcs_required <- liable_mwh * target_pct
lgcs_surrendered <- 1700000

shortfall_lgcs <- max(0, lgcs_required - lgcs_surrendered)
shortfall_aud <- shortfall_lgcs * 65   # pre-tax shortfall charge
shortfall_aud
```

## Reconciling against QCMR headline

``` r

# LGCs validated in 2024-Q4, from the QCMR data workbook
cer_qcmr_reference(quarter = "2024-Q4", measure = "lgc_validations")

# Reconcile a total from the LGC register against it
cer_reconcile(
  value    = 14010587,
  quarter  = "2024-Q4",
  measure  = "lgc_validations"
)
```

The value passed here would come from the REC Registry’s LGC validation
records for the quarter.
