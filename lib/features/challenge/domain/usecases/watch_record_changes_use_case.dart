import 'package:kid_matix/features/challenge/domain/repositories/record_repository.dart';

/// Emits an event each time a record may have changed.
class WatchRecordChangesUseCase {
  /// Creates the use case.
  const WatchRecordChangesUseCase({required this._repository});

  final RecordRepository _repository;

  /// Returns the stream of changes.
  Stream<void> call() => _repository.watchChanges();
}
