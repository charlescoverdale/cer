test_that("cer_safeguard_regime classifies correctly", {
  cer_ns <- asNamespace("cer")
  expect_equal(cer_ns$cer_safeguard_regime(2022L), "pre_reform")
  expect_equal(cer_ns$cer_safeguard_regime(2023L), "post_reform")
  expect_equal(cer_ns$cer_safeguard_regime("2022-23"), "pre_reform")
  expect_equal(cer_ns$cer_safeguard_regime("2023-24"), "post_reform")
})

# Level 2: base year baseline = input baseline.
test_that("baseline at 2023 equals bundled value (identity)", {
  traj <- cer_safeguard_baseline_trajectory("Aluminium smelting",
                                             from_year = 2023,
                                             to_year = 2023)
  expect_equal(traj$decline_factor, 1, tolerance = 1e-12)
  expect_equal(traj$baseline, 1.650, tolerance = 1e-6)
})

# Level 2: 2029-30 baseline = 2023-24 * (1-0.049)^6.
test_that("2029 baseline matches 4.9% p.a. declining formula", {
  traj <- cer_safeguard_baseline_trajectory("Aluminium smelting")
  b_2029 <- traj$baseline[traj$year == 2029]
  expected <- 1.650 * (1 - 0.049)^6
  expect_equal(b_2029, expected, tolerance = 1e-6)
})

# Level 3: monotonic decline.
test_that("baseline is monotone-decreasing across years", {
  traj <- cer_safeguard_baseline_trajectory("Cement clinker")
  expect_true(all(diff(traj$baseline) < 0))
})

test_that("cer_safeguard_industry_baselines returns bundled csv", {
  b <- cer_safeguard_industry_baselines()
  expect_s3_class(b, "data.frame")
  expect_gt(nrow(b), 15L)
})

test_that("cer_safeguard_teba_facilities returns bundled csv", {
  t <- cer_safeguard_teba_facilities()
  expect_s3_class(t, "data.frame")
  expect_true("facility_name" %in% names(t))
})

test_that("baseline trajectory errors on unknown industry", {
  expect_error(
    cer_safeguard_baseline_trajectory("not an industry"),
    "not found"
  )
})
