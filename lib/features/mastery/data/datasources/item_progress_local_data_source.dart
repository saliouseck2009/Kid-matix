import 'package:kid_matix/features/mastery/data/models/item_progress_local_model.dart';

/// Item progress stored in the local SQLite database.
///
/// Methods throw the `sqflite` exceptions as they come; the repository turns
/// them into typed failures.
abstract interface class ItemProgressLocalDataSource {
  /// Returns the rows of [profileId] in [domainId].
  Future<List<ItemProgressLocalModel>> getProgress({
    required String profileId,
    required String domainId,
  });

  /// Returns the row of [itemKey], or `null` when there is none.
  Future<ItemProgressLocalModel?> getItemProgress({
    required String profileId,
    required String domainId,
    required String itemKey,
  });

  /// Inserts [progress], replacing the row of the same item.
  Future<void> upsertProgress({required ItemProgressLocalModel progress});
}
