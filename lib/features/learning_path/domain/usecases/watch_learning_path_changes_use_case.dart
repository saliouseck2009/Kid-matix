import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';

/// Emits an event each time the learning path of a player may have
/// changed: new stars, or "Tout débloquer" turned on or off.
class WatchLearningPathChangesUseCase {
  /// Creates the use case over [repository].
  const WatchLearningPathChangesUseCase({required this._repository});

  final StageProgressRepository _repository;

  /// Returns the stream of changes.
  Stream<void> call() => _repository.watchChanges();
}
