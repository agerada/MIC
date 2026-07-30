#!/usr/bin/env python3
"""
Example usage of the mic_py package.

This script demonstrates how to use the Python interface to the MIC R package
for validating minimum inhibitory concentration (MIC) data.
"""

from mic_py import compare_mic


def main():
    """Run example MIC validation analyses."""
    
    print("=" * 60)
    print("Example 1: Basic MIC Validation")
    print("=" * 60)
    
    # Example MIC data without antibiotics/organisms
    gold_standard = ["<0.25", "8", "64", ">64"]
    test = ["<0.25", "2", "16", "64"]
    
    # Compare MIC values
    val = compare_mic(gold_standard, test)
    
    # Print validation object
    print("\nValidation object:")
    print(val)
    
    # Get summary statistics
    print("\nSummary statistics:")
    summary = val.summary()
    print(summary)
    
    # Convert to DataFrame
    print("\nValidation data as DataFrame:")
    df = val.as_dataframe()
    print(df)
    
    print("\n" + "=" * 60)
    print("Example 2: MIC Validation with Antibiotics and Organisms")
    print("=" * 60)
    
    # Example with antibiotic and organism data
    gold_standard = ["<0.25", "8", "64", ">64"]
    test = ["<0.25", "2", "16", "64"]
    ab = ["AMK", "AMK", "AMK", "AMK"]
    mo = ["B_ESCHR_COLI", "B_ESCHR_COLI", "B_ESCHR_COLI", "B_ESCHR_COLI"]
    
    # Compare with categorical agreement
    val_cat = compare_mic(gold_standard, test, ab=ab, mo=mo)
    
    print("\nValidation object with categorical agreement:")
    print(val_cat)
    
    print("\nDetailed summary:")
    summary_cat = val_cat.summary()
    print(summary_cat)
    
    # Get summary as DataFrame
    print("\nSummary as DataFrame:")
    summary_df = summary_cat.as_dataframe()
    print(summary_df)
    
    print("\n" + "=" * 60)
    print("Example 3: Plotting (requires display)")
    print("=" * 60)
    
    try:
        # Create a plot
        print("\nGenerating plot...")
        val.plot()
        print("Plot created successfully!")
    except Exception as e:
        print(f"Plot generation failed (this is expected in headless environments): {e}")
    
    print("\n" + "=" * 60)
    print("Examples completed successfully!")
    print("=" * 60)


if __name__ == "__main__":
    main()
