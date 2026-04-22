# Cache management

#' @noRd
cer_cache_dir <- function() {
  d <- getOption("cer.cache_dir",
                 default = tools::R_user_dir("cer", "cache"))
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
  d
}

#' Clear the cer cache
#'
#' Deletes all locally cached files. The next call to any data
#' function will re-download from the Clean Energy Regulator.
#'
#' @return Invisibly returns `NULL`.
#' @family configuration
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' cer_clear_cache()
#' options(op)
#' }
cer_clear_cache <- function() {
  d <- cer_cache_dir()
  files <- list.files(d, full.names = TRUE)
  n <- length(files)
  if (n > 0L) unlink(files, recursive = TRUE)
  cli::cli_inform("Removed {n} cached file{?s} from {.path {d}}.")
  invisible(NULL)
}

#' Inspect the local cer cache
#'
#' Returns the cache directory, number of files, total size, and
#' a per-file summary. Useful for deciding whether to call
#' [cer_clear_cache()].
#'
#' @return A list with elements `dir`, `n_files`, `size_bytes`,
#'   `size_human`, and `files` (a data frame with `name`,
#'   `size_bytes`, `modified`).
#' @family configuration
#' @export
#' @examples
#' \donttest{
#' op <- options(cer.cache_dir = tempdir())
#' cer_cache_info()
#' options(op)
#' }
cer_cache_info <- function() {
  d <- cer_cache_dir()
  empty <- data.frame(
    name = character(0L),
    size_bytes = numeric(0L),
    modified = as.POSIXct(character(0L)),
    stringsAsFactors = FALSE
  )
  paths <- list.files(d, full.names = TRUE)
  if (length(paths) == 0L) {
    return(list(dir = d, n_files = 0L, size_bytes = 0,
                size_human = "0 B", files = empty))
  }
  info <- file.info(paths)
  files <- data.frame(
    name = basename(paths),
    size_bytes = info$size,
    modified = info$mtime,
    stringsAsFactors = FALSE
  )
  files <- files[order(-files$size_bytes), , drop = FALSE]
  rownames(files) <- NULL
  total <- sum(files$size_bytes)
  list(dir = d, n_files = nrow(files), size_bytes = total,
       size_human = cer_format_bytes(total), files = files)
}
