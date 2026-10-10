import 'dart:async';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/core/services/reward_service.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_record.dart';
import 'package:kid_matix/features/mascot/domain/repositories/mascot_repository.dart';

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

/// [RewardService] answering the [level] and [badges] the test sets.
final class FixedRewardService implements RewardService {
  /// Creates the service.
  FixedRewardService({this.level = 1, this.badges = const <String>{}});

  /// Level returned.
  int level;

  /// Badges returned.
  Set<String> badges;

  /// Failure of every call, or `null`.
  AppException? failure;

  @override
  Future<DataState<int>> readLevel({required String profileId}) async {
    final AppException? error = failure;
    return error == null ? DataSuccess<int>(level) : DataFailed<int>(error);
  }

  @override
  Future<DataState<Set<String>>> readBadgeKeys({
    required String profileId,
  }) async => DataSuccess<Set<String>>(badges);

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

/// [CrownService] answering the [crowns] the test sets.
final class FixedCrownService implements CrownService {
  /// Creates the service.
  FixedCrownService({this.crowns = 0});

  /// Crowns returned.
  int crowns;

  @override
  Future<DataState<int>> readCrownCount({required String profileId}) async =>
      DataSuccess<int>(crowns);

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}
