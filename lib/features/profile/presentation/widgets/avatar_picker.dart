import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';

/// Grid of the 12 avatars, drawn in the chosen [color].
class AvatarPicker extends StatelessWidget {
  /// Creates the picker with [selected] highlighted.
  const AvatarPicker({
    required this.selected,
    required this.color,
    required this.onPicked,
    super.key,
  });

  static const int _columnCount = 4;

  /// Highlighted avatar.
  final ProfileAvatar selected;

  /// Color of the drawings.
  final ProfileColor color;

  /// Called with the tapped avatar.
  final ValueChanged<ProfileAvatar> onPicked;

  @override
  Widget build(BuildContext context) {
    const List<ProfileAvatar> avatars = ProfileAvatar.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          context.l10n.avatarPickerLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (int start = 0; start < avatars.length; start += _columnCount)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.space8),
            child: Row(
              spacing: AppSizes.space8,
              children: <Widget>[
                for (final ProfileAvatar avatar in avatars.sublist(
                  start,
                  start + _columnCount,
                ))
                  Expanded(
                    child: _AvatarOption(
                      avatar: avatar,
                      color: color,
                      isSelected: avatar == selected,
                      onTap: () => onPicked(avatar),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.avatar,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  static const double _height = 72;
  static const double _avatarSize = 52;
  static const double _ringWidth = 3;

  final ProfileAvatar avatar;
  final ProfileColor color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusMedium);
    return Semantics(
      button: true,
      selected: isSelected,
      label: context.l10n.avatarOptionLabel(avatar.index + 1),
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: isSelected ? colors.onSurface : Colors.transparent,
            width: _ringWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(borderRadius: radius),
          child: SizedBox(
            height: _height,
            child: Center(
              child: ProfileAvatarView(
                avatar: avatar,
                color: color,
                size: _avatarSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
