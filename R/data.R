#' Sample data with 10 economic indicators
#'
#' A dataset containing 10 monthly economic indicators. All variables are log-differenced, if necessary, to achieve stationarity.
#'
#' @format A data frame with 263 rows and 11 variables:
#'
#' \describe{
#'   \item{date}{Dates}
#'   \item{total_production}{Industrial production in Israel - total}
#'   \item{retail_revenue}{Revenue in Trade}
#'   \item{services_revenue}{Revenue in Services}
#'   \item{employment}{Employment excluding absent workers}
#'   \item{export_services}{Exports of services}
#'   \item{building_starts}{Building starts}
#'   \item{import_consumer_goods}{Imports of consumer goods}
#'   \item{import_production_inputs}{Imports of production inputs}
#'   \item{export_goods}{Exports of goods}
#'   \item{job_openings}{Job openings}
#' }
#' @source Public data from various sources
"indicators"
