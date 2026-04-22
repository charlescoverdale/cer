test_that("cer_sres_installations validates technology arg", {
  expect_error(cer_sres_installations(technology = "nuclear"))
})

test_that("cer_sres_installations validates measure arg", {
  expect_error(cer_sres_installations(measure = "kwh"))
})

test_that("cer_lgc_power_stations live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("CER_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  s <- cer_lgc_power_stations()
  expect_s3_class(s, "cer_tbl")
  expect_gt(nrow(s), 50L)
})

test_that("cer_sres_installations live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("CER_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  inst <- cer_sres_installations(technology = "solar_pv", postcode = "2000")
  expect_s3_class(inst, "cer_tbl")
})
