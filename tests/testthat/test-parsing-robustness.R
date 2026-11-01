test_that("cer_document_links() returns nothing when nothing matches", {
  html <- paste0(
    '<a href="/document/baselines-and-emissions-table-2024-25-0">csv</a>',
    '<a href="/markets/reports-and-data">page</a>'
  )
  expect_identical(cer_document_links(html, "no-such-slug"), character(0))
  expect_identical(cer_document_links("<p>no links</p>", "x"), character(0))
  expect_equal(
    cer_document_links(html, "baselines-and-emissions-table-2024-25"),
    "https://cer.gov.au/document/baselines-and-emissions-table-2024-25-0"
  )
})

test_that("cer_read_text() decodes Windows-1252 and strips a BOM", {
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path), add = TRUE)
  # 0x96 is an en dash in Windows-1252 and invalid as UTF-8
  writeBin(c(charToRaw("a,b\n1,2024"), as.raw(0x96), charToRaw("25\n2,x\n")), path)
  txt <- cer_read_text(path)
  expect_true(validUTF8(txt))
  df <- utils::read.csv(text = txt, stringsAsFactors = FALSE)
  expect_equal(nrow(df), 2L)
  expect_equal(df$b[1], "2024\u201325")

  writeBin(c(as.raw(c(0xef, 0xbb, 0xbf)), charToRaw("a\n1\n")), path)
  expect_equal(names(utils::read.csv(text = cer_read_text(path))), "a")
})

test_that("cer_parse_grouped_numbers() converts only separator-formatted columns", {
  df <- data.frame(
    qty      = c("30,439,497", "1,354", "12", NA),
    postcode = c("0800", "2000", "3000", "4000"),
    abn      = c("74 115 061 375", "57 101 876 135", NA, NA),
    mixed    = c("1,234", "n/a", "5", NA),
    stringsAsFactors = FALSE
  )
  out <- cer_parse_grouped_numbers(df)
  expect_equal(out$qty, c(30439497, 1354, 12, NA))
  expect_identical(out$postcode, df$postcode)
  expect_identical(out$abn, df$abn)
  expect_identical(out$mixed, df$mixed)
})

test_that("cer_fetch_auto() refuses an HTML page", {
  dir <- tempfile()
  dir.create(dir)
  op <- options(cer.cache_dir = dir)
  on.exit({ options(op); unlink(dir, recursive = TRUE) }, add = TRUE)
  url <- "https://cer.gov.au/document/example"
  cached <- file.path(dir, paste0(cer_digest_url(url), ""))
  writeLines("<!DOCTYPE html><html><body>Home</body></html>", cached)
  expect_error(cer_fetch_auto(url), "web page rather than a data file")
})

test_that("NGER files load in full", {
  skip_on_cran()
  skip_if_offline()
  corp <- cer_nger_corporate(2025)
  expect_gt(nrow(corp), 300L)
  expect_type(corp$total_scope_1_emissions_t_co2_e, "double")
  elec <- cer_nger_electricity(2025)
  expect_gt(nrow(elec), 500L)
})

test_that("cer_nger_corporate reaches the pre-2012-13 file naming", {
  skip_on_cran()
  skip_if_offline()
  expect_gt(nrow(cer_nger_corporate(2009)), 100L)
  expect_error(cer_nger_electricity(2010), "No NGER electricity dataset")
})
