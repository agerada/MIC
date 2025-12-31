# ============================================================================
# Base R plot tests (automated)
# ============================================================================

test_that("plot.single_ab_validation runs without error", {
  gold <- c("<0.25", "8", "64", ">64")
  test <- c("<0.25", "2", "16", "64")
  val <- compare_mic(gold, test)

  # expect no error (warnings are acceptable)
  expect_error(plot(val), NA)
  expect_error(plot(val, match_axes = FALSE), NA)
  expect_error(plot(val, add_missing_dilutions = FALSE), NA)
})

test_that("plot.multi_ab_validation runs without error", {
  gold <- c("<0.25", "8", "64", ">64", "0.5")
  test <- c("<0.25", "2", "16", "64", "1")
  ab <- c("AMK", "AMK", "CIP", "CIP", "AMK")
  val <- compare_mic(gold, test, ab = ab)

  # default should run (creates multi-panel plot for multiple abs)
  expect_error(plot(val), NA)

  # with match_axes = FALSE
  expect_error(plot(val, match_axes = FALSE), NA)
})

test_that("plot.mic_validation dispatches correctly based on ab column", {
  gold <- c("<0.25", "8", "64", ">64")
  test <- c("<0.25", "2", "16", "64")

  # Single ab validation
  val_single <- compare_mic(gold, test)
  expect_error(plot(val_single), NA)

  # Multi ab validation
  ab <- c("AMK", "AMK", "CIP", "CIP")
  val_multi <- compare_mic(gold, test, ab = ab)
  expect_error(plot(val_multi), NA)
})

test_that("base plot returns NULL invisibly", {
  gold <- c("<0.25", "8", "64", ">64")
  test <- c("<0.25", "2", "16", "64")
  val <- compare_mic(gold, test)

  result <- plot(val)
  expect_null(result)
})

test_that("base plot handles edge cases", {
  # All identical values
  gold <- c("8", "8", "8", "8")
  test <- c("8", "8", "8", "8")
  val <- compare_mic(gold, test)
  expect_error(plot(val), NA)

  # All essential agreement = TRUE
  gold <- c("8", "16")
  test <- c("8", "16")
  val <- compare_mic(gold, test)
  expect_error(plot(val), NA)

  # All essential agreement = FALSE
  gold <- c("0.25", "64")
  test <- c("64", "0.25")
  val <- compare_mic(gold, test)
  expect_error(plot(val), NA)
})

# ============================================================================
# autoplot (ggplot2) tests (automated)
# ============================================================================

test_that("autoplot.single_ab_validation returns ggplot object", {
  skip_if_not_installed("ggplot2")

  gold <- c("<0.25", "8", "64", ">64")
  test <- c("<0.25", "2", "16", "64")
  val <- compare_mic(gold, test)

  p <- ggplot2::autoplot(val)
  expect_s3_class(p, "ggplot")
})

test_that("autoplot.single_ab_validation respects match_axes parameter", {
  skip_if_not_installed("ggplot2")

  gold <- c("<0.25", "8", "64", ">64")
  test <- c("<0.25", "2", "16", "64")
  val <- compare_mic(gold, test)

  p1 <- ggplot2::autoplot(val, match_axes = TRUE)
  p2 <- ggplot2::autoplot(val, match_axes = FALSE)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("autoplot.multi_ab_validation returns ggplot object", {
  skip_if_not_installed("ggplot2")

  gold <- c("<0.25", "8", "64", ">64", "0.5")
  test <- c("<0.25", "2", "16", "64", "1")
  ab <- c("AMK", "AMK", "CIP", "CIP", "AMK")
  val <- compare_mic(gold, test, ab = ab)

  # Without faceting
  p1 <- ggplot2::autoplot(val)
  expect_s3_class(p1, "ggplot")
})

test_that("autoplot.multi_ab_validation handles faceting", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("ggh4x")

  gold <- c("<0.25", "8", "64", ">64", "0.5")
  test <- c("<0.25", "2", "16", "64", "1")
  ab <- c("AMK", "AMK", "CIP", "CIP", "AMK")
  val <- compare_mic(gold, test, ab = ab)

  # With facet_wrap_ncol
  p <- ggplot2::autoplot(val, facet_wrap_ncol = 2)
  expect_s3_class(p, "ggplot")

  # With facet_wrap_nrow
  p2 <- ggplot2::autoplot(val, facet_wrap_nrow = 2)
  expect_s3_class(p2, "ggplot")
})

test_that("autoplot.mic_validation dispatches correctly", {
  skip_if_not_installed("ggplot2")

  gold <- c("<0.25", "8", "64", ">64")
  test <- c("<0.25", "2", "16", "64")

  # Single ab
  val_single <- compare_mic(gold, test)
  p1 <- ggplot2::autoplot(val_single)
  expect_s3_class(p1, "ggplot")

  # Multi ab
  ab <- c("AMK", "AMK", "CIP", "CIP")
  val_multi <- compare_mic(gold, test, ab = ab)
  p2 <- ggplot2::autoplot(val_multi)
  expect_s3_class(p2, "ggplot")
})

test_that("autoplot handles edge cases", {
  skip_if_not_installed("ggplot2")

  # All identical values
  gold <- c("8", "8", "8", "8")
  test <- c("8", "8", "8", "8")
  val <- compare_mic(gold, test)
  expect_s3_class(ggplot2::autoplot(val), "ggplot")

  # All essential agreement = TRUE
  gold <- c("8", "16")
  test <- c("8", "16")
  val <- compare_mic(gold, test)
  expect_s3_class(ggplot2::autoplot(val), "ggplot")

  # All essential agreement = FALSE
  gold <- c("0.25", "64")
  test <- c("64", "0.25")
  val <- compare_mic(gold, test)
  expect_s3_class(ggplot2::autoplot(val), "ggplot")
})

# ============================================================================
# Visual inspection tests (interactive - skip on CI/CRAN)
# These tests require human visual inspection to verify correctness
# ============================================================================

test_that("base plot visual appearance is correct", {
  skip("Interactive test: requires visual inspection")
  skip_on_cran()
  skip_on_ci()


  gold <- c("<0.25", "8", "64", ">64", "0.5", "1", "2", "4")
  test <- c("<0.25", "2", "16", "64", "0.5", "2", "4", "8")
  val <- compare_mic(gold, test)

  # Visual check: plot should show a heatmap with:
# - White to teal gradient based on counts
  # - Red borders for cells without essential agreement
  # - Black borders for cells with essential agreement
  # - Count labels in each cell
  plot(val)
  message("Verify: Heatmap with proper colors, EA indicators, and count labels")
})

test_that("base plot multi-panel layout is correct", {
  skip("Interactive test: requires visual inspection")
  skip_on_cran()
  skip_on_ci()

  gold <- c("<0.25", "8", "64", ">64", "0.5", "1")
  test <- c("<0.25", "2", "16", "64", "0.5", "2")
  ab <- c("AMK", "AMK", "CIP", "CIP", "GEN", "GEN")
  val <- compare_mic(gold, test, ab = ab)

  # Visual check: should show 3 panels (one for each antibiotic)
  plot(val)
  message("Verify: 3-panel layout with proper antibiotic names as titles")
})

test_that("autoplot visual appearance is correct", {
  skip("Interactive test: requires visual inspection")
  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("ggplot2")

  gold <- c("<0.25", "8", "64", ">64", "0.5", "1", "2", "4")
  test <- c("<0.25", "2", "16", "64", "0.5", "2", "4", "8")
  val <- compare_mic(gold, test)

  # Visual check: ggplot should match base R plot appearance
  print(ggplot2::autoplot(val))
  message("Verify: ggplot heatmap with proper colors, EA legend, and count labels")
})

test_that("autoplot faceting is correct", {
  skip("Interactive test: requires visual inspection")
  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("ggh4x")

  gold <- c("<0.25", "8", "64", ">64", "0.5", "1")
  test <- c("<0.25", "2", "16", "64", "0.5", "2")
  ab <- c("AMK", "AMK", "CIP", "CIP", "GEN", "GEN")
  val <- compare_mic(gold, test, ab = ab)

  # Visual check: should show faceted plot with proper antibiotic names
  print(ggplot2::autoplot(val, facet_wrap_ncol = 2))
  message("Verify: Faceted layout with 2 columns and antibiotic names")
})

# ============================================================================
# Tests for prepare_mic_validation_plotting_data parameters
# These tests verify the match_axes and add_missing_dilutions parameters
# ============================================================================

test_that("prepare_mic_validation_plotting_data is accessible for testing", {
  # Access internal function
  prep_fn <- MIC:::prepare_mic_validation_plotting_data
  expect_true(is.function(prep_fn))
})

# --- match_axes parameter tests ---

test_that("match_axes = TRUE produces matching levels between gold_standard and test", {
  # Create validation with different MIC values in gold_standard and test
  # Use simple numeric values without < or > to avoid AMR conversion issues
  gold <- c("1", "8", "64")
  test <- c("0.5", "2", "4")
  val <- compare_mic(gold, test)

  prep_fn <- MIC:::prepare_mic_validation_plotting_data
  result <- prep_fn(val, match_axes = TRUE, add_missing_dilutions = FALSE)

  # Levels should match between gold_standard and test
  expect_equal(levels(result[["gold_standard"]]), levels(result[["test"]]))

  # Get the actual unique values from both columns
  gs_unique <- unique(as.character(result[["gold_standard"]]))
  test_unique <- unique(as.character(result[["test"]]))

  # All values from gold_standard should be in levels
  for (v in gs_unique) {
    expect_true(v %in% levels(result[["gold_standard"]]))
    expect_true(v %in% levels(result[["test"]]))  # Also in matched test levels
  }

  # All values from test should be in levels
  for (v in test_unique) {
    expect_true(v %in% levels(result[["gold_standard"]]))  # Also in matched gs levels
    expect_true(v %in% levels(result[["test"]]))
  }
})

test_that("match_axes = FALSE produces independent levels for each column", {
  # Create validation with different MIC values in gold_standard and test
  # Use simple numeric values without < or > to avoid AMR conversion issues
  gold <- c("1", "8", "64")
  test <- c("0.5", "2", "4")
  val <- compare_mic(gold, test)

  prep_fn <- MIC:::prepare_mic_validation_plotting_data
  result <- prep_fn(val, match_axes = FALSE, add_missing_dilutions = FALSE)

  # Levels should only contain values present in each column
  gs_levels <- levels(result[["gold_standard"]])
  test_levels <- levels(result[["test"]])

  # gold_standard levels should only contain gold_standard values
  expect_equal(length(gs_levels), 3)
  expect_true(all(c("1", "8", "64") %in% gs_levels))
  # test values should NOT be in gold_standard levels
  expect_false("0.5" %in% gs_levels)
  expect_false("2" %in% gs_levels)
  expect_false("4" %in% gs_levels)

  # test levels should only contain test values
  expect_equal(length(test_levels), 3)
  expect_true(all(c("0.5", "2", "4") %in% test_levels))
  # gold_standard values should NOT be in test levels
  expect_false("1" %in% test_levels)
  expect_false("8" %in% test_levels)
  expect_false("64" %in% test_levels)
})

test_that("match_axes = FALSE does not include all 1855 MIC levels", {
  # Regression test for bug where match_axes = FALSE kept all mic levels
  gold <- c("2", "4", "8")
  test <- c("1", "2", "4")
  val <- compare_mic(gold, test)

  prep_fn <- MIC:::prepare_mic_validation_plotting_data
  result <- prep_fn(val, match_axes = FALSE, add_missing_dilutions = FALSE)

  # Should have very few levels, not 1855
  expect_lt(length(levels(result[["gold_standard"]])), 10)
  expect_lt(length(levels(result[["test"]])), 10)
})

# --- add_missing_dilutions parameter tests ---

test_that("add_missing_dilutions = TRUE fills intermediate dilution levels", {
  # Create validation with gaps in dilution series
  gold <- c("1", "8", "64")  # Missing 2, 4, 16, 32
  test <- c("1", "8", "64")
  val <- compare_mic(gold, test)

  prep_fn <- MIC:::prepare_mic_validation_plotting_data
  result <- prep_fn(val, match_axes = TRUE, add_missing_dilutions = TRUE)

  # Should include intermediate levels (2, 4, 16, 32)
  gs_levels <- levels(result[["gold_standard"]])
  expect_true("2" %in% gs_levels)
  expect_true("4" %in% gs_levels)
  expect_true("16" %in% gs_levels)
  expect_true("32" %in% gs_levels)
})

test_that("add_missing_dilutions = FALSE keeps only observed levels", {
  # Create validation with gaps in dilution series
  gold <- c("1", "8", "64")  # Missing 2, 4, 16, 32
  test <- c("1", "8", "64")
  val <- compare_mic(gold, test)

  prep_fn <- MIC:::prepare_mic_validation_plotting_data
  result <- prep_fn(val, match_axes = TRUE, add_missing_dilutions = FALSE)

  # Should NOT include intermediate levels
  gs_levels <- levels(result[["gold_standard"]])
  expect_false("2" %in% gs_levels)
  expect_false("4" %in% gs_levels)
  expect_false("16" %in% gs_levels)
  expect_false("32" %in% gs_levels)

  # Should only have the observed values
  expect_equal(length(gs_levels), 3)
})

test_that("add_missing_dilutions respects cap_upper and cap_lower", {
  # Test that filled levels don't extend beyond observed range
  gold <- c("2", "16")
  test <- c("2", "16")
  val <- compare_mic(gold, test)

  prep_fn <- MIC:::prepare_mic_validation_plotting_data
  result <- prep_fn(val, match_axes = TRUE, add_missing_dilutions = TRUE)

  gs_levels <- levels(result[["gold_standard"]])

  # Should include intermediate levels
  expect_true("4" %in% gs_levels)
  expect_true("8" %in% gs_levels)

  # Should NOT include levels outside the observed range
  expect_false("1" %in% gs_levels)
  expect_false("32" %in% gs_levels)
})

# --- Combined parameter tests ---

test_that("match_axes = TRUE with add_missing_dilutions = TRUE works correctly", {
  gold <- c("1", "16")
  test <- c("2", "32")
  val <- compare_mic(gold, test)

  prep_fn <- MIC:::prepare_mic_validation_plotting_data
  result <- prep_fn(val, match_axes = TRUE, add_missing_dilutions = TRUE)

  # Levels should match
  expect_equal(levels(result[["gold_standard"]]), levels(result[["test"]]))

  # Should include all intermediate levels from min to max across both
  gs_levels <- levels(result[["gold_standard"]])
  expect_true("1" %in% gs_levels)
  expect_true("2" %in% gs_levels)
  expect_true("4" %in% gs_levels)
  expect_true("8" %in% gs_levels)
  expect_true("16" %in% gs_levels)
  expect_true("32" %in% gs_levels)
})

# --- Integration tests with plot() and autoplot() ---

test_that("plot respects match_axes = TRUE parameter", {
  gold <- c("1", "8")
  test <- c("2", "4")
  val <- compare_mic(gold, test)

  # Should execute without error
  expect_error(plot(val, match_axes = TRUE), NA)
})

test_that("plot respects match_axes = FALSE parameter", {
  gold <- c("1", "8")
  test <- c("2", "4")
  val <- compare_mic(gold, test)

  # Should execute without error
  expect_error(plot(val, match_axes = FALSE), NA)
})

test_that("plot respects add_missing_dilutions = TRUE parameter", {
  gold <- c("1", "16")
  test <- c("1", "16")
  val <- compare_mic(gold, test)

  # Should execute without error
  expect_error(plot(val, add_missing_dilutions = TRUE), NA)
})

test_that("plot respects add_missing_dilutions = FALSE parameter", {
  gold <- c("1", "16")
  test <- c("1", "16")
  val <- compare_mic(gold, test)

  # Should execute without error
  expect_error(plot(val, add_missing_dilutions = FALSE), NA)
})

test_that("autoplot respects match_axes = TRUE parameter", {
  skip_if_not_installed("ggplot2")

  gold <- c("1", "8")
  test <- c("2", "4")
  val <- compare_mic(gold, test)

  p <- ggplot2::autoplot(val, match_axes = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("autoplot respects match_axes = FALSE parameter", {
  skip_if_not_installed("ggplot2")

  gold <- c("1", "8")
  test <- c("2", "4")
  val <- compare_mic(gold, test)

  p <- ggplot2::autoplot(val, match_axes = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("autoplot respects add_missing_dilutions = TRUE parameter", {
  skip_if_not_installed("ggplot2")

  gold <- c("1", "16")
  test <- c("1", "16")
  val <- compare_mic(gold, test)

  p <- ggplot2::autoplot(val, add_missing_dilutions = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("autoplot respects add_missing_dilutions = FALSE parameter", {
  skip_if_not_installed("ggplot2")

  gold <- c("1", "16")
  test <- c("1", "16")
  val <- compare_mic(gold, test)

  p <- ggplot2::autoplot(val, add_missing_dilutions = FALSE)
  expect_s3_class(p, "ggplot")
})

# --- Multi-antibiotic tests ---

test_that("match_axes works with multi_ab_validation for plot", {
  gold <- c("1", "8", "2", "4")
  test <- c("2", "4", "1", "8")
  ab <- c("AMK", "AMK", "CIP", "CIP")
  val <- compare_mic(gold, test, ab = ab)

  expect_error(plot(val, match_axes = TRUE), NA)
  expect_error(plot(val, match_axes = FALSE), NA)
})

test_that("add_missing_dilutions works with multi_ab_validation for plot", {
  gold <- c("1", "16", "2", "32")
  test <- c("1", "16", "2", "32")
  ab <- c("AMK", "AMK", "CIP", "CIP")
  val <- compare_mic(gold, test, ab = ab)

  expect_error(plot(val, add_missing_dilutions = TRUE), NA)
  expect_error(plot(val, add_missing_dilutions = FALSE), NA)
})

test_that("match_axes works with multi_ab_validation for autoplot", {
  skip_if_not_installed("ggplot2")

  gold <- c("1", "8", "2", "4")
  test <- c("2", "4", "1", "8")
  ab <- c("AMK", "AMK", "CIP", "CIP")
  val <- compare_mic(gold, test, ab = ab)

  p1 <- ggplot2::autoplot(val, match_axes = TRUE)
  p2 <- ggplot2::autoplot(val, match_axes = FALSE)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("add_missing_dilutions works with multi_ab_validation for autoplot", {
  skip_if_not_installed("ggplot2")

  gold <- c("1", "16", "2", "32")
  test <- c("1", "16", "2", "32")
  ab <- c("AMK", "AMK", "CIP", "CIP")
  val <- compare_mic(gold, test, ab = ab)

  p1 <- ggplot2::autoplot(val, add_missing_dilutions = TRUE)
  p2 <- ggplot2::autoplot(val, add_missing_dilutions = FALSE)

  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})
