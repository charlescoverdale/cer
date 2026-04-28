# Clear the cer cache

Deletes all locally cached files. The next call to any data function
will re-download from the Clean Energy Regulator.

## Usage

``` r
cer_clear_cache()
```

## Value

Invisibly returns `NULL`.

## See also

Other configuration:
[`cer_cache_info()`](https://charlescoverdale.github.io/cer/reference/cer_cache_info.md)

## Examples

``` r
# \donttest{
op <- options(cer.cache_dir = tempdir())
cer_clear_cache()
options(op)
# }
```
