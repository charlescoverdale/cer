test_that("cer_sha256 returns a hex string for a real file", {
  f <- tempfile()
  writeLines("hello", f)
  sha <- cer_sha256(f)
  expect_type(sha, "character")
  expect_true(nzchar(sha))
})

test_that("cer_sha256 returns NA for missing file", {
  expect_true(is.na(cer_sha256(tempfile())))
})

# Level 2: NIST FIPS 180-4 empty-string vector.
test_that("cer_sha256 matches NIST FIPS 180-4 empty-string vector", {
  skip_if_not_installed("digest")
  f <- tempfile()
  file.create(f)
  expect_equal(
    cer_sha256(f),
    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  )
})

# Level 4: cross-implementation against openssl.
test_that("cer_sha256 agrees with openssl::sha256", {
  skip_if_not_installed("openssl")
  skip_if_not_installed("digest")
  f <- tempfile()
  writeLines("reproducibility audit", f)
  ours   <- cer_sha256(f)
  theirs <- paste(as.character(openssl::sha256(file(f))), collapse = "")
  expect_equal(tolower(ours), tolower(theirs))
})
