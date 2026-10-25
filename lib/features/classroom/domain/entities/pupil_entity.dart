import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:meta/meta.dart';

/// A pupil: an ordinary player of the device attached to a class, with
/// the same progress, XP and mascot as any player.
@immutable
final class PupilEntity {
  /// Creates the pupil [player] of [classroomId].
  const PupilEntity({required this.classroomId, required this.player});

  /// Class of the pupil.
  final String classroomId;

  /// Identifier, nickname and avatar of the player.
  final PlayerIdentity player;

  /// Identifier of the player's profile.
  String get id => player.id;

  /// Nickname, unique inside the class.
  String get nickname => player.nickname;

  /// Returns a copy with the given fields replaced.
  PupilEntity copyWith({String? classroomId, PlayerIdentity? player}) {
    return PupilEntity(
      classroomId: classroomId ?? this.classroomId,
      player: player ?? this.player,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PupilEntity &&
            other.classroomId == classroomId &&
            other.player == player;
  }

  @override
  int get hashCode => Object.hash(classroomId, player);

  @override
  String toString() => 'PupilEntity($id, $nickname)';
}
