import 'package:meta/meta.dart';

/// A badge a player has unlocked.
@immutable
final class BadgeUnlockEntity {
  /// Creates the unlock.
  const BadgeUnlockEntity({
    required this.badgeKey,
    required this.unlockedAt,
    this.sessionId,
  });

  /// Key of the badge, see `BadgeKey`.
  final String badgeKey;

  /// When it was unlocked.
  final DateTime unlockedAt;

  /// Quiz that unlocked it, or `null`.
  final String? sessionId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BadgeUnlockEntity &&
            other.badgeKey == badgeKey &&
            other.unlockedAt == unlockedAt &&
            other.sessionId == sessionId;
  }

  @override
  int get hashCode => Object.hash(badgeKey, unlockedAt, sessionId);
}
