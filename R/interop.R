# International comparator and carbondata interop.

#' Remap an ACCU project data frame to the carbondata voluntary-
#' project schema
#'
#' The `carbondata` R package exposes Verra, Gold Standard, ACR,
#' and CAR voluntary projects under a unified schema. This function
#' renames ACCU register columns to match, so an analyst can
#' compare ACCU issuance patterns against international voluntary
#' markets on a consistent basis.
#'
#' Schema mapping is lossy: ACCU-specific fields (Chubb flag,
#' permanence period, crediting-period dates) pass through with
#' original names.
#'
#' @param x A `cer_tbl` from [cer_accu_projects()].
#'
#' @return A data frame with carbondata-style columns:
#'   `project_id`, `project_name`, `methodology`, `project_type`,
#'   `country`, `registry`, `issued_credits_to_date`,
#'   `retired_credits_to_date`.
#'
#' @family interop
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' try({
#'   ccy <- cer_accu_projects()
#'   carb <- cer_to_carbondata(ccy)
#'   head(carb)
#' })
#' options(op)
#' }
cer_to_carbondata <- function(x) {
  df <- as.data.frame(x, stringsAsFactors = FALSE)

  rename_first <- function(df, candidates, target) {
    hit <- intersect(candidates, names(df))
    if (length(hit) > 0L) names(df)[names(df) == hit[1L]] <- target
    df
  }

  df <- rename_first(df, c("project_id", "era_project_id", "erf_project_id"),
                     "project_id")
  df <- rename_first(df, c("project_name", "name"), "project_name")
  df <- rename_first(df, c("method"), "methodology")
  df <- rename_first(df, c("sector", "method_sector"), "project_type")
  df <- rename_first(df, c("accus_issued", "issued"),
                     "issued_credits_to_date")
  df <- rename_first(df, c("accus_surrendered", "accus_relinquished",
                           "relinquished"),
                     "retired_credits_to_date")

  df$country <- "Australia"
  df$registry <- "Clean Energy Regulator (ACCU)"
  df
}

#' Bundled international carbon market comparator
#'
#' Returns headline price/volume figures for comparison between
#' ACCU (Australia) and major international markets: EU ETS, New
#' Zealand ETS, California-Quebec (WCI), Verra VCUs, and Gold
#' Standard. Values are indicative snapshots. For live data use
#' the companion `carbondata` package.
#'
#' @return A `cer_tbl` of indicative comparator data.
#'
#' @references
#' International Carbon Action Partnership (annual). \emph{Emissions
#'   Trading Worldwide: Status Report}. \url{https://icapcarbonaction.com}
#'
#' World Bank (annual). \emph{State and Trends of Carbon Pricing}.
#'
#' @family interop
#' @export
#' @examples
#' cer_international_comparator()
cer_international_comparator <- function() {
  df <- data.frame(
    market = c("ACCU", "EU_ETS", "NZ_ETS", "WCI",
               "Verra_VCU", "Gold_Standard_VER"),
    jurisdiction = c("Australia", "European Union", "New Zealand",
                      "California+Quebec", "International",
                      "International"),
    unit_name = c("ACCU", "EUA", "NZU", "CCA",
                   "VCU", "VER"),
    instrument_type = c("Offset (government-purchased or voluntary)",
                         "Compliance allowance",
                         "Compliance unit (hybrid cap and offset)",
                         "Compliance allowance",
                         "Voluntary offset",
                         "Voluntary offset"),
    indicative_price_2024_usd = c(22, 75, 35, 40, 5, 10),
    reference = c("QCMR Q4 2024",
                   "EEX secondary market",
                   "NZEA auction clearing price",
                   "WCI Joint Auction",
                   "Berkeley VROD",
                   "Gold Standard registry"),
    stringsAsFactors = FALSE
  )
  new_cer_tbl(df,
              source = "https://icapcarbonaction.com",
              licence = "Mixed (see reference column)",
              title = "International carbon market comparator (indicative)")
}
