import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_scope.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_use_case.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_state.dart';

/// Reads the weekly leaderboard of the phone for [profileId], and reads
/// it again each time [changes] emits, after XP are earned or a player
/// changes.
final class LeaderboardCubit extends Cubit<LeaderboardState> {
  /// Creates the Cubit.
  LeaderboardCubit({
    required this._profileId,
    required this._getLeaderboard,
    this._changes,
    this._scope = LeaderboardScope.phone,
  }) : super(const LeaderboardLoading());

  final String _profileId;
  final GetLeaderboardUseCase _getLeaderboard;
  final Stream<void>? _changes;
  final LeaderboardScope _scope;
  StreamSubscription<void>? _subscription;

  /// Reads the leaderboard and follows its changes.
  Future<void> load() async {
    _subscription ??= _changes?.listen((_) => unawaited(_read()));
    emit(const LeaderboardLoading());
    await _read();
  }

  Future<void> _read() async {
    final DataState<LeaderboardEntity> read = await _getLeaderboard(
      params: _scope,
    );
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<LeaderboardEntity>(:final data) => LeaderboardLoaded(
        leaderboard: data,
        activeProfileId: _profileId,
        chase: data.chaseOf(_profileId),
      ),
      DataFailed<LeaderboardEntity>(:final exception) => LeaderboardFailure(
        errorCode: exception.code,
      ),
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
