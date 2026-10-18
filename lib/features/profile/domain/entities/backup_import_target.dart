import 'package:meta/meta.dart';

/// Where a backup file is written: the player it becomes on the phone.
@immutable
final class BackupImportTarget {
  /// Creates the target.
  const BackupImportTarget({
    required this.profileId,
    required this.nickname,
    required this.replacesProfile,
  });

  /// Identifier of the imported player.
  final String profileId;

  /// Nickname of the imported player.
  final String nickname;

  /// Whether [profileId] is an existing player, erased first.
  final bool replacesProfile;

  /// Returns a copy with the given fields replaced.
  BackupImportTarget copyWith({
    String? profileId,
    String? nickname,
    bool? replacesProfile,
  }) {
    return BackupImportTarget(
      profileId: profileId ?? this.profileId,
      nickname: nickname ?? this.nickname,
      replacesProfile: replacesProfile ?? this.replacesProfile,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BackupImportTarget &&
        other.profileId == profileId &&
        other.nickname == nickname &&
        other.replacesProfile == replacesProfile;
  }

  @override
  int get hashCode => Object.hash(profileId, nickname, replacesProfile);
}
