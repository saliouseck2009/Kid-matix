import 'package:meta/meta.dart';

/// The result of a player's last placement test in one domain: the
/// skills of the domain the test found acquired.
@immutable
final class PlacementLevel {
  /// Creates the level: [level] skills of [skillCount].
  const PlacementLevel({
    required this.level,
    required this.skillCount,
    required this.takenAt,
  });

  /// Skills of the domain the child had.
  final int level;

  /// Skills the test checked in the domain.
  final int skillCount;

  /// When the test was taken.
  final DateTime takenAt;

  /// Share of the skills acquired, from 0 to 1.
  double get share => skillCount == 0 ? 0 : level / skillCount;

  /// Returns a copy with the given fields replaced.
  PlacementLevel copyWith({int? level, int? skillCount, DateTime? takenAt}) {
    return PlacementLevel(
      level: level ?? this.level,
      skillCount: skillCount ?? this.skillCount,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlacementLevel &&
            other.level == level &&
            other.skillCount == skillCount &&
            other.takenAt == takenAt;
  }

  @override
  int get hashCode => Object.hash(level, skillCount, takenAt);
}
