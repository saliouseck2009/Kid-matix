import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_result.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_word.dart';

part 'assessment_result_file_model.g.dart';

/// The result of a pupil in an assessment, in a class file (version 2):
/// the assessment, the pupil, the date in milliseconds since epoch, the
/// levels as compact rows `[domainId, level or null, skillCount]` and the
/// words as `[itemKey, understood]` (1 or 0).
@JsonSerializable(fieldRename: FieldRename.snake)
final class AssessmentResultFileModel {
  /// Creates the entry.
  const AssessmentResultFileModel({
    required this.assessmentId,
    required this.profileId,
    required this.takenAt,
    required this.levels,
    required this.words,
  });

  /// Builds the entry of [result].
  factory AssessmentResultFileModel.fromEntity(AssessmentResult result) {
    return AssessmentResultFileModel(
      assessmentId: result.assessmentId,
      profileId: result.pupilId,
      takenAt: result.takenAt.millisecondsSinceEpoch,
      levels: <List<Object?>>[
        for (final DomainPlacement level in result.levels)
          <Object?>[level.domainId, level.level, level.skillCount],
      ],
      words: <List<Object>>[
        for (final AssessmentWord word in result.words)
          <Object>[word.itemKey, if (word.isUnderstood) 1 else 0],
      ],
    );
  }

  /// Reads an entry of a class file.
  factory AssessmentResultFileModel.fromJson(Map<String, Object?> json) =>
      _$AssessmentResultFileModelFromJson(json);

  /// Assessment taken.
  final String assessmentId;

  /// Pupil who took it.
  final String profileId;

  /// When it was finished, in milliseconds since epoch.
  final int takenAt;

  /// Levels, one compact row each.
  final List<List<Object?>> levels;

  /// Words, one compact row each.
  final List<List<Object>> words;

  /// Returns the content written in the file.
  Map<String, Object?> toJson() => _$AssessmentResultFileModelToJson(this);

  /// Returns the result; throws a [FormatException] on a malformed row.
  AssessmentResult toEntity() {
    return AssessmentResult(
      assessmentId: assessmentId,
      pupilId: profileId,
      takenAt: DateTime.fromMillisecondsSinceEpoch(takenAt),
      levels: levels.map(_levelOf).toList(),
      words: words.map(_wordOf).toList(),
    );
  }

  static DomainPlacement _levelOf(List<Object?> row) {
    if (row.length != 3) throw const FormatException('Malformed level row.');
    final (Object? domainId, Object? level, Object? skillCount) = (
      row[0],
      row[1],
      row[2],
    );
    if (domainId is! String || level is! int? || skillCount is! int) {
      throw const FormatException('Malformed level row.');
    }
    return DomainPlacement(
      domainId: domainId,
      level: level,
      skillCount: skillCount,
    );
  }

  static AssessmentWord _wordOf(List<Object> row) {
    if (row.length != 2) throw const FormatException('Malformed word row.');
    final (Object itemKey, Object isUnderstood) = (row[0], row[1]);
    if (itemKey is! String || isUnderstood is! int) {
      throw const FormatException('Malformed word row.');
    }
    return AssessmentWord(itemKey: itemKey, isUnderstood: isUnderstood != 0);
  }
}
