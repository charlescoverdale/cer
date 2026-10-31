# CRAN submission comments: cer 0.2.0

## Reason for this submission

Data-correctness release. The Clean Energy Regulator reorganised its
website, so two functions were returning a web page parsed as data and
one was silently truncating a file; three bundled reference tables have
been rebuilt from their published sources. Details in NEWS.md.

## R CMD check results

0 errors | 0 warnings | 0 notes (CRAN settings, R 4.5.2, macOS).

Tests that need cer.gov.au are skipped on CRAN, and examples that reach
it are wrapped in `try()` inside `\donttest{}`.

## Downstream dependencies

None on CRAN.
