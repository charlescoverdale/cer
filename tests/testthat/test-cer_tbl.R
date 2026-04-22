test_that("new_cer_tbl attaches provenance attributes", {
  df <- data.frame(a = 1:3, b = letters[1:3])
  x <- cer:::new_cer_tbl(df,
                         source = "https://cer.gov.au",
                         licence = "CC BY 4.0",
                         retrieved = as.POSIXct("2026-04-22 00:00:00", tz = "UTC"),
                         title = "Test")
  expect_s3_class(x, "cer_tbl")
  expect_s3_class(x, "data.frame")
  expect_equal(attr(x, "cer_title"), "Test")
  expect_equal(attr(x, "cer_source"), "https://cer.gov.au")
  expect_equal(attr(x, "cer_licence"), "CC BY 4.0")
})

test_that("new_cer_tbl requires a data frame", {
  expect_error(cer:::new_cer_tbl(list(a = 1)))
})

test_that("print.cer_tbl emits the provenance header", {
  df <- data.frame(a = 1:2)
  x <- cer:::new_cer_tbl(df, title = "Demo",
                         source = "https://example.org",
                         licence = "CC BY 4.0",
                         retrieved = as.POSIXct("2026-01-01 00:00:00", tz = "UTC"))
  out <- capture.output(print(x))
  expect_true(any(grepl("cer_tbl: Demo", out, fixed = TRUE)))
  expect_true(any(grepl("example.org", out, fixed = TRUE)))
  expect_true(any(grepl("CC BY 4.0", out, fixed = TRUE)))
  expect_true(any(grepl("Rows:", out, fixed = TRUE)))
})

test_that("print.cer_tbl returns x invisibly", {
  df <- data.frame(a = 1)
  x <- cer:::new_cer_tbl(df)
  tf <- tempfile()
  sink(tf)
  wv <- withVisible(print(x))
  sink()
  unlink(tf)
  expect_false(wv$visible)
  expect_identical(wv$value, x)
})
