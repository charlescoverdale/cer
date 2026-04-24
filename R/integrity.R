# SHA-256 integrity: every cached file has a sidecar `.sha256`
# recording the hash at first download. Subsequent cache hits
# verify against the sidecar and warn on drift. Critical for
# carbon market data because the CER occasionally restates prior
# releases (e.g. Safeguard facility corrections, ACCU retroactive
# relinquishments).

#' Compute the SHA-256 digest of a file
#'
#' @param file Path to a local file.
#' @return A length-1 character string (hex digest), or `NA` if
#'   the file does not exist. Uses `digest::digest()` when the
#'   `digest` package is available (recommended for research work),
#'   falling back to `tools::md5sum()` otherwise.
#' @family reproducibility
#' @export
#' @examples
#' f <- tempfile()
#' writeLines("hello", f)
#' cer_sha256(f)
cer_sha256 <- function(file) {
  if (!file.exists(file)) return(NA_character_)
  if (requireNamespace("digest", quietly = TRUE)) {
    return(digest::digest(file = file, algo = "sha256"))
  }
  unname(tools::md5sum(file))
}

#' @noRd
cer_sha_sidecar <- function(file) {
  paste0(file, ".sha256")
}

#' @noRd
cer_sha_write <- function(file) {
  sha <- cer_sha256(file)
  if (is.na(sha)) return(invisible(NA_character_))
  writeLines(sha, cer_sha_sidecar(file))
  invisible(sha)
}

#' @noRd
cer_sha_read <- function(file) {
  side <- cer_sha_sidecar(file)
  if (!file.exists(side)) return(NA_character_)
  tryCatch(readLines(side, n = 1L, warn = FALSE),
           error = function(e) NA_character_)
}

#' @noRd
cer_sha_verify <- function(file) {
  expected <- cer_sha_read(file)
  if (is.na(expected) || !nzchar(expected)) {
    cer_sha_write(file)
    return(invisible(TRUE))
  }
  actual <- cer_sha256(file)
  if (!identical(expected, actual)) {
    cli::cli_warn(c(
      "SHA-256 mismatch for cached file {.path {basename(file)}}.",
      "i" = "The CER may have restated this data release.",
      "i" = "Expected {.val {substr(expected, 1, 12)}...}",
      "i" = "Got      {.val {substr(actual, 1, 12)}...}",
      "i" = "Run {.code cer_clear_cache()} and re-fetch to resolve."
    ))
    return(invisible(FALSE))
  }
  invisible(TRUE)
}
