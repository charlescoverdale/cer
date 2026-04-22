test_that("cer_accu_methods returns a cer_tbl with the expected columns", {
  m <- cer_accu_methods()
  expect_s3_class(m, "cer_tbl")
  expect_true(all(c("method", "sector") %in% names(m)))
  expect_gt(nrow(m), 0L)
})

test_that("cer_filter_like is case-insensitive and OR-matches", {
  df <- data.frame(method = c("HIR savanna fire", "Landfill gas", "Piggery waste"),
                   stringsAsFactors = FALSE)
  got <- cer:::cer_filter_like(df, "method", c("savanna", "piggery"))
  expect_equal(nrow(got), 2L)
})

test_that("cer_filter_in accepts a vector and is case-insensitive", {
  df <- data.frame(state = c("NSW", "VIC", "QLD"), stringsAsFactors = FALSE)
  got <- cer:::cer_filter_in(df, "state", c("nsw", "qld"))
  expect_equal(sort(got$state), c("NSW", "QLD"))
})

test_that("cer_clean_names snakecases punctuation-heavy headers", {
  got <- cer:::cer_clean_names(c("Project ID", "ACCUs Issued (to date)",
                                  "Method-Name", "  trailing "))
  expect_equal(got, c("project_id", "accus_issued_to_date",
                      "method_name", "trailing"))
})

test_that("cer_accu_projects signature validates status choices", {
  expect_error(cer_accu_projects(status = "invalid"))
})

test_that("cer_accu_projects hits the network when online", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("CER_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  p <- cer_accu_projects()
  expect_s3_class(p, "cer_tbl")
  expect_gt(nrow(p), 100L)
})

test_that("cer_accu_contracts hits the network when online", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("CER_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  c <- cer_accu_contracts()
  expect_s3_class(c, "cer_tbl")
  expect_gt(nrow(c), 10L)
})
