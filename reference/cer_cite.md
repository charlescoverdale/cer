# Cite a cer_tbl or URL in BibTeX, plain-text, or APA form

Returns a citation suitable for footnotes, papers, and carbon market
analysis reports. Uses the provenance attributes attached to every
`cer_tbl`: source URL, licence, retrieval date, title, snapshot pin
(from
[`cer_snapshot()`](https://charlescoverdale.github.io/cer/reference/cer_snapshot.md)),
and SHA-256 digest.

## Usage

``` r
cer_cite(x, style = c("text", "bibtex", "apa"), doi = NULL)
```

## Arguments

- x:

  A `cer_tbl` (as returned by any `cer_*` data function) or a character
  URL.

- style:

  One of `"text"` (default), `"bibtex"`, or `"apa"`.

- doi:

  Optional DOI (e.g. from
  [`cer_deposit_zenodo()`](https://charlescoverdale.github.io/cer/reference/cer_deposit_zenodo.md))
  to include in BibTeX output as a `doi` field and APA suffix.

## Value

A character string.

## Details

For carbon market research, the BibTeX `note` field includes the
snapshot date and first 12 hex characters of the SHA-256, which are the
minimum provenance fields needed to defend a published figure against a
reviewer.

## See also

Other reproducibility:
[`cer_deposit_zenodo()`](https://charlescoverdale.github.io/cer/reference/cer_deposit_zenodo.md),
[`cer_legislative_instrument()`](https://charlescoverdale.github.io/cer/reference/cer_legislative_instrument.md),
[`cer_manifest()`](https://charlescoverdale.github.io/cer/reference/cer_manifest.md),
[`cer_manifest_clear()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_clear.md),
[`cer_manifest_write()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_write.md),
[`cer_sha256()`](https://charlescoverdale.github.io/cer/reference/cer_sha256.md),
[`cer_snapshot()`](https://charlescoverdale.github.io/cer/reference/cer_snapshot.md)

## Examples

``` r
x <- data.frame(a = 1)
x <- structure(x,
  cer_source = "https://cer.gov.au/markets/reports-and-data/accu-project-and-contract-register",
  cer_licence = "CC BY 4.0",
  cer_retrieved = as.POSIXct("2026-04-24 00:00:00", tz = "UTC"),
  cer_title = "ACCU project register",
  cer_sha256 = "abc123def456",
  cer_snapshot_date = "2026-04-24",
  class = c("cer_tbl", "data.frame"))
cer_cite(x)
cer_cite(x, style = "bibtex")
# DOI style: supply any minted DOI (Zenodo, DataCite, etc.).
# The placeholder below is illustrative only.
cer_cite(x, style = "apa", doi = "10.5281/zenodo.XXXXXXXX")
```
