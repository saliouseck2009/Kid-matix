import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_edit_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_status.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_form_view.dart';

/// Where the active player renames themselves or changes their avatar or
/// color; goes back to the Profile tab once saved.
class ProfileEditPage extends StatelessWidget {
  /// Creates the page of the player [profileId].
  const ProfileEditPage({
    required this.profileId,
    required this.getProfile,
    required this.updateProfile,
    super.key,
  });

  /// Identifier of the edited player.
  final String profileId;

  /// Reads the player.
  final GetProfileUseCase getProfile;

  /// Saves the changes.
  final UpdateProfileUseCase updateProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileFormCubit>(
      create: (_) => ProfileEditCubit(
        profileId: profileId,
        getProfile: getProfile,
        updateProfile: updateProfile,
      )..load(),
      child: BlocListener<ProfileFormCubit, ProfileFormState>(
        listenWhen: (ProfileFormState previous, ProfileFormState current) =>
            current.status == ProfileFormStatus.saved,
        listener: (BuildContext context, ProfileFormState state) =>
            context.go(AppRoutes.profile),
        child: ProfileFormView(
          title: context.l10n.profileEditTitle,
          submitLabel: context.l10n.saveProfileButton,
          onBack: () => context.go(AppRoutes.profile),
        ),
      ),
    );
  }
}
