import 'package:kid_matix/features/learning_path/domain/repositories/placement_result_repository.dart';

/// Emits an event each time a placement result is kept.
class WatchPlacementResultsUseCase {
  /// Creates the use case over [repository].
  const WatchPlacementResultsUseCase({required this._repository});

  final PlacementResultRepository _repository;

  /// Returns the stream of changes.
  Stream<void> call() => _repository.watchChanges();
}
