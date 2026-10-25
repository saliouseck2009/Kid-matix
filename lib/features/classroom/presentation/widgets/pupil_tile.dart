import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/widgets/raised_card_frame.dart';
import 'package:kid_matix/features/classroom/domain/entities/pupil_entity.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/pupil_avatar_builder.dart';

/// A pupil in a grid: avatar and nickname, tappable as one button.
class PupilTile extends StatelessWidget {
  /// Creates the tile of [pupil].
  const PupilTile({
    required this.pupil,
    required this.avatarOf,
    required this.onTap,
    super.key,
  });

  /// Size of the avatar drawing.
  static const double avatarSize = 56;

  /// The pupil shown.
  final PupilEntity pupil;

  /// Draws the avatar.
  final PupilAvatarBuilder avatarOf;

  /// Called when the tile is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RaisedCardFrame(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSizes.space4,
          children: <Widget>[
            ExcludeSemantics(child: avatarOf(pupil.player, avatarSize)),
            Text(
              pupil.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
