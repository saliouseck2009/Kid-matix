import 'dart:async';
import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_local_data_source.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_tables.dart';
import 'package:kid_matix/features/reward/data/models/badge_unlock_local_model.dart';
import 'package:kid_matix/features/reward/data/models/session_reward_local_model.dart';
import 'package:kid_matix/features/reward/data/models/streak_local_model.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [RewardRepository] over the local database.
final class RewardRepositoryImpl implements RewardRepository {
  /// Creates the repository.
  const RewardRepositoryImpl({
    required this._rewards,
    required this._changeBus,
  });

  static const String _logName = 'reward';

  final RewardLocalDataSource _rewards;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<StreakEntity>> getStreak({required String profileId}) {
    return _read(() async {
      final StreakLocalModel? row = await _rewards.getStreak(
        await _rewards.database,
        profileId: profileId,
      );
      return row?.toEntity() ?? const StreakEntity.empty();
    });
  }

  @override
  Future<DataState<List<BadgeUnlockEntity>>> getBadges({
    required String profileId,
  }) {
    return _read(() async {
      final List<BadgeUnlockLocalModel> rows = await _rewards.getBadges(
        await _rewards.database,
        profileId: profileId,
      );
      return rows.map((BadgeUnlockLocalModel row) => row.toEntity()).toList();
    });
  }

  @override
  Future<DataState<int>> getXpEarned({
    required String profileId,
    DateTime? from,
    DateTime? to,
  }) {
    return _read(
      () async => _rewards.getXpEarned(
        await _rewards.database,
        profileId: profileId,
        from: from?.millisecondsSinceEpoch,
        to: to?.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<DataState<SessionXp?>> getSessionXp({required String sessionId}) {
    return _read(() async {
      final SessionRewardLocalModel? row = await _rewards.getSessionReward(
        await _rewards.database,
        sessionId: sessionId,
      );
      if (row == null) return null;
      return (
        profileId: row.profileId,
        xp: row.xpEarned,
        earnedAt: DateTime.fromMillisecondsSinceEpoch(row.earnedAt),
      );
    });
  }

  @override
  Stream<void> watchChanges() {
    final List<StreamSubscription<String>> subscriptions =
        <StreamSubscription<String>>[];
    late final StreamController<void> controller;
    controller = StreamController<void>(
      onListen: () {
        for (final String table in <String>[
          RewardTables.sessionReward,
          RewardTables.profile,
        ]) {
          subscriptions.add(
            _changeBus.watchTable(table: table).listen((_) {
              controller.add(null);
            }),
          );
        }
      },
      onCancel: () async {
        for (final StreamSubscription<String> subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }

  Future<DataState<T>> _read<T>(Future<T> Function() read) async {
    try {
      return DataSuccess<T>(await read());
    } on DatabaseException catch (error, stackTrace) {
      log(
        'Rewards not read',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<T>(CacheException(message: error.toString()));
    }
  }
}
