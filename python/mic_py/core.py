"""Core functionality for mic_py package."""

import os
from typing import Optional, List, Union

try:
    import rpy2.robjects as ro
    from rpy2.robjects import pandas2ri, vectors
    from rpy2.robjects.packages import importr
except ImportError:
    raise ImportError(
        "rpy2 is required for mic_py. Install it with: pip install rpy2>=3.5.0"
    )


class MICValidation:
    """
    Python wrapper for MIC validation objects from the R MIC package.
    
    This class wraps the S3 mic_validation object returned by compare_mic(),
    providing Python-friendly methods for print, summary, and plot operations.
    
    Attributes:
        r_object: The underlying R S3 object (mic_validation)
    """
    
    def __init__(self, r_object):
        """
        Initialize MICValidation wrapper.
        
        Args:
            r_object: R S3 mic_validation object
        """
        self.r_object = r_object
        self._mic_pkg = importr('MIC')
        
    def __repr__(self):
        """Return string representation using R's print method."""
        # Capture R print output
        return self._capture_r_output(ro.r['print'], self.r_object)
    
    def __str__(self):
        """Return string representation using R's print method."""
        return self.__repr__()
    
    def _capture_r_output(self, func, *args, **kwargs):
        """Capture output from R function."""
        # Use R's capture.output to get the printed string
        capture_output = ro.r['capture.output']
        output = capture_output(func(*args, **kwargs))
        return '\n'.join(output)
    
    def print(self):
        """
        Print the MIC validation object.
        
        This calls the R print.mic_validation method to display information
        about the validation object.
        
        Returns:
            str: String representation of the validation object
        """
        output = self._capture_r_output(ro.r['print'], self.r_object)
        print(output)
        return output
    
    def summary(self):
        """
        Generate summary statistics for the MIC validation.
        
        This calls the R summary.mic_validation method to calculate
        essential agreement rates, bias, and categorical agreement metrics.
        
        Returns:
            MICValidationSummary: Summary object with validation metrics
        """
        r_summary = ro.r['summary'](self.r_object)
        return MICValidationSummary(r_summary)
    
    def plot(self, 
             match_axes: bool = True,
             add_missing_dilutions: bool = True,
             facet_wrap_ncol: Optional[int] = None,
             facet_wrap_nrow: Optional[int] = None):
        """
        Plot the MIC validation results.
        
        This calls the R plot.mic_validation method to create a confusion
        matrix visualization showing essential agreement.
        
        Args:
            match_axes: Use same x and y axis scales
            add_missing_dilutions: Include dilutions not in data
            facet_wrap_ncol: Number of columns for faceting (multi-antibiotic plots)
            facet_wrap_nrow: Number of rows for faceting (multi-antibiotic plots)
            
        Returns:
            R ggplot2 object
        """
        plot_func = ro.r['plot']
        
        # Build arguments
        kwargs = {
            'match_axes': match_axes,
            'add_missing_dilutions': add_missing_dilutions
        }
        
        if facet_wrap_ncol is not None:
            kwargs['facet_wrap_ncol'] = facet_wrap_ncol
        if facet_wrap_nrow is not None:
            kwargs['facet_wrap_nrow'] = facet_wrap_nrow
            
        # Create plot
        plot_obj = plot_func(self.r_object, **kwargs)
        
        # Display plot
        ro.r['print'](plot_obj)
        
        return plot_obj
    
    def as_dataframe(self):
        """
        Convert MIC validation object to pandas DataFrame.
        
        Returns:
            pandas.DataFrame: DataFrame with validation results
        """
        # Activate automatic conversion between R and pandas
        with ro.conversion.localconverter(ro.default_converter + pandas2ri.converter):
            r_df = ro.r['as.data.frame'](self.r_object)
            return ro.conversion.rpy2py(r_df)


class MICValidationSummary:
    """
    Python wrapper for MIC validation summary objects.
    
    This class wraps the S3 mic_validation_summary object returned by
    summary.mic_validation().
    
    Attributes:
        r_object: The underlying R S3 object (mic_validation_summary)
    """
    
    def __init__(self, r_object):
        """
        Initialize MICValidationSummary wrapper.
        
        Args:
            r_object: R S3 mic_validation_summary object
        """
        self.r_object = r_object
        
    def __repr__(self):
        """Return string representation using R's print method."""
        return self._capture_r_output(ro.r['print'], self.r_object)
    
    def __str__(self):
        """Return string representation using R's print method."""
        return self.__repr__()
    
    def _capture_r_output(self, func, *args, **kwargs):
        """Capture output from R function."""
        capture_output = ro.r['capture.output']
        output = capture_output(func(*args, **kwargs))
        return '\n'.join(output)
    
    def print(self):
        """
        Print the summary object.
        
        Returns:
            str: String representation of the summary
        """
        output = self._capture_r_output(ro.r['print'], self.r_object)
        print(output)
        return output
    
    def as_dataframe(self):
        """
        Convert summary to pandas DataFrame.
        
        Returns:
            pandas.DataFrame: DataFrame with summary statistics
        """
        # Activate automatic conversion between R and pandas
        with ro.conversion.localconverter(ro.default_converter + pandas2ri.converter):
            r_df = ro.r['as.data.frame'](self.r_object)
            return ro.conversion.rpy2py(r_df)


def compare_mic(
    gold_standard: List[str],
    test: List[str],
    ab: Optional[Union[List[str], str]] = None,
    mo: Optional[Union[List[str], str]] = None,
    accept_ecoff: bool = False,
    simplify: bool = True,
    ea_mode: str = "categorical",
    tolerate_censoring: str = "gold_standard",
    tolerate_matched_censoring: str = "both",
    tolerate_leq: bool = True,
    tolerate_geq: bool = True,
) -> MICValidation:
    """
    Compare and validate MIC values.
    
    This function compares two sets of MIC values (typically a test assay
    against a gold standard) and calculates validation metrics including
    essential agreement and categorical agreement.
    
    Args:
        gold_standard: List of MIC values for the gold standard assay
        test: List of MIC values for the test assay
        ab: Antibiotic names (optional, enables categorical agreement)
        mo: Microorganism names (optional, enables categorical agreement)
        accept_ecoff: Use ECOFFs when clinical breakpoints unavailable
        simplify: Coerce MICs to closest halving dilution
        ea_mode: Essential agreement mode ("categorical" or "numeric")
        tolerate_censoring: How to handle censored data
            ("strict", "gold_standard", "test", or "both")
        tolerate_matched_censoring: How to handle matched censoring
            ("strict", "gold_standard", "test", or "both")
        tolerate_leq: Tolerate <= in essential agreement calculations
        tolerate_geq: Tolerate >= in essential agreement calculations
        
    Returns:
        MICValidation: Validation object with methods for print, summary, plot
        
    Examples:
        >>> from mic_py import compare_mic
        >>> gold_standard = ["<0.25", "8", "64", ">64"]
        >>> test = ["<0.25", "2", "16", "64"]
        >>> val = compare_mic(gold_standard, test)
        >>> print(val)
        >>> summary = val.summary()
        >>> print(summary)
    """
    # Import MIC R package
    try:
        mic_pkg = importr('MIC')
    except Exception as e:
        raise ImportError(
            f"Failed to import MIC R package: {e}. "
            "Make sure the MIC R package is installed: install.packages('MIC')"
        )
    
    # Convert Python lists to R vectors
    r_gold_standard = vectors.StrVector(gold_standard)
    r_test = vectors.StrVector(test)
    
    # Build arguments
    kwargs = {
        'gold_standard': r_gold_standard,
        'test': r_test,
        'accept_ecoff': accept_ecoff,
        'simplify': simplify,
        'ea_mode': ea_mode,
        'tolerate_censoring': tolerate_censoring,
        'tolerate_matched_censoring': tolerate_matched_censoring,
        'tolerate_leq': tolerate_leq,
        'tolerate_geq': tolerate_geq,
    }
    
    # Add optional arguments if provided
    if ab is not None:
        if isinstance(ab, list):
            kwargs['ab'] = vectors.StrVector(ab)
        else:
            kwargs['ab'] = ab
            
    if mo is not None:
        if isinstance(mo, list):
            kwargs['mo'] = vectors.StrVector(mo)
        else:
            kwargs['mo'] = mo
    
    # Call R compare_mic function
    r_result = mic_pkg.compare_mic(**kwargs)
    
    # Wrap in Python class
    return MICValidation(r_result)
