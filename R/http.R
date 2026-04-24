# HTTP helpers — httr2 wrapper with local caching

#' @noRd
CER_BASE_URL <- "https://cer.gov.au"

#' @noRd
cer_user_agent <- function() {
  paste0("cer R package/", utils::packageVersion("cer"),
         " (+https://github.com/charlescoverdale/cer)")
}

#' @noRd
cer_request <- function(url, timeout = 120) {
  httr2::request(url) |>
    httr2::req_user_agent(cer_user_agent()) |>
    httr2::req_throttle(rate = 5 / 10) |>
    httr2::req_timeout(timeout) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_error(is_error = function(r) FALSE)
}

#' Download a file to the cache and return the local path
#'
#' @param url URL to download.
#' @param cache Logical. Use an existing cached file if present.
#' @return Path to a local file.
#' @noRd
cer_download_cached <- function(url, cache = TRUE) {
  d <- cer_cache_dir()
  ext <- tools::file_ext(url)
  ext <- if (nzchar(ext)) paste0(".", ext) else ""
  file <- file.path(d, paste0(cer_digest_url(url), ext))

  if (cache && file.exists(file)) {
    cer_sha_verify(file)
    .cer_manifest_append(url = url, file = file)
    return(file)
  }

  cli::cli_progress_step("Downloading {.url {url}}")

  resp <- tryCatch(
    cer_request(url) |>
      httr2::req_perform(path = file),
    error = function(e) {
      if (file.exists(file)) unlink(file)
      cli::cli_abort(c(
        "Download failed.",
        "x" = conditionMessage(e)
      ))
    }
  )

  if (!is.null(resp) && httr2::resp_status(resp) >= 400L) {
    unlink(file, force = TRUE)
    cli::cli_abort(c(
      "HTTP {httr2::resp_status(resp)} from {.url {url}}.",
      "i" = "The CER may have moved or renamed the resource."
    ))
  }

  cer_sha_write(file)
  .cer_manifest_append(url = url, file = file)
  file
}

#' Scrape document links from a CER landing page matching a pattern
#'
#' Several CER data pages host the XLSX under a slug that shifts
#' year-to-year or quarter-to-quarter (e.g. QCMR, Safeguard,
#' NGER). Rather than hard-code each slug, this helper fetches
#' the landing page HTML and returns all `/document/*` links whose
#' slug matches a regex.
#'
#' @param page_url Landing page URL.
#' @param pattern Regex to filter the link slug.
#' @return Character vector of fully-qualified document URLs
#'   (absolute). Empty if nothing matches.
#' @noRd
cer_scrape_links <- function(page_url, pattern) {
  html <- tryCatch(
    cer_request(page_url) |>
      httr2::req_perform() |>
      httr2::resp_body_string(),
    error = function(e) NA_character_
  )
  if (is.na(html)) return(character(0L))

  hrefs <- regmatches(html, gregexpr('href="(/document/[^"]+)"', html))[[1]]
  hrefs <- gsub('^href="|"$', "", hrefs)
  hrefs <- unique(hrefs)
  keep <- grepl(pattern, hrefs, ignore.case = TRUE)
  paste0(CER_BASE_URL, hrefs[keep])
}

#' Stable URL hash for cache filenames
#'
#' A dependency-free weighted-checksum hash. Not cryptographic:
#' just collision-resistant enough for a single-user local cache.
#'
#' @param url URL to hash.
#' @return A 10-digit numeric string plus URL-length suffix.
#' @noRd
cer_digest_url <- function(url) {
  chars <- utf8ToInt(url)
  weights <- seq_along(chars)
  checksum <- sum(as.numeric(chars) * weights) %% (2^31 - 1)
  sprintf("%010.0f_%04d", as.numeric(checksum), nchar(url) %% 10000L)
}
