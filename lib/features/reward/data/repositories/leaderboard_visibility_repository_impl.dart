import 'dart:async';
import 'dart:developer';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/reward/data/datasources/leaderboard_visibility_local_data_source.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_visibility_repository.dart';

/// [LeaderboardVisibilityRepository] over the device preferences; tells
/// its watchers each time the setting changes.
final class LeaderboardVisibilityRepositoryImpl
    implements LeaderboardVisibilityRepository {
  /// Creates the repository over [local].
  LeaderboardVisibilityRepositoryImpl({required this._local});

  /// Value before the player ever changes the setting.
  static const bool isShownByDefault = true;

  static const String _logName = 'leaderboard';

  final LeaderboardVisibilityLocalDataSource _local;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  @override
  Future<DataState<bool>> isShown() {
    return _guard(
      () async => await _local.readShown() ?? isShownByDefault,
      failure: 'Leaderboard setting not read',
    );
  }

  @override
  Future<DataState<void>> setShown({required bool isShown}) async {
    final DataState<void> saved = await _guard(
      () => _local.writeShown(isShown: isShown),
      failure: 'Leaderboard setting not saved',
    );
    if (saved is DataSuccess<void>) _changes.add(isShown);
    return saved;
  }

  @override
  Stream<bool> watchShown() => _changes.stream;

  Future<DataState<T>> _guard<T>(
    Future<T> Function() action, {
    required String failure,
  }) async {
    try {
      return DataSuccess<T>(await action());
    } on Object catch (error, stackTrace) {
      // The preferences plugin throws platform errors of no common type.
      log(failure, name: _logName, error: error, stackTrace: stackTrace);
      return DataFailed<T>(CacheException(message: error.toString()));
    }
  }
}
