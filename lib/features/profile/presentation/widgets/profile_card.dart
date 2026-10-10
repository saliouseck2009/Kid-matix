import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_card_frame.dart';

/// Card of one player on "Qui joue ?": avatar, nickname, level and an
/// optional footer, the streak pill.
class ProfileCard extends StatelessWidget {
  /// Creates the card of [profile].
  const ProfileCard({
    required this.profile,
    required this.onTap,
    this.footer,
    super.key,
  });

  /// Size of the avatar drawing.
  static const double avatarSize = 72;

  /// Inner padding of the card.
  static const EdgeInsets padding = EdgeInsets.fromLTRB(
    AppSizes.space12,
    20,
    AppSizes.space12,
    AppSizes.space16,
  );

  /// Gap between the lines of the card.
  static const double gap = 6;

  /// Player shown.
  final ProfileEntity profile;

  /// Called when the player taps the card.
  final VoidCallback onTap;

  /// Widget under the level, such as the streak pill, or `null`.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return ProfileCardFrame(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Column(
          children: <Widget>[
            ProfileAvatarView(
              avatar: profile.avatar,
              color: profile.color,
              size: avatarSize,
            ),
            const SizedBox(height: gap),
            Text(
              profile.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: gap),
            Text(
              context.l10n.profileLevel(profile.level),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
            if (footer case final Widget below) ...<Widget>[
              const SizedBox(height: gap),
              below,
            ],
          ],
        ),
      ),
    );
  }
}
