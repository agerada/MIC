#' Example MIC data
#'
#' Example minimum inhibitory concentration validation data for three
#' antimicrobials on Escherichia coli strains. This data is synthetic and
#' generated to give an example of different MIC distribution.
#' @format ## `example_mics`
#' A data frame with 300 rows and 4 columns:
#' \describe{
#'   \item{gs}{Gold standard MICs}
#'   \item{test}{Test MICs}
#'   \item{mo}{Microorganism code in AMR::mo format}
#'   \item{ab}{Antibiotic code in AMR::ab format}
#' }
#' @source Synthetic data
"example_mics"

#' ECOFF data
#'
#' A dataset containing the epidemiological cut-off values (ECOFFs) for
#' different antibiotics and microorganisms. Currently, only the ECOFF values
#' for _Escherichia coli_ are included.
#'
#' @format ## `ecoffs`
#' A data frame with 85 rows and 25 columns:
#' \describe{
#'  \item{organism}{Microorganism code in AMR::mo format}
#'  \item{antibiotic}{Antibiotic code in AMR::ab format}
#'  \item{`0.002`:`512`}{Counts of isolates in each concentration "bin"}
#'  \item{Distributions}{see EUCAST documentation below}
#'  \item{Observations}{Number of observations}
#'  \item{`(T)ECOFF`}{see EUCAST documentation below}
#'  \item{`Confidence interval`}{see EUCAST documentation below}
#' }
#' @source EUCAST \url{https://www.eucast.org/mic_and_zone_distributions_and_ecoffs}
#'
#' These data have (or this document, presentation or video has) been produced
#' in part under ECDC service contracts and made available by EUCAST at no cost
#' to the user and can be accessed on the EUCAST website www.eucast.org.
#' The views and opinions expressed are those of EUCAST at a given point in time.
#' EUCAST recommendations are frequently updated and the latest versions are available at www.eucast.org.
"ecoffs"
