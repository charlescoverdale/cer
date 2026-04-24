# cer_tbl S3 class with provenance header

#' @noRd
new_cer_tbl <- function(df, source = NULL, licence = "CC BY 4.0",
                         retrieved = Sys.time(), title = NULL,
                         sha256 = NA_character_,
                         snapshot_date = cer_snapshot_str()) {
  stopifnot(is.data.frame(df))
  if (is.na(sha256) && !is.null(source) && nzchar(source)) {
    d <- tryCatch(cer_cache_dir(), error = function(e) NULL)
    if (!is.null(d)) {
      ext <- tools::file_ext(source)
      ext <- if (nzchar(ext)) paste0(".", ext) else ""
      f <- file.path(d, paste0(cer_digest_url(source), ext))
      if (file.exists(f)) sha256 <- cer_sha_read(f)
    }
  }
  attr(df, "cer_source") <- source
  attr(df, "cer_licence") <- licence
  attr(df, "cer_retrieved") <- retrieved
  attr(df, "cer_title") <- title
  attr(df, "cer_sha256") <- sha256
  attr(df, "cer_snapshot_date") <- snapshot_date
  class(df) <- c("cer_tbl", class(df))
  df
}

#' Print a cer_tbl
#'
#' Prints a provenance header (title, source URL, licence,
#' retrieval time, dimensions) followed by the data frame.
#'
#' @param x A `cer_tbl` object.
#' @param ... Passed to the next method.
#' @return Invisibly returns `x`.
#' @export
#' @examples
#' x <- data.frame(project_id = "ERF123", accus_issued = 4200)
#' x <- structure(x, cer_title = "Demo", cer_source = "https://cer.gov.au",
#'                cer_licence = "CC BY 4.0", cer_retrieved = Sys.time(),
#'                class = c("cer_tbl", "data.frame"))
#' print(x)
print.cer_tbl <- function(x, ...) {
  title <- attr(x, "cer_title") %||% "Clean Energy Regulator data"
  source <- attr(x, "cer_source") %||% "https://cer.gov.au"
  licence <- attr(x, "cer_licence") %||% "CC BY 4.0"
  retrieved <- attr(x, "cer_retrieved")
  retrieved_str <- if (!is.null(retrieved)) {
    format(retrieved, "%Y-%m-%d %H:%M %Z")
  } else {
    "-"
  }

  sha <- attr(x, "cer_sha256")
  snap <- attr(x, "cer_snapshot_date")
  cat("# cer_tbl: ", title, "\n", sep = "")
  cat("# Source:   ", source, "\n", sep = "")
  cat("# Licence:  ", licence, "\n", sep = "")
  cat("# Retrieved:", retrieved_str, "\n")
  if (!is.null(snap) && !is.na(snap)) {
    cat("# Snapshot: ", snap, "\n", sep = "")
  }
  if (!is.null(sha) && !is.na(sha) && nzchar(sha)) {
    cat("# SHA-256:  ", substr(sha, 1, 16), "...\n", sep = "")
  }
  cat("# Rows: ", formatC(nrow(x), big.mark = ",", format = "d"),
      "  Cols: ", ncol(x), "\n", sep = "")
  cat("\n")

  y <- x
  class(y) <- setdiff(class(y), "cer_tbl")
  print(y, ...)
  invisible(x)
}
