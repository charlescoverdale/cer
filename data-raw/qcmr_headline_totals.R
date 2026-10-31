# Build inst/extdata/qcmr_headline_totals.csv from the CER Quarterly
# Carbon Market Report data workbook.
#
# Every value is read from the published workbook; nothing is typed in by
# hand. Quarterly flows come straight from a figure's "Total" (or named)
# column, and cumulative series are their running sums from the first
# quarter the figure covers. Re-run each quarter: the workbook carries the
# full history as revised to that release, so the whole table is rebuilt
# rather than appended to.
#
# Source: https://cer.gov.au/markets/reports-and-data/quarterly-carbon-market-reports

library(readxl)

devtools::load_all(quiet = TRUE)
url <- qcmr_url("latest")
vintage <- sub(".*qcmr-data-workbook-", "", url)
message("Using ", url)

path <- tempfile(fileext = ".xlsx")
download.file(url, path, mode = "wb", quiet = TRUE)

read_quarterly <- function(sheet) {
  x <- as.data.frame(suppressMessages(
    read_excel(path, sheet = sheet, skip = 3, .name_repair = "minimal")
  ))
  x <- x[grepl("^[0-9]{4}$", x$Year) & grepl("^Q[1-4]$", x$Quarter), ]
  x$quarter <- paste0(x$Year, "-", x$Quarter)
  x
}

num <- function(v) {
  v <- trimws(as.character(v))
  v[v %in% c("-", "")] <- "0"
  out <- suppressWarnings(as.numeric(v))
  stopifnot(!anyNA(out))
  out
}

measure_rows <- function(x, column, measure, unit, sheet, cumulative = FALSE,
                         note = NA_character_) {
  v <- num(x[[column]])
  if (cumulative) v <- cumsum(v)
  data.frame(
    quarter = x$quarter,
    measure = measure,
    value   = v,
    unit    = unit,
    source  = sprintf("QCMR data workbook (%s), %s, column '%s'",
                      vintage, sheet, column),
    note    = note,
    stringsAsFactors = FALSE
  )
}

f12 <- read_quarterly("Figure 1.2")
f13 <- read_quarterly("Figure 1.3")
f17 <- read_quarterly("Figure 1.7")
f21 <- read_quarterly("Figure 2.1")
f37 <- read_quarterly("Figure 3.7")

out <- rbind(
  measure_rows(f12, "Total", "accu_issuances", "accus", "Figure 1.2"),
  measure_rows(f12, "Total", "accu_cumulative_issuances", "accus",
               "Figure 1.2", cumulative = TRUE,
               note = "Running sum of quarterly issuances from 2012-Q1"),
  measure_rows(f13, "Total", "accu_projects_registered", "projects",
               "Figure 1.3"),
  measure_rows(f13, "Total", "accu_cumulative_projects_registered", "projects",
               "Figure 1.3", cumulative = TRUE,
               note = "Running sum of registrations; not net of revocations"),
  measure_rows(f17, "ACCUs surrendered", "safeguard_accu_surrenders", "accus",
               "Figure 1.7"),
  measure_rows(f17, "SMCs surrendered", "safeguard_smc_surrenders", "smcs",
               "Figure 1.7"),
  measure_rows(f21, "Total", "lgc_validations", "lgcs", "Figure 2.1"),
  measure_rows(f21, "Total", "lgc_cumulative_validations", "lgcs",
               "Figure 2.1", cumulative = TRUE,
               note = "Running sum of quarterly validations from 2001-Q2"),
  measure_rows(f37, "Installations", "sres_solar_installations",
               "installations", "Figure 3.7"),
  measure_rows(f37, "Installations", "sres_cumulative_solar_installations",
               "installations", "Figure 3.7", cumulative = TRUE,
               note = "Running sum of quarterly installations from 2001-Q2")
)

out <- out[order(out$measure, out$quarter), ]
write.csv(out, "inst/extdata/qcmr_headline_totals.csv", row.names = FALSE,
          na = "")
message(nrow(out), " rows written")
