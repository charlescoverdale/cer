# Compute the SHA-256 digest of a file

Compute the SHA-256 digest of a file

## Usage

``` r
cer_sha256(file)
```

## Arguments

- file:

  Path to a local file.

## Value

A length-1 character string (hex digest), or `NA` if the file does not
exist. Uses
[`digest::digest()`](https://eddelbuettel.github.io/digest/man/digest.html)
when the `digest` package is available (recommended for research work),
falling back to [`tools::md5sum()`](https://rdrr.io/r/tools/md5sum.html)
otherwise.

## See also

Other reproducibility:
[`cer_cite()`](https://charlescoverdale.github.io/cer/reference/cer_cite.md),
[`cer_deposit_zenodo()`](https://charlescoverdale.github.io/cer/reference/cer_deposit_zenodo.md),
[`cer_legislative_instrument()`](https://charlescoverdale.github.io/cer/reference/cer_legislative_instrument.md),
[`cer_manifest()`](https://charlescoverdale.github.io/cer/reference/cer_manifest.md),
[`cer_manifest_clear()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_clear.md),
[`cer_manifest_write()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_write.md),
[`cer_snapshot()`](https://charlescoverdale.github.io/cer/reference/cer_snapshot.md)

## Examples

``` r
f <- tempfile()
writeLines("hello", f)
cer_sha256(f)
```
