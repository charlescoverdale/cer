test_that("cer_safeguard_facilities validates year bounds", {
  expect_error(cer_safeguard_facilities(year = 2010))
  expect_error(cer_safeguard_facilities(year = 2031))
  expect_error(cer_safeguard_facilities(year = "2025"))
})

test_that("nger_urls dispatches on kind arg", {
  expect_error(cer:::nger_urls(2025, "invalid"))
})

test_that("cer_safeguard_facilities live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("CER_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  f <- cer_safeguard_facilities(year = 2025)
  expect_s3_class(f, "cer_tbl")
  expect_gt(nrow(f), 100L)
})

test_that("cer_nger_corporate live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("CER_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  c <- cer_nger_corporate(year = 2025)
  expect_s3_class(c, "cer_tbl")
  expect_gt(nrow(c), 50L)
})
