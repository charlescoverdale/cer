test_that("cer_snapshot gets and sets the pin", {
  on.exit(cer_snapshot(NULL), add = TRUE)
  cer_snapshot(NULL)
  expect_null(cer_snapshot())

  d <- cer_snapshot("2026-04-24")
  expect_s3_class(d, "Date")
  expect_equal(format(cer_snapshot(), "%Y-%m-%d"), "2026-04-24")
})

test_that("cer_snapshot clears on NULL", {
  cer_snapshot("2026-04-24")
  cer_snapshot(NULL)
  expect_null(cer_snapshot())
})

test_that("cer_snapshot errors on bad input", {
  on.exit(cer_snapshot(NULL), add = TRUE)
  expect_error(cer_snapshot("not a date"), "parse")
})
