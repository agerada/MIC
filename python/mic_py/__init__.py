"""
mic_py: Python interface for the MIC R package.

This package provides Python bindings for the MIC R package, which is used
for analyzing minimum inhibitory concentration (MIC) data.
"""

from .core import compare_mic, MICValidation

__version__ = "0.1.0"
__all__ = ["compare_mic", "MICValidation"]
