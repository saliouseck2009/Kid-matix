import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';

/// A row of exclusive choices on a white band, the chosen one filled,
/// such as 10, 20 or 30 questions.
class ChoiceSegments<T> extends StatelessWidget {
  /// Creates the segments of [choices], [selected] filled.
  const ChoiceSegments({
    required this.choices,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.labelStyle,
    this.backgroundColor,
    super.key,
  });

  static const double _radius = 18;
  static const double _segmentRadius = 14;

  /// Values to choose from, in order.
  final List<T> choices;

  /// Value chosen.
  final T selected;

  /// Text of a value.
  final String Function(T value) labelOf;

  /// Called with the value tapped.
  final ValueChanged<T> onSelected;

  /// Style of the texts; the theme's medium title by default.
  final TextStyle? labelStyle;

  /// Color of the band; the surface color by default.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle? style =
        labelStyle ?? Theme.of(context).textTheme.titleMedium;
    return Container(
      padding: const EdgeInsets.all(AppSizes.space4),
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        spacing: AppSizes.space4,
        children: <Widget>[
          for (final T value in choices)
            Expanded(
              child: _Segment(
                label: labelOf(value),
                isSelected: value == selected,
                style: style,
                onTap: () => onSelected(value),
                radius: _segmentRadius,
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.style,
    required this.onTap,
    required this.radius,
  });

  final String label;
  final bool isSelected;
  final TextStyle? style;
  final VoidCallback onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final BorderRadius shape = BorderRadius.circular(radius);
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? scheme.primary : Colors.transparent,
        borderRadius: shape,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.space8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: style?.copyWith(
                color: isSelected ? scheme.onPrimary : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
