"""Tests for mic_py package."""

import pytest
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

try:
    from mic_py import compare_mic, MICValidation
except ImportError as e:
    pytest.skip(f"Could not import mic_py: {e}", allow_module_level=True)


class TestCompareMIC:
    """Test the compare_mic function."""
    
    def test_basic_comparison(self):
        """Test basic MIC comparison without antibiotics/organisms."""
        gold_standard = ["<0.25", "8", "64", ">64"]
        test = ["<0.25", "2", "16", "64"]
        
        val = compare_mic(gold_standard, test)
        
        # Check that we get a MICValidation object
        assert isinstance(val, MICValidation)
        assert val.r_object is not None
    
    def test_with_antibiotics(self):
        """Test MIC comparison with antibiotic and organism data."""
        gold_standard = ["<0.25", "8", "64", ">64"]
        test = ["<0.25", "2", "16", "64"]
        ab = ["AMK", "AMK", "AMK", "AMK"]
        mo = ["B_ESCHR_COLI", "B_ESCHR_COLI", "B_ESCHR_COLI", "B_ESCHR_COLI"]
        
        val = compare_mic(gold_standard, test, ab=ab, mo=mo)
        
        assert isinstance(val, MICValidation)
        assert val.r_object is not None
    
    def test_single_antibiotic(self):
        """Test with single antibiotic string instead of list."""
        gold_standard = ["<0.25", "8", "64", ">64"]
        test = ["<0.25", "2", "16", "64"]
        ab = "AMK"
        mo = "B_ESCHR_COLI"
        
        val = compare_mic(gold_standard, test, ab=ab, mo=mo)
        
        assert isinstance(val, MICValidation)


class TestMICValidation:
    """Test MICValidation class methods."""
    
    @pytest.fixture
    def validation_simple(self):
        """Create a simple validation object for testing."""
        gold_standard = ["<0.25", "8", "64", ">64"]
        test = ["<0.25", "2", "16", "64"]
        return compare_mic(gold_standard, test)
    
    @pytest.fixture
    def validation_with_ab(self):
        """Create a validation object with antibiotics for testing."""
        gold_standard = ["<0.25", "8", "64", ">64"]
        test = ["<0.25", "2", "16", "64"]
        ab = ["AMK", "AMK", "AMK", "AMK"]
        mo = ["B_ESCHR_COLI", "B_ESCHR_COLI", "B_ESCHR_COLI", "B_ESCHR_COLI"]
        return compare_mic(gold_standard, test, ab=ab, mo=mo)
    
    def test_print(self, validation_simple):
        """Test print method."""
        output = validation_simple.print()
        assert isinstance(output, str)
        assert "MIC validation object" in output
        assert "observations" in output
    
    def test_repr(self, validation_simple):
        """Test __repr__ method."""
        repr_str = repr(validation_simple)
        assert isinstance(repr_str, str)
        assert "MIC validation object" in repr_str
    
    def test_str(self, validation_simple):
        """Test __str__ method."""
        str_str = str(validation_simple)
        assert isinstance(str_str, str)
        assert "MIC validation object" in str_str
    
    def test_summary(self, validation_simple):
        """Test summary method."""
        summary = validation_simple.summary()
        assert summary is not None
        
        # Check that summary has print method
        output = summary.print()
        assert isinstance(output, str)
        assert "Essential agreement" in output
    
    def test_summary_with_categorical(self, validation_with_ab):
        """Test summary with categorical agreement."""
        summary = validation_with_ab.summary()
        assert summary is not None
        
        output = summary.print()
        assert isinstance(output, str)
        assert "Essential agreement" in output
    
    def test_summary_repr(self, validation_simple):
        """Test summary __repr__ method."""
        summary = validation_simple.summary()
        repr_str = repr(summary)
        assert isinstance(repr_str, str)
        assert "Essential agreement" in repr_str
    
    def test_as_dataframe(self, validation_simple):
        """Test conversion to DataFrame."""
        df = validation_simple.as_dataframe()
        assert df is not None
        assert len(df) == 4  # 4 observations
        assert "gold_standard" in df.columns
        assert "test" in df.columns
        assert "essential_agreement" in df.columns
    
    def test_summary_as_dataframe(self, validation_simple):
        """Test summary conversion to DataFrame."""
        summary = validation_simple.summary()
        df = summary.as_dataframe()
        assert df is not None
        # DataFrame structure depends on whether ab/mo are provided
        assert len(df) > 0
    
    def test_plot(self, validation_simple):
        """Test plot method - just ensure it doesn't error."""
        # This test just ensures plot() can be called without error
        # Visual inspection would be needed to verify actual plot
        try:
            plot_obj = validation_simple.plot()
            assert plot_obj is not None
        except Exception as e:
            # Plot might fail in headless environment, that's ok
            pytest.skip(f"Plot failed in test environment: {e}")


class TestParameters:
    """Test different parameter combinations."""
    
    def test_tolerate_censoring_options(self):
        """Test different tolerate_censoring options."""
        gold_standard = ["<0.25", "8"]
        test = ["0.5", "4"]
        
        for option in ["strict", "gold_standard", "test", "both"]:
            val = compare_mic(gold_standard, test, tolerate_censoring=option)
            assert isinstance(val, MICValidation)
    
    def test_ea_mode_options(self):
        """Test different ea_mode options."""
        gold_standard = ["0.25", "8"]
        test = ["0.5", "4"]
        
        for mode in ["categorical", "numeric"]:
            val = compare_mic(gold_standard, test, ea_mode=mode)
            assert isinstance(val, MICValidation)
    
    def test_boolean_parameters(self):
        """Test boolean parameter options."""
        gold_standard = ["<0.25", "8"]
        test = ["0.5", "4"]
        
        val = compare_mic(
            gold_standard, 
            test,
            accept_ecoff=True,
            simplify=False,
            tolerate_leq=False,
            tolerate_geq=False
        )
        assert isinstance(val, MICValidation)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
