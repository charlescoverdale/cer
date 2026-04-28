# Write the session manifest to a file

Write the session manifest to a file

## Usage

``` r
cer_manifest_write(path, format = c("auto", "csv", "yaml", "json"))
```

## Arguments

- path:

  Output file path. Extension determines format when `format = "auto"`.

- format:

  One of `"auto"`, `"csv"`, `"yaml"`, `"json"`.

## Value

Invisibly, the absolute path written.

## See also

Other reproducibility:
[`cer_cite()`](https://charlescoverdale.github.io/cer/reference/cer_cite.md),
[`cer_deposit_zenodo()`](https://charlescoverdale.github.io/cer/reference/cer_deposit_zenodo.md),
[`cer_legislative_instrument()`](https://charlescoverdale.github.io/cer/reference/cer_legislative_instrument.md),
[`cer_manifest()`](https://charlescoverdale.github.io/cer/reference/cer_manifest.md),
[`cer_manifest_clear()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_clear.md),
[`cer_sha256()`](https://charlescoverdale.github.io/cer/reference/cer_sha256.md),
[`cer_snapshot()`](https://charlescoverdale.github.io/cer/reference/cer_snapshot.md)

## Examples

``` r
# \donttest{
p <- tempfile(fileext = ".csv")
cer_manifest_clear()
cer_manifest_write(p)
# }
```
