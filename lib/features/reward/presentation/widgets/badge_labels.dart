import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_key.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names and hints of the badges.
final class BadgeLabels {
  /// Creates the labels.
  const BadgeLabels({required this.domains, required this.l10n});

  /// Learning domains, to name the tamer badges.
  final DomainRegistry domains;

  /// Localized strings.
  final AppLocalizations l10n;

  /// Name of the badge [key], such as "Premier pas".
  String nameOf(String key) {
    return switch (key) {
      BadgeKey.firstStep => l10n.rewardBadgeFirstStep,
      BadgeKey.perfect => l10n.rewardBadgePerfect,
      BadgeKey.lightning => l10n.rewardBadgeLightning,
      BadgeKey.regular => l10n.rewardBadgeRegular,
      BadgeKey.allFacts => l10n.rewardBadgeAllFacts,
      _ => _tamerName(key),
    };
  }

  /// Line under the name of the badge [key] in its celebration.
  String hintOf(String key) {
    return switch (key) {
      BadgeKey.firstStep => l10n.rewardBadgeFirstStepHint,
      BadgeKey.perfect => l10n.rewardBadgePerfectHint,
      BadgeKey.lightning => l10n.rewardBadgeLightningHint,
      BadgeKey.regular => l10n.rewardBadgeRegularHint,
      BadgeKey.allFacts => l10n.rewardBadgeAllFactsHint,
      _ => l10n.rewardBadgeTamerHint,
    };
  }

  String _tamerName(String key) {
    final String? unitKey = BadgeKey.unitOfTamer(key);
    if (unitKey == null) return '';
    for (final LearningDomain domain in domains.domains) {
      final LearningUnit? unit = domain.findUnit(unitKey);
      if (unit == null) continue;
      return switch (domain.id) {
        LearningDomainIds.multiplication => l10n.rewardBadgeTamerMultiplication(
          unit.number,
        ),
        _ => '',
      };
    }
    return '';
  }
}
