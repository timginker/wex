#' Sample Data with 10 Economic Indicators
#'
#' A dataset containing 10 monthly economic indicators, covering the period from January 2000 to November 2021. All variables have been log-differenced, when necessary, to achieve stationarity.
#'
#' @format A data frame with 263 rows and 11 variables:
#'
#' \describe{
#'   \item{date}{Date values (format: YYYY-MM-DD)}
#'   \item{total_production}{Total industrial production in Israel}
#'   \item{retail_revenue}{Trade revenue}
#'   \item{services_revenue}{Service revenue}
#'   \item{employment}{Employment (excluding absent workers)}
#'   \item{export_services}{Exports of services}
#'   \item{building_starts}{Building starts}
#'   \item{import_consumer_goods}{Imports of consumer goods}
#'   \item{import_production_inputs}{Imports of production inputs}
#'   \item{export_goods}{Exports of goods}
#'   \item{job_openings}{Job openings}
#' }
#' @source Public data from various sources
"indicators"
