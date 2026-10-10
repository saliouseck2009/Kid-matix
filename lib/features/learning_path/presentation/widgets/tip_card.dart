import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';

/// Yellow card of the Discovery stage: the mascot gives the tip of the
/// table.
class TipCard extends StatelessWidget {
  /// Creates the card of [tip].
  const TipCard({required this.tip, super.key});

  static const double _mascotSize = 72;

  /// Tip of the table.
  final String tip;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: context.palette.warmTint,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Row(
        spacing: AppSizes.space12,
        children: <Widget>[
          const ExcludeSemantics(
            child: MascotIllustration(size: _mascotSize),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(context.l10n.pathTipTitle, style: textTheme.titleMedium),
                Text(
                  tip,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
