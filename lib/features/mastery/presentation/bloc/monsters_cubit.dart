import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/mastery/domain/entities/monster_collection_entity.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_monsters_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';
import 'package:kid_matix/features/mastery/domain/usecases/watch_mastery_changes_use_case.dart';
import 'package:kid_matix/features/mastery/presentation/bloc/monsters_state.dart';

/// Reads the monsters of a player and reads them again after each answer.
final class MonstersCubit extends Cubit<MonstersState> {
  /// Creates the Cubit of [scope].
  MonstersCubit({
    required this._scope,
    required this._getMonsters,
    required this._watchChanges,
  }) : super(const MonstersLoading());

  final MasteryScope _scope;
  final GetMonstersUseCase _getMonsters;
  final WatchMasteryChangesUseCase _watchChanges;
  StreamSubscription<void>? _changes;

  /// Reads the monsters and follows their changes.
  Future<void> load() async {
    _changes ??= _watchChanges().listen((_) => unawaited(_reload()));
    await _reload();
  }

  Future<void> _reload() async {
    final DataState<MonsterCollectionEntity> read = await _getMonsters(
      params: _scope,
    );
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<MonsterCollectionEntity>(:final data) => MonstersLoaded(
        monsters: data,
      ),
      DataFailed<MonsterCollectionEntity>(:final exception) => MonstersFailure(
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
