# Federal Register of Legislation URL resolver.
#
# Every ACCU method and NGER/Safeguard rule is a Legislative
# Instrument on the Federal Register of Legislation
# (legislation.gov.au). The "F<YYYY>L<NNNNN>" identifier is stable
# and authoritative; CER webpage slugs are not.

#' Build a Federal Register of Legislation URL
#'
#' Given a Legislative Instrument identifier (e.g. `"F2024L01292"`
#' for the Environmental Plantings 2024 method), return the stable
#' URL on the Federal Register of Legislation. This is the
#' authoritative source of truth for ACCU methods, Safeguard Rule
#' amendments, and NGER Determinations.
#'
#' @param instrument Character identifier (e.g. `"F2024L01292"`).
#'   Case-insensitive.
#'
#' @return A length-1 character URL string.
#'
#' @references
#' Commonwealth of Australia. \emph{Legislation Act 2003} establishes
#'   the Federal Register of Legislation as the authoritative
#'   source for Legislative Instruments.
#'
#' @family reproducibility
#' @export
#' @examples
#' cer_legislative_instrument("F2024L01292")
#' cer_legislative_instrument("F2015L00398")
cer_legislative_instrument <- function(instrument) {
  stopifnot(is.character(instrument), length(instrument) == 1L)
  instrument <- toupper(trimws(instrument))
  if (!grepl("^F[0-9]{4}[LC][0-9]+$", instrument)) {
    cli::cli_warn(c(
      "{.val {instrument}} does not match the Legislative Instrument pattern.",
      "i" = "Expected format like {.val F2024L01292} (F + YYYY + L or C + digits)."
    ))
  }
  sprintf("https://www.legislation.gov.au/Details/%s", instrument)
}
