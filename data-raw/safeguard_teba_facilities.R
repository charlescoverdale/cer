# Build inst/extdata/safeguard_teba_facilities.csv from the CER's
# trade-exposed baseline-adjusted (TEBA) determinations table.
#
# One row per determination, as published: a facility can appear more
# than once when a determination is revoked and replaced. The ERC
# columns are the emissions reduction contributions the determination
# sets for each financial year ("-" where it does not apply).
#
# Source: https://cer.gov.au/markets/reports-and-data/safeguard-data/trade-exposed-baseline-adjusted-facility-data

library(readxl)

devtools::load_all(quiet = TRUE)
page <- "https://cer.gov.au/markets/reports-and-data/safeguard-data/trade-exposed-baseline-adjusted-facility-data"
hits <- cer_scrape_links(page, "trade-exposed-baseline-adjusted-table")
stopifnot(length(hits) > 0L)

# Both renditions on the page are XLSX; take the first that parses.
path <- tempfile(fileext = ".xlsx")
download.file(hits[1], path, mode = "wb", quiet = TRUE)
raw <- as.data.frame(read_excel(path, skip = 3, .name_repair = "minimal"))
stopifnot("Facility name" %in% names(raw))
raw <- raw[!is.na(raw[["Facility name"]]), ]

erc <- function(v) {
  v <- trimws(as.character(v))
  v[v %in% c("-", "")] <- NA
  round(as.numeric(v), 4)
}

out <- data.frame(
  facility_name       = trimws(raw[["Facility name"]]),
  responsible_emitter = trimws(raw[["Responsible emitter"]]),
  start_date          = as.Date(raw[["Start date"]]),
  end_date            = as.Date(raw[["End date"]]),
  facility_type       = raw[["Facility type"]],
  decline_rate        = as.numeric(raw[["Decline rate"]]),
  erc_2023_24         = erc(raw[["2023/2024 ERC"]]),
  erc_2024_25         = erc(raw[["2024/2025 ERC"]]),
  erc_2025_26         = erc(raw[["2025/2026 ERC"]]),
  erc_2026_27         = erc(raw[["2026/2027 ERC"]]),
  status              = tolower(raw[["Current or historical"]]),
  historical_reason   = ifelse(raw[["Historical reason"]] %in% c("-", ""),
                               NA_character_, raw[["Historical reason"]]),
  stringsAsFactors = FALSE
)
stopifnot(!anyNA(out$start_date), !anyNA(out$end_date))

write.csv(out, "inst/extdata/safeguard_teba_facilities.csv",
          row.names = FALSE, na = "")
message(nrow(out), " TEBA determinations written")
