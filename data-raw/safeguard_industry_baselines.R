# Build inst/extdata/safeguard_industry_baselines.csv from Schedule 1 of
# the National Greenhouse and Energy Reporting (Safeguard Mechanism) Rule
# 2015 (F2015L01637).
#
# Every production variable in Schedule 1 that has a default emissions
# intensity is written out with its section number, the value, and the
# unit text exactly as the Rule states it. Production variables whose
# default is "yet to be calculated" are omitted. Nothing is typed in by
# hand, so re-running against a new compilation picks up any amendment.
#
# The compilation is located through legislation.gov.au's "latest"
# address, which redirects to the current compilation.

latest <- "https://www.legislation.gov.au/F2015L01637/latest/text"
page <- paste(readLines(latest, warn = FALSE), collapse = "\n")
rel <- regmatches(page, regexpr(
  "F2015L01637/[0-9-]+/[0-9-]+/text/original/epub/OEBPS/document_1/document_1\\.html",
  page
))
stopifnot(length(rel) == 1L)
compilation <- sub("F2015L01637/([0-9-]+)/.*", "\\1", rel)
url <- paste0("https://www.legislation.gov.au/", rel)
message("Using compilation of ", compilation)

html <- paste(readLines(url, warn = FALSE, encoding = "UTF-8"), collapse = " ")
txt <- gsub("<[^>]+>", " ", html)
txt <- xml2::xml_text(xml2::read_html(paste0("<p>", txt, "</p>")))
# Collapse all whitespace, including the non-breaking spaces the Rule uses
# between headings and their numbers.
txt <- gsub("[\\s\u00a0]+", " ", txt, perl = TRUE)

# Schedule 1 body: from its last heading (the first is the contents
# list) to the start of Schedule 2.
s1 <- gregexpr("Schedule 1 ?— ?Production variables", txt)[[1]]
body <- substr(txt, s1[length(s1)], nchar(txt))
s2 <- regexpr("Schedule 2 ?—", body)
if (s2 > 0) body <- substr(body, 1, s2 - 1)

heading_rx <- paste0(
  "(?<![(\\w])(\\d{1,3}[A-Z]?) ",
  "([A-Z][A-Za-z0-9 ,‑–—'’()%/&-]{2,160}?) \\(1\\)"
)
heads <- gregexpr(heading_rx, body, perl = TRUE)[[1]]
head_txt <- regmatches(body, list(heads))[[1]]

default_rx <- paste0(
  "The default emissions intensity is ([0-9.]+) t CO 2 ‑ e per ([^.]+?)\\."
)

rows <- lapply(seq_along(heads), function(i) {
  from <- heads[i]
  to <- if (i < length(heads)) heads[i + 1L] - 1L else nchar(body)
  seg <- substr(body, from, to)
  m <- regmatches(seg, regexec(default_rx, seg))[[1]]
  if (length(m) == 0L) return(NULL)
  h <- regmatches(head_txt[i], regexec(heading_rx, head_txt[i], perl = TRUE))[[1]]
  data.frame(
    section = h[2],
    # Non-breaking hyphens and em dashes become ASCII hyphens so the
    # bundled CSV reads the same on every platform.
    production_variable = trimws(gsub("[‑—]", "-", h[3])),
    default_emissions_intensity = as.numeric(m[2]),
    unit = paste0("t CO2-e per ", trimws(gsub("[‑—]", "-", m[3]))),
    source = sprintf("Safeguard Mechanism Rule 2015, Schedule 1, section %s (compilation %s)",
                     h[2], compilation),
    stringsAsFactors = FALSE
  )
})
out <- do.call(rbind, rows)
stopifnot(nrow(out) > 50L, !anyDuplicated(out$section))

write.csv(out, "inst/extdata/safeguard_industry_baselines.csv",
          row.names = FALSE)
message(nrow(out), " production variables written")
