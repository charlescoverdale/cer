# Redirect the cer cache to a per-test-run tempdir so we never
# write into the user's real home filespace. testthat cleans up
# the tempdir automatically when the test session ends; each test
# using its own options() invocation also restores at teardown.
cer_tmp <- tempfile("cer_cache_")
dir.create(cer_tmp, recursive = TRUE, showWarnings = FALSE)
options(cer.cache_dir = cer_tmp)
