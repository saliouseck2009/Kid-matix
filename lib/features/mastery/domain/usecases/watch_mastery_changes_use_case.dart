import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';

/// Emits an event each time the progress of an item may have changed.
class WatchMasteryChangesUseCase {
  /// Creates the use case.
  const WatchMasteryChangesUseCase({required this._repository});

  final ItemProgressRepository _repository;

  /// Returns the stream of changes.
  Stream<void> call() => _repository.watchChanges();
}
