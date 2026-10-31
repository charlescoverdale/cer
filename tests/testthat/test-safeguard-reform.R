test_that("cer_safeguard_regime classifies correctly", {
  cer_ns <- asNamespace("cer")
  expect_equal(cer_ns$cer_safeguard_regime(2022L), "pre_reform")
  expect_equal(cer_ns$cer_safeguard_regime(2023L), "post_reform")
  expect_equal(cer_ns$cer_safeguard_regime("2022-23"), "pre_reform")
  expect_equal(cer_ns$cer_safeguard_regime("2023-24"), "post_reform")
})

# Level 2: the default ERC follows section 31 of the Safeguard Rule.
test_that("default ERC matches the Rule's table and post-2030 decline", {
  traj <- cer_safeguard_baseline_trajectory("Aluminium", 2023, 2031)
  expect_equal(traj$decline_factor,
               c(0.951, 0.902, 0.853, 0.804, 0.755, 0.706, 0.657,
                 0.62415, 0.5913), tolerance = 1e-12)
  long <- cer_safeguard_baseline_trajectory("Aluminium", 2045, 2052)
  expect_equal(long$decline_factor[long$year >= 2049], rep(0, 4))
  expect_true(all(long$decline_factor >= 0))
})

# Level 2: baseline = Schedule 1 default intensity x ERC.
test_that("aluminium baseline uses the Schedule 1 default of 1.94", {
  traj <- cer_safeguard_baseline_trajectory("aluminium", 2023, 2029)
  expect_equal(traj$default_emissions_intensity[1], 1.94)
  expect_equal(traj$baseline[traj$year == 2023], 1.94 * 0.951)
  expect_equal(traj$baseline[traj$year == 2029], 1.94 * 0.657)
  # Section number works as an identifier too
  expect_equal(cer_safeguard_baseline_trajectory("7")$baseline, 
               cer_safeguard_baseline_trajectory("Aluminium")$baseline)
})

# Level 3: monotonic decline.
test_that("baseline is monotone-decreasing across years", {
  traj <- cer_safeguard_baseline_trajectory("Clinker not used by facility to make cement")
  expect_true(all(diff(traj$baseline) < 0))
})

test_that("Schedule 1 table carries the legislated defaults", {
  b <- as.data.frame(cer_safeguard_industry_baselines())
  get <- function(sec) b$default_emissions_intensity[b$section == sec]
  expect_equal(get("7"), 1.94)    # aluminium
  expect_equal(get("8"), 0.545)   # alumina
  expect_equal(get("9"), 1.87)    # ammonia
  expect_equal(get("63"), 0.841)  # clinker
  expect_false(anyDuplicated(b$section) > 0)
  expect_true(all(grepl("^Safeguard Mechanism Rule 2015, Schedule 1", b$source)))
})

test_that("cer_safeguard_industry_baselines returns bundled csv", {
  b <- cer_safeguard_industry_baselines()
  expect_s3_class(b, "data.frame")
  expect_gt(nrow(b), 15L)
})

test_that("cer_safeguard_teba_facilities returns bundled csv", {
  t <- cer_safeguard_teba_facilities()
  expect_s3_class(t, "data.frame")
  expect_true(all(c("facility_name", "start_date", "end_date",
                    "erc_2023_24", "status") %in% names(t)))
  expect_s3_class(t$start_date, "Date")
  expect_true(all(t$end_date > t$start_date))
  expect_true(all(t$status %in% c("current", "historical")))
})

test_that("baseline trajectory errors on unknown industry", {
  expect_error(
    cer_safeguard_baseline_trajectory("not an industry"),
    "not found"
  )
})
