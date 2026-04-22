#' cer: Australian Clean Energy Regulator Data
#'
#' Tidy R access to data published by the Australian Clean Energy
#' Regulator on carbon credits, the Safeguard Mechanism, renewable
#' energy certificates, and greenhouse gas reporting.
#'
#' @section Main function families:
#' - [cer_accu_projects()], [cer_accu_issuances()],
#'   [cer_accu_contracts()], [cer_accu_methods()],
#'   [cer_accu_relinquishments()]: Australian Carbon Credit Unit
#'   ('ACCU') Scheme.
#' - [cer_safeguard_facilities()]: Safeguard Mechanism covered
#'   emissions, baselines, and SMC issuance.
#' - [cer_nger_corporate()], [cer_nger_electricity()]: National
#'   Greenhouse and Energy Reporting ('NGER') scheme.
#' - [cer_lgc_power_stations()]: Large-scale Renewable Energy Target
#'   ('LRET') accredited power stations.
#' - [cer_sres_installations()]: Small-scale Renewable Energy Scheme
#'   ('SRES') postcode installation data.
#' - [cer_qcmr()]: Quarterly Carbon Market Report data workbook.
#' - [cer_cache_info()], [cer_clear_cache()]: cache management.
#'
#' @section Data source:
#' All data is published by the Clean Energy Regulator at
#' <https://cer.gov.au/markets/reports-and-data> under a Creative
#' Commons Attribution 4.0 International licence.
#'
#' @keywords internal
#' @concept Australian climate policy
#' @concept carbon markets
#' @concept ACCU
#' @concept Safeguard Mechanism
#' @concept NGER
"_PACKAGE"

utils::globalVariables(c("accu_methods"))
