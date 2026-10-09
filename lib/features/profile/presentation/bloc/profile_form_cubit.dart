import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_status.dart';

/// Shared behaviour of the forms that create or edit a player.
///
/// Subclasses only decide what [submit] saves.
abstract class ProfileFormCubit extends Cubit<ProfileFormState> {
  /// Creates the form with [initialState].
  ProfileFormCubit(super.initialState);

  /// Records the typed [nickname].
  void changeNickname(String nickname) {
    emit(state.copyWith(nickname: nickname, status: ProfileFormStatus.editing));
  }

  /// Records the chosen [avatar].
  void pickAvatar(ProfileAvatar avatar) => emit(state.copyWith(avatar: avatar));

  /// Records the chosen [color].
  void pickColor(ProfileColor color) => emit(state.copyWith(color: color));

  /// Saves the player.
  Future<void> submit();

  /// Whether [submit] may save: shows the nickname error and returns
  /// `false` when the nickname breaks the rules.
  bool checkBeforeSubmit() {
    if (!state.canSubmit) return false;
    if (state.nicknameError == null) return true;
    emit(state.copyWith(showsNicknameError: true));
    return false;
  }
}
