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

# The register names methods by their full legal title. Matching on the
# scorecard's short names classified none of them.
register_methods <- function() {
  readLines(test_path("fixtures", "accu_register_methods.txt"), encoding = "UTF-8")
}

test_that("register methods map to at most one scorecard row", {
  integ <- as.data.frame(cer_method_integrity())
  m <- register_methods()
  hits <- vapply(m, function(x) {
    sum(vapply(integ$register_pattern, grepl, logical(1), x = x,
               ignore.case = TRUE, perl = TRUE))
  }, integer(1))
  expect_true(all(hits <= 1L))
  # 38 of the register's 75 determinations are covered by the scorecard
  expect_gte(sum(hits == 1L), 38L)
})

test_that("register methods are classified by determination", {
  integ <- as.data.frame(cer_method_integrity())
  short <- function(x) integ$method_short[cer_method_lookup(x, integ)]
  m <- register_methods()
  pick <- function(pattern) m[grepl(pattern, m, fixed = TRUE)]
  expect_true(all(short(pick("Human-Induced Regeneration")) == "HIR"))
  expect_true(all(short(pick("Mallee Plantings-FullCAM) Methodology Determination 2014")) == "Plantings_2014"))
  expect_true(all(short(pick("Mallee Plantings-FullCAM) Methodology Determination 2024")) == "Plantings_2024"))
  expect_true(all(short(pick("Savanna Fire Management-Emissions Avoidance) Methodology Determination 2018")) == "Savanna_EA_2018"))
  expect_true(all(short(pick("Methodology Determination 2026")) == "Savanna_2026"))
  # Not in the scorecard: the 2015 savanna method and the 2021 soil method
  expect_true(all(is.na(short(pick("Emissions Abatement through Savanna Fire Management")))))
  expect_true(all(is.na(short(pick("Estimation of Soil Organic Carbon Sequestration")))))
})

test_that("cer_accu_aggregate sums the register's issuance column by default", {
  fake <- data.frame(
    method = c("Carbon Credits (Carbon Farming Initiative) (Human-Induced Regeneration of a Permanent Even-Aged Native Forest-1.1) Methodology Determination 2013 (Compilation No. 3)",
               "Carbon Credits (Carbon Farming Initiative-Savanna Fire Management-Emissions Avoidance) Methodology Determination 2026"),
    accus_total_units_issued = c(900, 100),
    stringsAsFactors = FALSE
  )
  agg <- suppressWarnings(cer_accu_aggregate(fake))
  expect_equal(agg$accus_total_units_issued_sum[agg$integrity_tier == "contested"], 900)
  expect_equal(agg$accus_total_units_issued_sum[agg$integrity_tier == "high"], 100)
  expect_warning(cer_accu_aggregate(fake), "Contested-integrity")
})
