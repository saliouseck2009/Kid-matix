import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';

/// Top of the Profile tab: the avatar, nickname and level, which open the
/// edition, and the round buttons of [actions].
class ProfileHeader extends StatelessWidget {
  /// Creates the header of [profile].
  const ProfileHeader({
    required this.profile,
    required this.onEdit,
    required this.actions,
    super.key,
  });

  static const double _avatarSize = 56;
  static const double _nameSize = 28;
  static const double _editIconSize = 18;

  /// The active player.
  final ProfileEntity profile;

  /// Opens the edition of the player.
  final VoidCallback onEdit;

  /// Round buttons at the end, such as "Changer de joueur".
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        Expanded(
          child: Semantics(
            button: true,
            hint: context.l10n.editProfileButton,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              child: Row(
                spacing: AppSizes.space12,
                children: <Widget>[
                  ProfileAvatarView(
                    avatar: profile.avatar,
                    color: profile.color,
                    size: _avatarSize,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          spacing: AppSizes.space4,
                          children: <Widget>[
                            Flexible(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  profile.nickname,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontSize: _nameSize,
                                  ),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.edit_rounded,
                              size: _editIconSize,
                              color: context.palette.mutedText,
                            ),
                          ],
                        ),
                        Text(
                          context.l10n.profileLevel(profile.level),
                          style: textTheme.labelLarge?.copyWith(
                            color: context.palette.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ...actions,
      ],
    );
  }
}
