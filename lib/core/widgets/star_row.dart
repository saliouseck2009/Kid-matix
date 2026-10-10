import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// A row of stars, the first [count] filled: the stars of a stage.
///
/// Screen readers hear "2 étoiles sur 3"; the shapes alone carry the
/// meaning, never the color.
class StarRow extends StatelessWidget {
  /// Creates [max] stars of [size], [count] of them filled.
  const StarRow({
    required this.count,
    this.max = defaultMax,
    this.size = 24,
    super.key,
  });

  /// Stars of a stage.
  static const int defaultMax = 3;

  /// Filled stars.
  final int count;

  /// Stars shown.
  final int max;

  /// Size of each star.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.starsLabel(count, max),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int index = 0; index < max; index++)
            Icon(
              index < count ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: index < count
                  ? context.palette.secondaryDepth
                  : context.palette.lockedDepth,
            ),
        ],
      ),
    );
  }
}
