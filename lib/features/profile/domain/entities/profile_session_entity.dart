import 'package:meta/meta.dart';

/// Snapshot of who is playing on the device.
@immutable
final class ProfileSessionEntity {
  /// Creates a snapshot.
  const ProfileSessionEntity({
    required this.profileCount,
    this.activeProfileId,
  });

  /// Number of profiles on the device.
  final int profileCount;

  /// Identifier of the active player, or `null` when nobody is playing.
  final String? activeProfileId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProfileSessionEntity &&
            other.profileCount == profileCount &&
            other.activeProfileId == activeProfileId;
  }

  @override
  int get hashCode => Object.hash(profileCount, activeProfileId);
}
