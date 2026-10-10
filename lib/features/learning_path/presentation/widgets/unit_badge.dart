import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// How a unit badge looks.
enum UnitBadgeStyle {
  /// Violet: a table done or open.
  reached,

  /// Yellow with a white ring: the current table.
  current,

  /// Grey with a lock: a table not reached yet.
  locked,
}

/// Round raised badge of a table, such as "×5".
class UnitBadge extends StatelessWidget {
  /// Creates the badge showing [mark].
  const UnitBadge({
    required this.mark,
    required this.style,
    this.size = 88,
    super.key,
  });

  static const double _depthRatio = 0.07;
  static const double _ringWidth = 5;

  /// Text of the badge, such as "×5".
  final String mark;

  /// How the badge looks.
  final UnitBadgeStyle style;

  /// Diameter of the badge.
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final (Color face, Color depth, Color text) = switch (style) {
      UnitBadgeStyle.reached => (
        scheme.primary,
        context.palette.primaryDepth,
        scheme.onPrimary,
      ),
      UnitBadgeStyle.current => (
        scheme.secondary,
        context.palette.secondaryDepth,
        scheme.onSecondary,
      ),
      UnitBadgeStyle.locked => (
        context.palette.lockedFace,
        context.palette.lockedDepth,
        context.palette.mutedText,
      ),
    };
    final TextStyle? textStyle = Theme.of(context).textTheme.headlineMedium
        ?.copyWith(color: text, fontSize: size * 0.34);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.only(bottom: size * _depthRatio),
      decoration: BoxDecoration(
        color: depth,
        shape: BoxShape.circle,
        border: style == UnitBadgeStyle.current
            ? Border.all(color: scheme.surface, width: _ringWidth)
            : null,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(color: face, shape: BoxShape.circle),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (style == UnitBadgeStyle.locked)
                Icon(
                  Icons.lock_outline_rounded,
                  color: text,
                  size: size * 0.28,
                ),
              FittedBox(
                child: Text(
                  mark,
                  style: style == UnitBadgeStyle.locked
                      ? textStyle?.copyWith(fontSize: size * 0.24)
                      : textStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
