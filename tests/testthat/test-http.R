test_that("cer_digest_url is deterministic and length-varying", {
  d1 <- cer:::cer_digest_url("https://cer.gov.au/a")
  d2 <- cer:::cer_digest_url("https://cer.gov.au/a")
  d3 <- cer:::cer_digest_url("https://cer.gov.au/b")

  expect_equal(d1, d2)
  expect_false(identical(d1, d3))
  expect_match(d1, "^[0-9]+_[0-9]+$")
})

test_that("cer_user_agent includes the package version", {
  ua <- cer:::cer_user_agent()
  expect_match(ua, "^cer R package/")
  expect_match(ua, "github.com/charlescoverdale/cer")
})

test_that("cer_request returns a httr2 request object", {
  req <- cer:::cer_request("https://cer.gov.au")
  expect_s3_class(req, "httr2_request")
})

test_that("cer_download_cached uses existing cached file when present", {
  tmp <- tempfile("cer_cache_")
  op <- options(cer.cache_dir = tmp)
  on.exit(options(op), add = TRUE)
  dir.create(tmp, recursive = TRUE)

  url <- "https://cer.gov.au/test-file.csv"
  hash <- cer:::cer_digest_url(url)
  fake_path <- file.path(tmp, paste0(hash, ".csv"))
  writeLines("col1,col2\n1,2", fake_path)

  got <- cer:::cer_download_cached(url, cache = TRUE)
  expect_equal(normalizePath(got), normalizePath(fake_path))
})
