# Pin or inspect the session snapshot date

Call once at the top of an analysis script to declare the vintage of CER
data you intend to use. Every subsequent `cer_*` fetch records this date
in the `cer_tbl` provenance header, in
[`cer_manifest()`](https://charlescoverdale.github.io/cer/reference/cer_manifest.md)
entries, and in
[`cer_cite()`](https://charlescoverdale.github.io/cer/reference/cer_cite.md)
output.

## Usage

``` r
cer_snapshot(date)
```

## Arguments

- date:

  ISO `"YYYY-MM-DD"` character, `Date`, or `POSIXct`. Pass `NULL` to
  clear.

## Value

Invisibly, the new pinned date (as `Date`), or `NULL`.

## Details

This matters more for CER data than for most government data: projects
relinquish ACCUs retroactively, the CER transfers projects between
proponents, methods are reclassified (e.g. post-Chubb-Review status
changes), and the Quarterly Carbon Market Report occasionally restates
prior quarters. A snapshot pin is the minimum evidence a reviewer needs
to verify a published carbon-market claim.

## See also

Other reproducibility:
[`cer_cite()`](https://charlescoverdale.github.io/cer/reference/cer_cite.md),
[`cer_deposit_zenodo()`](https://charlescoverdale.github.io/cer/reference/cer_deposit_zenodo.md),
[`cer_legislative_instrument()`](https://charlescoverdale.github.io/cer/reference/cer_legislative_instrument.md),
[`cer_manifest()`](https://charlescoverdale.github.io/cer/reference/cer_manifest.md),
[`cer_manifest_clear()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_clear.md),
[`cer_manifest_write()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_write.md),
[`cer_sha256()`](https://charlescoverdale.github.io/cer/reference/cer_sha256.md)

## Examples

``` r
cer_snapshot("2026-04-24")
cer_snapshot()
cer_snapshot(NULL)
```
