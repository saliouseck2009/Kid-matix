import 'dart:async';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_record.dart';
import 'package:kid_matix/features/mascot/domain/repositories/mascot_repository.dart';

export '../../../helpers/fixed_progress_services.dart';

/// [MascotRepository] in memory.
final class InMemoryMascotRepository implements MascotRepository {
  /// Records per player.
  final Map<String, MascotRecord> records = <String, MascotRecord>{};

  /// Failure of every call, or `null`.
  AppException? failure;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<DataState<MascotRecord>> getMascot({required String profileId}) async {
    final AppException? error = failure;
    if (error != null) return DataFailed<MascotRecord>(error);
    return DataSuccess<MascotRecord>(
      records[profileId] ?? const MascotRecord.initial(),
    );
  }

  @override
  Future<DataState<void>> saveMascot({
    required String profileId,
    required MascotRecord mascot,
  }) async {
    records[profileId] = mascot;
    _changes.add(null);
    return const DataSuccess<void>(null);
  }

  @override
  Stream<void> watchChanges() => _changes.stream;
}
