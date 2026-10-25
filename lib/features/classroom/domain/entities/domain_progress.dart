import 'package:meta/meta.dart';

/// How a group of pupils moved in one domain of the placement test
/// between two assessments: the average share of its skills they had at
/// each, and how many went up.
@immutable
final class DomainProgress {
  /// Creates the progress in [domainId].
  const DomainProgress({
    required this.domainId,
    required this.assessedFromCount,
    required this.assessedToCount,
    required this.progressedCount,
    this.averageFrom,
    this.averageTo,
  });

  /// Learning domain.
  final String domainId;

  /// Average share of the skills at the first assessment, from 0 to 1,
  /// or `null` when nobody was assessed in the domain.
  final double? averageFrom;

  /// Average share of the skills at the second assessment.
  final double? averageTo;

  /// Pupils with a level in the domain at the first assessment.
  final int assessedFromCount;

  /// Pupils with a level in the domain at the second assessment.
  final int assessedToCount;

  /// Pupils assessed at both whose level went up.
  final int progressedCount;

  /// Gain of the average share, or `null` without both averages.
  double? get gain {
    final double? start = averageFrom;
    final double? end = averageTo;
    return start == null || end == null ? null : end - start;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DomainProgress &&
            other.domainId == domainId &&
            other.averageFrom == averageFrom &&
            other.averageTo == averageTo &&
            other.assessedFromCount == assessedFromCount &&
            other.assessedToCount == assessedToCount &&
            other.progressedCount == progressedCount;
  }

  @override
  int get hashCode => Object.hash(
    domainId,
    averageFrom,
    averageTo,
    assessedFromCount,
    assessedToCount,
    progressedCount,
  );

  @override
  String toString() => 'DomainProgress($domainId, $averageFrom, $averageTo)';
}
