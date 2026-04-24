# Session-level manifest: every fetch appends a row recording URL,
# SHA-256, timestamp, snapshot pin, and dataset title. Export for
# paper appendix or Zenodo deposit.

#' @noRd
.cer_manifest_append <- function(url, file = NA_character_,
                                  title = NA_character_,
                                  licence = NA_character_) {
  sha <- if (!is.na(file) && file.exists(file)) cer_sha256(file) else NA_character_
  size <- if (!is.na(file) && file.exists(file)) {
    as.numeric(file.info(file)$size)
  } else {
    NA_real_
  }
  row <- data.frame(
    url            = url,
    title          = title,
    licence        = licence,
    sha256         = sha,
    size_bytes     = size,
    retrieved      = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    snapshot_date  = cer_snapshot_str(),
    r_version      = as.character(getRversion()),
    cer_version    = as.character(utils::packageVersion("cer")),
    stringsAsFactors = FALSE
  )
  key <- url
  existing <- .cer_env$manifest %||% list()
  existing[[key]] <- row
  .cer_env$manifest <- existing
  invisible(row)
}

#' Return the session manifest of fetched CER datasets
#'
#' Every call to a data function appends one row to the session
#' manifest, recording URL, dataset title, SHA-256 of the cached
#' file, size, retrieval timestamp, and the snapshot pin set via
#' [cer_snapshot()]. Duplicate URLs within a session are
#' deduplicated (last fetch wins).
#'
#' For carbon market research this is the minimum artefact needed
#' for reproducibility: ACCU project registers and Safeguard
#' releases change retroactively, so a citation that points to a
#' URL alone is not enough. The manifest plus SHA-256 fixes the
#' exact bytes analysed.
#'
#' @param format One of `"df"` (default), `"yaml"`, or `"json"`.
#' @return A data frame, YAML string, or JSON string.
#' @family reproducibility
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' cer_manifest_clear()
#' cer_snapshot("2026-04-24")
#' cer_manifest()
#' options(op)
#' }
cer_manifest <- function(format = c("df", "yaml", "json")) {
  format <- match.arg(format)
  rows <- .cer_env$manifest %||% list()
  if (length(rows) == 0L) {
    df <- data.frame(
      url = character(0), title = character(0),
      licence = character(0), sha256 = character(0),
      size_bytes = numeric(0), retrieved = character(0),
      snapshot_date = character(0), r_version = character(0),
      cer_version = character(0),
      stringsAsFactors = FALSE
    )
  } else {
    df <- do.call(rbind, rows)
    rownames(df) <- NULL
  }
  if (format == "df") return(df)
  if (format == "json") {
    if (!requireNamespace("jsonlite", quietly = TRUE)) {
      cli::cli_abort("JSON output requires the {.pkg jsonlite} package.")
    }
    return(jsonlite::toJSON(df, pretty = TRUE, auto_unbox = TRUE,
                            na = "null"))
  }
  cer_to_yaml(df)
}

#' Clear the session manifest
#'
#' @return Invisibly `NULL`.
#' @family reproducibility
#' @export
#' @examples
#' cer_manifest_clear()
cer_manifest_clear <- function() {
  .cer_env$manifest <- list()
  invisible(NULL)
}

#' Write the session manifest to a file
#'
#' @param path Output file path. Extension determines format when
#'   `format = "auto"`.
#' @param format One of `"auto"`, `"csv"`, `"yaml"`, `"json"`.
#' @return Invisibly, the absolute path written.
#' @family reproducibility
#' @export
#' @examples
#' \donttest{
#' p <- tempfile(fileext = ".csv")
#' cer_manifest_clear()
#' cer_manifest_write(p)
#' }
cer_manifest_write <- function(path,
                                format = c("auto", "csv", "yaml", "json")) {
  format <- match.arg(format)
  if (format == "auto") {
    ext <- tolower(tools::file_ext(path))
    format <- switch(ext,
      csv = "csv",
      yaml = "yaml", yml = "yaml",
      json = "json",
      "csv"
    )
  }
  if (format == "csv") {
    utils::write.csv(cer_manifest("df"), path, row.names = FALSE)
  } else if (format == "yaml") {
    writeLines(cer_manifest("yaml"), path)
  } else {
    writeLines(cer_manifest("json"), path)
  }
  invisible(normalizePath(path, mustWork = FALSE))
}

#' @noRd
cer_to_yaml <- function(df) {
  if (nrow(df) == 0L) return("# empty manifest\n")
  entries <- vapply(seq_len(nrow(df)), function(i) {
    lines <- vapply(names(df), function(k) {
      v <- df[i, k, drop = TRUE]
      v <- if (is.na(v)) "null" else {
        s <- as.character(v)
        if (grepl("[:#\\-\\[\\]{}!&*]|^ | $", s)) {
          paste0("\"", gsub("\"", "\\\"", s, fixed = TRUE), "\"")
        } else {
          s
        }
      }
      sprintf("  %s: %s", k, v)
    }, character(1))
    paste0("- ", sub("^  ", "", lines[1]), "\n",
           paste(lines[-1], collapse = "\n"))
  }, character(1))
  paste(entries, collapse = "\n")
}
