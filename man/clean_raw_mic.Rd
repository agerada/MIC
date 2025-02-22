% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/meta_data.R
\name{clean_raw_mic}
\alias{clean_raw_mic}
\title{Clean up raw MIC for use as a feature}
\usage{
clean_raw_mic(mic)
}
\arguments{
\item{mic}{character containing MIC/s}
}
\value{
character of clean MIC/s
}
\description{
Removes leading "=" which can sometimes be present in raw MIC results. Also converts co-trimoxazole to trimethprim component only.
}
\examples{
clean_raw_mic(c("==>64","0.25/8.0"))
}
