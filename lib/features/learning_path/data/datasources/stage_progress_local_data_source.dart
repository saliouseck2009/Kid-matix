import 'package:kid_matix/features/learning_path/data/models/stage_progress_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// Stage progress stored in the local SQLite database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository turns
/// them into typed failures.
abstract interface class StageProgressLocalDataSource {
  /// Returns the rows of [profileId] in [domainId].
  Future<List<StageProgressLocalModel>> getProgress({
    required String profileId,
    required String domainId,
  });

  /// Returns the keys of the units of [domainId] that the placement test
  /// of [profileId] opened.
  Future<Set<String>> getPlacedUnitKeys({
    required String profileId,
    required String domainId,
  });

  /// Stores that the placement test of [profileId] opened [unitKey] of
  /// [domainId] at [placedAt], in milliseconds since epoch.
  Future<void> placeUnit({
    required String profileId,
    required String domainId,
    required String unitKey,
    required int placedAt,
  });

  /// Keeps the best of [result] and the stored row of its stage, with
  /// [executor], inside the transaction that saves the session.
  Future<void> keepBest({
    required DatabaseExecutor executor,
    required StageProgressLocalModel result,
  });
}
