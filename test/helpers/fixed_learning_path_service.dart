import 'package:kid_matix/core/services/learning_path_service.dart';

/// [LearningPathService] that gives [stars] to any quiz with a source key.
final class FixedLearningPathService implements LearningPathService {
  /// Creates the service.
  const FixedLearningPathService({this.stars = 3});

  /// Stars given.
  final int stars;

  @override
  int? starsFor({
    required String? sourceKey,
    required int correctCount,
    required int questionCount,
    bool isBossDefeated = false,
  }) => sourceKey == null ? null : stars;

  @override
  bool isStage(String? sourceKey) => sourceKey != null;

  @override
  String? crownedUnitOf({
    required String? sourceKey,
    required bool isBossDefeated,
  }) => null;
}
