import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Card of the results listing the facts missed during the quiz.
class FactsToReviewCard extends StatelessWidget {
  /// Creates the card of [facts], such as "5 × 8 = 40".
  const FactsToReviewCard({required this.facts, super.key});

  static const EdgeInsets _chipPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 6,
  );

  /// Whole facts to review, with their result.
  final List<String> facts;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.space24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.space12,
        children: <Widget>[
          Text(context.l10n.resultsToReview, style: textTheme.titleMedium),
          if (facts.isEmpty)
            Text(
              context.l10n.resultsNothingToReview,
              style: textTheme.bodyMedium?.copyWith(
                color: context.palette.mutedText,
              ),
            )
          else
            Wrap(
              spacing: AppSizes.space8,
              runSpacing: AppSizes.space8,
              children: <Widget>[
                for (final String fact in facts)
                  Container(
                    padding: _chipPadding,
                    decoration: BoxDecoration(
                      color: context.feedbackPalette.wrongTint,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: Text(
                      fact,
                      style: textTheme.titleLarge?.copyWith(
                        color: context.feedbackPalette.wrongDepth,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
