% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/patric.R
\name{load_patric_db}
\alias{load_patric_db}
\title{Load PATRIC database}
\usage{
load_patric_db(x = patric_ftp_path)
}
\arguments{
\item{x}{Character path to local or ftp path (.txt or .rds), or
data.frame object.}
}
\value{
PATRIC database (S3 class 'patric_db')
}
\description{
Load PATRIC database
}
\examples{
\donttest{
patric_db <- load_patric_db()  # will get from PATRIC ftp
}

# make data.frame with single row
p <- data.frame(genome_id = 1,
                genome_name = "E. coli",
                antibiotic = "amoxicillin",
                measurement = 2.0,
                measurement_unit = "mg/L",
                laboratory_typing_method = "Agar dilution",
                resistant_phenotype = "R")
load_patric_db(p)
}
