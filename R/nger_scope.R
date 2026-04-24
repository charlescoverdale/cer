# NGER scope discipline helpers.
#
# Scope confusion is the most common error in Australian emissions
# reporting. NGER publishes Scope 1 + Scope 2 at corporate level,
# but only Scope 1 at facility level (for the electricity sector).
# Climate Active, TCFD, and SBTi require scope-explicit reporting.

#' Select NGER columns by scope with explicit errors
#'
#' Given an NGER corporate-level data frame from
#' [cer_nger_corporate()], select the requested scope columns and
#' error if they are not present. Avoids the silent-misaggregation
#' failure mode where a user sums a column that is actually Scope
#' 1+2 combined when they intended Scope 1 only.
#'
#' Column-name detection is heuristic because NGER renames columns
#' year to year. Pass `col_pattern` to override.
#'
#' @param x A `cer_tbl` or data frame from [cer_nger_corporate()].
#' @param scope One of `"1_plus_2"` (default), `"1"`, `"2_market"`,
#'   or `"2_location"`.
#' @param col_pattern Optional regex override for the target column.
#'
#' @return A data frame with an `emissions_t_co2e` column populated
#'   by the requested scope and a `scope` column recording which
#'   scope was selected.
#' @family nger
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' try({
#'   x <- cer_nger_corporate(2025)
#'   cer_nger_scope(x, scope = "1")
#' })
#' options(op)
#' }
cer_nger_scope <- function(x,
                            scope = c("1_plus_2", "1",
                                      "2_market", "2_location"),
                            col_pattern = NULL) {
  scope <- match.arg(scope)
  df <- as.data.frame(x, stringsAsFactors = FALSE)
  if (is.null(col_pattern)) {
    col_pattern <- switch(scope,
      `1_plus_2`    = "scope.?1.?(and|[+]).?2|scope_1_2|total.?emissions",
      `1`           = "scope.?1(?!.?2)",
      `2_market`    = "scope.?2.?market|scope_2_market",
      `2_location`  = "scope.?2.?location|scope_2_location|scope.?2(?!.?market)"
    )
  }
  # Try Perl-regex; fall back if cer renames don't use the markers.
  hit <- suppressWarnings(
    grep(col_pattern, names(df), perl = TRUE, ignore.case = TRUE,
         value = TRUE)
  )
  if (length(hit) == 0L) {
    cli::cli_abort(c(
      "Could not find a column for scope {.val {scope}}.",
      "i" = "NGER column names drift year-to-year; pass {.arg col_pattern}.",
      "i" = "Available columns: {.val {head(names(df), 20L)}}"
    ))
  }
  df$emissions_t_co2e <- suppressWarnings(as.numeric(df[[hit[1L]]]))
  df$scope <- scope
  df$scope_source_column <- hit[1L]
  df
}

#' Translate NGER scope columns to Climate Active categories
#'
#' Climate Active (Australia's voluntary carbon-neutral certification)
#' uses a Scope 1 / Scope 2 (market-based and location-based) /
#' Scope 3 taxonomy. NGER publishes Scope 1 and Scope 2 only (Scope 3
#' is not NGER-reportable). This helper renames columns so an NGER
#' output flows into a Climate Active inventory template.
#'
#' @param x A `cer_tbl` or data frame from [cer_nger_corporate()].
#'
#' @return A data frame with Climate Active-style columns:
#'   `operational_scope_1_t_co2e`, `operational_scope_2_location_t_co2e`,
#'   `operational_scope_2_market_t_co2e`.
#'
#' @references
#' Department of Climate Change, Energy, the Environment and Water
#'   (annual). \emph{Climate Active Carbon Neutral Standard for
#'   Organisations}.
#'   \url{https://www.climateactive.org.au}
#'
#' Greenhouse Gas Protocol (2004). \emph{A Corporate Accounting and
#'   Reporting Standard (Revised Edition)}. World Resources Institute.
#'
#' @family nger
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' try({
#'   x <- cer_nger_corporate(2025)
#'   cer_nger_climate_active(x)
#' })
#' options(op)
#' }
cer_nger_climate_active <- function(x) {
  df <- as.data.frame(x, stringsAsFactors = FALSE)

  rename_if <- function(df, old, new) {
    i <- which(names(df) == old)
    if (length(i) > 0L) names(df)[i] <- new
    df
  }

  # Attempt heuristic rename on the most common NGER column shapes.
  scope1_col  <- grep("^scope_1(?!.*2)", names(df), perl = TRUE, value = TRUE)
  scope2m_col <- grep("scope.?2.?market",   names(df), perl = TRUE, value = TRUE)
  scope2l_col <- grep("scope.?2.?location", names(df), perl = TRUE, value = TRUE)

  if (length(scope1_col) > 0L) {
    df <- rename_if(df, scope1_col[1L], "operational_scope_1_t_co2e")
  }
  if (length(scope2m_col) > 0L) {
    df <- rename_if(df, scope2m_col[1L], "operational_scope_2_market_t_co2e")
  }
  if (length(scope2l_col) > 0L) {
    df <- rename_if(df, scope2l_col[1L], "operational_scope_2_location_t_co2e")
  }
  df$climate_active_ready <- TRUE
  df
}
