import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// A challenge of the challenges screen: its icon in a tinted circle, its
/// name and rule, and the player's record when there is one, or a chevron
/// when it opens a screen.
class ChallengeCard extends StatelessWidget {
  /// Creates the card of the challenge [title], showing [icon] or else
  /// [illustration].
  const ChallengeCard({
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.illustration,
    this.record,
    this.iconColor,
    this.note,
    this.hasChevron = false,
    super.key,
  }) : assert(icon != null || illustration != null, 'an icon is needed');

  static const double _minHeight = 80;
  static const double _radius = 22;
  static const double _iconCircle = 52;
  static const double _iconSize = 28;
  static const double _titleSize = 20;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: AppSizes.space12,
  );

  /// Icon of the challenge, or `null` to show [illustration].
  final IconData? icon;

  /// Drawing shown in the circle when there is no [icon].
  final Widget? illustration;

  /// Whether a chevron says the card opens a screen.
  final bool hasChevron;

  /// Color of the circle behind [icon].
  final Color iconBackground;

  /// Color of [icon], or `null` for the text color.
  final Color? iconColor;

  /// Name of the challenge.
  final String title;

  /// Rule of the challenge.
  final String subtitle;

  /// "Record 18", or `null` before a first record.
  final String? record;

  /// A short line under [subtitle], or `null`.
  final String? note;

  /// Starts the challenge.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? record = this.record;
    final String? note = this.note;
    final BorderRadius radius = BorderRadius.circular(_radius);
    return Semantics(
      button: true,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
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
                Container(
                  width: _iconCircle,
                  height: _iconCircle,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: icon == null
                      ? Center(child: illustration)
                      : Icon(icon, size: _iconSize, color: iconColor),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: _titleSize,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: context.palette.mutedText,
                        ),
                      ),
                      if (note != null)
                        Text(
                          note,
                          style: textTheme.bodySmall?.copyWith(
                            color: context.palette.mutedText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                if (record != null)
                  Text(
                    record,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.palette.primaryText,
                    ),
                  ),
                if (hasChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.palette.mutedText,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
