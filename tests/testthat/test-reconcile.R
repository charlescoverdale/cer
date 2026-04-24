test_that("cer_qcmr_reference returns rows", {
  df <- cer_qcmr_reference()
  expect_s3_class(df, "data.frame")
  expect_gt(nrow(df), 10L)
})

test_that("cer_qcmr_reference filters by quarter", {
  df <- cer_qcmr_reference(quarter = "2024-Q4")
  expect_true(all(df$quarter == "2024-Q4"))
})

# Level 2: reconcile at exact match returns diff = 0.
test_that("cer_reconcile returns zero diff on exact match", {
  res <- cer_reconcile(value = 185000000,
                       quarter = "2024-Q4",
                       measure = "accu_cumulative_issuances")
  expect_equal(res$diff, 0)
  expect_equal(res$pct_diff, 0)
})

# Level 3: warning fires when gap > 2%.
test_that("cer_reconcile warns on gap > 2%", {
  expect_warning(
    cer_reconcile(value = 200000000,
                   quarter = "2024-Q4",
                   measure = "accu_cumulative_issuances"),
    "Reconciliation gap"
  )
})

# Level 3: pct_diff sign is consistent with (value - reference).
test_that("pct_diff sign is consistent with diff", {
  high <- suppressWarnings(cer_reconcile(200000000, "2024-Q4",
                                           "accu_cumulative_issuances"))
  low  <- suppressWarnings(cer_reconcile(170000000, "2024-Q4",
                                           "accu_cumulative_issuances"))
  expect_gt(high$diff, 0)
  expect_gt(high$pct_diff, 0)
  expect_lt(low$diff, 0)
  expect_lt(low$pct_diff, 0)
})

test_that("cer_reconcile errors on unknown measure/quarter", {
  expect_error(
    cer_reconcile(1e6, "2999-Q1", "not_a_measure"),
    "No QCMR reference"
  )
})
