% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/meta_data.R
\name{compare_mic}
\alias{compare_mic}
\title{Compare and validate MIC values}
\usage{
compare_mic(
  gold_standard,
  test,
  ab = NULL,
  mo = NULL,
  accept_ecoff = FALSE,
  simplify = TRUE
)
}
\arguments{
\item{gold_standard}{vector of MICs to compare against.}

\item{test}{vector of MICs that are under investigation}

\item{ab}{character vector (same length as MIC) of antibiotic names (optional)}

\item{mo}{character vector (same length as MIC) of microorganism names (optional)}

\item{accept_ecoff}{if TRUE, ECOFFs will be used when no clinical breakpoints are available}

\item{simplify}{if TRUE, MIC values will be coerced into the closest halving
dilution (e.g., 0.55 will be converted to 0.5)}
}
\value{
S3 mic_validation object
}
\description{
This function compares an vector of MIC values to another. Generally, this is
in the context of a validation experiment -- an investigational assay or
method (the "test") is compared to a gold standard. The rules used by this
function are in line with "ISO 20776-2:2021 Part 2: Evaluation of performance
of antimicrobial susceptibility test devices against reference broth
micro-dilution."

There are two levels of detail that are provided. If only the MIC values are
provided, the function will look for essential agreement between the two sets
of MIC. If the organism and antibiotic arguments are provided, the function
will also calculate the categorical agreement using EUCAST breakpoints (or,
if breakpoint not available and accept_ecoff = TRUE, ECOFFs).

The function returns a special dataframe of results, which is also an
mic_validation object. This object can be summarised using summary() for
summary metrics, plotted using plot() for an essential agreement confusion
matrix, and tabulated using table().
}
\examples{
# Just using MIC values only
gold_standard <- c("<0.25", "8", "64", ">64")
test <- c("<0.25", "2", "16", "64")
val <- compare_mic(gold_standard, test)
summary(val)

# Using MIC values and antibiotic and organism names
gold_standard <- c("<0.25", "8", "64", ">64")
test <- c("<0.25", "2", "16", "64")
ab <- c("AMK", "AMK", "AMK", "AMK")
mo <- c("B_ESCHR_COLI", "B_ESCHR_COLI", "B_ESCHR_COLI", "B_ESCHR_COLI")
val <- compare_mic(gold_standard, test, ab, mo)
"error" \%in\% names(val)  # val now has categorical agreement
}
