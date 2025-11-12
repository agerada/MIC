#!/usr/bin/env python3
"""
Validate the Python interface structure and imports.

This script validates that the mic_py package has the correct structure
and can be imported, without requiring the full R MIC package to be installed.
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

def test_imports():
    """Test that the package can be imported."""
    print("Testing package imports...")
    
    try:
        import mic_py
        print("✓ mic_py package imported successfully")
        print(f"  Version: {mic_py.__version__}")
        print(f"  Exports: {mic_py.__all__}")
    except ImportError as e:
        print(f"✗ Failed to import mic_py: {e}")
        return False
    
    try:
        from mic_py import compare_mic, MICValidation
        print("✓ Core components imported successfully")
        print(f"  - compare_mic function: {compare_mic}")
        print(f"  - MICValidation class: {MICValidation}")
    except ImportError as e:
        print(f"✗ Failed to import core components: {e}")
        return False
    
    return True


def test_rpy2():
    """Test that rpy2 is available."""
    print("\nTesting rpy2 availability...")
    
    try:
        import rpy2
        print(f"✓ rpy2 is available (version {rpy2.__version__})")
    except ImportError:
        print("✗ rpy2 is not installed")
        print("  Install with: sudo apt-get install python3-rpy2")
        print("  Or: pip install rpy2>=3.5.0")
        return False
    
    try:
        import rpy2.robjects as ro
        print("✓ rpy2.robjects imported successfully")
    except ImportError as e:
        print(f"✗ Failed to import rpy2.robjects: {e}")
        return False
    
    return True


def test_r_installation():
    """Test that R is available."""
    print("\nTesting R installation...")
    
    try:
        import rpy2.robjects as ro
        r_version = ro.r('R.version.string')[0]
        print(f"✓ R is available: {r_version}")
        return True
    except Exception as e:
        print(f"✗ R is not properly configured: {e}")
        return False


def test_mic_package():
    """Test that the MIC R package is available."""
    print("\nTesting MIC R package...")
    
    try:
        from rpy2.robjects.packages import importr
        mic_pkg = importr('MIC')
        print("✓ MIC R package is installed")
        
        # Try to access compare_mic function
        compare_mic_r = mic_pkg.compare_mic
        print(f"✓ compare_mic function is accessible: {compare_mic_r}")
        return True
    except Exception as e:
        print(f"✗ MIC R package is not available: {e}")
        print("  Install with: install.packages('MIC')")
        print("  Or from GitHub: remotes::install_github('agerada/MIC')")
        return False


def test_class_structure():
    """Test the structure of the Python classes."""
    print("\nTesting Python class structure...")
    
    try:
        from mic_py import MICValidation
        from mic_py.core import MICValidationSummary
        
        # Check MICValidation methods
        expected_methods = ['print', 'summary', 'plot', 'as_dataframe', '__repr__', '__str__']
        for method in expected_methods:
            if hasattr(MICValidation, method):
                print(f"✓ MICValidation.{method} exists")
            else:
                print(f"✗ MICValidation.{method} missing")
                return False
        
        # Check MICValidationSummary methods
        expected_methods = ['print', 'as_dataframe', '__repr__', '__str__']
        for method in expected_methods:
            if hasattr(MICValidationSummary, method):
                print(f"✓ MICValidationSummary.{method} exists")
            else:
                print(f"✗ MICValidationSummary.{method} missing")
                return False
        
        return True
    except Exception as e:
        print(f"✗ Error checking class structure: {e}")
        return False


def test_compare_mic_signature():
    """Test the compare_mic function signature."""
    print("\nTesting compare_mic function signature...")
    
    try:
        from mic_py import compare_mic
        import inspect
        
        sig = inspect.signature(compare_mic)
        params = list(sig.parameters.keys())
        
        expected_params = [
            'gold_standard', 'test', 'ab', 'mo', 'accept_ecoff',
            'simplify', 'ea_mode', 'tolerate_censoring',
            'tolerate_matched_censoring', 'tolerate_leq', 'tolerate_geq'
        ]
        
        for param in expected_params:
            if param in params:
                print(f"✓ Parameter '{param}' present")
            else:
                print(f"✗ Parameter '{param}' missing")
                return False
        
        return True
    except Exception as e:
        print(f"✗ Error checking function signature: {e}")
        return False


def main():
    """Run all validation tests."""
    print("=" * 60)
    print("mic_py Package Validation")
    print("=" * 60)
    
    results = []
    
    # Test basic imports
    results.append(("Package Imports", test_imports()))
    
    # Test rpy2
    results.append(("rpy2 Availability", test_rpy2()))
    
    # Test R installation
    results.append(("R Installation", test_r_installation()))
    
    # Test MIC R package (this will fail if package not installed)
    results.append(("MIC R Package", test_mic_package()))
    
    # Test Python class structure
    results.append(("Class Structure", test_class_structure()))
    
    # Test function signature
    results.append(("Function Signature", test_compare_mic_signature()))
    
    # Summary
    print("\n" + "=" * 60)
    print("Validation Summary")
    print("=" * 60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{name:.<40} {status}")
    
    print(f"\nTotal: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n✓ All validation tests passed!")
        print("The mic_py package is ready to use.")
        return 0
    else:
        print(f"\n✗ {total - passed} test(s) failed")
        if not results[3][1]:  # MIC R package test
            print("\nNote: The MIC R package installation failure is expected")
            print("if you haven't installed it yet. Install it with:")
            print("  R: install.packages('MIC')")
        return 1


if __name__ == "__main__":
    sys.exit(main())
