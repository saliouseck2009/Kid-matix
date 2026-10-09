import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_creation_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_creation_status.dart';

/// Drives the profile creation form.
///
/// On success the new player becomes the active one; the profile session
/// changes and the router leaves the form on its own.
final class ProfileCreationCubit extends Cubit<ProfileCreationState> {
  /// Creates the Cubit.
  ProfileCreationCubit({
    required this._createProfile,
    required this._selectProfile,
  }) : super(const ProfileCreationState.initial());

  final CreateProfileUseCase _createProfile;
  final SelectProfileUseCase _selectProfile;

  /// Records the typed [nickname].
  void changeNickname(String nickname) {
    emit(
      state.copyWith(
        nickname: nickname,
        status: ProfileCreationStatus.editing,
      ),
    );
  }

  /// Records the chosen [avatar].
  void pickAvatar(ProfileAvatar avatar) => emit(state.copyWith(avatar: avatar));

  /// Records the chosen [color].
  void pickColor(ProfileColor color) => emit(state.copyWith(color: color));

  /// Creates the player and makes them the active one.
  Future<void> submit() async {
    if (!state.canSubmit) return;
    if (state.nicknameError != null) {
      emit(state.copyWith(showsNicknameError: true));
      return;
    }
    emit(state.copyWith(status: ProfileCreationStatus.submitting));
    final DataState<ProfileEntity> created = await _createProfile(
      params: CreateProfileParams(
        nickname: state.nickname,
        avatar: state.avatar,
        color: state.color,
      ),
    );
    final DataState<ProfileEntity> selected = switch (created) {
      DataSuccess<ProfileEntity>(:final data) => await _selectProfile(
        params: data.id,
      ),
      DataFailed<ProfileEntity>() => created,
    };
    if (selected case DataFailed<ProfileEntity>(:final exception)) {
      emit(
        state.copyWith(
          status: ProfileCreationStatus.failed,
          showsNicknameError: true,
          failureCode: exception.code,
        ),
      );
    }
  }
}
