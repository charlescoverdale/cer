# Return the session manifest of fetched CER datasets

Every call to a data function appends one row to the session manifest,
recording URL, dataset title, SHA-256 of the cached file, size,
retrieval timestamp, and the snapshot pin set via
[`cer_snapshot()`](https://charlescoverdale.github.io/cer/reference/cer_snapshot.md).
Duplicate URLs within a session are deduplicated (last fetch wins).

## Usage

``` r
cer_manifest(format = c("df", "yaml", "json"))
```

## Arguments

- format:

  One of `"df"` (default), `"yaml"`, or `"json"`.

## Value

A data frame, YAML string, or JSON string.

## Details

For carbon market research this is the minimum artefact needed for
reproducibility: ACCU project registers and Safeguard releases change
retroactively, so a citation that points to a URL alone is not enough.
The manifest plus SHA-256 fixes the exact bytes analysed.

## See also

Other reproducibility:
[`cer_cite()`](https://charlescoverdale.github.io/cer/reference/cer_cite.md),
[`cer_deposit_zenodo()`](https://charlescoverdale.github.io/cer/reference/cer_deposit_zenodo.md),
[`cer_legislative_instrument()`](https://charlescoverdale.github.io/cer/reference/cer_legislative_instrument.md),
[`cer_manifest_clear()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_clear.md),
[`cer_manifest_write()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_write.md),
[`cer_sha256()`](https://charlescoverdale.github.io/cer/reference/cer_sha256.md),
[`cer_snapshot()`](https://charlescoverdale.github.io/cer/reference/cer_snapshot.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
cer_manifest_clear()
cer_snapshot("2026-04-24")
cer_manifest()
options(op)
# }
```
