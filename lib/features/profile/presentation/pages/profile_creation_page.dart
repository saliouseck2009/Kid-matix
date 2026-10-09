import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_creation_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_creation_state.dart';
import 'package:kid_matix/features/profile/presentation/widgets/avatar_picker.dart';
import 'package:kid_matix/features/profile/presentation/widgets/color_picker.dart';
import 'package:kid_matix/features/profile/presentation/widgets/nickname_error_message.dart';
import 'package:kid_matix/features/profile/presentation/widgets/nickname_field.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_error_message.dart';

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
    return BlocProvider<ProfileCreationCubit>(
      create: (_) => ProfileCreationCubit(
        createProfile: createProfile,
        selectProfile: selectProfile,
      ),
      child: _ProfileCreationView(canGoBack: canGoBack),
    );
  }
}

class _ProfileCreationView extends StatelessWidget {
  const _ProfileCreationView({required this.canGoBack});

  static const double _previewSize = 92;
  static const double _sectionGap = 14;

  final bool canGoBack;

  @override
  Widget build(BuildContext context) {
    final ProfileCreationCubit cubit = context.read<ProfileCreationCubit>();
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileCreationCubit, ProfileCreationState>(
          builder: (BuildContext context, ProfileCreationState state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _CreationHeader(canGoBack: canGoBack),
                  const SizedBox(height: _sectionGap),
                  Center(
                    child: ProfileAvatarView(
                      avatar: state.avatar,
                      color: state.color,
                      size: _previewSize,
                    ),
                  ),
                  const SizedBox(height: _sectionGap),
                  NicknameField(
                    onChanged: cubit.changeNickname,
                    onSubmitted: cubit.submit,
                    errorText: _describeNicknameError(context, state),
                  ),
                  const SizedBox(height: _sectionGap),
                  AvatarPicker(
                    selected: state.avatar,
                    color: state.color,
                    onPicked: cubit.pickAvatar,
                  ),
                  const SizedBox(height: _sectionGap),
                  ColorPicker(selected: state.color, onPicked: cubit.pickColor),
                  const SizedBox(height: AppSizes.space24),
                  _CreationFooter(state: state, onSubmit: cubit.submit),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String? _describeNicknameError(
    BuildContext context,
    ProfileCreationState state,
  ) {
    if (state.failureCode == AppErrorCode.conflict) {
      return context.l10n.nicknameTaken;
    }
    if (!state.showsNicknameError) return null;
    return state.nicknameError?.toMessage(context.l10n);
  }
}

class _CreationHeader extends StatelessWidget {
  const _CreationHeader({required this.canGoBack});

  final bool canGoBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        if (canGoBack)
          AppIconButton(
            icon: Icons.chevron_left,
            tooltip: context.l10n.commonBack,
            onPressed: () => context.go(AppRoutes.whoIsPlaying),
          ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              context.l10n.profileCreationTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _CreationFooter extends StatelessWidget {
  const _CreationFooter({required this.state, required this.onSubmit});

  final ProfileCreationState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final AppErrorCode? failureCode = state.failureCode;
    final bool showsFailure =
        failureCode != null && failureCode != AppErrorCode.conflict;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showsFailure)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.space12),
            child: Semantics(
              liveRegion: true,
              child: Text(
                failureCode.toProfileMessage(context.l10n),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        DepthButton(
          label: context.l10n.createProfileButton,
          onPressed: state.canSubmit ? onSubmit : null,
        ),
      ],
    );
  }
}
