import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_creation_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_cubit.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_form_view.dart';

/// Creation of a new player: nickname, avatar and color.
class ProfileCreationPage extends StatelessWidget {
  /// Creates the page; [canGoBack] shows the back arrow to "Qui joue ?".
  const ProfileCreationPage({
    required this.createProfile,
    required this.selectProfile,
    required this.canGoBack,
    super.key,
  });

  /// Saves the new player.
  final CreateProfileUseCase createProfile;

  /// Makes the new player the active one.
  final SelectProfileUseCase selectProfile;

  /// Whether other players exist to go back to.
  final bool canGoBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileFormCubit>(
      create: (_) => ProfileCreationCubit(
        createProfile: createProfile,
        selectProfile: selectProfile,
      ),
      child: ProfileFormView(
        title: context.l10n.profileCreationTitle,
        submitLabel: context.l10n.createProfileButton,
        onBack: canGoBack ? () => context.go(AppRoutes.whoIsPlaying) : null,
      ),
    );
  }
}
