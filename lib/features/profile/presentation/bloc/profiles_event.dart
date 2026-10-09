/// Something the player did on the "Qui joue ?" screen.
sealed class ProfilesEvent {
  /// Creates an event.
  const ProfilesEvent();
}

/// The screen opened, or the player asked to try again.
final class ProfilesRequested extends ProfilesEvent {
  /// Creates the event.
  const ProfilesRequested();
}

/// The player tapped the card of [profileId].
final class ProfileSelected extends ProfilesEvent {
  /// Creates the event.
  const ProfileSelected({required this.profileId});

  /// Identifier of the chosen profile.
  final String profileId;
}
