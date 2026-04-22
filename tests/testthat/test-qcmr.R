test_that("qcmr_url rejects malformed quarter strings", {
  skip_if_offline()
  expect_error(cer:::qcmr_url("2025"))
  expect_error(cer:::qcmr_url("2025q5"))
  expect_error(cer:::qcmr_url("Q4 2025"))
})

test_that("cer_qcmr live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("CER_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  x <- cer_qcmr("latest")
  expect_s3_class(x, "cer_tbl")
  expect_gt(nrow(x), 0L)
})
