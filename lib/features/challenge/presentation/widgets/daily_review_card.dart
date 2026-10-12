import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_pill.dart';

/// The daily review at the top of the challenges screen: a raised violet
/// card with its icon, its name, its rule and the facts to review.
///
/// Without [onTap] the card is greyed out: the player has seen no fact
/// yet, and [subtitle] says what to do first.
class DailyReviewCard extends StatelessWidget {
  /// Creates the card.
  const DailyReviewCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.dueLabel,
    super.key,
  });

  static const double _minHeight = 84;
  static const double _radius = 22;
  static const double _iconCircle = 52;
  static const double _iconSize = 28;
  static const double _titleSize = 20;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: AppSizes.space12,
  );

  /// "Révision du jour".
  final String title;

  /// The rule of the review, or what to do before it opens.
  final String subtitle;

  /// "8 à revoir", or `null` when no fact is due.
  final String? dueLabel;

  /// Starts the review, or `null` while it cannot be played.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isEnabled = onTap != null;
    final Color face = isEnabled ? colors.primary : context.palette.lockedFace;
    final Color text = isEnabled ? colors.onPrimary : context.palette.mutedText;
    final BorderRadius radius = BorderRadius.circular(_radius);
    return Semantics(
      button: true,
      enabled: isEnabled,
      child: Container(
        padding: const EdgeInsets.only(bottom: AppSizes.buttonDepth),
        decoration: BoxDecoration(
          color: isEnabled
              ? context.palette.primaryDepth
              : context.palette.lockedDepth,
          borderRadius: radius,
        ),
        child: Material(
          color: face,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              constraints: const BoxConstraints(minHeight: _minHeight),
              padding: _padding,
              child: Row(
                spacing: AppSizes.space12,
                children: <Widget>[
                  _ReviewIcon(isEnabled: isEnabled),
                  Expanded(
                    child: _ReviewTexts(
                      title: title,
                      subtitle: subtitle,
                      color: text,
                    ),
                  ),
                  if (dueLabel case final String label)
                    AppPill(label: label, backgroundColor: colors.secondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewIcon extends StatelessWidget {
  const _ReviewIcon({required this.isEnabled});

  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DailyReviewCard._iconCircle,
      height: DailyReviewCard._iconCircle,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.sync_rounded,
        size: DailyReviewCard._iconSize,
        color: isEnabled
            ? context.palette.primaryText
            : context.palette.mutedText,
      ),
    );
  }
}

class _ReviewTexts extends StatelessWidget {
  const _ReviewTexts({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontSize: DailyReviewCard._titleSize,
            color: color,
          ),
        ),
        Text(subtitle, style: textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
