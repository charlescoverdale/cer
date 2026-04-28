# Build a Federal Register of Legislation URL

Given a Legislative Instrument identifier (e.g. `"F2024L01292"` for the
Environmental Plantings 2024 method), return the stable URL on the
Federal Register of Legislation. This is the authoritative source of
truth for ACCU methods, Safeguard Rule amendments, and NGER
Determinations.

## Usage

``` r
cer_legislative_instrument(instrument)
```

## Arguments

- instrument:

  Character identifier (e.g. `"F2024L01292"`). Case-insensitive.

## Value

A length-1 character URL string.

## References

Commonwealth of Australia. *Legislation Act 2003* establishes the
Federal Register of Legislation as the authoritative source for
Legislative Instruments.

## See also

Other reproducibility:
[`cer_cite()`](https://charlescoverdale.github.io/cer/reference/cer_cite.md),
[`cer_deposit_zenodo()`](https://charlescoverdale.github.io/cer/reference/cer_deposit_zenodo.md),
[`cer_manifest()`](https://charlescoverdale.github.io/cer/reference/cer_manifest.md),
[`cer_manifest_clear()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_clear.md),
[`cer_manifest_write()`](https://charlescoverdale.github.io/cer/reference/cer_manifest_write.md),
[`cer_sha256()`](https://charlescoverdale.github.io/cer/reference/cer_sha256.md),
[`cer_snapshot()`](https://charlescoverdale.github.io/cer/reference/cer_snapshot.md)

## Examples

``` r
cer_legislative_instrument("F2024L01292")
cer_legislative_instrument("F2015L00398")
```
