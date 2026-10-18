import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/set_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_leaderboard_visibility_use_case.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';

/// Whether the leaderboard is shown on this phone: drives its entry on
/// the Profile tab and its switch in the settings.
final class LeaderboardVisibilityCubit extends Cubit<RewardValueState<bool>> {
  /// Creates the Cubit.
  LeaderboardVisibilityCubit({
    required this._get,
    required this._set,
    required this._watch,
  }) : super(const RewardValueLoading<bool>());

  final GetLeaderboardVisibilityUseCase _get;
  final SetLeaderboardVisibilityUseCase _set;
  final WatchLeaderboardVisibilityUseCase _watch;
  StreamSubscription<bool>? _subscription;

  /// Reads the setting and follows its changes.
  Future<void> load() async {
    _subscription ??= _watch().listen(_show);
    emit(const RewardValueLoading<bool>());
    final DataState<bool> read = await _get();
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<bool>(:final data) => RewardValueLoaded<bool>(value: data),
      DataFailed<bool>(:final exception) => RewardValueFailure<bool>(
        errorCode: exception.code,
      ),
    });
  }

  /// Shows the leaderboard when [isShown], hides it otherwise.
  Future<void> setShown({required bool isShown}) async {
    final RewardValueState<bool> previous = state;
    _show(isShown);
    final DataState<void> saved = await _set(params: isShown);
    if (isClosed || saved is DataSuccess<void>) return;
    emit(previous);
  }

  void _show(bool isShown) {
    if (isClosed) return;
    emit(RewardValueLoaded<bool>(value: isShown));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
