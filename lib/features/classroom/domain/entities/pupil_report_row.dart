import 'package:kid_matix/core/entities/domain_placement.dart';
import 'package:meta/meta.dart';

/// The words of the word check one pupil understood in one assessment.
typedef WordScore = ({int understood, int asked});

/// One pupil in a class report: their number in the class list, their
/// nickname in the named version only, and what changed between the two
/// assessments compared.
@immutable
final class PupilReportRow {
  /// Creates the row of the pupil numbered [number].
  PupilReportRow({
    required this.number,
    required Map<String, DomainPlacement> levelsFrom,
    required Map<String, DomainPlacement> levelsTo,
    required this.practiceTime,
    required this.sessionCount,
    required this.acquiredItemCount,
    this.nickname,
    this.wordsFrom,
    this.wordsTo,
  }) : levelsFrom = Map<String, DomainPlacement>.unmodifiable(levelsFrom),
       levelsTo = Map<String, DomainPlacement>.unmodifiable(levelsTo);

  /// Rank of the pupil in the class list, from 1: what the anonymous
  /// version shows instead of the nickname.
  final int number;

  /// Nickname, or `null` in the anonymous version.
  final String? nickname;

  /// Level in each domain at the first assessment, by domain id; a domain
  /// is missing when the pupil was not assessed.
  final Map<String, DomainPlacement> levelsFrom;

  /// Level in each domain at the second assessment.
  final Map<String, DomainPlacement> levelsTo;

  /// Words understood at the first assessment, or `null`.
  final WordScore? wordsFrom;

  /// Words understood at the second assessment, or `null`.
  final WordScore? wordsTo;

  /// Time played between the two assessments.
  final Duration practiceTime;

  /// Sessions played between the two assessments.
  final int sessionCount;

  /// Facts and words acquired between the two assessments (right the
  /// last three times at the second, not at the first).
  final int acquiredItemCount;

  @override
  String toString() => 'PupilReportRow($number)';
}
