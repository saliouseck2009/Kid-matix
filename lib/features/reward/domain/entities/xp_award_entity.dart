import 'package:meta/meta.dart';

/// XP a player earned outside a quiz, such as in a duel.
@immutable
final class XpAwardEntity {
  /// Creates the award.
  const XpAwardEntity({
    required this.id,
    required this.profileId,
    required this.sourceKey,
    required this.xp,
    required this.earnedAt,
  });

  /// Unique identifier, a UUID created on the device.
  final String id;

  /// Player who earned the XP.
  final String profileId;

  /// Game that earned them, such as `duel`.
  final String sourceKey;

  /// XP earned.
  final int xp;

  /// When they were earned.
  final DateTime earnedAt;

  /// Returns a copy with the given fields replaced.
  XpAwardEntity copyWith({
    String? id,
    String? profileId,
    String? sourceKey,
    int? xp,
    DateTime? earnedAt,
  }) {
    return XpAwardEntity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      sourceKey: sourceKey ?? this.sourceKey,
      xp: xp ?? this.xp,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is XpAwardEntity &&
            other.id == id &&
            other.profileId == profileId &&
            other.sourceKey == sourceKey &&
            other.xp == xp &&
            other.earnedAt == earnedAt;
  }

  @override
  int get hashCode => Object.hash(id, profileId, sourceKey, xp, earnedAt);
}
