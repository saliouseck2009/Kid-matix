import 'package:meta/meta.dart';

/// A period of assessment, such as « Début d'année »: every assessment of
/// a class whose label is the same, case and accents aside (one per
/// tablet when the teacher opened it on several).
@immutable
final class AssessmentPeriod {
  /// Creates the period [key].
  AssessmentPeriod({
    required this.key,
    required this.label,
    required this.startedAt,
    required List<String> assessmentIds,
  }) : assessmentIds = List<String>.unmodifiable(assessmentIds);

  /// Key shared by the labels of the period.
  final String key;

  /// Label of its first assessment.
  final String label;

  /// When its first assessment was opened.
  final DateTime startedAt;

  /// Its assessments, oldest first.
  final List<String> assessmentIds;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AssessmentPeriod &&
            other.key == key &&
            other.label == label &&
            other.startedAt == startedAt &&
            other.assessmentIds.join(',') == assessmentIds.join(',');
  }

  @override
  int get hashCode =>
      Object.hash(key, label, startedAt, Object.hashAll(assessmentIds));

  @override
  String toString() => 'AssessmentPeriod($key)';
}
