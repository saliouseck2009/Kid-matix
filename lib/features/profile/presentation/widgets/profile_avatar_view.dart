import 'package:flutter/material.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_painter.dart';

/// A player's avatar drawn in their color, [size] wide.
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
    final Color background = context.palette.avatarBackgrounds[color.index];
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isLight =
        ThemeData.estimateBrightnessForColor(background) == Brightness.light;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: ProfileAvatarPainter(
          avatar: avatar,
          background: background,
          faceColor: isLight ? colors.onSurface : colors.surface,
        ),
      ),
    );
  }
}
