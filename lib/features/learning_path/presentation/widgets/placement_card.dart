import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_history_cubit.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_history_state.dart';

/// "Mon niveau de départ" on the Profile tab: the level of each domain at
/// the latest placement test with its date, the earlier tests, and a
/// button to take the test again. No mockup: it follows the Profile cards.
class PlacementCard extends StatelessWidget {
  /// Creates the card; the tests come from the enclosing
  /// [PlacementHistoryCubit], [onRetake] starts the test again.
  const PlacementCard({required this.onRetake, super.key});

  /// Most earlier tests listed under the latest one.
  static const int maxPastResults = 3;

  /// Starts the placement test again.
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final PlacementHistoryState state = context
        .watch<PlacementHistoryCubit>()
        .state;
    if (state is! PlacementHistoryLoaded) return const SizedBox.shrink();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<PlacementResultEntity> results = state.results;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space12,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              context.l10n.placementCardTitle,
              style: textTheme.titleMedium,
            ),
          ),
          if (results.isEmpty)
            Text(
              context.l10n.placementCardEmpty,
              style: textTheme.bodyMedium?.copyWith(
                color: context.palette.mutedText,
              ),
            )
          else ...<Widget>[
            _LatestResult(result: results.first),
            for (final PlacementResultEntity past
                in results.skip(1).take(maxPastResults))
              _PastResult(result: past),
          ],
          DepthButton(
            label: context.l10n.placementCardRetake,
            variant: DepthButtonVariant.secondary,
            onPressed: onRetake,
          ),
        ],
      ),
    );
  }
}

class _LatestResult extends StatelessWidget {
  const _LatestResult({required this.result});

  final PlacementResultEntity result;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSizes.space4,
      children: <Widget>[
        Text(
          context.l10n.placementCardLatest(_dateOf(context, result.takenAt)),
          style: textTheme.labelLarge?.copyWith(
            color: context.palette.mutedText,
          ),
        ),
        for (final DomainResultEntity domain in result.domains)
          Semantics(
            label: context.l10n.placementSkillSemantics(
              context.l10n.domainSpokenName(domain.domainId),
              context.l10n.placementCardLevel(domain.level, domain.skillCount),
            ),
            excludeSemantics: true,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.l10n.domainName(domain.domainId),
                    style: textTheme.bodyLarge,
                  ),
                ),
                Text(
                  context.l10n.placementCardLevel(
                    domain.level,
                    domain.skillCount,
                  ),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PastResult extends StatelessWidget {
  const _PastResult({required this.result});

  final PlacementResultEntity result;

  @override
  Widget build(BuildContext context) {
    final int levels = result.domains.fold(
      0,
      (int sum, DomainResultEntity domain) => sum + domain.level,
    );
    return Text(
      context.l10n.placementCardPast(_dateOf(context, result.takenAt), levels),
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: context.palette.mutedText),
    );
  }
}

String _dateOf(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatShortDate(date);
}
