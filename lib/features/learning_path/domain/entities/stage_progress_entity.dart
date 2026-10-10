import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:meta/meta.dart';

/// The best result of a player on one stage of the learning path.
@immutable
final class StageProgressEntity {
  /// Creates the progress.
  const StageProgressEntity({
    required this.profileId,
    required this.domainId,
    required this.unitKey,
    required this.stage,
    required this.bestStars,
    required this.bestScore,
    required this.completedAt,
  });

  /// Player.
  final String profileId;

  /// Learning domain.
  final String domainId;

  /// Key of the table, such as `mul:5`, or of the review, `review:2`.
  final String unitKey;

  /// Stage of the unit.
  final StageKind stage;

  /// Best stars earned, from 0 to 3.
  final int bestStars;

  /// Best number of right answers.
  final int bestScore;

  /// When the stage was first completed.
  final DateTime completedAt;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StageProgressEntity &&
            other.profileId == profileId &&
            other.domainId == domainId &&
            other.unitKey == unitKey &&
            other.stage == stage &&
            other.bestStars == bestStars &&
            other.bestScore == bestScore &&
            other.completedAt == completedAt;
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    domainId,
    unitKey,
    stage,
    bestStars,
    bestScore,
    completedAt,
  );
}
