import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_grid_entity.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_mastery_grid_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';
import 'package:kid_matix/features/mastery/domain/usecases/watch_mastery_changes_use_case.dart';

/// Reads the mastery grid of a player and reads it again after each
/// answer; `null` while reading and when it cannot be read.
final class MasteryGridCubit extends Cubit<MasteryGridEntity?> {
  /// Creates the Cubit of [scope].
  MasteryGridCubit({
    required this._scope,
    required this._getGrid,
    required this._watchChanges,
  }) : super(null);

  final MasteryScope _scope;
  final GetMasteryGridUseCase _getGrid;
  final WatchMasteryChangesUseCase _watchChanges;
  StreamSubscription<void>? _changes;

  /// Reads the grid and follows its changes.
  Future<void> load() async {
    _changes ??= _watchChanges().listen((_) => unawaited(_reload()));
    await _reload();
  }

  Future<void> _reload() async {
    final DataState<MasteryGridEntity> read = await _getGrid(params: _scope);
    if (isClosed) return;
    if (read case DataSuccess<MasteryGridEntity>(:final data)) emit(data);
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
