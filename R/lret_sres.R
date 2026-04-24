# LRET + SRES

#' @noRd
LRET_POWER_STATIONS_CSV <- "https://cer.gov.au/document/historical-accredited-power-stations-and-projects-0"

#' @noRd
LRET_LANDING <- "https://cer.gov.au/markets/reports-and-data/large-scale-renewable-energy-data/historical-large-scale-renewable-energy-supply-data"

#' @noRd
SRES_INSTALL_XLSX <- "https://cer.gov.au/document/sres-postcode-data-installations-2011-to-present-and-totals"

#' @noRd
SRES_CAPACITY_XLSX <- "https://cer.gov.au/document/sres-postcode-data-capacity-2011-to-present-and-totals"

#' @noRd
SRES_LANDING <- "https://cer.gov.au/markets/reports-and-data/small-scale-installation-postcode-data"

#' LRET accredited power stations
#'
#' Power stations accredited under the Large-scale Renewable
#' Energy Target ('LRET') and eligible to create Large-scale
#' Generation Certificates ('LGCs').
#'
#' @param technology Optional character vector of technology
#'   substrings (e.g. `"solar"`, `"wind"`, `"hydro"`, `"bioenergy"`).
#' @param state Optional character vector of Australian state codes
#'   (e.g. `c("VIC", "SA")`).
#'
#' @return A `cer_tbl` with one row per accredited power station,
#'   including accreditation date, technology, capacity (MW), and
#'   state.
#'
#' @source Clean Energy Regulator, Historical large-scale renewable
#'   energy supply data:
#'   <https://cer.gov.au/markets/reports-and-data/large-scale-renewable-energy-data/historical-large-scale-renewable-energy-supply-data>.
#'   Licensed under CC BY 4.0.
#'
#' @references
#' Commonwealth of Australia. \emph{Renewable Energy (Electricity)
#'   Act 2000}. Establishes the Renewable Energy Target (RET), the
#'   LGC (Large-scale Generation Certificate) and the shortfall
#'   charge mechanism.
#'
#' Clean Energy Regulator (annual). \emph{LRET: Accreditation and
#'   eligibility guidelines for power stations}.
#'
#' Australian Energy Market Commission (2023). \emph{Integrated
#'   System Plan 2024} reference on renewable capacity expansion.
#'
#' @family lret
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' s <- cer_lgc_power_stations(technology = "solar", state = "VIC")
#' head(s)
#' options(op)
#' }
cer_lgc_power_stations <- function(technology = NULL, state = NULL) {
  df <- cer_fetch_csv(LRET_POWER_STATIONS_CSV)
  df <- cer_filter_like(df, "fuel_source", technology)
  if (is.null(technology) == FALSE && !"fuel_source" %in% names(df)) {
    df <- cer_filter_like(df, "technology", technology)
  }
  df <- cer_filter_in(df, "state", state)
  rownames(df) <- NULL
  new_cer_tbl(df,
              source = LRET_LANDING,
              licence = "CC BY 4.0",
              title = "LRET accredited power stations")
}

#' SRES small-scale installations by postcode
#'
#' Monthly Small-scale Renewable Energy Scheme ('SRES') installation
#' counts or capacity by postcode. Covers rooftop solar PV, solar
#' water heaters, air-source heat pumps, and small batteries.
#'
#' @param technology Character. One of `"solar_pv"` (default), `"swh"`
#'   (solar water heater), `"heat_pump"`, or `"battery"`.
#' @param postcode Optional character vector of 4-digit Australian
#'   postcodes to filter on.
#' @param measure Character. `"installations"` (default, counts) or
#'   `"capacity"` (total kW installed).
#'
#' @return A `cer_tbl`. For `measure = "installations"` columns
#'   include postcode and per-month install counts. For
#'   `measure = "capacity"`, per-month kW capacity.
#'
#' @source Clean Energy Regulator, Small-scale installation
#'   postcode data:
#'   <https://cer.gov.au/markets/reports-and-data/small-scale-installation-postcode-data>.
#'   Licensed under CC BY 4.0.
#'
#' @references
#' Commonwealth of Australia. \emph{Renewable Energy (Electricity)
#'   Act 2000}, Small-scale Renewable Energy Scheme provisions.
#'
#' Australian Energy Market Operator (2024). \emph{Distributed PV
#'   Forecasting Methodology}. AEMO uses SRES installation data
#'   as input to ISP and ESOO forecasts.
#'
#' Best, R., Burke, P.J. and Nishitateno, S. (2019). "Understanding
#'   the determinants of rooftop solar installation: evidence from
#'   Australian household data." \emph{Energy Economics}, 84.
#'   \doi{10.1016/j.eneco.2019.104515}
#'
#' @family sres
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' inst <- cer_sres_installations(postcode = c("2000", "3000"))
#' head(inst)
#' options(op)
#' }
cer_sres_installations <- function(technology = c("solar_pv", "swh", "heat_pump", "battery"),
                                    postcode = NULL,
                                    measure = c("installations", "capacity")) {
  technology <- match.arg(technology)
  measure <- match.arg(measure)

  url <- if (measure == "installations") SRES_INSTALL_XLSX else SRES_CAPACITY_XLSX
  df <- cer_fetch_xlsx(url, sheet = 1, skip = 0)

  tech_col <- intersect(c("sgu_type", "technology", "type"), names(df))[1]
  if (!is.na(tech_col)) {
    label <- switch(technology,
      solar_pv = "solar",
      swh = "water",
      heat_pump = "heat pump",
      battery = "battery"
    )
    df <- cer_filter_like(df, tech_col, label)
  }

  if (!is.null(postcode)) {
    pc_col <- intersect(c("postcode", "post_code"), names(df))[1]
    if (!is.na(pc_col)) {
      df <- df[as.character(df[[pc_col]]) %in% as.character(postcode), , drop = FALSE]
    }
  }
  rownames(df) <- NULL

  new_cer_tbl(df,
              source = SRES_LANDING,
              licence = "CC BY 4.0",
              title = paste0("SRES ", technology, " ", measure))
}
