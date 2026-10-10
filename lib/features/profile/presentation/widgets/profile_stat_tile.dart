import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// A figure of the Profile tab, such as "6 jours / de série".
class ProfileStatTile extends StatelessWidget {
  /// Creates the tile showing [value] over [label].
  const ProfileStatTile({
    required this.value,
    required this.label,
    this.isHighlighted = false,
    super.key,
  });

  static const double _radius = 20;
  static const double _valueSize = 24;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: AppSizes.space12,
  );

  /// Figure, such as "6 jours" or "3".
  final String value;

  /// What the figure counts, such as "de série".
  final String label;

  /// Whether the tile is tinted, as the streak is.
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      child: Container(
        padding: _padding,
        decoration: BoxDecoration(
          color: isHighlighted
              ? context.palette.warmTint
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Column(
          spacing: 2,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: textTheme.titleLarge?.copyWith(fontSize: _valueSize),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.labelMedium?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
