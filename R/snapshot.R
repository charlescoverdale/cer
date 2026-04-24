# Reproducibility: session-level snapshot date pin.
#
# Carbon market data is retroactively revised (ACCU relinquishments,
# project transfers, method reclassifications, Safeguard amendments).
# A snapshot_date pin lets the user record their intended vintage
# and pair it with SHA-256 integrity for a reproducible audit trail.

#' Pin or inspect the session snapshot date
#'
#' Call once at the top of an analysis script to declare the vintage
#' of CER data you intend to use. Every subsequent `cer_*` fetch
#' records this date in the `cer_tbl` provenance header, in
#' [cer_manifest()] entries, and in [cer_cite()] output.
#'
#' This matters more for CER data than for most government data:
#' projects relinquish ACCUs retroactively, the CER transfers
#' projects between proponents, methods are reclassified (e.g.
#' post-Chubb-Review status changes), and the Quarterly Carbon
#' Market Report occasionally restates prior quarters. A snapshot
#' pin is the minimum evidence a reviewer needs to verify a
#' published carbon-market claim.
#'
#' @param date ISO `"YYYY-MM-DD"` character, `Date`, or `POSIXct`.
#'   Pass `NULL` to clear.
#'
#' @return Invisibly, the new pinned date (as `Date`), or `NULL`.
#' @family reproducibility
#' @export
#' @examples
#' cer_snapshot("2026-04-24")
#' cer_snapshot()
#' cer_snapshot(NULL)
cer_snapshot <- function(date) {
  if (missing(date)) {
    return(.cer_env$snapshot_date %||% NULL)
  }
  if (is.null(date)) {
    .cer_env$snapshot_date <- NULL
    return(invisible(NULL))
  }
  d <- tryCatch(as.Date(date), error = function(e) NA)
  if (is.na(d)) {
    cli::cli_abort(
      "Could not parse {.arg date} as a date. Use {.val YYYY-MM-DD}."
    )
  }
  .cer_env$snapshot_date <- d
  invisible(d)
}

#' @noRd
cer_snapshot_str <- function() {
  d <- .cer_env$snapshot_date %||% NULL
  if (is.null(d)) NA_character_ else format(d, "%Y-%m-%d")
}
