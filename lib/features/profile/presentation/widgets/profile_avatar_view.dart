import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/presentation/widgets/premium_avatar_painter.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_painter.dart';

/// A player's avatar drawn in their color, [size] wide; an avatar of the
/// shop keeps its own colors.
///
/// Decorative: the nickname next to it carries the meaning, so the drawing
/// is hidden from screen readers.
class ProfileAvatarView extends StatelessWidget {
  /// Creates the avatar [avatar] in [color].
  const ProfileAvatarView({
    required this.avatar,
    required this.color,
    required this.size,
    super.key,
  });

  /// Character to draw.
  final ProfileAvatar avatar;

  /// Color of the character.
  final ProfileColor color;

  /// Width and height of the drawing.
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: avatar.isFree
            ? _createFreePainter(context)
            : PremiumAvatarPainter(avatar: avatar),
      ),
    );
  }

  // The face stays dark on light colors and white on dark ones, whatever
  // the theme of the player.
  ProfileAvatarPainter _createFreePainter(BuildContext context) {
    final Color background = context.palette.avatarBackgrounds[color.index];
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isLight =
        ThemeData.estimateBrightnessForColor(background) == Brightness.light;
    return ProfileAvatarPainter(
      avatar: avatar,
      background: background,
      faceColor: isLight ? colors.onSecondary : colors.onPrimary,
    );
  }
}
