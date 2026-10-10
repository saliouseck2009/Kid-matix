import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Texts of the learning path, some of them depending on the domain.
final class PathLabels {
  /// Creates the labels.
  const PathLabels({required this.domainId, required this.l10n});

  /// Learning domain of the path.
  final String domainId;

  /// Localized strings.
  final AppLocalizations l10n;

  /// Name of the unit [number], such as "Table de 5".
  String unitName(int number) {
    return switch (domainId) {
      LearningDomainIds.multiplication => l10n.quizMultiplicationUnit(number),
      _ => '',
    };
  }

  /// Short mark of the unit [number] on its badge, such as "×5".
  String unitMark(int number) {
    return switch (domainId) {
      LearningDomainIds.multiplication => '×$number',
      _ => '$number',
    };
  }

  /// Tip of the unit [number], shown at its Discovery stage.
  String unitTip(int number) {
    return switch (domainId) {
      LearningDomainIds.multiplication => l10n.pathMultiplicationTip(
        '$number',
      ),
      _ => '',
    };
  }

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
    final String name = unitName(table.number);
    return switch (table.status) {
      TableStatus.done => l10n.pathTableNodeDone(name, table.averageStars),
      TableStatus.current => l10n.pathTableNodeCurrent(name),
      TableStatus.open => l10n.pathTableNodeOpen(name),
      TableStatus.locked => l10n.pathTableNodeLocked(name),
    };
  }

  /// Message of a path that cannot be read.
  String describeError(AppErrorCode code) {
    return switch (code) {
      AppErrorCode.cache => l10n.errorStorage,
      _ => l10n.errorUnknown,
    };
  }
}
