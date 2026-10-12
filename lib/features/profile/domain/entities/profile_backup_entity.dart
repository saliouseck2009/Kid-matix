import 'package:meta/meta.dart';

/// A backup file read and checked, waiting to be imported.
@immutable
final class ProfileBackupEntity {
  /// Creates the backup of the player [nickname].
  const ProfileBackupEntity({
    required this.nickname,
    required this.level,
    required this.exportedAt,
    required this.sections,
  });

  /// Nickname of the player in the file.
  final String nickname;

  /// Level of the player in the file.
  final int level;

  /// When the file was written.
  final DateTime exportedAt;

  /// Content of the file, one entry per section; only the data layer
  /// reads it.
  final Map<String, Object?> sections;

  /// Returns a copy with the given fields replaced.
  ProfileBackupEntity copyWith({
    String? nickname,
    int? level,
    DateTime? exportedAt,
    Map<String, Object?>? sections,
  }) {
    return ProfileBackupEntity(
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      exportedAt: exportedAt ?? this.exportedAt,
      sections: sections ?? this.sections,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileBackupEntity &&
        other.nickname == nickname &&
        other.level == level &&
        other.exportedAt == exportedAt &&
        identical(other.sections, sections);
  }

  @override
  int get hashCode =>
      Object.hash(nickname, level, exportedAt, identityHashCode(sections));
}
