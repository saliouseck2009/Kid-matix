import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/mascot/domain/entities/mascot_entity.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_state.dart';
import 'package:kid_matix/features/mascot/presentation/bloc/mascot_use_cases.dart';

/// Reads the mascot of a player, follows its changes and saves the
/// choices of the child.
final class MascotCubit extends Cubit<MascotState> {
  /// Creates the Cubit of the mascot of [profileId].
  MascotCubit({required this._profileId, required this._useCases})
    : super(const MascotLoading());

  final String _profileId;
  final MascotUseCases _useCases;
  StreamSubscription<void>? _changes;

  /// Reads the mascot and follows its changes.
  Future<void> load() async {
    _changes ??= _useCases.watchChanges().listen((_) => unawaited(_reload()));
    await _reload();
  }

  /// Names the mascot.
  Future<void> rename(String name) async {
    await _useCases.update.rename(profileId: _profileId, name: name);
  }

  /// Puts [accessory] on, or takes it off.
  Future<void> toggleAccessory(MascotAccessory accessory) async {
    await _useCases.update.toggleAccessory(
      profileId: _profileId,
      accessory: accessory,
    );
  }

  /// Remembers that the growth to [stage] was celebrated.
  Future<void> markCelebrated(int stage) async {
    await _useCases.update.markCelebrated(profileId: _profileId, stage: stage);
  }

  Future<void> _reload() async {
    final DataState<MascotEntity> read = await _useCases.getMascot(
      params: _profileId,
    );
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<MascotEntity>(:final data) => MascotLoaded(mascot: data),
      DataFailed<MascotEntity>(:final exception) => MascotFailure(
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
