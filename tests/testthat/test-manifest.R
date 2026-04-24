test_that("cer_manifest_clear empties the manifest", {
  cer_manifest_clear()
  df <- cer_manifest("df")
  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 0L)
})

test_that("cer_manifest df has expected columns", {
  cer_manifest_clear()
  df <- cer_manifest("df")
  expect_true(all(c("url", "title", "licence", "sha256", "size_bytes",
                    "retrieved", "snapshot_date", "r_version",
                    "cer_version") %in% names(df)))
})

test_that("cer_manifest_write writes CSV", {
  cer_manifest_clear()
  p <- tempfile(fileext = ".csv")
  cer_manifest_write(p)
  expect_true(file.exists(p))
  df <- utils::read.csv(p)
  expect_s3_class(df, "data.frame")
})

test_that("manifest records a fetch via internal helper", {
  cer_manifest_clear()
  f <- tempfile()
  writeLines("test", f)
  cer_ns <- asNamespace("cer")
  cer_ns$.cer_manifest_append(
    url = "https://cer.gov.au/document/x",
    file = f,
    title = "test dataset"
  )
  df <- cer_manifest("df")
  expect_equal(nrow(df), 1L)
  expect_equal(df$title, "test dataset")
  expect_true(nzchar(df$sha256))
})
