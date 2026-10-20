import 'package:kid_matix/features/learning_path/data/models/placement_result_local_model.dart';

/// Placement results stored in the local SQLite database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository turns
/// them into typed failures.
abstract interface class PlacementResultLocalDataSource {
  /// Stores the rows of one test in one transaction.
  Future<void> insertAll(List<PlacementResultLocalModel> rows);

  /// Returns the live rows of [profileId], the latest test first.
  Future<List<PlacementResultLocalModel>> getRows({required String profileId});
}
