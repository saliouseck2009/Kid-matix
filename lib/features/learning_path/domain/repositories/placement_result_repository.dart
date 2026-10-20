import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';

/// The placement tests of each player, kept with their date.
abstract interface class PlacementResultRepository {
  /// Keeps [outcome] as the test [profileId] just finished, dated now.
  Future<DataState<void>> save({
    required String profileId,
    required PlacementOutcome outcome,
  });

  /// Returns every test of [profileId], the latest first.
  Future<DataState<List<PlacementResultEntity>>> getHistory({
    required String profileId,
  });

  /// Emits an event each time a result is kept.
  Stream<void> watchChanges();
}
