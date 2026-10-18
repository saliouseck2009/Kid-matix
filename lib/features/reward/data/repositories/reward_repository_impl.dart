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
import 'package:kid_matix/features/reward/data/models/xp_award_local_model.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/xp_award_entity.dart';
import 'package:kid_matix/features/reward/domain/repositories/reward_repository.dart';
import 'package:kid_matix/features/reward/domain/services/level_policy.dart';
import 'package:sqflite/sqflite.dart';

/// [RewardRepository] over the local database.
final class RewardRepositoryImpl implements RewardRepository {
  /// Creates the repository.
  const RewardRepositoryImpl({
    required this._rewards,
    required this._changeBus,
    this._levels = const LevelPolicy(),
  });

  static const String _logName = 'reward';

  final RewardLocalDataSource _rewards;
  final TableChangeBus _changeBus;
  final LevelPolicy _levels;

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
  Future<DataState<void>> saveXpAward({required XpAwardEntity award}) async {
    final DataState<void> saved = await _read(() async {
      final DatabaseExecutor database = await _rewards.database;
      final int totalXp =
          await _rewards.getXpEarned(database, profileId: award.profileId) +
          award.xp;
      await _rewards.writeXpAward(
        database,
        award: XpAwardLocalModel.fromEntity(award, updatedAt: award.earnedAt),
        totalXp: totalXp,
        level: _levels.levelOf(totalXp).level,
      );
    }, failure: 'XP award not saved');
    if (saved is DataSuccess<void>) {
      _changeBus
        ..notifyChanged(table: RewardTables.xpAward)
        ..notifyChanged(table: RewardTables.profile);
    }
    return saved;
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
          RewardTables.xpAward,
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

  Future<DataState<T>> _read<T>(
    Future<T> Function() read, {
    String failure = 'Rewards not read',
  }) async {
    try {
      return DataSuccess<T>(await read());
    } on DatabaseException catch (error, stackTrace) {
      log(
        failure,
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<T>(CacheException(message: error.toString()));
    }
  }
}
