# Print a cer_tbl

Prints a provenance header (title, source URL, licence, retrieval time,
dimensions) followed by the data frame.

## Usage

``` r
# S3 method for class 'cer_tbl'
print(x, ...)
```

## Arguments

- x:

  A `cer_tbl` object.

- ...:

  Passed to the next method.

## Value

Invisibly returns `x`.

## Examples

``` r
x <- data.frame(project_id = "ERF123", accus_issued = 4200)
x <- structure(x, cer_title = "Demo", cer_source = "https://cer.gov.au",
               cer_licence = "CC BY 4.0", cer_retrieved = Sys.time(),
               class = c("cer_tbl", "data.frame"))
print(x)
```
