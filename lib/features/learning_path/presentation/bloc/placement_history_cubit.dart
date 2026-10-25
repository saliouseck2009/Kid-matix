import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_history_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_history_use_cases.dart';

/// The placement tests of a player for the Profile card; it follows a
/// test finished on the other screen.
final class PlacementHistoryCubit extends Cubit<PlacementHistoryState> {
  /// Creates the Cubit of the player [profileId].
  PlacementHistoryCubit({required this._profileId, required this._useCases})
    : super(const PlacementHistoryLoading());

  final String _profileId;
  final PlacementHistoryUseCases _useCases;
  StreamSubscription<void>? _changes;

  /// Reads the tests and follows the next ones.
  Future<void> load() async {
    _changes ??= _useCases.watchResults().listen((_) => unawaited(_read()));
    await _read();
  }

  Future<void> _read() async {
    final DataState<List<PlacementResultEntity>> read = await _useCases
        .getHistory(params: _profileId);
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<List<PlacementResultEntity>>(:final data) =>
        PlacementHistoryLoaded(results: data),
      DataFailed<List<PlacementResultEntity>>(:final exception) =>
        PlacementHistoryFailure(errorCode: exception.code),
    });
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
