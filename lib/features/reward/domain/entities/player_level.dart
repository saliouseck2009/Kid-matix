import 'package:meta/meta.dart';

/// A player's level and the way to the next one.
@immutable
final class PlayerLevel {
  /// Creates the level.
  const PlayerLevel({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  /// Level, from 1.
  final int level;

  /// XP earned since the start of [level].
  final int xpIntoLevel;

  /// XP from the start of [level] to the next one.
  final int xpForNextLevel;

  /// XP still missing for the next level.
  int get xpToNextLevel => xpForNextLevel - xpIntoLevel;

  /// Share of the way to the next level, from 0 to 1.
  double get progress => xpIntoLevel / xpForNextLevel;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlayerLevel &&
            other.level == level &&
            other.xpIntoLevel == xpIntoLevel &&
            other.xpForNextLevel == xpForNextLevel;
  }

  @override
  int get hashCode => Object.hash(level, xpIntoLevel, xpForNextLevel);

  @override
  String toString() => 'level $level ($xpIntoLevel / $xpForNextLevel)';
}
