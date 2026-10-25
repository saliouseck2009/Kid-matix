import 'package:meta/meta.dart';

/// A pupil to add to a class: an ordinary player attached to the class.
///
/// The class mode chooses the identifier, so that the same pupil keeps it
/// on every tablet of the class and their results merge. The avatar and
/// its color are the stable names of the profile feature; `null` lets it
/// pick one.
@immutable
final class PupilDraft {
  /// Creates the draft of the pupil [id].
  const PupilDraft({
    required this.id,
    required this.nickname,
    this.avatarKey,
    this.colorKey,
  });

  /// Identifier of the profile to create.
  final String id;

  /// Nickname, unique inside the class.
  final String nickname;

  /// Stable name of the avatar, or `null` to let the profile feature
  /// choose.
  final String? avatarKey;

  /// Stable name of the avatar color, or `null` to let the profile
  /// feature choose.
  final String? colorKey;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PupilDraft &&
            other.id == id &&
            other.nickname == nickname &&
            other.avatarKey == avatarKey &&
            other.colorKey == colorKey;
  }

  @override
  int get hashCode => Object.hash(id, nickname, avatarKey, colorKey);

  @override
  String toString() => 'PupilDraft($id, $nickname)';
}
