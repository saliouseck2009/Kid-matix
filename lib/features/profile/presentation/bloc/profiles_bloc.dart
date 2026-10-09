import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_limits.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profiles_event.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profiles_state.dart';

/// Drives the "Qui joue ?" screen: lists the players and opens one.
///
/// Once a player is selected, the profile session changes and the router
/// leaves the screen on its own; the Bloc stays in [ProfilesLoading].
final class ProfilesBloc extends Bloc<ProfilesEvent, ProfilesState> {
  /// Creates the Bloc.
  ProfilesBloc({
    required this._getProfiles,
    required this._selectProfile,
  }) : super(const ProfilesLoading()) {
    on<ProfilesRequested>(_onRequested);
    on<ProfileSelected>(_onSelected);
  }

  final GetProfilesUseCase _getProfiles;
  final SelectProfileUseCase _selectProfile;

  Future<void> _onRequested(
    ProfilesRequested event,
    Emitter<ProfilesState> emit,
  ) async {
    emit(const ProfilesLoading());
    final DataState<List<ProfileEntity>> state = await _getProfiles();
    emit(switch (state) {
      DataSuccess<List<ProfileEntity>>(:final data) => ProfilesLoaded(
        profiles: data,
        canAddProfile: data.length < ProfileLimits.maxProfiles,
      ),
      DataFailed<List<ProfileEntity>>(:final exception) => ProfilesFailure(
        errorCode: exception.code,
      ),
    });
  }

  Future<void> _onSelected(
    ProfileSelected event,
    Emitter<ProfilesState> emit,
  ) async {
    emit(const ProfilesLoading());
    final DataState<ProfileEntity> state = await _selectProfile(
      params: event.profileId,
    );
    if (state case DataFailed<ProfileEntity>(:final exception)) {
      emit(ProfilesFailure(errorCode: exception.code));
    }
  }
}
