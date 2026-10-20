import 'package:meta/meta.dart';

/// The result of a player's last placement test in one domain: how far
/// along its path the test placed them.
@immutable
final class PlacementLevel {
  /// Creates the level: [acquiredUnitCount] of [unitCount] units.
  const PlacementLevel({
    required this.acquiredUnitCount,
    required this.unitCount,
    required this.takenAt,
  });

  /// Units of the path the test found acquired.
  final int acquiredUnitCount;

  /// Units of the path of the domain.
  final int unitCount;

  /// When the test was taken.
  final DateTime takenAt;

  /// Share of the path acquired, from 0 to 1.
  double get share => unitCount == 0 ? 0 : acquiredUnitCount / unitCount;

  /// Returns a copy with the given fields replaced.
  PlacementLevel copyWith({
    int? acquiredUnitCount,
    int? unitCount,
    DateTime? takenAt,
  }) {
    return PlacementLevel(
      acquiredUnitCount: acquiredUnitCount ?? this.acquiredUnitCount,
      unitCount: unitCount ?? this.unitCount,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlacementLevel &&
            other.acquiredUnitCount == acquiredUnitCount &&
            other.unitCount == unitCount &&
            other.takenAt == takenAt;
  }

  @override
  int get hashCode => Object.hash(acquiredUnitCount, unitCount, takenAt);
}
