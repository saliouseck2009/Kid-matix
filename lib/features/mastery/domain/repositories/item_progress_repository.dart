import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';

/// Progress of the items of each player.
abstract interface class ItemProgressRepository {
  /// Returns the progress of the items of [domainId] that [profileId] has
  /// already been asked.
  Future<DataState<List<ItemProgressEntity>>> getProgress({
    required String profileId,
    required String domainId,
  });

  /// Returns the progress of [itemKey], never presented when it has no row.
  Future<DataState<ItemProgressEntity>> getItemProgress({
    required String profileId,
    required String domainId,
    required String itemKey,
  });

  /// Creates or replaces the row of [progress].
  Future<DataState<void>> saveProgress({required ItemProgressEntity progress});

  /// Emits an event each time a progress may have changed.
  Stream<void> watchChanges();
}
