prepare_mic_validation_plotting_data <- function(x, match_axes, add_missing_dilutions) {
  x <- as.data.frame(x)
  # keep only columns needed for plotting
  if (!"ab" %in% colnames(x)) {
    x <- x[,c("gold_standard", "test", "essential_agreement")]
  } else {
    x <- x[,c("gold_standard", "test", "essential_agreement", "ab")]
  }

  if (match_axes) {
    x[["gold_standard"]] <- match_levels(x[["gold_standard"]], match_to = x[["test"]])
    x[["test"]] <- match_levels(x[["test"]], match_to = x[["gold_standard"]])

    if (add_missing_dilutions) {
      x[["gold_standard"]] <- fill_dilution_levels(x[["gold_standard"]],
                                                   cap_lower = TRUE,
                                                   cap_upper = TRUE)
      x[["test"]] <- fill_dilution_levels(x[["test"]],
                                          cap_lower = TRUE,
                                          cap_upper = TRUE)
    }

    if (length(levels(x[["gold_standard"]])) > length(levels(x[["test"]]))) {
      # after dilution filling, levels may not yet match, force another match
      x[["test"]] <- forcats::fct_expand(x[["test"]],
                                          as.character(levels(x[["gold_standard"]])))
      x[["test"]] <- forcats::fct_relevel(x[["test"]],
                                          levels(x[["gold_standard"]]))
    }

    if (length(levels(x[["test"]])) > length(levels(x[["gold_standard"]]))) {
      x[["gold_standard"]] <- forcats::fct_expand(x[["gold_standard"]],
                                                  as.character(levels(x[["test"]])))
      x[["gold_standard"]] <- forcats::fct_relevel(x[["gold_standard"]],
                                                  levels(x[["test"]]))
    }
  }

  # temp fix - drop use of mic class as a patch to allow AMR v3 compatibility
  # When match_axes = TRUE, preserve the matched levels
  # When match_axes = FALSE, drop unused levels
  if (match_axes) {
    gs_levels <- levels(x[["gold_standard"]])
    test_levels <- levels(x[["test"]])
    x[["gold_standard"]] <- factor(x[["gold_standard"]], levels = gs_levels)
    x[["test"]] <- factor(x[["test"]], levels = test_levels)
  } else {
    x[["gold_standard"]] <- factor(x[["gold_standard"]])
    x[["test"]] <- factor(x[["test"]])
  }

  x
}

# Base R plotting helper function
plot_mic_validation_base <- function(x_df, main = "", ...) {
  # Create contingency table
  tab <- table(x_df[["gold_standard"]], x_df[["test"]])

  # Get levels for axes
  gs_levels <- levels(x_df[["gold_standard"]])
  test_levels <- levels(x_df[["test"]])

  n_gs <- length(gs_levels)
  n_test <- length(test_levels)

  # Set up color palette based on counts
  max_count <- max(tab)
  if (max_count == 0) max_count <- 1

  # Create color gradient from white to teal
  color_ramp <- grDevices::colorRampPalette(c("white", "#009194"))
  colors <- color_ramp(max_count + 1)

  # Set up plot
  old_par <- graphics::par(mar = c(5, 5, 4, 2) + 0.1, las = 2)
  on.exit(graphics::par(old_par))

  # Create empty plot
  graphics::plot(NA,
       xlim = c(0.5, n_gs + 0.5),
       ylim = c(0.5, n_test + 0.5),
       xlab = "",
       ylab = "",
       xaxt = "n",
       yaxt = "n",
       main = main,
       ...)

  graphics::title(xlab = "Gold standard MIC (mg/L)", line = 4)
  graphics::title(ylab = "Test (mg/L)", line = 4)

  # Add axes
  graphics::axis(1, at = seq_len(n_gs), labels = gs_levels, las = 2)
  graphics::axis(2, at = seq_len(n_test), labels = test_levels, las = 1)

  # Create EA lookup table
  # Convert essential_agreement to logical if it's a factor
  x_df$essential_agreement <- as.logical(x_df$essential_agreement)
  ea_tab <- stats::aggregate(
    essential_agreement ~ gold_standard + test,
    data = x_df,
    FUN = function(x) all(x)
  )

  # Draw tiles
  for (i in seq_len(n_gs)) {
    for (j in seq_len(n_test)) {
      count <- tab[i, j]
      if (count > 0) {
        fill_col <- colors[count + 1]

        # Check EA status for border color
        ea_match <- ea_tab$essential_agreement[
          ea_tab$gold_standard == gs_levels[i] & ea_tab$test == test_levels[j]
        ]
        border_col <- if (length(ea_match) > 0 && !ea_match) "red" else "black"

        graphics::rect(i - 0.4, j - 0.4, i + 0.4, j + 0.4,
             col = fill_col, border = border_col, lwd = 1.5)
        graphics::text(i, j, labels = count, col = border_col)
      }
    }
  }

  invisible(NULL)
}

#' @export
plot.single_ab_validation <- function(x,
                                      match_axes = TRUE,
                                      add_missing_dilutions = TRUE,
                                      ...) {
  x_df <- prepare_mic_validation_plotting_data(x, match_axes, add_missing_dilutions)
  plot_mic_validation_base(x_df, ...)
}

#' @export
plot.multi_ab_validation <- function(x,
                                     match_axes = TRUE,
                                     add_missing_dilutions = TRUE,
                                     ...) {
  x_df <- prepare_mic_validation_plotting_data(x, match_axes, add_missing_dilutions)

  if ("ab" %in% colnames(x_df)) {
    abs <- unique(x_df[["ab"]])
    n_abs <- length(abs)

    # Set up multi-panel layout
    n_cols <- ceiling(sqrt(n_abs))
    n_rows <- ceiling(n_abs / n_cols)

    old_par <- graphics::par(mfrow = c(n_rows, n_cols))
    on.exit(graphics::par(old_par))

    for (ab_val in abs) {
      ab_data <- x_df[x_df[["ab"]] == ab_val, ]
      ab_name <- tryCatch(
        AMR::ab_name(AMR::as.ab(as.character(ab_val))),
        error = function(e) ab_val
      )
      if (is.na(ab_name)) ab_name <- "unknown"
      plot_mic_validation_base(ab_data, main = ab_name, ...)
    }
  } else {
    plot_mic_validation_base(x_df, ...)
  }
}

#' Plot MIC validation results
#'
#' @param x object generated using compare_mic
#' @param match_axes Same x and y axis
#' @param add_missing_dilutions Axes will include dilutions that are not
#' represented in the data, based on a series of dilutions generated using mic_range().
#' @param ... additional arguments
#'
#' @return NULL (invisibly); called for side effects
#'
#' @export
#'
#' @examples
#' gold_standard <- c("<0.25", "8", "64", ">64")
#' test <- c("<0.25", "2", "16", "64")
#' val <- compare_mic(gold_standard, test)
#' plot(val)
#'
#' # if the validation contains multiple antibiotics, i.e.,
#' ab <- c("CIP", "CIP", "AMK", "AMK")
#' val <- compare_mic(gold_standard, test, ab)
#' # the following will plot all antibiotics in a single plot (pooled results)
#' plot(val)
plot.mic_validation <- function(x,
                                match_axes = TRUE,
                                add_missing_dilutions = TRUE,
                                ...) {
  # Fallback for objects without specific class
  if (!is.null(x$ab) && length(unique(x$ab)) > 1) {
    plot.multi_ab_validation(x,
                             match_axes = match_axes,
                             add_missing_dilutions = add_missing_dilutions,
                             ...)
  } else {
    plot.single_ab_validation(x,
                              match_axes = match_axes,
                              add_missing_dilutions = add_missing_dilutions,
                              ...)
  }
}

# ============================================================================
# autoplot methods (ggplot2-based plotting)
# ============================================================================

#' @exportS3Method ggplot2::autoplot single_ab_validation
autoplot.single_ab_validation <- function(object,
                                          match_axes = TRUE,
                                          add_missing_dilutions = TRUE,
                                          ...) {
  x_df <- prepare_mic_validation_plotting_data(object, match_axes, add_missing_dilutions)

  p <- x_df |>
    dplyr::group_by(.data[["gold_standard"]],
                    .data[["test"]],
                    .data[["essential_agreement"]]) |>
    dplyr::summarise(n = dplyr::n()) |>
    dplyr::rename(EA = "essential_agreement") |>
    ggplot2::ggplot(ggplot2::aes(x = .data[["gold_standard"]],
                                 y = .data[["test"]],
                                 fill = .data[["n"]],
                                 color = .data[["EA"]])) +
    ggplot2::geom_tile(alpha=1, show.legend = TRUE) +
    ggplot2::geom_text(ggplot2::aes(label=.data[["n"]]), show.legend = TRUE) +
    ggplot2::scale_fill_gradient(low="white", high="#009194") +
    ggplot2::scale_fill_manual(values=c("red", "black"), aesthetics = "color", drop = FALSE) +
    ggplot2::guides(color=ggplot2::guide_legend(override.aes=list(fill=NA))) +
    ggplot2::theme_bw(base_size = 13) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust=1)) +
    ggplot2::xlab("Gold standard MIC (mg/L)") +
    ggplot2::ylab("Test (mg/L)")

  if (match_axes) {
    p <- p + ggplot2::scale_x_discrete(drop = FALSE)
    p <- p + ggplot2::scale_y_discrete(drop = FALSE)
  }

  p
}

#' @exportS3Method ggplot2::autoplot multi_ab_validation
autoplot.multi_ab_validation <- function(object,
                                         match_axes = TRUE,
                                         add_missing_dilutions = TRUE,
                                         facet_wrap_ncol = NULL,
                                         facet_wrap_nrow = NULL,
                                         ...) {
  if (is.null(facet_wrap_ncol) && is.null(facet_wrap_nrow)) {
    return(autoplot.single_ab_validation(object, match_axes, add_missing_dilutions, ...))
  }

  x_df <- prepare_mic_validation_plotting_data(object, match_axes, add_missing_dilutions)

  p <- x_df |>
    dplyr::group_by(.data[["gold_standard"]],
                    .data[["test"]],
                    .data[["essential_agreement"]],
                    .data[["ab"]]) |>
    dplyr::mutate(ab = AMR::ab_name(AMR::as.ab(as.character(.data[["ab"]])))) |>
    dplyr::mutate(ab = dplyr::if_else(is.na(.data[["ab"]]), "unknown", .data[["ab"]])) |>
    dplyr::summarise(n = dplyr::n()) |>
    dplyr::rename(EA = "essential_agreement") |>
    ggplot2::ggplot(ggplot2::aes(x = .data[["gold_standard"]],
                                 y = .data[["test"]],
                                 fill = .data[["n"]],
                                 color = .data[["EA"]])) +
    ggplot2::geom_tile(alpha=1) +
    ggplot2::geom_text(ggplot2::aes(label=.data[["n"]])) +
    ggplot2::scale_fill_gradient(low="white", high="#009194") +
    ggplot2::scale_fill_manual(values=c("red", "black"), aesthetics = "color", drop = FALSE)

    if (any(!is.null(c(facet_wrap_ncol, facet_wrap_nrow)))) {
      p <- p + ggh4x::facet_wrap2(~ ab,
                                     nrow = facet_wrap_nrow,
                                     ncol = facet_wrap_ncol,
                                     axes = "all")
    }

    p <- p +
    ggplot2::guides(color=ggplot2::guide_legend(override.aes=list(fill=NA))) +
    ggplot2::theme_bw(base_size = 13) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5, hjust=1)) +
    ggplot2::xlab("Gold standard MIC (mg/L)") +
    ggplot2::ylab("Test (mg/L)")

  if (match_axes) {
    p <- p + ggplot2::scale_x_discrete(drop = FALSE)
    p <- p + ggplot2::scale_y_discrete(drop = FALSE)
  }
  p
}

#' Create a ggplot for MIC validation results
#'
#' @param object object generated using compare_mic
#' @param match_axes Same x and y axis
#' @param add_missing_dilutions Axes will include dilutions that are not
#' @param facet_wrap_ncol Facet wrap into n columns by antimicrobial (optional,
#' only available when more than one antimicrobial in validation)
#' @param facet_wrap_nrow Facet wrap into n rows by antimicrobial (optional,
#' only available when more than one antimicrobial in validation)
#' represented in the data, based on a series of dilutions generated using mic_range().
#' @param ... additional arguments
#'
#' @return ggplot object
#'
#' @exportS3Method ggplot2::autoplot mic_validation
#'
#' @examples
#' gold_standard <- c("<0.25", "8", "64", ">64")
#' test <- c("<0.25", "2", "16", "64")
#' val <- compare_mic(gold_standard, test)
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ggplot2::autoplot(val)
#' }
#'
#' # if the validation contains multiple antibiotics, i.e.,
#' ab <- c("CIP", "CIP", "AMK", "AMK")
#' val <- compare_mic(gold_standard, test, ab)
#' # the following will plot all antibiotics in a single plot (pooled results)
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ggplot2::autoplot(val)
#' }
#' # use the faceting arguments to split the plot by antibiotic
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ggplot2::autoplot(val, facet_wrap_ncol = 2)
#' }
autoplot.mic_validation <- function(object,
                                    match_axes = TRUE,
                                    add_missing_dilutions = TRUE,
                                    facet_wrap_ncol = NULL,
                                    facet_wrap_nrow = NULL,
                                    ...) {
  # Fallback for objects without specific class
  if (!is.null(object$ab) && length(unique(object$ab)) > 1) {
    autoplot.multi_ab_validation(object,
                                 match_axes = match_axes,
                                 add_missing_dilutions = add_missing_dilutions,
                                 facet_wrap_ncol = facet_wrap_ncol,
                                 facet_wrap_nrow = facet_wrap_nrow,
                                 ...)
  } else {
    autoplot.single_ab_validation(object,
                                  match_axes = match_axes,
                                  add_missing_dilutions = add_missing_dilutions,
                                  ...)
  }
}
