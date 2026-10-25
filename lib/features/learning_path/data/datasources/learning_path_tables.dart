/// Names of the tables of the learning path.
abstract final class LearningPathTables {
  /// Best result per player, domain, unit and stage.
  static const String stageProgress = 'stage_progress';

  /// Dated results of the placement test, one row per test and domain.
  static const String placementResult = 'placement_result';

  /// Value of the `stage` column of a unit opened by the placement test.
  ///
  /// Such a row is no stage: it holds no star and the stage progress
  /// leaves it out.
  static const String placementStage = 'placement';

  /// Players, notified by the profile feature when a player or their
  /// settings change, such as "Tout débloquer".
  static const String profile = 'profile';
}
