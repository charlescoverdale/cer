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

#' Fetch and parse a CER document URL, auto-detecting CSV vs XLSX
#'
#' CER's `/document/<slug>` and `/document/<slug>-0` pairs follow
#' inconsistent conventions: ACCU has XLSX at the plain slug and
#' CSV at `-0`, while Safeguard has CSV at the plain slug and XLSX
#' at `-0`. Rather than guessing from the URL, this helper
#' downloads the file and inspects the first bytes: XLSX is a ZIP
#' container starting with the `PK\x03\x04` signature.
#'
#' For XLSX files, many CER workbooks have a multi-line title or
#' narrative block before the data header. The helper reads the
#' first 15 rows without a header, finds the first row where at
#' least three cells are non-empty character strings (the header
#' row), then re-reads with that row as the header.
#'
#' @param url URL to a CER data document.
#' @param sheet Sheet name or index (used only for XLSX).
#' @return A data frame.
#' @noRd
cer_fetch_auto <- function(url, sheet = 1) {
  file <- cer_download_cached(url)
  sig <- tryCatch(readBin(file, what = "raw", n = 4L),
                  error = function(e) raw(0))
  is_xlsx <- length(sig) >= 4L &&
    identical(sig[1:2], as.raw(c(0x50, 0x4B)))  # "PK" (zip magic)

  if (is_xlsx) {
    if (!requireNamespace("readxl", quietly = TRUE)) {
      cli::cli_abort(c(
        "The {.pkg readxl} package is required to parse XLSX files."
      ))
    }
    skip <- cer_detect_header_row(file, sheet = sheet)
    df <- as.data.frame(
      readxl::read_excel(file, sheet = sheet, skip = skip,
                         .name_repair = "minimal"),
      stringsAsFactors = FALSE
    )
  } else {
    df <- utils::read.csv(file, stringsAsFactors = FALSE,
                          check.names = FALSE,
                          na.strings = c("", "NA", "N/A", "-"),
                          fileEncoding = "UTF-8")
  }
  names(df) <- cer_clean_names(names(df))
  df
}

#' Find the first row in an XLSX sheet that looks like a header
#'
#' Heuristic: reads up to 15 rows without a header, then finds the
#' first row with at least 3 non-empty character columns. Many CER
#' workbooks have a title + 1-5 narrative rows before the data
#' header, and this avoids hardcoding per-file skip values.
#'
#' @noRd
cer_detect_header_row <- function(file, sheet = 1, max_scan = 15L) {
  probe <- tryCatch(
    readxl::read_excel(file, sheet = sheet, col_names = FALSE,
                       n_max = max_scan, .name_repair = "minimal"),
    error = function(e) NULL
  )
  if (is.null(probe) || nrow(probe) == 0L) return(0L)

  is_string_row <- function(row) {
    vals <- unlist(row, use.names = FALSE)
    vals <- vals[!is.na(vals) & nzchar(as.character(vals))]
    # A header row has at least 3 cells, all character-like, and
    # no cell containing newlines (narrative blocks break this).
    if (length(vals) < 3L) return(FALSE)
    chars <- suppressWarnings(as.character(vals))
    has_newline <- any(grepl("\n", chars))
    looks_numeric <- suppressWarnings(!any(is.na(as.numeric(chars))))
    !has_newline && !looks_numeric
  }

  for (i in seq_len(nrow(probe))) {
    if (is_string_row(probe[i, , drop = FALSE])) {
      return(i - 1L)  # `skip` counts rows before the header.
    }
  }
  0L
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
