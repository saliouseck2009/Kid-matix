import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';

/// What the mascot says, in a white rounded bubble announced to screen
/// readers when it changes.
class SpeechBubble extends StatelessWidget {
  /// Creates the bubble of [text].
  const SpeechBubble({required this.text, this.color, super.key});

  static const double _radius = 18;

  /// What the mascot says.
  final String text;

  /// Background of the bubble; the surface color when `null`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSizes.space8,
        ),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(_radius),
            topRight: Radius.circular(_radius),
            bottomRight: Radius.circular(_radius),
            bottomLeft: Radius.circular(AppSizes.space4),
          ),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
