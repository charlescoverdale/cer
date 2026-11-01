# ACCU integrity layer : the unique `cer` contribution.
#
# After Chubb (2022), Australian carbon credit units cannot be
# treated as fungible. Different methods have different integrity
# profiles; some are under review; some are suspended. This layer
# surfaces those distinctions to users before they aggregate or
# publish numbers.

#' ACCU method integrity scorecard
#'
#' Returns a method-level integrity scorecard for all ACCU methods.
#' Columns include `integrity_tier` (high / standard / contested),
#' `chubb_affected` (whether the Chubb 2022 Independent Review
#' flagged the method), `chubb_recommendation_applies` (whether a
#' specific Chubb recommendation targets the method), and
#' `federal_register_instrument` (authoritative legislative
#' instrument ID).
#'
#' Use this to filter or weight ACCU aggregates, or to annotate a
#' chart with integrity context. For example, an analyst reporting
#' "185 million ACCUs issued to date" should, at minimum, break
#' the total down by `integrity_tier` and flag the contested share.
#'
#' @param tier Optional filter on `integrity_tier`. One or more of
#'   `"high"`, `"standard"`, `"contested"`.
#' @param status Optional filter on method `status`. One or more of
#'   `"active"`, `"suspended"`, `"under_review"`, `"superseded"`,
#'   `"expired"`.
#'
#' @return A `cer_tbl` with one row per method (19 rows at v0.2.0). The
#'   `register_pattern` column is the regular expression that assigns the
#'   ACCU project register's full legal method names (for example,
#'   "Carbon Credits (Carbon Farming Initiative-Landfill Gas) Methodology
#'   Determination 2015") to each row; [cer_accu_aggregate()] and the
#'   `chubb_flag` column of [cer_accu_projects()] use it. Register methods
#'   that no pattern matches are reported as `"unclassified"`.
#'
#' @references
#' Chubb, I. (2022). \emph{Independent Review of Australian Carbon
#'   Credit Units}. Commonwealth of Australia, Department of
#'   Climate Change, Energy, the Environment and Water.
#'
#' Macintosh, A., Butler, D., Larraondo, P., Evans, M.C., Ansell,
#'   D., Gibbons, P., Lindenmayer, D., Waschka, M. and Fisher, R.
#'   (2022). "The emperor's new clothes: assessing the integrity
#'   of ACCUs." Australian National University working paper series.
#'
#' Butler, D., Macintosh, A. and Pouliot, M. (2023). "Response to
#'   the Chubb Review." Australian National University.
#'
#' Ansell, D. \emph{et al.} (2020). "Contemporary fire regimes of
#'   northern Australia: a review of current patterns, impacts and
#'   challenges." \emph{Environmental Research Reviews}.
#'
#' @family accu
#' @export
#' @examples
#' cer_method_integrity()
#' cer_method_integrity(tier = "contested")
#' cer_method_integrity(status = "active")
cer_method_integrity <- function(tier = NULL, status = NULL) {
  path <- system.file("extdata", "accu_method_integrity.csv",
                       package = "cer")
  if (!nzchar(path) || !file.exists(path)) {
    cli::cli_abort(
      "Method integrity CSV not installed at {.path inst/extdata/}."
    )
  }
  df <- utils::read.csv(path, stringsAsFactors = FALSE,
                         na.strings = c("", "NA"), check.names = FALSE)
  if (!is.null(tier)) {
    df <- df[df$integrity_tier %in% tolower(tier), , drop = FALSE]
  }
  if (!is.null(status)) {
    df <- df[df$status %in% tolower(status), , drop = FALSE]
  }
  rownames(df) <- NULL
  new_cer_tbl(df,
              source = "https://cer.gov.au/schemes/australian-carbon-credit-unit-scheme/accu-scheme-methods",
              licence = "CC BY 4.0",
              title = "ACCU method integrity scorecard (post-Chubb)")
}

#' Federal Register URL for an ACCU method determination
#'
#' Given a method short name (e.g. `"HIR"`, `"Savanna_2026"`),
#' return the authoritative legislative instrument URL on the
#' Federal Register of Legislation. This is the technical
#' determination document that defines measurement, monitoring,
#' baseline, and permanence rules for the method.
#'
#' @param method_short Character scalar matching a `method_short`
#'   value from [cer_method_integrity()].
#'
#' @return A length-1 character URL, or `NA_character_` if not found.
#' @family accu
#' @export
#' @examples
#' cer_method_determination("HIR")
#' cer_method_determination("Savanna_2026")
cer_method_determination <- function(method_short) {
  stopifnot(is.character(method_short), length(method_short) == 1L)
  df <- as.data.frame(cer_method_integrity())
  hit <- df[df$method_short == method_short, ]
  if (nrow(hit) == 0L) {
    cli::cli_warn(c(
      "No method found with {.val method_short = {method_short}}.",
      "i" = "Run {.code cer_method_integrity()} to see available names."
    ))
    return(NA_character_)
  }
  hit$latest_determination_url[1L]
}

#' Integrity-weighted ACCU aggregation
#'
#' Takes an `ato_tbl` or data frame of ACCU project records (from
#' [cer_accu_projects()]), joins the method integrity scorecard,
#' and aggregates by integrity tier. Emits a warning if contested
#' or under-review methods contribute materially to the total so
#' the analyst cannot silently aggregate them into a single
#' headline figure.
#'
#' @param x A `cer_tbl` or data frame with columns `method` and a
#'   numeric issuance column.
#' @param value_col Column to sum. Default `NULL` uses the register's
#'   `accus_total_units_issued` column (or `accus_issued`, if that is the
#'   one `x` has).
#' @param warn_contested_pct Warn if the contested tier exceeds
#'   this share of the total. Default `0.05` (5%).
#'
#' @return A data frame with one row per integrity tier and
#'   columns `integrity_tier`, `projects`, `<value_col>_sum` and
#'   `share_pct`. Register methods are assigned to a tier through the
#'   scorecard's `register_pattern`; methods it does not cover are
#'   `"unclassified"`.
#' @family accu
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' try({
#'   p <- cer_accu_projects()
#'   cer_accu_aggregate(p)
#' })
#' options(op)
#' }
cer_accu_aggregate <- function(x,
                                value_col = NULL,
                                warn_contested_pct = 0.05) {
  if (is.data.frame(x)) {
    df <- as.data.frame(x, stringsAsFactors = FALSE)
  } else {
    cli::cli_abort("{.arg x} must be a data frame.")
  }
  if (!"method" %in% names(df)) {
    cli::cli_abort(
      "{.arg x} has no {.val method} column."
    )
  }
  if (is.null(value_col)) {
    value_col <- intersect(c("accus_total_units_issued", "accus_issued"),
                           names(df))[1]
    if (is.na(value_col)) value_col <- "accus_total_units_issued"
  }
  if (!value_col %in% names(df)) {
    cli::cli_warn(c(
      "Column {.val {value_col}} not in {.arg x}; using row counts.",
      "i" = "Pass {.arg value_col} to specify a numeric column."
    ))
    df$.value <- 1
  } else {
    df$.value <- suppressWarnings(as.numeric(df[[value_col]]))
  }

  integ <- as.data.frame(cer_method_integrity())
  joined <- df
  joined$integrity_tier <- integ$integrity_tier[cer_method_lookup(df$method, integ)]
  joined$integrity_tier[is.na(joined$integrity_tier)] <- "unclassified"

  agg <- stats::aggregate(
    cbind(projects = 1, value = joined$.value) ~ integrity_tier,
    data = joined, FUN = sum, na.rm = TRUE
  )
  names(agg)[names(agg) == "value"] <- paste0(value_col, "_sum")
  total <- sum(agg[[paste0(value_col, "_sum")]], na.rm = TRUE)
  agg$share_pct <- 100 * agg[[paste0(value_col, "_sum")]] / total
  agg <- agg[order(-agg$share_pct), , drop = FALSE]
  rownames(agg) <- NULL

  contested_share <- sum(agg[[paste0(value_col, "_sum")]][
    agg$integrity_tier == "contested"
  ], na.rm = TRUE) / total
  if (isTRUE(contested_share > warn_contested_pct)) {
    cli::cli_warn(c(
      "Contested-integrity methods account for {round(100 * contested_share, 1)}% of the total.",
      "i" = "Chubb (2022) flagged these methods for review.",
      "i" = "Do not report a single headline figure without breaking down by integrity tier."
    ))
  }
  agg
}

#' @noRd
# Internal helper: attach a `chubb_flag` column to a data frame of
# ACCU projects, looking up the method via the integrity scorecard.
cer_attach_chubb_flag <- function(df) {
  if (!"method" %in% names(df)) return(df)
  integ <- as.data.frame(cer_method_integrity())
  df$chubb_flag <- integ$status[cer_method_lookup(df$method, integ)]
  df$chubb_flag[is.na(df$chubb_flag)] <- "unclassified"
  df
}

#' @noRd
# Index of the scorecard row each register method belongs to (NA when the
# scorecard does not cover it). The register names a method by its full
# legal title ("Carbon Credits (Carbon Farming Initiative-Landfill Gas)
# Methodology Determination 2015 (Compilation No. 1)"), never by the
# scorecard's short name, so an exact join on the name matched nothing
# and every project came out "unclassified". Rows are matched on
# `register_pattern`; an exact scorecard name still matches its own row.
cer_method_lookup <- function(methods,
                              integ = as.data.frame(cer_method_integrity())) {
  idx <- match(tolower(methods), tolower(integ$method_full_name))
  for (i in seq_len(nrow(integ))) {
    hit <- is.na(idx) &
      grepl(integ$register_pattern[i], methods, ignore.case = TRUE, perl = TRUE)
    idx[hit] <- i
  }
  idx
}
