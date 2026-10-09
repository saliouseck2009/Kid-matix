import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Horizontal bar filled in proportion to a progress [value].
class AppProgressBar extends StatelessWidget {
  /// Creates a bar filled to [value], a fraction from 0 to 1.
  const AppProgressBar({
    required this.value,
    required this.semanticLabel,
    super.key,
  }) : assert(value >= 0 && value <= 1, 'value must be between 0 and 1.');

  /// Filled fraction of the bar, from 0 to 1.
  final double value;

  /// Full localized description of the progress for screen readers.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusPill);
    return Semantics(
      label: semanticLabel,
      child: Container(
        height: AppSizes.progressBarHeight,
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: context.palette.tint,
          borderRadius: radius,
        ),
        child: FractionallySizedBox(
          widthFactor: value,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: radius,
            ),
          ),
        ),
      ),
    );
  }
}
