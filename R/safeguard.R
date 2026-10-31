# Safeguard Mechanism + NGER

#' @noRd
SAFEGUARD_LANDING <- "https://cer.gov.au/markets/reports-and-data/safeguard-data"

#' @noRd
NGER_LANDING <- "https://cer.gov.au/markets/reports-and-data/nger-reporting-data-and-registers"

#' @noRd
safeguard_urls <- function(year) {
  yr_lo <- year - 1L
  yr_hi <- year %% 100L
  yr_label <- sprintf("%d-%02d", yr_lo, yr_hi)

  # CER uses three different URL conventions across years:
  #   2023-24+: /safeguard-data/<year>-baselines-and-emissions-data/
  #             -> /document/baselines-and-emissions-table-<year>
  #                (2023-24 itself: /document/<year>-baselines-and-emissions-table)
  #   ~2022-23: /safeguard-facility-covered-emissions-data-<year>/
  #             -> /document/safeguard-facilities-data-<year>
  #   Pre-2022: /safeguard-facility-reported-emissions-data/safeguard-facility-reported-emissions-<year>/
  #             -> similar slug inside
  # Try each subpage, collect /document/ links, filter to data-table
  # slugs (not explanation letters, not PDFs).
  subpages <- c(
    sprintf("%s/%s-baselines-and-emissions-data", SAFEGUARD_LANDING, yr_label),
    sprintf("https://cer.gov.au/markets/reports-and-data/safeguard-facility-covered-emissions-data-%s", yr_label),
    sprintf("https://cer.gov.au/markets/reports-and-data/safeguard-facility-reported-emissions-data/safeguard-facility-reported-emissions-%s", yr_label)
  )

  # Slugs that identify the headline data file (exclude per-facility
  # "explanation-letter" PDFs and method determinations).
  table_rx <- paste0(
    "baselines-and-emissions-table-", yr_label, "|",
    yr_label, "-baselines-and-emissions-table", "|",
    "safeguard-facilities-data-", yr_label, "|",
    "safeguard-facility-data-", yr_label, "|",
    "safeguard-facility-covered-emissions-", yr_label, "|",
    "safeguard-facility-reported-emissions-", yr_label
  )

  hits <- character(0)
  for (sp in subpages) {
    hits <- cer_scrape_links(sp, table_rx)
    if (length(hits) > 0L) break
  }
  if (length(hits) == 0L) {
    cli::cli_abort(c(
      "No safeguard dataset found for reporting year {yr_lo}-{yr_hi}.",
      "i" = "The CER landing page is {.url {SAFEGUARD_LANDING}}."
    ))
  }
  # Prefer CSV (`-0` or `-csv` suffix) over XLSX (`-excel` or plain).
  csv <- hits[grepl("-0$|-csv$", hits)]
  xlsx <- setdiff(hits, csv)
  list(csv = if (length(csv) > 0L) csv[1L] else NA_character_,
       xlsx = if (length(xlsx) > 0L) xlsx[1L] else NA_character_)
}

#' @noRd
nger_urls <- function(year, kind = c("corporate", "electricity")) {
  kind <- match.arg(kind)
  yr_lo <- year - 1L
  yr_hi <- year %% 100L
  yr_label <- sprintf("%d-%02d", yr_lo, yr_hi)

  # Since 2026 each reporting year has its own subpage under the NGER
  # landing page, and the data files are /document/ links on that page.
  subpage <- switch(kind,
    corporate   = sprintf("%s/corporate-emissions-and-energy-data-%s",
                          NGER_LANDING, yr_label),
    electricity = sprintf("%s/electricity-sector-emissions-and-generation-data-%s",
                          NGER_LANDING, yr_label)
  )
  pattern <- switch(kind,
    corporate   = sprintf("greenhouse-and-energy-information-registered-corporation-%s",
                          yr_label),
    electricity = sprintf("greenhouse-and-energy-information-designated-generation-facilit(y|ies)-%s",
                          yr_label)
  )
  hits <- cer_scrape_links(subpage, pattern)
  if (length(hits) == 0L) {
    cli::cli_abort(c(
      "No NGER {kind} dataset found for reporting year {yr_lo}-{yr_hi}.",
      "i" = "Looked on {.url {subpage}}.",
      "i" = "The CER landing page is {.url {NGER_LANDING}}."
    ))
  }
  # The "-0" document is the CSV rendition; the plain slug is XLSX.
  csv <- hits[grepl("-0$", hits)]
  if (length(csv) > 0L) return(csv[1L])
  hits[1L]
}

#' Safeguard Mechanism facility-level data
#'
#' Covered emissions, baselines, Safeguard Mechanism Credits (SMCs)
#' issued or surrendered, and abatement information for facilities
#' above the 100,000 tonne CO2e threshold.
#'
#' Published annually by the CER on 15 April following each
#' reporting year. The download URL is resolved dynamically from
#' the CER's Safeguard landing page, so no slug changes here are
#' required when new years publish.
#'
#' @param year Integer. Reporting year ending 30 June (e.g. `2025`
#'   for 2024-25). Defaults to the most recently released year.
#'
#' @return A `cer_tbl` with one row per facility.
#'
#' @source Clean Energy Regulator, Safeguard data:
#'   <https://cer.gov.au/markets/reports-and-data/safeguard-data>.
#'   Licensed under CC BY 4.0.
#'
#' @references
#' Commonwealth of Australia. \emph{National Greenhouse and Energy
#'   Reporting Act 2007}.
#'
#' Commonwealth of Australia. \emph{National Greenhouse and Energy
#'   Reporting (Safeguard Mechanism) Rule 2015} (as amended).
#'
#' Commonwealth of Australia (2023). \emph{Safeguard Mechanism
#'   (Crediting) Amendment Act 2023}. Introduced declining industry
#'   baselines (4.9% p.a. nominal) and Safeguard Mechanism Credits
#'   (SMCs).
#'
#' Climate Change Authority (2023). \emph{Review of the Safeguard
#'   Mechanism}.
#'
#' @family safeguard
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' try({
#'   f <- cer_safeguard_facilities(year = 2025)
#'   head(f)
#' })
#' options(op)
#' }
cer_safeguard_facilities <- function(year = 2025) {
  stopifnot(is.numeric(year), length(year) == 1L, year >= 2017L, year <= 2030L)
  urls <- safeguard_urls(year)

  # URL suffix convention is inconsistent across years (ACCU inverse
  # of Safeguard), so fall back on file magic bytes for dispatch.
  candidate <- if (!is.na(urls$csv)) urls$csv else urls$xlsx
  df <- cer_fetch_auto(candidate)

  # Regime flag: pre-reform (FY 2016-17 to 2022-23) vs post-reform
  # (FY 2023-24 onward). The reform changed baseline methodology
  # fundamentally; a cross-regime time series should not be
  # summarised as a single trend without this split.
  fy_start <- year - 1L
  df$regime <- cer_safeguard_regime(fy_start)
  df$financial_year <- sprintf("%d-%02d", fy_start, fy_start %% 100L + 1L)

  # TEBA flag: a facility is flagged when a TEBA determination covers
  # this financial year, matched on facility name. Determinations only
  # exist from FY 2023-24, so earlier years are all FALSE.
  teba <- as.data.frame(cer_safeguard_teba_facilities())
  fy_from <- as.Date(sprintf("%d-07-01", fy_start))
  fy_to <- as.Date(sprintf("%d-06-30", fy_start + 1L))
  covering <- teba[teba$start_date <= fy_from & teba$end_date >= fy_to, ,
                   drop = FALSE]
  fac_col <- intersect(c("facility_name", "facility"), names(df))[1]
  if (!is.na(fac_col)) {
    norm <- function(x) gsub("\\s+", " ", trimws(tolower(x)))
    df$teba_declared <- norm(df[[fac_col]]) %in% norm(covering$facility_name)
  } else {
    df$teba_declared <- NA
  }

  rownames(df) <- NULL
  new_cer_tbl(df,
              source = SAFEGUARD_LANDING,
              licence = "CC BY 4.0",
              title = paste0("Safeguard facilities ", year - 1L, "-", year %% 100L))
}

#' NGER corporate emissions and energy data
#'
#' Controlling-corporation-level Scope 1 and Scope 2 emissions and
#' energy use from the National Greenhouse and Energy Reporting
#' ('NGER') scheme.
#'
#' Published annually by the CER on 28 February. Facility-level
#' Scope 1 and 2 data is only published for the electricity
#' sector; non-electricity sectors report at this
#' controlling-corporation level only.
#'
#' @param year Integer. Reporting year ending 30 June.
#'
#' @return A `cer_tbl` with one row per reporting corporation.
#'
#' @source Clean Energy Regulator, NGER reporting data and registers:
#'   <https://cer.gov.au/markets/reports-and-data/nger-reporting-data-and-registers>.
#'   Licensed under CC BY 4.0.
#'
#' @references
#' Commonwealth of Australia. \emph{National Greenhouse and Energy
#'   Reporting Act 2007}; \emph{National Greenhouse and Energy
#'   Reporting (Measurement) Determination 2008} (as amended
#'   annually).
#'
#' Greenhouse Gas Protocol (2004). \emph{A Corporate Accounting
#'   and Reporting Standard (Revised Edition)}. World Resources
#'   Institute.
#'
#' Department of Climate Change, Energy, the Environment and Water
#'   (annual). \emph{NGER Technical Guidelines}. Methodology for
#'   Scope 1 and Scope 2 calculations.
#'
#' @family nger
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' try({
#'   x <- cer_nger_corporate(year = 2025)
#'   head(x)
#' })
#' options(op)
#' }
cer_nger_corporate <- function(year = 2025) {
  stopifnot(is.numeric(year), length(year) == 1L, year >= 2009L, year <= 2030L)
  url <- nger_urls(year, "corporate")
  df <- cer_fetch_auto(url)
  rownames(df) <- NULL
  new_cer_tbl(df,
              source = NGER_LANDING,
              licence = "CC BY 4.0",
              title = paste0("NGER corporate ", year - 1L, "-", year %% 100L))
}

#' NGER electricity sector facility emissions
#'
#' Facility-level Scope 1 emissions and generated electricity for
#' facilities in the electricity generation sector that met the
#' NGER reporting threshold.
#'
#' @param year Integer. Reporting year ending 30 June.
#' @param facility Optional character vector of facility name
#'   substrings (case-insensitive).
#'
#' @return A `cer_tbl` with one row per generator facility.
#'
#' @source Clean Energy Regulator, National Greenhouse and Energy
#'   Register:
#'   <https://cer.gov.au/markets/reports-and-data/nger-reporting-data-and-registers>.
#'   Licensed under CC BY 4.0.
#'
#' @family nger
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' try({
#'   e <- cer_nger_electricity(year = 2025, facility = "Bayswater")
#'   head(e)
#' })
#' options(op)
#' }
cer_nger_electricity <- function(year = 2025, facility = NULL) {
  stopifnot(is.numeric(year), length(year) == 1L, year >= 2009L, year <= 2030L)
  url <- nger_urls(year, "electricity")
  df <- cer_fetch_auto(url)
  df <- cer_filter_like(df, "facility_name", facility)
  if (!is.null(facility) && !"facility_name" %in% names(df)) {
    df <- cer_filter_like(df, "facility", facility)
  }
  rownames(df) <- NULL
  new_cer_tbl(df,
              source = NGER_LANDING,
              licence = "CC BY 4.0",
              title = paste0("NGER electricity ", year - 1L, "-", year %% 100L))
}
