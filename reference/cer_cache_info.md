# Inspect the local cer cache

Returns the cache directory, number of files, total size, and a per-file
summary. Useful for deciding whether to call
[`cer_clear_cache()`](https://charlescoverdale.github.io/cer/reference/cer_clear_cache.md).

## Usage

``` r
cer_cache_info()
```

## Value

A list with elements `dir`, `n_files`, `size_bytes`, `size_human`, and
`files` (a data frame with `name`, `size_bytes`, `modified`).

## See also

Other configuration:
[`cer_clear_cache()`](https://charlescoverdale.github.io/cer/reference/cer_clear_cache.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
cer_cache_info()
options(op)
# }
```
