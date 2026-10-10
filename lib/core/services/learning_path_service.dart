/// The learning path, as the quiz results and the rewards see it.
///
/// Implemented by the learning path feature, which owns the stages and
/// their stars.
abstract interface class LearningPathService {
  /// Stars earned by a quiz played for [sourceKey] with [correctCount]
  /// right answers out of [questionCount]; [isBossDefeated] tells how a
  /// boss fight ended. `null` when [sourceKey] is not a stage of the path.
  int? starsFor({
    required String? sourceKey,
    required int correctCount,
    required int questionCount,
    bool isBossDefeated = false,
  });

  /// Whether [sourceKey] is a stage of the path.
  bool isStage(String? sourceKey);

  /// The unit a quiz played for [sourceKey] crowns: its table when it was
  /// a boss fight the player won; `null` otherwise.
  String? crownedUnitOf({
    required String? sourceKey,
    required bool isBossDefeated,
  });
}
