import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Texts of the learning path, some of them depending on the domain: the
/// multiplication speaks of tables, the domains after it of lessons.
final class PathLabels {
  /// Creates the labels.
  const PathLabels({required this.domainId, required this.l10n});

  /// Learning domain of the path.
  final String domainId;

  /// Localized strings.
  final AppLocalizations l10n;

  bool get _isMultiplication => domainId == LearningDomainIds.multiplication;

  /// Name of the unit [unitKey], such as "Table de 5" or "Comparer".
  String unitName(String unitKey) => l10n.unitName(domainId, unitKey);

  /// Short mark of the unit [unitKey] on its badge, such as "×5".
  String unitMark(String unitKey) => l10n.unitMark(domainId, unitKey);

  /// Tip of the unit [unitKey], shown at its Discovery stage.
  String unitTip(String unitKey) => l10n.unitTip(domainId, unitKey);

  /// Title of the Discovery page of [unit], such as "Voici la table de 5"
  /// or the name of a lesson.
  String discoveryTitle(LearningUnit unit) {
    return _isMultiplication
        ? l10n.pathDiscoveryTitle(unit.number)
        : unitName(unit.key);
  }

  /// Button of a unit's detail that shows its Discovery page again.
  String get showUnit =>
      _isMultiplication ? l10n.pathShowTable : l10n.pathShowUnit;

  /// Name of [stage], such as "Entraînement".
  String stageName(StageKind stage) {
    return switch (stage) {
      StageKind.discovery => l10n.pathStageDiscovery,
      StageKind.training => l10n.pathStageTraining,
      StageKind.writing => l10n.pathStageWriting,
      StageKind.speed => l10n.pathStageSpeed,
      StageKind.boss => l10n.pathStageBoss,
      StageKind.review => l10n.pathStageReview,
    };
  }

  /// One-line description of [stage].
  String stageHint(StageKind stage) {
    return switch (stage) {
      StageKind.discovery when !_isMultiplication =>
        l10n.pathUnitStageDiscoveryHint,
      StageKind.boss when !_isMultiplication => l10n.pathUnitStageBossHint,
      StageKind.review when !_isMultiplication => l10n.pathUnitStageReviewHint,
      StageKind.discovery => l10n.pathStageDiscoveryHint,
      StageKind.training => l10n.pathStageTrainingHint,
      StageKind.writing => l10n.pathStageWritingHint,
      StageKind.speed => l10n.pathStageSpeedHint,
      StageKind.boss => l10n.pathStageBossHint,
      StageKind.review => l10n.pathStageReviewHint,
    };
  }

  /// What a screen reader says of [table] on the map.
  String describeTable(TablePathNode table) {
    final String name = unitName(table.unitKey);
    final String label = switch (table.status) {
      TableStatus.done => l10n.pathTableNodeDone(name, table.averageStars),
      TableStatus.current => l10n.pathTableNodeCurrent(name),
      TableStatus.open => l10n.pathTableNodeOpen(name),
      TableStatus.locked => l10n.pathTableNodeLocked(name),
    };
    return switch (table.crown) {
      TableCrown.none => label,
      TableCrown.crown || TableCrown.golden => l10n.pathTableNodeCrowned(
        label,
        table.crown.name,
      ),
    };
  }

  /// What a screen reader says of the monster of [table] in « Mes
  /// monstres », defeated once the table is crowned.
  String describeMonster(TablePathNode table) {
    final bool isDefeated = table.crown != TableCrown.none;
    if (_isMultiplication) {
      return isDefeated
          ? l10n.pathMonsterDefeatedSpoken(table.number)
          : l10n.pathMonsterHiddenSpoken(table.number);
    }
    final String name = unitName(table.unitKey);
    return isDefeated
        ? l10n.pathUnitMonsterDefeatedSpoken(name)
        : l10n.pathUnitMonsterHiddenSpoken(name);
  }

  /// Message of a path that cannot be read.
  String describeError(AppErrorCode code) {
    return switch (code) {
      AppErrorCode.cache => l10n.errorStorage,
      _ => l10n.errorUnknown,
    };
  }
}
