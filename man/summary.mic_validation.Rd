% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/meta_data.R
\name{summary.mic_validation}
\alias{summary.mic_validation}
\title{Summary of MIC validation results}
\usage{
\method{summary}{mic_validation}(object, ...)
}
\arguments{
\item{object}{S3 mic_validation object}

\item{...}{further optional parameters}
}
\value{
S3 mic_validation_summary object
}
\description{
Summarise the results of an MIC validation generated using compare_mic().
}
\examples{
gold_standard <- c("<0.25", "8", "64", ">64")
test <- c("<0.25", "2", "16", "64")
val <- compare_mic(gold_standard, test)
summary(val)
# or, for more detailed results
as.data.frame(summary(val))
}
