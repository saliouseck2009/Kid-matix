import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';

/// "Nouveau record !" on the results of a quiz that beat the player's
/// best score, with the record it beat.
class NewRecordCard extends StatelessWidget {
  /// Creates the card of [record].
  const NewRecordCard({required this.record, super.key});

  static const double _iconCircle = 52;
  static const double _iconSize = 30;

  /// Record set by the quiz.
  final RecordEntity record;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int? previous = record.previousBest;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.space16),
        decoration: BoxDecoration(
          color: context.palette.warmTint,
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Row(
          spacing: AppSizes.space12,
          children: <Widget>[
            Container(
              width: _iconCircle,
              height: _iconCircle,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded, size: _iconSize),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.resultsNewRecord,
                    style: textTheme.titleLarge,
                  ),
                  Text(
                    context.l10n.resultsRecordScore(record.bestScore),
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    previous == null
                        ? context.l10n.resultsFirstRecord
                        : context.l10n.resultsRecordBeaten(previous),
                    style: textTheme.bodySmall?.copyWith(
                      color: context.palette.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
