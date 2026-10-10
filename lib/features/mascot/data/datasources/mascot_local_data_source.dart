import 'package:kid_matix/features/mascot/data/models/mascot_local_model.dart';

/// Mascot rows stored in the local SQLite database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository turns
/// them into typed failures.
abstract interface class MascotLocalDataSource {
  /// Returns the row of [profileId], or `null`.
  Future<MascotLocalModel?> getMascot({required String profileId});

  /// Inserts [mascot], replacing the row of its player.
  Future<void> upsertMascot({required MascotLocalModel mascot});
}
