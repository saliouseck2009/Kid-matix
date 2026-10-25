import 'package:json_annotation/json_annotation.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';

part 'class_pupil_file_model.g.dart';

/// A pupil in a class file: identifier, nickname and avatar, nothing of
/// their settings.
@JsonSerializable()
final class ClassPupilFileModel {
  /// Creates the entry with every field given.
  const ClassPupilFileModel({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.color,
  });

  /// Builds the entry of [pupil].
  factory ClassPupilFileModel.fromEntity(PupilEntity pupil) {
    return ClassPupilFileModel(
      id: pupil.id,
      nickname: pupil.nickname,
      avatar: pupil.player.avatarKey,
      color: pupil.player.colorKey,
    );
  }

  /// Reads an entry of a class file.
  factory ClassPupilFileModel.fromJson(Map<String, Object?> json) =>
      _$ClassPupilFileModelFromJson(json);

  /// Identifier of the profile, the same on every tablet.
  final String id;

  /// Nickname.
  final String nickname;

  /// Stable name of the avatar.
  final String avatar;

  /// Stable name of the avatar color.
  final String color;

  /// Returns the content written in the file.
  Map<String, Object?> toJson() => _$ClassPupilFileModelToJson(this);

  /// Returns the pupil of this entry, in [classroomId].
  PupilEntity toEntity(String classroomId) {
    return PupilEntity(
      classroomId: classroomId,
      player: PlayerIdentity(
        id: id,
        nickname: nickname,
        avatarKey: avatar,
        colorKey: color,
      ),
    );
  }
}
