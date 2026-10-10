import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';

/// Loads the learning path of a player and reloads it after each session
/// or settings change, told by the table change signal.
final class LearningPathBloc
    extends Bloc<LearningPathEvent, LearningPathState> {
  /// Creates the Bloc of the path of [params].
  LearningPathBloc({required this._params, required this._useCases})
    : super(const LearningPathLoading()) {
    on<LearningPathStarted>(_onStarted);
    on<LearningPathChanged>(
      (_, Emitter<LearningPathState> emit) => _load(emit),
    );
  }

  final LearningPathParams _params;
  final LearningPathUseCases _useCases;
  StreamSubscription<void>? _changes;

  Future<void> _onStarted(
    LearningPathStarted event,
    Emitter<LearningPathState> emit,
  ) async {
    _changes ??= _useCases.watchChanges().listen(
      (_) => add(const LearningPathChanged()),
    );
    emit(const LearningPathLoading());
    await _load(emit);
  }

  Future<void> _load(Emitter<LearningPathState> emit) async {
    final DataState<LearningPathEntity> loaded = await _useCases
        .getLearningPath(params: _params);
    emit(switch (loaded) {
      DataSuccess<LearningPathEntity>(:final data) => LearningPathLoaded(
        path: data,
      ),
      DataFailed<LearningPathEntity>(:final exception) => LearningPathFailure(
        errorCode: exception.code,
      ),
    });
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
