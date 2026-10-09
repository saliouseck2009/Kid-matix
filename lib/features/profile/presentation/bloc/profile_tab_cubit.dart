import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_use_cases.dart';

/// Drives the Profile tab of version 1.0's lot F1: the active player, with
/// "switch player", "edit" and "delete".
///
/// Switching or deleting changes the profile session; the router then
/// leaves the tab, so the Cubit stays in [ProfileTabLoading].
final class ProfileTabCubit extends Cubit<ProfileTabState> {
  /// Creates the Cubit for the player [profileId].
  ProfileTabCubit({required this._profileId, required this._useCases})
    : super(const ProfileTabLoading());

  final String _profileId;
  final ProfileTabUseCases _useCases;
  StreamSubscription<void>? _changes;
  bool _isLeaving = false;

  /// Loads the player and reloads it after every change.
  Future<void> load() async {
    _changes ??= _useCases.watchChanges().listen((_) => unawaited(_reload()));
    emit(const ProfileTabLoading());
    await _reload();
  }

  /// Goes back to "Qui joue ?" so another child can play.
  Future<void> switchPlayer() => _leave(_useCases.clearActiveProfile.call);

  /// Deletes the player and all of their data.
  Future<void> deleteProfile() {
    return _leave(() => _useCases.deleteProfile(params: _profileId));
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }

  Future<void> _reload() async {
    if (_isLeaving) return;
    final DataState<ProfileEntity> loaded = await _useCases.getProfile(
      params: _profileId,
    );
    if (_isLeaving || isClosed) return;
    emit(switch (loaded) {
      DataSuccess<ProfileEntity>(:final data) => ProfileTabLoaded(
        profile: data,
      ),
      DataFailed<ProfileEntity>(:final exception) => ProfileTabFailure(
        errorCode: exception.code,
      ),
    });
  }

  /// Runs [action], after which the router leaves the tab; reloads are
  /// ignored meanwhile so the tab never flashes an error.
  Future<void> _leave(Future<DataState<void>> Function() action) async {
    _isLeaving = true;
    emit(const ProfileTabLoading());
    final DataState<void> result = await action();
    if (result case DataFailed<void>(:final exception)) {
      _isLeaving = false;
      if (!isClosed) emit(ProfileTabFailure(errorCode: exception.code));
    }
  }
}
