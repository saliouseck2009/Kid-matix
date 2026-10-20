import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:meta/meta.dart';

/// What the placement card of the Profile shows.
@immutable
sealed class PlacementHistoryState {
  const PlacementHistoryState();
}

/// The tests are being read.
final class PlacementHistoryLoading extends PlacementHistoryState {
  /// Creates the state.
  const PlacementHistoryLoading();
}

/// The tests of the player, the latest first; empty when none was taken.
final class PlacementHistoryLoaded extends PlacementHistoryState {
  /// Creates the state of [results].
  PlacementHistoryLoaded({required List<PlacementResultEntity> results})
    : results = List<PlacementResultEntity>.unmodifiable(results);

  /// Finished tests, latest first.
  final List<PlacementResultEntity> results;
}

/// The tests could not be read.
final class PlacementHistoryFailure extends PlacementHistoryState {
  /// Creates the state for [errorCode].
  const PlacementHistoryFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
