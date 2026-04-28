# Bundled international carbon market comparator

Returns headline price/volume figures for comparison between ACCU
(Australia) and major international markets: EU ETS, New Zealand ETS,
California-Quebec (WCI), Verra VCUs, and Gold Standard. Values are
indicative snapshots. For live data use the companion `carbondata`
package.

## Usage

``` r
cer_international_comparator()
```

## Value

A `cer_tbl` of indicative comparator data.

## References

International Carbon Action Partnership (annual). *Emissions Trading
Worldwide: Status Report*. <https://icapcarbonaction.com/en>

World Bank (annual). *State and Trends of Carbon Pricing*.

## See also

Other interop:
[`cer_to_carbondata()`](https://charlescoverdale.github.io/cer/reference/cer_to_carbondata.md)

## Examples

``` r
cer_international_comparator()
```
