import 'package:meta/meta.dart';

/// The progress figures of a player shown on the Profile tab.
@immutable
final class ProfileStatsEntity {
  /// Creates the figures.
  const ProfileStatsEntity({
    required this.streak,
    required this.crownCount,
    required this.badgeCount,
  });

  /// Days in a row the player has played, as shown today.
  final int streak;

  /// Tables crowned.
  final int crownCount;

  /// Badges unlocked.
  final int badgeCount;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProfileStatsEntity &&
            other.streak == streak &&
            other.crownCount == crownCount &&
            other.badgeCount == badgeCount;
  }

  @override
  int get hashCode => Object.hash(streak, crownCount, badgeCount);
}
