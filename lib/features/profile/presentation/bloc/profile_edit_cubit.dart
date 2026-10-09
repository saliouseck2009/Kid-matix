import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_status.dart';

/// Drives the form where a player renames themselves or changes their
/// avatar or color.
final class ProfileEditCubit extends ProfileFormCubit {
  /// Creates the form of the player [profileId]; call [load] first.
  ProfileEditCubit({
    required this._profileId,
    required this._getProfile,
    required this._updateProfile,
  }) : super(
         const ProfileFormState.initial().copyWith(
           status: ProfileFormStatus.loading,
         ),
       );

  final String _profileId;
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  ProfileEntity? _profile;

  /// Fills the form with the stored player.
  Future<void> load() async {
    if (state.status != ProfileFormStatus.loading) {
      emit(state.copyWith(status: ProfileFormStatus.loading));
    }
    final DataState<ProfileEntity> loaded = await _getProfile(
      params: _profileId,
    );
    switch (loaded) {
      case DataSuccess<ProfileEntity>(:final data):
        _profile = data;
        emit(
          ProfileFormState.filled(
            nickname: data.nickname,
            avatar: data.avatar,
            color: data.color,
          ),
        );
      case DataFailed<ProfileEntity>(:final exception):
        emit(
          state.copyWith(
            status: ProfileFormStatus.failed,
            failureCode: exception.code,
          ),
        );
    }
  }

  /// Saves the changes; the state becomes [ProfileFormStatus.saved].
  @override
  Future<void> submit() async {
    final ProfileEntity? profile = _profile;
    if (profile == null || !checkBeforeSubmit()) return;
    emit(state.copyWith(status: ProfileFormStatus.submitting));
    final DataState<ProfileEntity> updated = await _updateProfile(
      params: profile.copyWith(
        nickname: state.nickname,
        avatar: state.avatar,
        color: state.color,
      ),
    );
    emit(switch (updated) {
      DataSuccess<ProfileEntity>() => state.copyWith(
        status: ProfileFormStatus.saved,
      ),
      DataFailed<ProfileEntity>(:final exception) => state.copyWith(
        status: ProfileFormStatus.failed,
        showsNicknameError: true,
        failureCode: exception.code,
      ),
    });
  }
}
