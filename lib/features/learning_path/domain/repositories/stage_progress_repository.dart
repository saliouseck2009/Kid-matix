import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';

/// The best results of each player on the stages of the learning path.
abstract interface class StageProgressRepository {
  /// Returns the stages of [domainId] that [profileId] has completed.
  Future<DataState<List<StageProgressEntity>>> getProgress({
    required String profileId,
    required String domainId,
  });

  /// Returns the keys of the units of [domainId] that the placement test
  /// of [profileId] opened.
  Future<DataState<Set<String>>> getPlacedUnitKeys({
    required String profileId,
    required String domainId,
  });

  /// Opens [unitKey] of [domainId] for [profileId] after a right answer
  /// to the placement test; its stages keep no star.
  Future<DataState<void>> openUnit({
    required String profileId,
    required String domainId,
    required String unitKey,
  });

  /// Emits an event each time the stars or the player's settings change.
  Stream<void> watchChanges();
}
