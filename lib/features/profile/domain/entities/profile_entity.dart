import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:meta/meta.dart';

/// A player of the shared phone, identified by a unique nickname.
@immutable
final class ProfileEntity {
  /// Creates a profile with every field given.
  const ProfileEntity({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.color,
    required this.totalXp,
    required this.level,
    required this.createdAt,
    this.lastPlayedAt,
  });

  /// Creates the profile of a new player: no XP yet, first level.
  const ProfileEntity.newPlayer({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.color,
    required this.createdAt,
  }) : totalXp = initialTotalXp,
       level = initialLevel,
       lastPlayedAt = null;

  /// XP of a player who has not played yet.
  static const int initialTotalXp = 0;

  /// Level of a player who has not played yet.
  static const int initialLevel = 1;

  /// Unique identifier, a UUID created on the device.
  final String id;

  /// Nickname as the player typed it.
  final String nickname;

  /// Character shown for the player.
  final ProfileAvatar avatar;

  /// Color of the avatar.
  final ProfileColor color;

  /// XP earned since the profile was created.
  final int totalXp;

  /// Player level, derived from [totalXp].
  final int level;

  /// When the profile was created.
  final DateTime createdAt;

  /// End of the last finished session, or `null` before the first one.
  final DateTime? lastPlayedAt;

  /// Returns a copy with the given fields replaced.
  ProfileEntity copyWith({
    String? id,
    String? nickname,
    ProfileAvatar? avatar,
    ProfileColor? color,
    int? totalXp,
    int? level,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      color: color ?? this.color,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProfileEntity &&
            other.id == id &&
            other.nickname == nickname &&
            other.avatar == avatar &&
            other.color == color &&
            other.totalXp == totalXp &&
            other.level == level &&
            other.createdAt == createdAt &&
            other.lastPlayedAt == lastPlayedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    avatar,
    color,
    totalXp,
    level,
    createdAt,
    lastPlayedAt,
  );

  @override
  String toString() => 'ProfileEntity($id, level $level)';
}
