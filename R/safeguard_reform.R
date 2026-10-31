# Safeguard Mechanism reform (1 July 2023) handling.
#
# The reform changed the baseline regime fundamentally:
# - Pre-reform (2016-17 to 2022-23): production-adjusted,
#   facility-specific baselines; no SMCs.
# - Post-reform (2023-24 onward): baselines scaled by an emissions
#   reduction contribution that falls by 0.049 a year to 2029-30 and
#   by 0.03285 a year after that; SMC (Safeguard Mechanism Credit)
#   instrument introduced.
#
# Time-series analysis across the reform without flagging the
# regime break is a common analytical error.

#' Safeguard Mechanism reform-era constants
#'
#' @noRd
SAFEGUARD_REFORM_DATE <- as.Date("2023-07-01")

#' Default emissions reduction contribution by financial year
#'
#' Section 31 of the Safeguard Mechanism Rule 2015: 0.951 for 2023-24,
#' falling by 0.049 each year to 0.657 for 2029-30, then by 0.03285 a year
#' with a floor of zero. Names are the starting calendar year.
#' @noRd
SAFEGUARD_DEFAULT_ERC <- c(
  "2023" = 0.951, "2024" = 0.902, "2025" = 0.853, "2026" = 0.804,
  "2027" = 0.755, "2028" = 0.706, "2029" = 0.657
)

#' @noRd
SAFEGUARD_POST_2030_DECLINE <- 0.03285

#' Default emissions reduction contribution for financial years
#'
#' @param years Integer starting calendar years (2023 for FY 2023-24).
#' @return Numeric vector of default ERCs.
#' @noRd
safeguard_default_erc <- function(years) {
  if (any(years < 2023L)) {
    cli::cli_abort("The emissions reduction contribution applies from FY 2023-24 (year 2023).")
  }
  vapply(years, function(y) {
    if (y <= 2029L) return(SAFEGUARD_DEFAULT_ERC[[as.character(y)]])
    # Rounded to the Rule's five decimal places so that, for example,
    # 2049-50 is exactly zero rather than a floating-point remainder.
    max(round(SAFEGUARD_DEFAULT_ERC[["2029"]] -
                SAFEGUARD_POST_2030_DECLINE * (y - 2029L), 5), 0)
  }, numeric(1))
}

#' Classify a Safeguard record by regime (pre- or post-reform)
#'
#' @param financial_year Character or integer year; accepts
#'   `"2022-23"`, `2022`, etc.
#' @return `"pre_reform"` (FY 2022-23 or earlier) or
#'   `"post_reform"` (FY 2023-24 or later).
#' @noRd
cer_safeguard_regime <- function(financial_year) {
  # Accept integers, character "YYYY-YY", or "YYYY/YY" etc.
  start_year <- if (is.numeric(financial_year)) {
    as.integer(financial_year)
  } else {
    as.integer(sub("[-/].*", "", as.character(financial_year)))
  }
  ifelse(start_year < 2023, "pre_reform", "post_reform")
}

#' Default Safeguard baseline emissions intensity trajectory
#'
#' Returns the baseline emissions intensity, per unit of a production
#' variable, for a facility whose baseline is set at the default
#' emissions intensity in Schedule 1 of the Safeguard Mechanism Rule
#' 2015 and the default emissions reduction contribution (ERC) in
#' section 31:
#'
#' \deqn{B_t = EI \times ERC_t}
#'
#' where `ERC` is 0.951 for FY 2023-24 and falls by 0.049 a year (a
#' linear decline of 4.9 percent of the default intensity) to 0.657 for
#' FY 2029-30, then by 0.03285 a year, never below zero. Facilities
#' using site-specific emissions intensities, and trade-exposed
#' baseline-adjusted facilities (see [cer_safeguard_teba_facilities()]),
#' have different baselines.
#'
#' @param industry Character scalar: a `production_variable` from
#'   [cer_safeguard_industry_baselines()] (case-insensitive), or its
#'   Schedule 1 section number, e.g. `"7"` for aluminium.
#' @param from_year Start year (default 2023 for FY 2023-24).
#' @param to_year End year (default 2030 for FY 2030-31).
#'
#' @return A data frame with `year`, `financial_year`,
#'   `default_emissions_intensity`, `decline_factor` (the default ERC)
#'   and `baseline` (t CO2-e per unit of the production variable).
#'
#' @references
#' Commonwealth of Australia. \emph{National Greenhouse and Energy
#'   Reporting (Safeguard Mechanism) Rule 2015} (F2015L01637),
#'   compilation of 31 August 2024: sections 31 to 33 and Schedule 1.
#'
#' @family safeguard
#' @export
#' @examples
#' cer_safeguard_baseline_trajectory("Aluminium")
#' cer_safeguard_baseline_trajectory("63", from_year = 2023, to_year = 2035)
cer_safeguard_baseline_trajectory <- function(industry,
                                                from_year = 2023,
                                                to_year = 2030) {
  stopifnot(is.character(industry), length(industry) == 1L)
  stopifnot(is.numeric(from_year), is.numeric(to_year), from_year <= to_year)
  b <- as.data.frame(cer_safeguard_industry_baselines())
  hit <- b[tolower(b$production_variable) == tolower(industry) |
             b$section == industry, , drop = FALSE]
  if (nrow(hit) == 0L) {
    cli::cli_abort(c(
      "Production variable {.val {industry}} not found in the bundled Schedule 1 table.",
      "i" = "Run {.code cer_safeguard_industry_baselines()} to see the {nrow(b)} production variables."
    ))
  }
  ei <- hit$default_emissions_intensity[1L]
  years <- seq.int(as.integer(from_year), as.integer(to_year))
  erc <- safeguard_default_erc(years)
  data.frame(
    year                        = years,
    financial_year              = sprintf("%d-%02d", years, (years + 1L) %% 100L),
    default_emissions_intensity = ei,
    decline_factor              = erc,
    baseline                    = ei * erc,
    stringsAsFactors = FALSE
  )
}

#' Safeguard default emissions intensities by production variable
#'
#' The default (industry-average) emissions intensity for every
#' production variable in Schedule 1 of the Safeguard Mechanism Rule
#' 2015 that has one, read from the Rule by
#' `data-raw/safeguard_industry_baselines.R`. Production variables whose
#' default is yet to be specified are omitted.
#'
#' @return A `cer_tbl` with columns `section`, `production_variable`,
#'   `default_emissions_intensity`, `unit` (the Rule's wording) and
#'   `source` (section and compilation date).
#' @family safeguard
#' @export
#' @examples
#' b <- cer_safeguard_industry_baselines()
#' b[b$production_variable %in% c("Aluminium", "Alumina"), ]
cer_safeguard_industry_baselines <- function() {
  path <- system.file("extdata", "safeguard_industry_baselines.csv",
                       package = "cer")
  df <- utils::read.csv(path, stringsAsFactors = FALSE,
                         colClasses = c(section = "character"),
                         na.strings = c("", "NA"), check.names = FALSE)
  new_cer_tbl(df,
              source = "https://www.legislation.gov.au/F2015L01637/latest/text",
              licence = "CC BY 4.0",
              title = "Safeguard Mechanism default emissions intensities (Schedule 1)")
}

#' Trade-exposed baseline-adjusted (TEBA) facility list
#'
#' Returns the Clean Energy Regulator's table of trade-exposed
#' baseline-adjusted (TEBA) determinations, bundled by
#' `data-raw/safeguard_teba_facilities.R`. A TEBA determination sets a
#' slower decline in a facility's emissions reduction contribution
#' (ERC) than the default, for the financial years it covers. A
#' facility appears once per determination, so a revoked and replaced
#' determination gives two rows.
#'
#' @return A `cer_tbl` with columns `facility_name`,
#'   `responsible_emitter`, `start_date`, `end_date` (the financial
#'   years covered), `facility_type`, `decline_rate`, `erc_2023_24` to
#'   `erc_2026_27` (`NA` where the determination does not apply),
#'   `status` (`"current"` or `"historical"`) and `historical_reason`.
#'
#' @references
#' Clean Energy Regulator. \emph{Trade-exposed baseline-adjusted
#'   facility data}.
#'   \url{https://cer.gov.au/markets/reports-and-data/safeguard-data/trade-exposed-baseline-adjusted-facility-data}
#'
#' @family safeguard
#' @export
#' @examples
#' cer_safeguard_teba_facilities()
cer_safeguard_teba_facilities <- function() {
  path <- system.file("extdata", "safeguard_teba_facilities.csv",
                       package = "cer")
  df <- utils::read.csv(path, stringsAsFactors = FALSE,
                         na.strings = c("", "NA"), check.names = FALSE)
  df$start_date <- as.Date(df$start_date)
  df$end_date <- as.Date(df$end_date)
  new_cer_tbl(df,
              source = "https://cer.gov.au/markets/reports-and-data/safeguard-data/trade-exposed-baseline-adjusted-facility-data",
              licence = "CC BY 4.0",
              title = "Safeguard TEBA facilities")
}
