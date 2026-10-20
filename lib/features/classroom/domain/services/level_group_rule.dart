import 'package:kid_matix/core/entities/placement_level.dart';
import 'package:kid_matix/features/classroom/domain/entities/level_group.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_progress.dart';

/// Proposes level groups in one domain from the placement test (F27)
/// and the mastery shown in the class results.
///
/// A pupil's score is the larger of two shares: the part of the path
/// their last placement found acquired, and the part of the items the
/// class has worked on in the domain that they acquired (right the last
/// three times). The groups split the scores in thirds. They are only a
/// proposal for the teacher.
abstract final class LevelGroupRule {
  /// Score from which a pupil is « en route ».
  static const double onTheWayFrom = 1 / 3;

  /// Score from which a pupil is « à l'aise ».
  static const double confidentFrom = 2 / 3;

  /// The groups of [pupils], in the order of [LevelGroupKind]; empty
  /// groups are left out. [classItemKeys] are the items of the domain
  /// the class answered; [placements] the last placement of each pupil
  /// in the domain, by pupil identifier.
  static List<LevelGroup> group({
    required List<PupilProgress> pupils,
    required Set<String> classItemKeys,
    Map<String, PlacementLevel> placements = const <String, PlacementLevel>{},
  }) {
    final Map<LevelGroupKind, List<PupilProgress>> groups =
        <LevelGroupKind, List<PupilProgress>>{};
    for (final PupilProgress progress in pupils) {
      final LevelGroupKind kind = kindOf(
        progress: progress,
        classItemKeys: classItemKeys,
        placement: placements[progress.pupil.id],
      );
      groups.putIfAbsent(kind, () => <PupilProgress>[]).add(progress);
    }
    return <LevelGroup>[
      for (final LevelGroupKind kind in LevelGroupKind.values)
        if (groups[kind] case final List<PupilProgress> members)
          LevelGroup(
            kind: kind,
            pupils: members.map((PupilProgress p) => p.pupil).toList(),
          ),
    ];
  }

  /// The group of one pupil.
  static LevelGroupKind kindOf({
    required PupilProgress progress,
    required Set<String> classItemKeys,
    PlacementLevel? placement,
  }) {
    final bool hasAnswers = progress.answeredItemKeys.any(
      classItemKeys.contains,
    );
    if (placement == null && !hasAnswers) return LevelGroupKind.notYet;
    final double mastery = classItemKeys.isEmpty
        ? 0
        : progress.acquiredItemKeys.intersection(classItemKeys).length /
              classItemKeys.length;
    final double score = placement != null && placement.share > mastery
        ? placement.share
        : mastery;
    if (score >= confidentFrom) return LevelGroupKind.confident;
    if (score >= onTheWayFrom) return LevelGroupKind.onTheWay;
    return LevelGroupKind.firstSteps;
  }
}
