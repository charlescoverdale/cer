# Internal helpers

#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x

#' @noRd
cer_format_bytes <- function(x) {
  if (is.na(x) || x < 1024) return(paste0(x, " B"))
  units <- c("KB", "MB", "GB", "TB")
  for (i in seq_along(units)) {
    x <- x / 1024
    if (x < 1024 || i == length(units)) {
      return(sprintf("%.1f %s", x, units[i]))
    }
  }
}

#' Clean column names: lowercase, snake_case, strip punctuation
#' @param x Character vector of column names.
#' @return Character vector of cleaned names.
#' @noRd
cer_clean_names <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", "_", x)
  x <- gsub("^_+|_+$", "", x)
  x <- gsub("_+", "_", x)
  x
}

#' Fetch a CSV from the CER site and return a tidy data frame
#'
#' Uses the cache-aware downloader to retrieve the file, then
#' \code{utils::read.csv} with sensible defaults. Column names
#' are cleaned to snake_case.
#'
#' @param url URL to a CSV file.
#' @param ... Passed to \code{utils::read.csv}.
#' @return A data frame.
#' @noRd
cer_fetch_csv <- function(url, ...) {
  file <- cer_download_cached(url)
  df <- utils::read.csv(file, stringsAsFactors = FALSE,
                        check.names = FALSE,
                        na.strings = c("", "NA", "N/A", "-"),
                        ...)
  names(df) <- cer_clean_names(names(df))
  df
}

#' Fetch an XLSX from the CER site, returning a data frame
#'
#' @param url URL to an XLSX file.
#' @param sheet Sheet name or index.
#' @param skip Number of rows to skip.
#' @return A data frame.
#' @noRd
cer_fetch_xlsx <- function(url, sheet = 1, skip = 0) {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg readxl} package is required to parse XLSX files.",
      "i" = "Install it with {.code install.packages('readxl')}."
    ))
  }
  file <- cer_download_cached(url)
  df <- as.data.frame(
    readxl::read_excel(file, sheet = sheet, skip = skip, .name_repair = "minimal"),
    stringsAsFactors = FALSE
  )
  names(df) <- cer_clean_names(names(df))
  df
}

#' Case-insensitive substring filter on a character column
#'
#' @param df Data frame.
#' @param col Column name (character scalar).
#' @param patterns Character vector of patterns to OR together.
#' @return Filtered data frame.
#' @noRd
cer_filter_like <- function(df, col, patterns) {
  if (is.null(patterns) || length(patterns) == 0L) return(df)
  if (!col %in% names(df)) return(df)
  pattern <- paste(tolower(patterns), collapse = "|")
  keep <- grepl(pattern, tolower(df[[col]]), fixed = FALSE)
  df[keep, , drop = FALSE]
}

#' Exact-match filter on a character column, case-insensitive
#' @noRd
cer_filter_in <- function(df, col, values) {
  if (is.null(values) || length(values) == 0L) return(df)
  if (!col %in% names(df)) return(df)
  values <- toupper(values)
  keep <- toupper(df[[col]]) %in% values
  df[keep, , drop = FALSE]
}
