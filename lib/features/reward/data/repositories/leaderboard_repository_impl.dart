import 'dart:developer';

import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_directory_service.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_local_data_source.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_scope.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [LeaderboardRepository] of the phone: the players of the device and
/// the XP stored locally. The online scopes need a remote source.
final class LeaderboardRepositoryImpl implements LeaderboardRepository {
  /// Creates the repository.
  const LeaderboardRepositoryImpl({
    required this._local,
    required this._players,
  });

  static const String _logName = 'leaderboard';

  final LeaderboardLocalDataSource _local;
  final PlayerDirectoryService _players;

  @override
  Future<DataState<List<LeaderboardEntry>>> getEntries({
    required LeaderboardScope scope,
    required DateTime from,
    required DateTime to,
  }) async {
    if (scope != LeaderboardScope.phone) {
      return DataFailed<List<LeaderboardEntry>>(
        UnknownException(message: 'Scope ${scope.name} needs online mode.'),
      );
    }
    final DataState<List<PlayerIdentity>> players = await _players
        .readPlayers();
    return switch (players) {
      DataSuccess<List<PlayerIdentity>>(:final data) => _withXp(
        data,
        from: from,
        to: to,
      ),
      DataFailed<List<PlayerIdentity>>(:final exception) =>
        DataFailed<List<LeaderboardEntry>>(exception),
    };
  }

  Future<DataState<List<LeaderboardEntry>>> _withXp(
    List<PlayerIdentity> players, {
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final Map<String, int> xp = await _local.getXpByProfile(
        from: from.millisecondsSinceEpoch,
        to: to.millisecondsSinceEpoch,
      );
      return DataSuccess<List<LeaderboardEntry>>(<LeaderboardEntry>[
        for (final PlayerIdentity player in players)
          LeaderboardEntry(player: player, weeklyXp: xp[player.id] ?? 0),
      ]);
    } on DatabaseException catch (error, stackTrace) {
      log(
        'Leaderboard not read',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      return DataFailed<List<LeaderboardEntry>>(
        CacheException(message: error.toString()),
      );
    }
  }
}
