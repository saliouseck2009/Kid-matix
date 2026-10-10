import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_definition.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';

/// The unlocking rules of the learning path.
///
/// A stage opens once the previous one has a star; the next table opens
/// once the writing stage (3) has one, so a child slow with the timer is
/// never stuck. A review follows every group of 3 tables and opens with
/// the last table of its group; it never locks anything. "Tout
/// débloquer" opens every table and stage.
final class LearningPathBuilder {
  /// Creates the builder.
  const LearningPathBuilder();

  /// Tables per group, each group followed by a review.
  static const int groupSize = 3;

  /// Stage that opens the next table.
  static const StageKind gateStage = StageKind.writing;

  /// Stages not delivered yet: the boss fight comes with lot F6.
  static const Set<StageKind> comingSoon = <StageKind>{StageKind.boss};

  /// Prefix of the review keys, `review:1` to `review:4`.
  static const String reviewKeyPrefix = 'review';

  /// Key of the [number]th review.
  static String reviewKeyOf(int number) => '$reviewKeyPrefix:$number';

  /// Builds the path of [units], in path order, from [progress].
  LearningPathEntity build({
    required String domainId,
    required List<LearningUnit> units,
    required List<StageProgressEntity> progress,
    required bool isEverythingUnlocked,
  }) {
    final Map<String, int> stars = <String, int>{
      for (final StageProgressEntity stage in progress)
        _key(stage.unitKey, stage.stage): stage.bestStars,
    };
    int starsOf(String unitKey, StageKind stage) =>
        stars[_key(unitKey, stage)] ?? 0;
    final List<PathNode> nodes = <PathNode>[];
    bool isCurrentFound = false;
    for (int index = 0; index < units.length; index++) {
      final LearningUnit unit = units[index];
      final bool isUnlocked =
          isEverythingUnlocked ||
          index == 0 ||
          starsOf(units[index - 1].key, gateStage) > 0;
      final bool isDone = isUnlocked && starsOf(unit.key, gateStage) > 0;
      final bool isLast = index == units.length - 1;
      final bool isCurrent =
          isUnlocked && !isCurrentFound && (!isDone || isLast);
      isCurrentFound = isCurrentFound || isCurrent;
      nodes.add(
        TablePathNode(
          unitKey: unit.key,
          number: unit.number,
          status: _statusOf(isUnlocked, isDone, isCurrent),
          stages: _stagesOf(
            unit.key,
            isUnlocked,
            isEverythingUnlocked,
            starsOf,
          ),
        ),
      );
      if ((index + 1) % groupSize == 0) {
        nodes.add(_reviewOf(units, index, isEverythingUnlocked, starsOf));
      }
    }
    return LearningPathEntity(domainId: domainId, nodes: nodes);
  }

  TableStatus _statusOf(bool isUnlocked, bool isDone, bool isCurrent) {
    if (isCurrent) return TableStatus.current;
    if (isDone) return TableStatus.done;
    if (isUnlocked) return TableStatus.open;
    return TableStatus.locked;
  }

  List<StageState> _stagesOf(
    String unitKey,
    bool isTableUnlocked,
    bool isEverythingUnlocked,
    int Function(String, StageKind) starsOf,
  ) {
    final List<StageState> stages = <StageState>[];
    for (final StageDefinition definition in StageDefinition.tableStages) {
      final bool isUnlocked =
          isTableUnlocked &&
          (stages.isEmpty || isEverythingUnlocked || stages.last.stars > 0);
      stages.add(
        StageState(
          definition: definition,
          stars: starsOf(unitKey, definition.kind),
          isUnlocked: isUnlocked,
          isComingSoon: comingSoon.contains(definition.kind),
        ),
      );
    }
    return stages;
  }

  ReviewPathNode _reviewOf(
    List<LearningUnit> units,
    int lastIndex,
    bool isEverythingUnlocked,
    int Function(String, StageKind) starsOf,
  ) {
    final int number = (lastIndex + 1) ~/ groupSize;
    final String key = reviewKeyOf(number);
    return ReviewPathNode(
      unitKey: key,
      number: number,
      tableKeys: <String>[
        for (int index = 0; index <= lastIndex; index++) units[index].key,
      ],
      stage: StageState(
        definition: StageDefinition.review,
        stars: starsOf(key, StageKind.review),
        isUnlocked:
            isEverythingUnlocked ||
            starsOf(units[lastIndex].key, gateStage) > 0,
      ),
    );
  }

  static String _key(String unitKey, StageKind stage) =>
      '$unitKey/${stage.name}';
}
