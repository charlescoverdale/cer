test_that("cer_legislative_instrument builds a URL", {
  u <- cer_legislative_instrument("F2024L01292")
  expect_match(u, "legislation\\.gov\\.au/Details/F2024L01292")
})

test_that("cer_legislative_instrument warns on bad identifier", {
  expect_warning(cer_legislative_instrument("garbage"),
                 "does not match")
})

test_that("cer_legislative_instrument uppercases input", {
  u <- cer_legislative_instrument("f2024l01292")
  expect_match(u, "F2024L01292")
})
