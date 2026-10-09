import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_status.dart';

/// Drives the profile creation form.
///
/// On success the new player becomes the active one; the profile session
/// changes and the router leaves the form on its own.
final class ProfileCreationCubit extends ProfileFormCubit {
  /// Creates the Cubit.
  ProfileCreationCubit({
    required this._createProfile,
    required this._selectProfile,
  }) : super(const ProfileFormState.initial());

  final CreateProfileUseCase _createProfile;
  final SelectProfileUseCase _selectProfile;

  /// Creates the player and makes them the active one.
  @override
  Future<void> submit() async {
    if (!checkBeforeSubmit()) return;
    emit(state.copyWith(status: ProfileFormStatus.submitting));
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
          status: ProfileFormStatus.failed,
          showsNicknameError: true,
          failureCode: exception.code,
        ),
      );
    }
  }
}
