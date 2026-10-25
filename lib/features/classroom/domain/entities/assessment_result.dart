import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:kid_matix/features/classroom/domain/entities/assessment_word.dart';
import 'package:meta/meta.dart';

/// What one pupil showed in one assessment: the level the placement test
/// found in each domain and the words of the word check they understood.
///
/// It belongs to the class: the progress reset of the pupil keeps it.
@immutable
final class AssessmentResult {
  /// Creates the result of [pupilId] in [assessmentId].
  AssessmentResult({
    required this.assessmentId,
    required this.pupilId,
    required this.takenAt,
    required List<DomainPlacement> levels,
    required List<AssessmentWord> words,
  }) : levels = List<DomainPlacement>.unmodifiable(levels),
       words = List<AssessmentWord>.unmodifiable(words);

  /// Assessment taken.
  final String assessmentId;

  /// Pupil who took it.
  final String pupilId;

  /// When they finished it.
  final DateTime takenAt;

  /// The level in each domain of the placement test; empty when the
  /// pupil skipped the test.
  final List<DomainPlacement> levels;

  /// Each word of the word check.
  final List<AssessmentWord> words;

  /// Words of the word check the pupil understood.
  int get understoodWordCount =>
      words.where((AssessmentWord word) => word.isUnderstood).length;

  /// The level in [domainId], or `null` when the test did not give one.
  DomainPlacement? levelIn(String domainId) {
    for (final DomainPlacement level in levels) {
      if (level.domainId == domainId) return level;
    }
    return null;
  }

  /// Returns a copy with the given fields replaced.
  AssessmentResult copyWith({
    String? assessmentId,
    String? pupilId,
    DateTime? takenAt,
    List<DomainPlacement>? levels,
    List<AssessmentWord>? words,
  }) {
    return AssessmentResult(
      assessmentId: assessmentId ?? this.assessmentId,
      pupilId: pupilId ?? this.pupilId,
      takenAt: takenAt ?? this.takenAt,
      levels: levels ?? this.levels,
      words: words ?? this.words,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AssessmentResult &&
            other.assessmentId == assessmentId &&
            other.pupilId == pupilId &&
            other.takenAt == takenAt &&
            Object.hashAll(other.levels) == Object.hashAll(levels) &&
            Object.hashAll(other.words) == Object.hashAll(words);
  }

  @override
  int get hashCode => Object.hash(
    assessmentId,
    pupilId,
    takenAt,
    Object.hashAll(levels),
    Object.hashAll(words),
  );

  @override
  String toString() => 'AssessmentResult($assessmentId, $pupilId)';
}
