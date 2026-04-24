test_that("cer_to_carbondata renames known columns", {
  fake <- data.frame(
    project_id = "ERF101",
    project_name = "Test project",
    method = "HIR",
    accus_issued = 10000,
    stringsAsFactors = FALSE
  )
  out <- cer_to_carbondata(fake)
  expect_true("methodology" %in% names(out))
  expect_true("issued_credits_to_date" %in% names(out))
  expect_equal(out$country, "Australia")
  expect_equal(out$registry, "Clean Energy Regulator (ACCU)")
})

test_that("cer_international_comparator returns ACCU row", {
  comp <- cer_international_comparator()
  expect_s3_class(comp, "data.frame")
  expect_true("ACCU" %in% comp$market)
  expect_true("EU_ETS" %in% comp$market)
})
