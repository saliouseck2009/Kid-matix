import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_status.dart';
import 'package:kid_matix/features/profile/presentation/widgets/avatar_picker.dart';
import 'package:kid_matix/features/profile/presentation/widgets/color_picker.dart';
import 'package:kid_matix/features/profile/presentation/widgets/nickname_error_message.dart';
import 'package:kid_matix/features/profile/presentation/widgets/nickname_field.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_error_message.dart';

/// Body of the forms that create or edit a player, driven by the
/// [ProfileFormCubit] above it.
class ProfileFormView extends StatelessWidget {
  /// Creates the form titled [title] with a [submitLabel] button.
  const ProfileFormView({
    required this.title,
    required this.submitLabel,
    this.onBack,
    super.key,
  });

  static const double _previewSize = 92;
  static const double _sectionGap = 14;

  /// Title of the screen.
  final String title;

  /// Label of the button that saves the player.
  final String submitLabel;

  /// Called by the back arrow; the arrow is hidden when `null`.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final ProfileFormCubit cubit = context.read<ProfileFormCubit>();
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileFormCubit, ProfileFormState>(
          builder: (BuildContext context, ProfileFormState state) {
            if (state.status == ProfileFormStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _FormHeader(title: title, onBack: onBack),
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
                    initialValue: state.nickname,
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
                  _FormFooter(
                    state: state,
                    submitLabel: submitLabel,
                    onSubmit: cubit.submit,
                  ),
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
    ProfileFormState state,
  ) {
    if (state.failureCode == AppErrorCode.conflict) {
      return context.l10n.nicknameTaken;
    }
    if (!state.showsNicknameError) return null;
    return state.nicknameError?.toMessage(context.l10n);
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? back = onBack;
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        if (back != null)
          AppIconButton(
            icon: Icons.chevron_left,
            tooltip: context.l10n.commonBack,
            onPressed: back,
          ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormFooter extends StatelessWidget {
  const _FormFooter({
    required this.state,
    required this.submitLabel,
    required this.onSubmit,
  });

  final ProfileFormState state;
  final String submitLabel;
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
          label: submitLabel,
          onPressed: state.canSubmit ? onSubmit : null,
        ),
      ],
    );
  }
}
