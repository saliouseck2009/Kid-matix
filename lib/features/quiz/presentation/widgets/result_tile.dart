import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// White tile of the results: a big value over a small label.
class ResultTile extends StatelessWidget {
  /// Creates a tile showing [value] over [label].
  const ResultTile({required this.value, required this.label, super.key});

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space12,
    vertical: 20,
  );

  /// Big value, such as "9 / 10".
  final String value;

  /// What the value is, such as "réussies".
  final String label;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return MergeSemantics(
      child: Container(
        padding: _padding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Column(
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: textTheme.headlineMedium),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
