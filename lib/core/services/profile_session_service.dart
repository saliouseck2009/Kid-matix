import 'package:flutter/foundation.dart';

/// Who is playing: the active player of the shared phone.
///
/// The router listens to it (`refreshListenable`) and redirects to "Qui
/// joue ?" or to the profile creation while no player is active. Implemented
/// by the profile feature.
abstract interface class ProfileSessionService implements Listenable {
  /// Whether [restore] has completed at least once.
  bool get isRestored;

  /// Whether at least one profile exists on the device.
  bool get hasProfiles;

  /// Identifier of the active player, or `null` when nobody is playing.
  String? get activeProfileId;

  /// Reads the stored session; call once before the app starts.
  Future<void> restore();
}
