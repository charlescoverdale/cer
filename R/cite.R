# Citation helper.

#' Cite a cer_tbl or URL in BibTeX, plain-text, or APA form
#'
#' Returns a citation suitable for footnotes, papers, and carbon
#' market analysis reports. Uses the provenance attributes attached
#' to every `cer_tbl`: source URL, licence, retrieval date, title,
#' snapshot pin (from [cer_snapshot()]), and SHA-256 digest.
#'
#' For carbon market research, the BibTeX `note` field includes
#' the snapshot date and first 12 hex characters of the SHA-256,
#' which are the minimum provenance fields needed to defend a
#' published figure against a reviewer.
#'
#' @param x A `cer_tbl` (as returned by any `cer_*` data function)
#'   or a character URL.
#' @param style One of `"text"` (default), `"bibtex"`, or `"apa"`.
#' @param doi Optional DOI (e.g. from [cer_deposit_zenodo()]) to
#'   include in BibTeX output as a `doi` field and APA suffix.
#'
#' @return A character string.
#' @family reproducibility
#' @export
#' @examples
#' x <- data.frame(a = 1)
#' x <- structure(x,
#'   cer_source = "https://cer.gov.au/markets/reports-and-data/accu-project-and-contract-register",
#'   cer_licence = "CC BY 4.0",
#'   cer_retrieved = as.POSIXct("2026-04-24 00:00:00", tz = "UTC"),
#'   cer_title = "ACCU project register",
#'   cer_sha256 = "abc123def456",
#'   cer_snapshot_date = "2026-04-24",
#'   class = c("cer_tbl", "data.frame"))
#' cer_cite(x)
#' cer_cite(x, style = "bibtex")
#' # DOI style: supply any minted DOI (Zenodo, DataCite, etc.).
#' # The placeholder below is illustrative only.
#' cer_cite(x, style = "apa", doi = "10.5281/zenodo.XXXXXXXX")
cer_cite <- function(x, style = c("text", "bibtex", "apa"),
                      doi = NULL) {
  style <- match.arg(style)

  if (is.character(x) && length(x) == 1L) {
    src <- x
    licence <- "CC BY 4.0"
    retrieved <- Sys.time()
    title <- basename(x)
    sha <- NA_character_
    snap <- NA_character_
  } else if (inherits(x, "cer_tbl")) {
    src <- attr(x, "cer_source") %||% ""
    licence <- attr(x, "cer_licence") %||% "CC BY 4.0"
    retrieved <- attr(x, "cer_retrieved") %||% Sys.time()
    title <- attr(x, "cer_title") %||% "Clean Energy Regulator data"
    sha <- attr(x, "cer_sha256") %||% NA_character_
    snap <- attr(x, "cer_snapshot_date") %||% NA_character_
  } else {
    cli::cli_abort(
      "{.arg x} must be a {.cls cer_tbl} or a character URL."
    )
  }

  date_str <- format(as.Date(retrieved), "%Y-%m-%d")
  year <- format(as.Date(retrieved), "%Y")
  sha_str <- if (!is.na(sha) && nzchar(sha)) substr(sha, 1, 12) else ""
  snap_str <- if (!is.na(snap) && nzchar(snap)) snap else ""

  note_parts <- c(
    sprintf("Retrieved %s", date_str),
    sprintf("licensed under %s", licence)
  )
  if (nzchar(snap_str)) note_parts <- c(note_parts,
                                         sprintf("snapshot %s", snap_str))
  if (nzchar(sha_str)) note_parts <- c(note_parts,
                                        sprintf("sha256:%s", sha_str))
  note <- paste(note_parts, collapse = "; ")

  doi_line <- if (!is.null(doi) && nzchar(doi)) {
    sprintf("  doi    = {%s},\n", doi)
  } else {
    ""
  }

  switch(style,
    text = {
      s <- sprintf(
        "Clean Energy Regulator. %s. Retrieved %s from %s. Licensed under %s.",
        title, date_str, src, licence
      )
      if (nzchar(snap_str)) s <- paste0(s, " Snapshot: ", snap_str, ".")
      if (nzchar(sha_str)) s <- paste0(s, " SHA-256: ", sha_str, ".")
      if (!is.null(doi) && nzchar(doi)) s <- paste0(s, " DOI: ", doi, ".")
      s
    },
    apa = {
      s <- sprintf(
        "Clean Energy Regulator. (%s). %s [Data set]. cer.gov.au. %s",
        year, title, src
      )
      if (!is.null(doi) && nzchar(doi)) s <- paste0(s, " https://doi.org/", doi)
      s
    },
    bibtex = sprintf(
      paste0(
        "@misc{cer_%s,\n",
        "  author = {{Clean Energy Regulator}},\n",
        "  title  = {{%s}},\n",
        "  year   = {%s},\n",
        "%s",
        "  note   = {%s},\n",
        "  url    = {%s}\n",
        "}"
      ),
      gsub("[^a-z0-9]+", "_", tolower(title)),
      title, year, doi_line, note, src
    )
  )
}
