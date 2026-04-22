# cer_tbl S3 class with provenance header

#' @noRd
new_cer_tbl <- function(df, source = NULL, licence = "CC BY 4.0",
                         retrieved = Sys.time(), title = NULL) {
  stopifnot(is.data.frame(df))
  attr(df, "cer_source") <- source
  attr(df, "cer_licence") <- licence
  attr(df, "cer_retrieved") <- retrieved
  attr(df, "cer_title") <- title
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

  cat("# cer_tbl: ", title, "\n", sep = "")
  cat("# Source:   ", source, "\n", sep = "")
  cat("# Licence:  ", licence, "\n", sep = "")
  cat("# Retrieved:", retrieved_str, "\n")
  cat("# Rows: ", formatC(nrow(x), big.mark = ",", format = "d"),
      "  Cols: ", ncol(x), "\n", sep = "")
  cat("\n")

  y <- x
  class(y) <- setdiff(class(y), "cer_tbl")
  print(y, ...)
  invisible(x)
}
