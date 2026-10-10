import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';

/// The records of the players.
abstract interface class RecordRepository {
  /// Returns the records of [profileId], one per mode played.
  Future<DataState<List<RecordEntity>>> getRecords({
    required String profileId,
  });

  /// Returns the record set by the session [sessionId], or `null` when it
  /// set none or a later session beat it.
  Future<DataState<RecordEntity?>> getRecordOfSession({
    required String sessionId,
  });

  /// Emits an event each time a record may have changed.
  Stream<void> watchChanges();
}
