test_that("cer_cite text includes title and source", {
  x <- structure(data.frame(a = 1),
    cer_source = "https://cer.gov.au/document/x",
    cer_licence = "CC BY 4.0",
    cer_retrieved = as.POSIXct("2026-04-24", tz = "UTC"),
    cer_title = "ACCU project register",
    class = c("cer_tbl", "data.frame")
  )
  s <- cer_cite(x, style = "text")
  expect_match(s, "Clean Energy Regulator")
  expect_match(s, "ACCU project register")
})

test_that("cer_cite bibtex includes SHA and snapshot when set", {
  x <- structure(data.frame(a = 1),
    cer_source = "https://cer.gov.au/document/x",
    cer_licence = "CC BY 4.0",
    cer_retrieved = as.POSIXct("2026-04-24", tz = "UTC"),
    cer_title = "ACCU",
    cer_sha256 = "abcdef123456789012345678",
    cer_snapshot_date = "2026-04-24",
    class = c("cer_tbl", "data.frame")
  )
  b <- cer_cite(x, style = "bibtex")
  expect_match(b, "snapshot 2026-04-24")
  expect_match(b, "sha256:abcdef123456")
})

test_that("cer_cite includes DOI when provided", {
  x <- structure(data.frame(a = 1),
    cer_source = "https://x", cer_title = "t",
    cer_retrieved = Sys.time(),
    class = c("cer_tbl", "data.frame")
  )
  b <- cer_cite(x, style = "bibtex", doi = "10.5281/zenodo.42")
  expect_match(b, "doi    = \\{10\\.5281/zenodo\\.42\\}")
})
