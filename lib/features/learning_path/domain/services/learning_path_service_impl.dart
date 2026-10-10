import 'package:kid_matix/core/services/learning_path_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/services/star_policy.dart';

/// [LearningPathService] over the stage rules.
final class LearningPathServiceImpl implements LearningPathService {
  /// Creates the service.
  const LearningPathServiceImpl({this._stars = const StarPolicy()});

  final StarPolicy _stars;

  @override
  int? starsFor({
    required String? sourceKey,
    required int correctCount,
    required int questionCount,
  }) {
    if (StageSource.tryParse(sourceKey) == null) return null;
    return _stars.starsFor(
      correctCount: correctCount,
      questionCount: questionCount,
    );
  }
}
