import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_definition.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_builder.dart';

/// Turns a stage of the learning path into the quiz to play.
final class StageQuizSpecs {
  /// Creates the builder.
  const StageQuizSpecs();

  /// The quiz of [source] in [domain], or `null` when [domain] lacks its
  /// table or the stage is unknown.
  QuizSpec? specOf({
    required LearningDomain domain,
    required StageSource source,
  }) {
    final List<LearningUnit>? units = _unitsOf(domain, source);
    if (units == null || units.isEmpty) return null;
    final StageDefinition definition = source.stage == StageKind.review
        ? StageDefinition.review
        : StageDefinition.tableStages.firstWhere(
            (StageDefinition stage) => stage.kind == source.stage,
          );
    return QuizSpec(
      domainId: domain.id,
      mode: QuizMode.path,
      itemKeys: <String>[
        for (final LearningUnit unit in units)
          for (final LearningItem item in unit.items) item.key,
      ],
      questionTypeIds: definition.questionTypeIds,
      selection: definition.selection,
      questionCount: definition.questionCount,
      baseTimeLimit: definition.baseTimeLimit,
      sourceKey: source.toKey(),
    );
  }

  /// The tables of [source]: its own, or every table up to a review.
  List<LearningUnit>? _unitsOf(LearningDomain domain, StageSource source) {
    if (source.stage != StageKind.review) {
      final LearningUnit? unit = domain.findUnit(source.unitKey);
      return unit == null ? null : <LearningUnit>[unit];
    }
    final List<String> parts = source.unitKey.split(':');
    final int? number =
        parts.length == 2 && parts.first == LearningPathBuilder.reviewKeyPrefix
        ? int.tryParse(parts.last)
        : null;
    final int tableCount = (number ?? 0) * LearningPathBuilder.groupSize;
    if (tableCount <= 0 || tableCount > domain.path.length) return null;
    return domain.path.take(tableCount).toList();
  }

  /// Whether [source] can be played on [path] now.
  bool isPlayable({
    required LearningPathEntity path,
    required StageSource source,
  }) {
    if (source.stage == StageKind.review) {
      return path.findReview(source.unitKey)?.stage.isPlayable ?? false;
    }
    return path.findTable(source.unitKey)?.stageOf(source.stage).isPlayable ??
        false;
  }
}
