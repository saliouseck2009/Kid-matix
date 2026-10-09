import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';

/// Emits an event each time a profile or the active player changes.
class WatchProfileChangesUseCase {
  /// Creates the use case over [repository].
  const WatchProfileChangesUseCase({required this._repository});

  final ProfileRepository _repository;

  /// Returns the stream of changes.
  Stream<void> call() => _repository.watchProfileChanges();
}
