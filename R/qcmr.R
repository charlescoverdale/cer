# Quarterly Carbon Market Report

#' @noRd
QCMR_LANDING <- "https://cer.gov.au/markets/reports-and-data/quarterly-carbon-market-reports"

#' @noRd
qcmr_url <- function(quarter) {
  if (identical(quarter, "latest")) {
    hits <- cer_scrape_links(QCMR_LANDING, "qcmr.*data.*workbook")
    if (length(hits) == 0L) {
      cli::cli_abort(c(
        "Could not find any QCMR data workbook on the landing page.",
        "i" = "Browse {.url {QCMR_LANDING}} manually."
      ))
    }
    return(hits[1L])
  }

  q <- tolower(gsub("[^0-9a-z]", "", quarter))
  parts <- regmatches(q, regexec("^([0-9]{4})q([1-4])$", q))[[1]]
  if (length(parts) != 3L) {
    cli::cli_abort(c(
      "Could not parse quarter {.val {quarter}}.",
      "i" = "Use format like {.val 2025q4} or {.val 2024q2}, or pass {.val latest}."
    ))
  }
  yr <- parts[2]
  qn <- as.integer(parts[3])
  month <- c("march", "june", "september", "december")[qn]
  pattern <- sprintf("qcmr.*%s.*%s|qcmr.*%s.*%s", month, yr, yr, month)
  hits <- cer_scrape_links(QCMR_LANDING, pattern)
  if (length(hits) == 0L) {
    cli::cli_abort(c(
      "No QCMR data workbook found for {month} quarter {yr}.",
      "i" = "Try {.val latest} or browse {.url {QCMR_LANDING}}."
    ))
  }
  hits[1L]
}

#' Quarterly Carbon Market Report data workbook
#'
#' Aggregate carbon market statistics from the CER's Quarterly
#' Carbon Market Report, including ACCU issuances, LGC creations,
#' STC volumes, unit surrenders, and Safeguard Mechanism
#' developments.
#'
#' @param quarter Character. Quarter identifier in `"YYYYqN"` form
#'   (e.g. `"2025q4"` for the December 2025 quarter). Defaults to
#'   `"latest"`, which resolves to the most recent release.
#' @param sheet Sheet name or integer index. The CER QCMR workbook
#'   contains a `Contents` sheet (default) plus one sheet per
#'   figure (e.g. `"Figure 1.1"`, `"Figure 3.14"`). Pass a figure
#'   name to extract that figure's data.
#'
#' @return A `cer_tbl` with the requested sheet's contents.
#'
#' @source Clean Energy Regulator, Quarterly Carbon Market Reports:
#'   <https://cer.gov.au/markets/reports-and-data/quarterly-carbon-market-reports>.
#'   Licensed under CC BY 4.0.
#'
#' @references
#' Clean Energy Regulator (quarterly). \emph{Quarterly Carbon
#'   Market Report}. Methodology notes accompany each release.
#'
#' Clean Energy Regulator (2024). \emph{Carbon Market Indicators:
#'   methodology and data dictionary}.
#'
#' @family qcmr
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' try({
#'   # Contents sheet lists all available figures
#'   toc <- cer_qcmr("latest")
#'   head(toc)
#'   # Fetch a specific figure
#'   fig <- cer_qcmr("latest", sheet = "Figure 1.1")
#' })
#' options(op)
#' }
cer_qcmr <- function(quarter = "latest", sheet = "Contents") {
  url <- qcmr_url(quarter)
  df <- cer_fetch_auto(url, sheet = sheet)
  rownames(df) <- NULL
  new_cer_tbl(df,
              source = QCMR_LANDING,
              licence = "CC BY 4.0",
              title = paste0("QCMR ", quarter))
}
