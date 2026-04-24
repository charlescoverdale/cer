# Zenodo deposit helper. Mints a DOI for a CER data vintage so a
# paper can cite the exact snapshot rather than a URL that may
# return different bytes after a retroactive CER restatement.

#' Prepare a Zenodo deposit payload for the session manifest
#'
#' Builds Zenodo-shaped metadata for a data deposit using the
#' current [cer_manifest()] and the snapshot pin set via
#' [cer_snapshot()]. Dry run by default; pass `upload = TRUE` and
#' a token to actually deposit.
#'
#' Because CER data is revised retroactively, Zenodo DOIs are the
#' strongest reproducibility artefact available: they freeze the
#' exact bytes of the ACCU project register, Safeguard facility
#' file, or QCMR workbook at the date of analysis.
#'
#' @param title Deposit title. Defaults to a snapshot-date string.
#' @param description Free-text description. Defaults to a short
#'   auto-generated summary of datasets fetched.
#' @param creators List of creator records.
#' @param keywords Character vector of keywords.
#' @param upload Logical. If `TRUE`, POSTs to Zenodo.
#' @param sandbox Logical. If `TRUE`, uses Zenodo Sandbox for tests.
#' @param token Zenodo personal access token. Defaults to
#'   `Sys.getenv("ZENODO_TOKEN")`.
#'
#' @return A list with `payload`, `manifest_path`, and (on upload)
#'   `deposit_id`, `doi_prereserve`, `url`.
#' @family reproducibility
#' @export
#' @examples
#' \donttest{
#' cer_snapshot("2026-04-24")
#' cer_deposit_zenodo(
#'   title = "CER data snapshot for working paper v1",
#'   creators = list(list(name = "Author, A.")),
#'   upload = FALSE
#' )
#' }
cer_deposit_zenodo <- function(title = NULL,
                                description = NULL,
                                creators = list(list(name = "Anonymous")),
                                keywords = c("Clean Energy Regulator",
                                             "carbon markets", "Australia",
                                             "ACCU", "Safeguard",
                                             "reproducibility"),
                                upload = FALSE,
                                sandbox = FALSE,
                                token = Sys.getenv("ZENODO_TOKEN")) {
  man <- cer_manifest("df")
  if (nrow(man) == 0L) {
    cli::cli_warn(c(
      "Session manifest is empty.",
      "i" = "Fetch some datasets (e.g. {.code cer_accu_projects()}) first."
    ))
  }

  snap <- cer_snapshot_str()
  if (is.null(title) || is.na(title)) {
    title <- sprintf(
      "CER data snapshot %s",
      if (!is.na(snap)) snap else format(Sys.Date(), "%Y-%m-%d")
    )
  }
  if (is.null(description) || is.na(description)) {
    description <- sprintf(
      paste0("Snapshot of %d Clean Energy Regulator dataset(s) ",
             "fetched via the 'cer' R package (v%s). Snapshot ",
             "date: %s. Datasets: %s."),
      nrow(man), utils::packageVersion("cer"),
      if (!is.na(snap)) snap else "unset",
      paste(unique(man$title), collapse = "; ")
    )
  }

  payload <- list(
    metadata = list(
      title = title,
      description = description,
      upload_type = "dataset",
      creators = creators,
      keywords = as.list(keywords),
      license = "cc-by-4.0",
      access_right = "open",
      related_identifiers = lapply(unique(man$url), function(u) {
        list(identifier = u, relation = "isDerivedFrom", scheme = "url")
      })
    )
  )

  manifest_path <- file.path(tempdir(),
                              paste0("cer_manifest_",
                                     format(Sys.time(), "%Y%m%d_%H%M%S"),
                                     ".csv"))
  cer_manifest_write(manifest_path, format = "csv")

  result <- list(payload = payload, manifest_path = manifest_path)

  if (!isTRUE(upload)) {
    cli::cli_inform(c(
      "v" = "Dry run: payload built, manifest staged at {.path {manifest_path}}.",
      "i" = "Call with {.code upload = TRUE} to deposit to Zenodo."
    ))
    return(invisible(result))
  }

  if (!nzchar(token)) {
    cli::cli_abort(c(
      "No Zenodo token.",
      "i" = "Set {.envvar ZENODO_TOKEN} or pass {.arg token}."
    ))
  }

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    cli::cli_abort("Upload requires the {.pkg jsonlite} package.")
  }

  base <- if (isTRUE(sandbox)) {
    "https://sandbox.zenodo.org/api"
  } else {
    "https://zenodo.org/api"
  }

  create_url <- sprintf("%s/deposit/depositions", base)
  resp <- httr2::request(create_url) |>
    httr2::req_headers(Authorization = paste("Bearer", token)) |>
    httr2::req_body_json(payload) |>
    httr2::req_method("POST") |>
    httr2::req_error(is_error = function(r) FALSE) |>
    httr2::req_perform()

  if (httr2::resp_status(resp) >= 400L) {
    cli::cli_abort(c(
      "Zenodo returned HTTP {httr2::resp_status(resp)}.",
      "x" = httr2::resp_body_string(resp)
    ))
  }

  deposit <- jsonlite::fromJSON(httr2::resp_body_string(resp),
                                 simplifyVector = FALSE)
  upload_url <- deposit$links$bucket %||%
                sprintf("%s/files", deposit$links$self)

  file_resp <- httr2::request(sprintf("%s/%s", upload_url,
                                       basename(manifest_path))) |>
    httr2::req_headers(Authorization = paste("Bearer", token)) |>
    httr2::req_method("PUT") |>
    httr2::req_body_file(manifest_path) |>
    httr2::req_perform()

  if (httr2::resp_status(file_resp) >= 400L) {
    cli::cli_warn(c(
      "Manifest upload returned HTTP {httr2::resp_status(file_resp)}.",
      "i" = "Deposit created but file upload failed. Complete manually."
    ))
  }

  cli::cli_inform(c(
    "v" = "Zenodo deposit created.",
    "i" = "DOI (pre-reserved): {.val {deposit$metadata$prereserve_doi$doi}}",
    "i" = "Review and publish at {.url {deposit$links$html}}"
  ))

  result$deposit_id <- deposit$id
  result$doi_prereserve <- deposit$metadata$prereserve_doi$doi
  result$url <- deposit$links$html
  invisible(result)
}
