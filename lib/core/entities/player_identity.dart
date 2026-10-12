import 'package:meta/meta.dart';

/// Who a player of the shared phone is, as other features show them: a
/// nickname and an avatar drawn in a color.
///
/// The avatar and the color are the stable names the profile feature
/// stores; only that feature knows how to draw them.
@immutable
final class PlayerIdentity {
  /// Creates the identity of the player [id].
  const PlayerIdentity({
    required this.id,
    required this.nickname,
    required this.avatarKey,
    required this.colorKey,
  });

  /// Identifier of the profile.
  final String id;

  /// Nickname as the player typed it.
  final String nickname;

  /// Stable name of the avatar, such as `avatar3`.
  final String avatarKey;

  /// Stable name of the avatar color, such as `green`.
  final String colorKey;

  /// Returns a copy with the given fields replaced.
  PlayerIdentity copyWith({
    String? id,
    String? nickname,
    String? avatarKey,
    String? colorKey,
  }) {
    return PlayerIdentity(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarKey: avatarKey ?? this.avatarKey,
      colorKey: colorKey ?? this.colorKey,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlayerIdentity &&
            other.id == id &&
            other.nickname == nickname &&
            other.avatarKey == avatarKey &&
            other.colorKey == colorKey;
  }

  @override
  int get hashCode => Object.hash(id, nickname, avatarKey, colorKey);

  @override
  String toString() => 'PlayerIdentity($id, $nickname)';
}
