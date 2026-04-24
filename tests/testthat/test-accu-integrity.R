test_that("cer_method_integrity returns a data frame", {
  m <- cer_method_integrity()
  expect_s3_class(m, "data.frame")
  expect_gt(nrow(m), 15L)
  expect_true(all(c("method_short", "status", "integrity_tier",
                    "chubb_affected") %in% names(m)))
})

test_that("cer_method_integrity tier filter works", {
  contested <- cer_method_integrity(tier = "contested")
  expect_true(all(contested$integrity_tier == "contested"))
  expect_gt(nrow(contested), 0L)
})

test_that("cer_method_integrity status filter works", {
  suspended <- cer_method_integrity(status = "suspended")
  expect_true(all(suspended$status == "suspended"))
})

# Level 2: HIR should be flagged under_review (Chubb recommendation).
test_that("HIR is under_review post-Chubb", {
  m <- cer_method_integrity()
  hir <- m[m$method_short == "HIR", ]
  expect_equal(hir$status, "under_review")
  expect_true(hir$chubb_affected)
})

# Level 2: Avoided Deforestation suspended post-Chubb.
test_that("AD is suspended post-Chubb", {
  m <- cer_method_integrity()
  ad <- m[m$method_short == "AD", ]
  expect_equal(ad$status, "suspended")
})

test_that("cer_method_determination returns Federal Register URL", {
  url <- cer_method_determination("HIR")
  expect_match(url, "legislation\\.gov\\.au")
})

test_that("cer_method_determination warns on unknown method", {
  expect_warning(cer_method_determination("NOT_A_METHOD"), "No method")
})

# Level 3: aggregate is shape-stable across tiers.
test_that("cer_accu_aggregate returns tier breakdown", {
  fake <- data.frame(
    method = c("Human-Induced Regeneration of a permanent even-aged native forest",
               "Savanna Fire Management 2026",
               "Landfill Gas Capture and Combustion"),
    accus_issued = c(100000, 50000, 30000),
    stringsAsFactors = FALSE
  )
  agg <- suppressWarnings(cer_accu_aggregate(fake))
  expect_s3_class(agg, "data.frame")
  expect_true("integrity_tier" %in% names(agg))
  expect_true("share_pct" %in% names(agg))
  expect_equal(sum(agg$share_pct), 100, tolerance = 0.01)
})

# Level 3: aggregate warns when contested > 5%.
test_that("cer_accu_aggregate warns on high contested share", {
  fake <- data.frame(
    method = c("Human-Induced Regeneration of a permanent even-aged native forest"),
    accus_issued = 1000000,
    stringsAsFactors = FALSE
  )
  # HIR is "contested" tier; 100% of the total triggers the warn.
  expect_warning(cer_accu_aggregate(fake), "Contested-integrity")
})
