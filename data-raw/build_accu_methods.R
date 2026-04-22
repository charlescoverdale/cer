# data-raw/build_accu_methods.R
#
# Build the embedded accu_methods lookup table shipped in sysdata.rda.
#
# Run manually with:
#   source("data-raw/build_accu_methods.R")
#
# The output lands in R/sysdata.rda so that cer_accu_methods() can
# return a lookup without any network dependency.

library(usethis)

accu_methods <- data.frame(
  method = c(
    # Vegetation
    "Human-induced regeneration of a permanent even-aged native forest",
    "Avoided deforestation",
    "Avoided clearing of native regrowth",
    "Native forest from managed regrowth",
    "Reforestation by environmental or mallee plantings",
    "Reforestation and afforestation (non-plantation)",
    "Plantation forestry",
    # Savanna
    "Savanna fire management (emissions avoidance)",
    "Savanna fire management (sequestration and emissions avoidance)",
    # Agriculture
    "Beef cattle herd management",
    "Dairy cattle milk productivity",
    "Piggery waste",
    "Estimating sequestration of carbon in soil using default values",
    "Measurement of soil carbon sequestration in agricultural systems",
    # Landfill and Waste
    "Landfill gas",
    "Alternative waste treatment",
    "Source-separated organic waste",
    # Mining / Oil / Gas
    "Coal mine waste gas",
    "Oil and gas fugitive emissions",
    # Energy Efficiency
    "Energy efficiency in commercial buildings",
    "Industrial equipment upgrades",
    "Facilities project",
    # Transport
    "Aggregated small energy users",
    # Blue carbon
    "Tidal restoration of blue carbon ecosystems"
  ),
  sector = c(
    rep("Vegetation", 7L),
    rep("Savanna", 2L),
    rep("Agriculture", 5L),
    rep("Landfill and Waste", 3L),
    rep("Mining/Oil/Gas", 2L),
    rep("Energy Efficiency", 3L),
    "Transport",
    "Blue carbon"
  ),
  short_name = c(
    "HIR", "AD", "AC native regrowth", "MNFR", "Plantings",
    "R&A", "Plantation",
    "Savanna EA", "Savanna EA+S",
    "Beef cattle", "Dairy", "Piggery", "Soil default", "Soil measured",
    "Landfill", "AWT", "SSOW",
    "CMWG", "Oil and gas FE",
    "Commercial", "Industrial", "Facilities",
    "Aggregated SEU",
    "Blue carbon"
  ),
  commenced = as.Date(c(
    "2013-07-01", "2015-04-01", "2015-04-01", "2015-07-01", "2014-05-30",
    "2022-06-01", "2022-06-01",
    "2012-12-01", "2018-05-01",
    "2015-08-12", "2022-06-01", "2012-11-09", "2014-11-27", "2018-02-09",
    "2012-08-24", "2015-07-01", "2015-07-01",
    "2018-03-28", "2022-06-01",
    "2013-07-01", "2015-07-01", "2022-06-01",
    "2015-07-01",
    "2022-06-01"
  )),
  source_url = rep(
    "https://cer.gov.au/schemes/australian-carbon-credit-unit-scheme/accu-scheme-methods",
    25L
  ),
  stringsAsFactors = FALSE
)

# Write sysdata.rda so cer_accu_methods() can read it on load.
usethis::use_data(accu_methods, internal = TRUE, overwrite = TRUE)

message("Wrote R/sysdata.rda with ", nrow(accu_methods), " methods.")
