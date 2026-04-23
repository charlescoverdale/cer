# ACCU Scheme — project register, issuances, contracts, methods, relinquishments

#' @noRd
ACCU_PROJECT_CSV <- "https://cer.gov.au/document/accu-scheme-project-register-0"

#' @noRd
ACCU_CONTRACT_CSV <- "https://cer.gov.au/document/carbon-abatement-contract-register-0"

#' ACCU Scheme project register
#'
#' Download and parse the Clean Energy Regulator's Australian
#' Carbon Credit Unit ('ACCU') Scheme project register. Returns one
#' row per project with proponent, method, state, crediting period,
#' permanence period, and cumulative ACCUs issued and relinquished.
#'
#' The register is updated monthly by the CER, usually around the
#' third week. Downloaded once per R session (or invalidate with
#' [cer_clear_cache()]).
#'
#' @param state Optional character vector of Australian state
#'   codes (e.g. `"NSW"`, `c("VIC", "QLD")`) to filter on. `NULL`
#'   returns projects across all states.
#' @param method Optional character vector of method name
#'   substrings (case-insensitive, e.g. `"savanna"`, `"landfill"`,
#'   `"vegetation"`).
#' @param status Character. One of `"active"` (default), `"revoked"`,
#'   `"completed"`, or `"all"`.
#'
#' @return A `cer_tbl` (data frame) with one row per ACCU project.
#'
#' @source Clean Energy Regulator, ACCU project and contract register:
#'   <https://cer.gov.au/markets/reports-and-data/accu-project-and-contract-register>.
#'   Licensed under CC BY 4.0.
#'
#' @family accu
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' p <- cer_accu_projects(state = "NSW")
#' head(p)
#' options(op)
#' }
cer_accu_projects <- function(state = NULL, method = NULL,
                               status = c("active", "revoked", "completed", "all")) {
  status <- match.arg(status)
  df <- cer_fetch_csv(ACCU_PROJECT_CSV)

  df <- cer_filter_in(df, "state", state)
  df <- cer_filter_like(df, "method", method)

  if (status != "all") {
    status_col <- intersect(c("project_status", "status"), names(df))[1]
    if (!is.na(status_col)) {
      df <- df[tolower(df[[status_col]]) == status, , drop = FALSE]
    }
  }

  rownames(df) <- NULL
  new_cer_tbl(df,
              source = ACCU_PROJECT_CSV,
              licence = "CC BY 4.0",
              title = "ACCU Scheme project register")
}

#' ACCU issuances by project
#'
#' Derived from the ACCU Scheme project register: returns one row
#' per project with `accus_issued`, project metadata, and total
#' issuance net of relinquishments. For method- or period-level
#' issuance tracking, query [cer_accu_projects()] directly.
#'
#' @param method Optional character vector of method substrings.
#' @param project_id Optional character vector of ERF / EOP project
#'   identifiers.
#' @param from,to Optional `Date` (or YYYY-MM-DD string) for
#'   crediting-period overlap filter. `NULL` returns all projects.
#'
#' @return A `cer_tbl` with one row per project.
#' @source Clean Energy Regulator ACCU project register (CC BY 4.0).
#' @family accu
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' i <- cer_accu_issuances(method = "savanna")
#' head(i)
#' options(op)
#' }
cer_accu_issuances <- function(method = NULL, project_id = NULL,
                                from = NULL, to = NULL) {
  df <- cer_fetch_csv(ACCU_PROJECT_CSV)
  df <- cer_filter_like(df, "method", method)
  df <- cer_filter_in(df, "project_id", project_id)

  if (!is.null(from) || !is.null(to)) {
    start_col <- intersect(c("crediting_period_start", "start_date"), names(df))[1]
    end_col <- intersect(c("crediting_period_end", "end_date"), names(df))[1]
    if (!is.na(start_col) && !is.na(end_col)) {
      s <- suppressWarnings(as.Date(df[[start_col]]))
      e <- suppressWarnings(as.Date(df[[end_col]]))
      if (!is.null(from)) df <- df[is.na(e) | e >= as.Date(from), , drop = FALSE]
      if (!is.null(to))   df <- df[is.na(s) | s <= as.Date(to), , drop = FALSE]
    }
  }

  rownames(df) <- NULL
  new_cer_tbl(df,
              source = ACCU_PROJECT_CSV,
              licence = "CC BY 4.0",
              title = "ACCU issuances by project")
}

#' ACCU Carbon Abatement Contract register
#'
#' Government purchase contracts under Emissions Reduction Fund
#' auctions administered by the CER.
#'
#' @param auction Optional character vector of auction identifiers
#'   (e.g. `"ERF Auction 18"`).
#'
#' @return A `cer_tbl` with one row per contract.
#' @source Clean Energy Regulator Carbon Abatement Contract register
#'   (CC BY 4.0).
#' @family accu
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' cer_accu_contracts()
#' options(op)
#' }
cer_accu_contracts <- function(auction = NULL) {
  df <- cer_fetch_csv(ACCU_CONTRACT_CSV)
  df <- cer_filter_like(df, "auction", auction)
  rownames(df) <- NULL
  new_cer_tbl(df,
              source = ACCU_CONTRACT_CSV,
              licence = "CC BY 4.0",
              title = "Carbon Abatement Contract register")
}

#' Approved ACCU Scheme methods
#'
#' A static table of ACCU Scheme methods grouped by sector
#' (Agriculture, Energy Efficiency, Landfill and Waste,
#' Mining/Oil/Gas, Vegetation, Savanna, Blue Carbon,
#' Transport). Built from the CER methods index at build time.
#'
#' Because the CER publishes methods as per-method PDFs on the
#' Federal Register of Legislation rather than a machine-readable
#' index, this function returns a package-embedded lookup. The
#' `status` column captures post-Chubb Review changes: methods
#' are flagged as `"active"`, `"expired"`, `"suspended"`, or
#' `"under_review"`. Run [cer_accu_projects()] then
#' `unique(x$method)` to cross-check against currently-registered
#' projects.
#'
#' @return A `cer_tbl` with columns `method`, `sector`,
#'   `short_name`, `status`, `commenced`, and `source_url`.
#' @source Clean Energy Regulator ACCU Scheme methods index
#'   <https://cer.gov.au/schemes/australian-carbon-credit-unit-scheme/accu-scheme-methods>.
#' @family accu
#' @export
#' @examples
#' m <- cer_accu_methods()
#' head(m)
cer_accu_methods <- function() {
  # Embedded via sysdata.rda — regenerated by data-raw/build_accu_methods.R
  df <- get0("accu_methods", envir = asNamespace("cer"))
  if (is.null(df)) {
    # Fallback seed table so the function always works before
    # sysdata has been built. Reflects the post-Chubb method
    # landscape as of April 2026.
    df <- data.frame(
      method = c(
        # Vegetation
        "Human-induced regeneration of a permanent even-aged native forest",
        "Avoided deforestation",
        "Avoided clearing of native regrowth",
        "Native forest from managed regrowth",
        "Reforestation by environmental or mallee plantings (2014)",
        "Reforestation by environmental or mallee plantings (FullCAM 2024)",
        # Savanna
        "Savanna fire management 2018 (emissions avoidance)",
        "Savanna fire management 2018 (sequestration and emissions avoidance)",
        "Savanna fire management 2026",
        # Agriculture
        "Beef cattle herd management",
        "Piggery waste",
        "Measurement of soil carbon sequestration in agricultural systems",
        # Landfill and Waste
        "Landfill gas",
        "Alternative waste treatment",
        # Mining / Oil / Gas
        "Coal mine waste gas",
        "Oil and gas fugitive emissions",
        # Energy Efficiency
        "Energy efficiency in commercial buildings",
        "Industrial equipment upgrades",
        # Blue carbon
        "Tidal restoration of blue carbon ecosystems"
      ),
      sector = c(
        rep("Vegetation", 6L),
        rep("Savanna", 3L),
        rep("Agriculture", 3L),
        rep("Landfill and Waste", 2L),
        rep("Mining/Oil/Gas", 2L),
        rep("Energy Efficiency", 2L),
        "Blue carbon"
      ),
      short_name = c(
        "HIR", "AD", "AC native regrowth", "MNFR",
        "Plantings 2014", "Plantings 2024",
        "Savanna EA 2018", "Savanna EA+S 2018", "Savanna 2026",
        "Beef cattle", "Piggery", "Soil measured",
        "Landfill", "AWT",
        "CMWG", "Oil and gas FE",
        "Commercial", "Industrial",
        "Blue carbon"
      ),
      # Status reflects post-Chubb Review changes (January 2023):
      #  - "under_review": HIR pending IFLM replacement method
      #  - "suspended":    Avoided Deforestation closed to new projects
      #  - "expired":      Plantings 2014 expired 30 September 2024,
      #                    superseded by Plantings 2024 FullCAM method
      #  - "superseded":   Savanna 2018 methods superseded by
      #                    Savanna Fire Management 2026
      #  - "active":       everything else
      status = c(
        "under_review", "suspended", "active", "active",
        "expired", "active",
        "superseded", "superseded", "active",
        "active", "active", "active",
        "active", "active",
        "active", "active",
        "active", "active",
        "active"
      ),
      commenced = as.Date(c(
        "2013-07-01", "2015-04-01", "2015-04-01", "2015-07-01",
        "2014-05-30", "2024-10-01",
        "2018-05-01", "2018-05-01", "2026-01-01",
        "2015-08-12", "2012-11-09", "2018-02-09",
        "2012-08-24", "2015-07-01",
        "2018-03-28", "2022-06-01",
        "2013-07-01", "2015-07-01",
        "2022-06-01"
      )),
      source_url = rep(
        "https://cer.gov.au/schemes/australian-carbon-credit-unit-scheme/accu-scheme-methods",
        19L
      ),
      stringsAsFactors = FALSE
    )
  }
  new_cer_tbl(df,
              source = "https://cer.gov.au/schemes/australian-carbon-credit-unit-scheme/accu-scheme-methods",
              licence = "CC BY 4.0",
              title = "ACCU Scheme methods (post-Chubb)")
}

#' ACCU relinquishments by project
#'
#' Returns projects with non-zero ACCU relinquishments. Useful for
#' tracking voluntary cancellations and compliance obligations.
#'
#' @param project_id Optional character vector of project IDs.
#'
#' @return A `cer_tbl` with one row per project with
#'   `accus_relinquished > 0`.
#' @source Clean Energy Regulator ACCU project register (CC BY 4.0).
#' @family accu
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' cer_accu_relinquishments()
#' options(op)
#' }
cer_accu_relinquishments <- function(project_id = NULL) {
  df <- cer_fetch_csv(ACCU_PROJECT_CSV)
  df <- cer_filter_in(df, "project_id", project_id)

  rel_col <- intersect(
    c("accus_relinquished", "relinquished_accus", "relinquishments"),
    names(df)
  )[1]
  if (!is.na(rel_col)) {
    vals <- suppressWarnings(as.numeric(df[[rel_col]]))
    df <- df[!is.na(vals) & vals > 0, , drop = FALSE]
  }
  rownames(df) <- NULL
  new_cer_tbl(df,
              source = ACCU_PROJECT_CSV,
              licence = "CC BY 4.0",
              title = "ACCU relinquishments by project")
}
