import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';
import 'package:kid_matix/features/mastery/domain/services/monster_rule.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Texts of the « Mes monstres » screen.
final class MonsterLabels {
  /// Creates the labels of the monsters of [domain].
  const MonsterLabels({required this.domain, required this.l10n});

  /// Learning domain of the facts.
  final LearningDomain domain;

  /// Localized strings.
  final AppLocalizations l10n;

  /// The fact of [itemKey] as shown, such as "7 × 8".
  String factOf(String itemKey) => _promptOf(itemKey).toDisplayText();

  /// The fact of [itemKey] as a screen reader says it, such as "7 fois 8".
  String spokenFactOf(String itemKey) {
    return _promptOf(itemKey).toSpokenText(l10n);
  }

  /// How tough a monster of [box] still is, such as "Très coriace".
  String toughnessOf(int box) {
    return switch (box) {
      <= MasteryPolicy.firstBox => l10n.monsterToughnessVeryTough,
      < MonsterRule.tamedBox - 1 => l10n.monsterToughnessTough,
      _ => l10n.monsterToughnessAlmostTamed,
    };
  }

  /// Share of the way a monster of [box] has gone toward being tamed.
  static double progressOf(int box) {
    return (box / MonsterRule.tamedBox).clamp(0, 1).toDouble();
  }

  /// Message of a failure to read the monsters.
  String errorOf(AppErrorCode code) {
    return code == AppErrorCode.cache ? l10n.errorStorage : l10n.errorUnknown;
  }

  /// The fact without its answer: the tokens before the equals sign.
  List<PromptToken> _promptOf(String itemKey) {
    final LearningItem? item = domain.findItem(itemKey);
    if (item == null) return const <PromptToken>[];
    return domain
        .describeItem(item)
        .takeWhile((PromptToken token) => token is! EqualsToken)
        .toList();
  }
}
