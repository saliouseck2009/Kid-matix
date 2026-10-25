import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_level_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_result_local_model.dart';
import 'package:kid_matix/features/classroom/data/models/assessment_word_local_model.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_word.dart';

/// The rows of one assessment result: the result, its levels, its words.
typedef AssessmentResultRows = ({
  AssessmentResultLocalModel result,
  List<AssessmentLevelLocalModel> levels,
  List<AssessmentWordLocalModel> words,
});

/// Turns an [AssessmentResult] into its rows and back.
abstract final class AssessmentResultMapper {
  /// The rows of [result], written at [updatedAt].
  static AssessmentResultRows rowsOf(
    AssessmentResult result, {
    required DateTime updatedAt,
  }) {
    final int changedAt = updatedAt.millisecondsSinceEpoch;
    return (
      result: AssessmentResultLocalModel(
        assessmentId: result.assessmentId,
        profileId: result.pupilId,
        takenAt: result.takenAt.millisecondsSinceEpoch,
        wordCount: result.words.length,
        understoodWordCount: result.understoodWordCount,
        updatedAt: changedAt,
      ),
      levels: <AssessmentLevelLocalModel>[
        for (final DomainPlacement level in result.levels)
          AssessmentLevelLocalModel(
            assessmentId: result.assessmentId,
            profileId: result.pupilId,
            domainId: level.domainId,
            level: level.level,
            skillCount: level.skillCount,
            updatedAt: changedAt,
          ),
      ],
      words: <AssessmentWordLocalModel>[
        for (final AssessmentWord word in result.words)
          AssessmentWordLocalModel(
            assessmentId: result.assessmentId,
            profileId: result.pupilId,
            itemKey: word.itemKey,
            isUnderstood: word.isUnderstood,
            updatedAt: changedAt,
          ),
      ],
    );
  }

  /// The result of [rows].
  static AssessmentResult entityOf(AssessmentResultRows rows) {
    return AssessmentResult(
      assessmentId: rows.result.assessmentId,
      pupilId: rows.result.profileId,
      takenAt: DateTime.fromMillisecondsSinceEpoch(rows.result.takenAt),
      levels: rows.levels
          .map((AssessmentLevelLocalModel row) => row.toEntity())
          .toList(),
      words: rows.words
          .map((AssessmentWordLocalModel row) => row.toEntity())
          .toList(),
    );
  }
}
