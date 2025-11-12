# mic-py: Python Interface for the MIC R Package

This package provides a Python interface to the [MIC R package](https://github.com/agerada/MIC) for analyzing minimum inhibitory concentration (MIC) data.

## Installation

### System Requirements

- Python 3.8+
- R (>= 4.1.0)
- rpy2 >= 3.5.0
- pandas >= 1.0.0

### Install Dependencies

**Option 1: System packages (recommended)**

Ubuntu/Debian:
```bash
sudo apt-get install r-base python3-rpy2 python3-pandas
```

**Option 2: Via pip**
```bash
pip install rpy2>=3.5.0 pandas>=1.0.0
```

### Install mic-py

```bash
cd python
pip install -e .
```

### Install the MIC R Package

The MIC R package must be installed in your R environment:

To install the MIC R package:

```r
# From CRAN
install.packages("MIC")

# Or from GitHub
remotes::install_github("agerada/MIC")
```

## Usage

```python
from mic_py import compare_mic

# Example MIC data
gold_standard = ["<0.25", "8", "64", ">64"]
test = ["<0.25", "2", "16", "64"]

# Compare MIC values
val = compare_mic(gold_standard, test)

# Print validation object
print(val)

# Get summary statistics
summary = val.summary()
print(summary)

# Plot results (creates a ggplot2 visualization)
val.plot()
```

## Features

- **compare_mic()**: Validate and compare MIC values between a test and gold standard
- **print()**: Display MIC validation object information
- **summary()**: Get detailed validation statistics (essential agreement, bias, etc.)
- **plot()**: Generate confusion matrix plots for MIC validation

## Documentation

For detailed documentation on the MIC validation methods and parameters, see the [MIC R package documentation](https://github.com/agerada/MIC).

## License

This package is licensed under GPL (>= 3), matching the license of the MIC R package.
