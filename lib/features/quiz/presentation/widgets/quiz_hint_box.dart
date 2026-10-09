import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/dashed_border_painter.dart';

/// Dashed box under the answers that tells what to do.
class QuizHintBox extends StatelessWidget {
  /// Creates the box showing [hint].
  const QuizHintBox({required this.hint, super.key});

  /// Height shared with the feedback panel, so nothing jumps.
  static const double height = 116;

  static const double _dashWidth = 3;

  /// What the player has to do.
  final String hint;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: context.palette.softBorder,
        strokeWidth: _dashWidth,
        radius: AppSizes.radiusLarge,
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: height),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(AppSizes.space16),
        child: Text(
          hint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: context.palette.mutedText,
          ),
        ),
      ),
    );
  }
}
