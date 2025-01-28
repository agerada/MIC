
<!-- README.md is generated from README.Rmd. Please edit that file -->

# MIC

<!-- badges: start -->

[![R-CMD-check](https://github.com/agerada/MIC/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/agerada/MIC/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Introduction

`MIC` is an R package for the analysis of minimum inhibitory
concentration (MIC) data. The package was designed to be compatible with
the [`AMR`](https://msberends.github.io/AMR/), in particular most of the
functions in `MIC` are designed to accept and return `AMR` objects, such
as `mic` and `sir`. The primary functions in `MIC` are designed towards
validation studies of minimum inhibitory concentrations, however it also
can (optionally) be used to support the construction of machine learning
models that predict MIC values from genomic data.

## Features

- Validation metrics (such as essential agreement) for MIC experiments
  or predictions allow comparison against a gold standard, in line with
  ISO 20776-2:2021.
- Plots and tables can be generated from validation experiments.
- Quality control analysis of MIC experiments.
- Functions to deal with censoring in MIC data.
- Helper functions to download whole genome sequencing data and
  susceptibility metadata from the
  [PATRIC](https://www.bv-brc.org/docs/system_documentation/data.html)
  database at BV-BRC.
- Conversion of whole genome sequence data (assembled .fna files) to
  k-mer based features for machine learning models.
- Fast k-mer counting using C++ and `Rcpp`.
- K-mer features stored in `XGBoost`-compatible `libsvm` format.

## Installation

### GitHub

``` r
# install.packages("remotes")
remotes::install_github("agerada/MIC")
```

## Example

``` r
library(MIC)
#> 
#> Attaching package: 'MIC'
#> The following object is masked from 'package:base':
#> 
#>     table
```

``` r
library(AMR)

mic1 <- c("2", "4", "2", "0.25", "0.5")
mic2 <- c("1", "4", "2", "4", "0.25")
mic1 <- as.mic(mic1)
mic2 <- as.mic(mic2)
val <- compare_mic(mic1, mic2)
summary(val)
#> $EA_n
#> [1] 4
#> 
#> $EA_pcent
#> [1] 0.8
#> 
#> $bias
#> [1] -20
```

``` r
plot(val)
```

<img src="man/figures/README-fig-val-ea-1.png" width="100%" />
