#!/usr/bin/env python3
"""
Demonstrate the mic_py API structure.

This script shows how to use the mic_py package to analyze MIC data,
demonstrating the API even when the MIC R package is not fully installed.
"""

import sys

def demonstrate_api():
    """Demonstrate the mic_py API."""
    
    print("=" * 70)
    print("mic_py: Python Interface for the MIC R Package")
    print("=" * 70)
    
    print("\n1. Importing the package:")
    print("-" * 70)
    print("   from mic_py import compare_mic")
    
    try:
        from mic_py import compare_mic
        print("   ✓ Successfully imported compare_mic")
    except ImportError as e:
        print(f"   ✗ Failed to import: {e}")
        return False
    
    print("\n2. Example MIC data:")
    print("-" * 70)
    
    gold_standard = ["<0.25", "8", "64", ">64"]
    test = ["<0.25", "2", "16", "64"]
    
    print(f"   Gold standard MICs: {gold_standard}")
    print(f"   Test MICs:          {test}")
    
    print("\n3. Calling compare_mic():")
    print("-" * 70)
    print("   val = compare_mic(gold_standard, test)")
    
    try:
        val = compare_mic(gold_standard, test)
        print("   ✓ compare_mic() executed successfully")
    except Exception as e:
        print(f"   ✗ compare_mic() failed: {e}")
        print("\n   This is expected if the MIC R package is not installed.")
        print("   Install it with: install.packages('MIC') in R")
        return False
    
    print("\n4. Using the validation object:")
    print("-" * 70)
    
    print("\n   a) Print validation object:")
    print("      print(val)")
    try:
        print(val)
        print("   ✓ Print successful")
    except Exception as e:
        print(f"   ✗ Print failed: {e}")
    
    print("\n   b) Get summary statistics:")
    print("      summary = val.summary()")
    try:
        summary = val.summary()
        print(summary)
        print("   ✓ Summary successful")
    except Exception as e:
        print(f"   ✗ Summary failed: {e}")
    
    print("\n   c) Convert to DataFrame:")
    print("      df = val.as_dataframe()")
    try:
        df = val.as_dataframe()
        print(df)
        print("   ✓ DataFrame conversion successful")
    except Exception as e:
        print(f"   ✗ DataFrame conversion failed: {e}")
    
    print("\n   d) Plot validation results:")
    print("      val.plot()")
    try:
        val.plot()
        print("   ✓ Plot successful (may not display in terminal)")
    except Exception as e:
        print(f"   ✗ Plot failed: {e}")
    
    print("\n5. Using antibiotics and organisms:")
    print("-" * 70)
    
    ab = ["AMK", "AMK", "AMK", "AMK"]
    mo = ["B_ESCHR_COLI", "B_ESCHR_COLI", "B_ESCHR_COLI", "B_ESCHR_COLI"]
    
    print(f"   Antibiotics: {ab}")
    print(f"   Organisms:   {mo}")
    print("   val2 = compare_mic(gold_standard, test, ab=ab, mo=mo)")
    
    try:
        val2 = compare_mic(gold_standard, test, ab=ab, mo=mo)
        print("   ✓ compare_mic() with ab/mo successful")
        
        print("\n   Summary with categorical agreement:")
        summary2 = val2.summary()
        print(summary2)
        
    except Exception as e:
        print(f"   ✗ Failed: {e}")
    
    print("\n6. Available parameters:")
    print("-" * 70)
    print("""
   compare_mic(
       gold_standard,           # Required: Gold standard MIC values
       test,                    # Required: Test MIC values
       ab=None,                 # Optional: Antibiotic names
       mo=None,                 # Optional: Organism names
       accept_ecoff=False,      # Use ECOFFs when breakpoints unavailable
       simplify=True,           # Coerce to closest dilution
       ea_mode="categorical",   # Essential agreement mode
       tolerate_censoring="gold_standard",  # Censoring tolerance
       tolerate_matched_censoring="both",   # Matched censoring
       tolerate_leq=True,       # Tolerate <=
       tolerate_geq=True        # Tolerate >=
   )
    """)
    
    print("\n" + "=" * 70)
    print("API Demonstration Complete!")
    print("=" * 70)
    
    return True


def main():
    """Main entry point."""
    success = demonstrate_api()
    
    if success:
        print("\n✓ The mic_py package is working correctly!")
        print("  You can now use it to analyze your MIC data.")
        return 0
    else:
        print("\n⚠ The MIC R package needs to be installed to use mic_py.")
        print("  Install it from CRAN or GitHub:")
        print("    R: install.packages('MIC')")
        print("    R: remotes::install_github('agerada/MIC')")
        return 1


if __name__ == "__main__":
    sys.exit(main())
