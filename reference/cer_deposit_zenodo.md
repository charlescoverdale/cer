# Prepare a Zenodo deposit payload for the session manifest

Builds Zenodo-shaped metadata for a data deposit using the current
[`cer_manifest()`](https://charlescoverdale.github.io/cer/reference/cer_manifest.md)
and the snapshot pin set via
[`cer_snapshot()`](https://charlescoverdale.github.io/cer/reference/cer_snapshot.md).
Dry run by default; pass `upload = TRUE` and a token to actually
deposit.

## Usage

``` r
cer_deposit_zenodo(
  title = NULL,
  description = NULL,
  creators = list(list(name = "Anonymous")),
  keywords = c("Clean Energy Regulator", "carbon markets", "Australia", "ACCU",
    "Safeguard", "reproducibility"),
  upload = FALSE,
  sandbox = FALSE,
  token = Sys.getenv("ZENODO_TOKEN")
)
```

## Arguments

- title:

  Deposit title. Defaults to a snapshot-date string.

- description:

  Free-text description. Defaults to a short auto-generated summary of
  datasets fetched.

- creators:

  List of creator records.

- keywords:

  Character vector of keywords.

- upload:

  Logical. If `TRUE`, POSTs to Zenodo.

- sandbox:

  Logical. If `TRUE`, uses Zenodo Sandbox for tests.

- token:

  Zenodo personal access token. Defaults to
  `Sys.getenv("ZENODO_TOKEN")`.

## Value

A list with `payload`, `manifest_path`, and (on upload) `deposit_id`,
`doi_prereserve`, `url`.

## Details

Because CER data is revised retroactively, Zenodo DOIs are the strongest
reproducibility artefact available: they freeze the exact bytes of the
ACCU project register, Safeguard facility file, or QCMR workbook at the
date of analysis.

## See also

Other reproducibility:
[`cer_cite()`](https://charlescoverdale.github.io/cer/reference/cer_cite.md),
[`cer_legislative_instrument()`](https://charlescoverdale.github.io/cer/reference/cer_legislative_instrument.md),
[`cer_manifest()`](https://charlescoverdale.github.io/cer/reference/cer_manifest.md),
[`cer_manifest_clear()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_clear.md),
[`cer_manifest_write()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_write.md),
[`cer_sha256()`](https://charlescoverdale.github.io/cer/reference/cer_sha256.md),
[`cer_snapshot()`](https://charlescoverdale.github.io/cer/reference/cer_snapshot.md)

## Examples

``` r
# \donttest{
cer_snapshot("2026-04-24")
cer_deposit_zenodo(
  title = "CER data snapshot for working paper v1",
  creators = list(list(name = "Author, A.")),
  upload = FALSE
)
# }
```
