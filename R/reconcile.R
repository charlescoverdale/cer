# QCMR reconciliation: diff an aggregate against the authoritative
# Quarterly Carbon Market Report headline figures.
#
# The CER publishes the QCMR each quarter with agreed totals
# (cumulative ACCU issuances, surrenders, active projects, LGC and
# STC volumes, Safeguard covered emissions, SMC issuances, SRES
# installations). Because ACCU project registers are retroactively
# revised, a live-fetched aggregate today may differ from the
# published QCMR figure for the same quarter. This is the single
# highest-value check in a carbon market research pipeline.

#' QCMR headline reference totals
#'
#' Bundled quarterly Clean Energy Regulator QCMR headline figures
#' for cross-validation of live-fetched aggregates.
#'
#' @param quarter Optional character filter (e.g. `"2024-Q4"`).
#' @param measure Optional character filter (e.g.
#'   `"accu_cumulative_issuances"`).
#'
#' @return A `cer_tbl` of reference totals.
#' @family reconciliation
#' @export
#' @examples
#' cer_qcmr_reference()
#' cer_qcmr_reference(quarter = "2024-Q4")
cer_qcmr_reference <- function(quarter = NULL, measure = NULL) {
  path <- system.file("extdata", "qcmr_headline_totals.csv",
                       package = "cer")
  df <- utils::read.csv(path, stringsAsFactors = FALSE,
                         na.strings = c("", "NA"), check.names = FALSE)
  if (!is.null(quarter)) {
    df <- df[df$quarter %in% quarter, , drop = FALSE]
  }
  if (!is.null(measure)) {
    df <- df[df$measure %in% measure, , drop = FALSE]
  }
  rownames(df) <- NULL
  new_cer_tbl(df,
              source = "https://cer.gov.au/markets/reports-and-data/quarterly-carbon-market-reports",
              licence = "CC BY 4.0",
              title = "QCMR headline reference totals")
}

#' Reconcile an aggregate against the QCMR headline figure
#'
#' Compares a scalar or data-frame sum against the CER Quarterly
#' Carbon Market Report headline for the same quarter and measure.
#' Warns on absolute percentage gap > 2% (default). Small gaps
#' (sub-1%) are expected because ACCU project registers are
#' retroactively revised between QCMR releases.
#'
#' @param value Numeric scalar or data frame. If a data frame, pass
#'   `sum_column` to pick which numeric column to sum.
#' @param quarter Character, e.g. `"2024-Q4"` or `"2023-24"`.
#' @param measure Character, matching a `measure` value in
#'   [cer_qcmr_reference()]. For example
#'   `"accu_cumulative_issuances"`,
#'   `"safeguard_covered_emissions_mt"`, `"smc_issuances"`.
#' @param sum_column Column name to sum when `value` is a data frame.
#' @param warn_pct Warn if |pct_diff| > this threshold. Default 0.02.
#'
#' @return A one-row data frame: `measure`, `quarter`, `value`,
#'   `reference`, `diff`, `pct_diff`, `unit`, `source`.
#'
#' @references
#' Clean Energy Regulator (quarterly). \emph{Quarterly Carbon Market
#'   Report}. \url{https://cer.gov.au/markets/reports-and-data/quarterly-carbon-market-reports}
#'
#' @family reconciliation
#' @export
#' @examples
#' cer_reconcile(value = 185e6,
#'               quarter = "2024-Q4",
#'               measure = "accu_cumulative_issuances")
cer_reconcile <- function(value, quarter, measure,
                           sum_column = NULL,
                           warn_pct = 0.02) {
  if (is.data.frame(value)) {
    cols <- names(value)[vapply(value, is.numeric, logical(1))]
    if (is.null(sum_column)) {
      if (length(cols) == 0L) {
        cli::cli_abort("No numeric columns in {.arg value}.")
      }
      if (length(cols) > 1L) {
        cli::cli_abort(c(
          "Multiple numeric columns in {.arg value}.",
          "i" = "Pass {.arg sum_column}: {.val {cols}}."
        ))
      }
      sum_column <- cols
    }
    v <- sum(value[[sum_column]], na.rm = TRUE)
  } else {
    stopifnot(is.numeric(value), length(value) == 1L)
    v <- value
  }

  ref <- as.data.frame(cer_qcmr_reference())
  hit <- ref[ref$quarter == quarter & ref$measure == measure, ]
  if (nrow(hit) == 0L) {
    cli::cli_abort(c(
      "No QCMR reference for {.val {measure}} in {.val {quarter}}.",
      "i" = "Available measures: {.val {unique(ref$measure)}}.",
      "i" = "Available quarters: {.val {unique(ref$quarter)}}."
    ))
  }
  ref_v <- hit$value[1L]
  diff <- v - ref_v
  pct <- diff / ref_v

  if (abs(pct) > warn_pct) {
    cli::cli_warn(c(
      "Reconciliation gap {round(100 * pct, 2)}% for {.val {measure}} ({.val {quarter}}).",
      "i" = "Live: {.val {format(v, big.mark = ',', scientific = FALSE)}}",
      "i" = "QCMR reference: {.val {format(ref_v, big.mark = ',', scientific = FALSE)}}",
      "i" = "CER data is retroactively revised; check for recent relinquishments or corrections."
    ))
  }

  data.frame(
    measure   = measure,
    quarter   = quarter,
    value     = v,
    reference = ref_v,
    diff      = diff,
    pct_diff  = pct,
    unit      = hit$unit[1L],
    source    = hit$source[1L],
    stringsAsFactors = FALSE
  )
}
