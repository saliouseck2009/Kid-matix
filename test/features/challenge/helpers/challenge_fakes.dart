import 'dart:async';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/open_units_service.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/domain/repositories/record_repository.dart';

/// [OpenUnitsService] that returns fixed units, or fails without any.
final class FixedOpenUnits implements OpenUnitsService {
  /// Creates the service returning [unitKeys]; `null` fails.
  const FixedOpenUnits([this.unitKeys = const <String>['mul:1']]);

  /// Units returned, or `null` to fail.
  final List<String>? unitKeys;

  @override
  Future<DataState<List<String>>> readOpenUnitKeys({
    required String profileId,
  }) async {
    final List<String>? keys = unitKeys;
    if (keys == null) {
      return const DataFailed<List<String>>(CacheException(message: 'down'));
    }
    return DataSuccess<List<String>>(keys);
  }
}

/// [RecordRepository] kept in memory.
final class InMemoryRecordRepository implements RecordRepository {
  /// Creates the repository holding [records].
  InMemoryRecordRepository([
    List<RecordEntity> records = const <RecordEntity>[],
  ]) : records = List<RecordEntity>.of(records);

  /// Stored records, of any player.
  final List<RecordEntity> records;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Tells the watchers that [records] changed.
  void notifyChanged() => _changes.add(null);

  @override
  Future<DataState<List<RecordEntity>>> getRecords({
    required String profileId,
  }) async {
    return DataSuccess<List<RecordEntity>>(List<RecordEntity>.of(records));
  }

  @override
  Future<DataState<RecordEntity?>> getRecordOfSession({
    required String sessionId,
  }) async {
    return DataSuccess<RecordEntity?>(
      records
          .where((RecordEntity record) => record.sessionId == sessionId)
          .firstOrNull,
    );
  }

  @override
  Stream<void> watchChanges() => _changes.stream;
}
