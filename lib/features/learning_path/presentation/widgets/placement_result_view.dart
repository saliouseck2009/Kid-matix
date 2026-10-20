import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/widgets/app_card.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_level.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_levels.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_skill_row.dart';

/// Result of the placement test (mockup 18, adapted): the skills the child
/// passed among the five of the test, and the unit to start with.
///
/// The units found are open on the path; this screen only tells what was
/// found. The list of skills and the card of the start unit have no
/// mockup: they follow the grid of the mockup with the design system.
class PlacementResultView extends StatelessWidget {
  /// Creates the result of [outcome].
  const PlacementResultView({
    required this.outcome,
    required this.onSeePath,
    super.key,
  });

  static const double _mascotSize = 140;

  /// What the test found.
  final PlacementOutcome outcome;

  /// Opens the path.
  final VoidCallback onSeePath;

  bool _isAcquired(SkillLevel skill) {
    return outcome.skills.any(
      (SkillResult result) => result.skillId == skill.id && result.isAcquired,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int acquiredCount = SkillLevels.all.where(_isAcquired).length;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSizes.space16,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSizes.space16,
                children: <Widget>[
                  const Center(
                    child: MascotIllustration(
                      size: _mascotSize,
                      mood: MascotMood.happy,
                    ),
                  ),
                  Semantics(
                    header: true,
                    child: Text(
                      context.l10n.placementResultTitle(acquiredCount),
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall,
                    ),
                  ),
                  Text(
                    context.l10n.placementResultSubtitle(acquiredCount),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: context.palette.mutedText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppCard(
                    child: Column(
                      spacing: AppSizes.space8,
                      children: <Widget>[
                        for (final SkillLevel skill in SkillLevels.all)
                          PlacementSkillRow(
                            key: ValueKey<SkillId>(skill.id),
                            skill: skill,
                            isAcquired: _isAcquired(skill),
                          ),
                      ],
                    ),
                  ),
                  _StartCard(outcome: outcome),
                ],
              ),
            ),
          ),
          DepthButton(
            label: context.l10n.placementSeePath,
            onPressed: onSeePath,
          ),
        ],
      ),
    );
  }
}

/// The unit the test recommends starting with, or the congratulation when
/// every skill is passed.
class _StartCard extends StatelessWidget {
  const _StartCard({required this.outcome});

  final PlacementOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? domainId = outcome.recommendedDomainId;
    final String? unitKey = outcome.recommendedUnitKey;
    if (domainId == null || unitKey == null) {
      return AppCard(
        child: Text(
          context.l10n.placementResultAllDone,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium,
        ),
      );
    }
    return AppCard(
      child: Column(
        spacing: AppSizes.space4,
        children: <Widget>[
          Text(
            context.l10n.placementResultStartLabel,
            style: textTheme.labelLarge?.copyWith(
              color: context.palette.mutedText,
            ),
          ),
          Text(
            context.l10n.unitName(domainId, unitKey),
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
