import 'package:kid_matix/features/learning_path/domain/entities/stage_definition.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:meta/meta.dart';

/// The learning path of a player: the tables in path order, with a review
/// after every group of 3.
@immutable
final class LearningPathEntity {
  /// Creates the path.
  LearningPathEntity({required this.domainId, required List<PathNode> nodes})
    : nodes = List<PathNode>.unmodifiable(nodes);

  /// Learning domain of the path.
  final String domainId;

  /// Tables and reviews, in path order.
  final List<PathNode> nodes;

  /// The tables of the path, in order.
  List<TablePathNode> get tables => nodes.whereType<TablePathNode>().toList();

  /// The table the player is working on, or `null` when none is open.
  TablePathNode? get currentTable {
    for (final TablePathNode table in tables) {
      if (table.status == TableStatus.current) return table;
    }
    return null;
  }

  /// The table of [unitKey], or `null` when the path has none.
  TablePathNode? findTable(String unitKey) {
    for (final TablePathNode table in tables) {
      if (table.unitKey == unitKey) return table;
    }
    return null;
  }

  /// The review of [unitKey], such as `review:2`, or `null`.
  ReviewPathNode? findReview(String unitKey) {
    for (final ReviewPathNode review in nodes.whereType<ReviewPathNode>()) {
      if (review.unitKey == unitKey) return review;
    }
    return null;
  }
}

/// How a table shows on the map.
enum TableStatus {
  /// Its stage 3 is validated: the next table is open.
  done,

  /// The table to work on now.
  current,

  /// Open by "Tout débloquer", not started yet.
  open,

  /// Not reached yet.
  locked,
}

/// One node of the map.
@immutable
sealed class PathNode {
  const PathNode({required this.unitKey});

  /// Key of the table, such as `mul:5`, or of the review, `review:2`.
  final String unitKey;
}

/// A table and its five stages.
final class TablePathNode extends PathNode {
  /// Creates the node.
  TablePathNode({
    required super.unitKey,
    required this.number,
    required this.status,
    required List<StageState> stages,
  }) : stages = List<StageState>.unmodifiable(stages);

  /// Number of the table, such as 5.
  final int number;

  /// How the table shows on the map.
  final TableStatus status;

  /// Its five stages, in order.
  final List<StageState> stages;

  /// Stars of every stage added up.
  int get totalStars =>
      stages.fold(0, (int sum, StageState stage) => sum + stage.stars);

  /// The first open stage without a star, or `null` when every open stage
  /// has one.
  StageState? get nextStage {
    for (final StageState stage in stages) {
      if (stage.isPlayable && stage.stars == 0) return stage;
    }
    return null;
  }

  /// The state of [kind].
  StageState stageOf(StageKind kind) {
    return stages.firstWhere((StageState stage) => stage.kind == kind);
  }
}

/// The review of a group of 3 tables.
final class ReviewPathNode extends PathNode {
  /// Creates the node.
  ReviewPathNode({
    required super.unitKey,
    required this.number,
    required List<String> tableKeys,
    required this.stage,
  }) : tableKeys = List<String>.unmodifiable(tableKeys);

  /// Rank of the review, from 1.
  final int number;

  /// Every table seen up to this review.
  final List<String> tableKeys;

  /// Its single stage.
  final StageState stage;
}

/// A stage as the player sees it.
@immutable
final class StageState {
  /// Creates the state.
  const StageState({
    required this.definition,
    required this.stars,
    required this.isUnlocked,
    this.isComingSoon = false,
  });

  /// What the stage is made of.
  final StageDefinition definition;

  /// Best stars earned.
  final int stars;

  /// Whether the previous stage, or table, opens it.
  final bool isUnlocked;

  /// Whether the stage arrives with a later version of the app.
  final bool isComingSoon;

  /// Which stage it is.
  StageKind get kind => definition.kind;

  /// Whether the player can start it.
  bool get isPlayable => isUnlocked && !isComingSoon;
}
