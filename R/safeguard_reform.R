# Safeguard Mechanism reform (1 July 2023) handling.
#
# The reform changed the baseline regime fundamentally:
# - Pre-reform (2016-17 to 2022-23): production-adjusted,
#   facility-specific baselines; no SMCs.
# - Post-reform (2023-24 onward): industry-average default baselines
#   declining 4.9% per annum (nominal) to 2030; SMC (Safeguard
#   Mechanism Credit) instrument introduced.
#
# Time-series analysis across the reform without flagging the
# regime break is a common analytical error.

#' Safeguard Mechanism reform-era constants
#'
#' @noRd
SAFEGUARD_REFORM_DATE <- as.Date("2023-07-01")

#' @noRd
SAFEGUARD_ANNUAL_DECLINE_RATE <- 0.049

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

#' Compute a declining Safeguard baseline trajectory
#'
#' Implements the 4.9% per-annum nominal decline in industry-average
#' default baselines introduced by the 2023 reform. The formula is:
#'
#' \deqn{B_t = B_{2023\text{-}24} \times (1 - 0.049)^{t - 2023}}
#'
#' where `t` is the starting calendar year of the financial year.
#' Default values are drawn from
#' `inst/extdata/safeguard_industry_baselines.csv`.
#'
#' @param industry Character scalar matching an `industry` value
#'   from [cer_safeguard_industry_baselines()].
#' @param from_year Start year (default 2023 for FY 2023-24).
#' @param to_year End year (default 2029 for FY 2029-30).
#'
#' @return A data frame with `year`, `financial_year`, `baseline`,
#'   and `decline_factor` columns.
#'
#' @references
#' Commonwealth of Australia (2023). \emph{Safeguard Mechanism
#'   (Crediting) Amendment Act 2023}. Introduces 4.9% p.a. nominal
#'   baseline decline to 2030.
#'
#' Clean Energy Regulator (annual). \emph{Safeguard Mechanism:
#'   declining baselines}. Methodology notes accompanying annual
#'   baseline determinations.
#'
#' @family safeguard
#' @export
#' @examples
#' cer_safeguard_baseline_trajectory("Aluminium smelting")
#' cer_safeguard_baseline_trajectory("Cement clinker",
#'                                    from_year = 2023, to_year = 2030)
cer_safeguard_baseline_trajectory <- function(industry,
                                                from_year = 2023,
                                                to_year = 2030) {
  stopifnot(is.character(industry), length(industry) == 1L)
  b <- cer_safeguard_industry_baselines()
  hit <- b[tolower(b$industry) == tolower(industry), ]
  if (nrow(hit) == 0L) {
    cli::cli_abort(c(
      "Industry {.val {industry}} not found in bundled baseline table.",
      "i" = "Run {.code cer_safeguard_industry_baselines()} to see available industries."
    ))
  }
  b_base <- hit$baseline_2023_24_t_co2e_per_unit[1L]
  years <- seq.int(from_year, to_year)
  decline <- (1 - SAFEGUARD_ANNUAL_DECLINE_RATE) ^ (years - 2023L)
  out <- data.frame(
    year           = years,
    financial_year = sprintf("%d-%02d", years, (years + 1L) %% 100L),
    baseline       = b_base * decline,
    decline_factor = decline,
    stringsAsFactors = FALSE
  )
  out
}

#' Bundled Safeguard industry-average default baselines
#'
#' @return A `cer_tbl` of industry default baselines.
#' @family safeguard
#' @export
#' @examples
#' cer_safeguard_industry_baselines()
cer_safeguard_industry_baselines <- function() {
  path <- system.file("extdata", "safeguard_industry_baselines.csv",
                       package = "cer")
  df <- utils::read.csv(path, stringsAsFactors = FALSE,
                         na.strings = c("", "NA"), check.names = FALSE)
  new_cer_tbl(df,
              source = "https://cer.gov.au/schemes/safeguard-mechanism",
              licence = "CC BY 4.0",
              title = "Safeguard industry-average default baselines")
}

#' Trade-exposed baseline-adjusted (TEBA) facility list
#'
#' Returns the bundled list of facilities declared as TEBA under
#' the 2023 reform. TEBA facilities are eligible for softer
#' baseline treatment reflecting international competitiveness.
#'
#' @return A `cer_tbl` of TEBA facilities.
#'
#' @references
#' Commonwealth of Australia (2023). \emph{National Greenhouse
#'   and Energy Reporting (Safeguard Mechanism) Rule 2015} as
#'   amended by the Safeguard Mechanism (Crediting) Amendment
#'   Rule 2023. TEBA definition and declaration process.
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
  new_cer_tbl(df,
              source = "https://cer.gov.au/schemes/safeguard-mechanism/trade-exposed-baseline-adjusted-facilities",
              licence = "CC BY 4.0",
              title = "Safeguard TEBA facilities")
}
