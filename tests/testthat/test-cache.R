test_that("cer_cache_dir honours the cer.cache_dir option", {
  tmp <- tempfile("cer_cache_")
  op <- options(cer.cache_dir = tmp)
  on.exit(options(op), add = TRUE)

  d <- cer:::cer_cache_dir()
  expect_equal(normalizePath(d), normalizePath(tmp))
  expect_true(dir.exists(d))
})

test_that("cer_cache_info returns the expected structure on an empty cache", {
  tmp <- tempfile("cer_cache_")
  op <- options(cer.cache_dir = tmp)
  on.exit(options(op), add = TRUE)

  info <- cer_cache_info()
  expect_type(info, "list")
  expect_setequal(names(info),
                  c("dir", "n_files", "size_bytes", "size_human", "files"))
  expect_equal(info$n_files, 0L)
  expect_equal(info$size_bytes, 0)
  expect_s3_class(info$files, "data.frame")
  expect_equal(nrow(info$files), 0L)
})

test_that("cer_cache_info counts files correctly", {
  tmp <- tempfile("cer_cache_")
  op <- options(cer.cache_dir = tmp)
  on.exit(options(op), add = TRUE)

  dir.create(tmp, recursive = TRUE)
  writeLines("a", file.path(tmp, "a.csv"))
  writeLines("ab", file.path(tmp, "b.csv"))

  info <- cer_cache_info()
  expect_equal(info$n_files, 2L)
  expect_gte(info$size_bytes, 3)
  expect_match(info$size_human, "B$")
})

test_that("cer_clear_cache removes cached files silently", {
  tmp <- tempfile("cer_cache_")
  op <- options(cer.cache_dir = tmp)
  on.exit(options(op), add = TRUE)

  dir.create(tmp, recursive = TRUE)
  writeLines("x", file.path(tmp, "x.csv"))
  expect_true(file.exists(file.path(tmp, "x.csv")))

  expect_invisible(cer_clear_cache())
  expect_false(file.exists(file.path(tmp, "x.csv")))
})

test_that("cer_format_bytes formats across SI thresholds", {
  expect_equal(cer:::cer_format_bytes(0), "0 B")
  expect_equal(cer:::cer_format_bytes(500), "500 B")
  expect_match(cer:::cer_format_bytes(1500), "KB$")
  expect_match(cer:::cer_format_bytes(1500000), "MB$")
  expect_match(cer:::cer_format_bytes(1500000000), "GB$")
})
