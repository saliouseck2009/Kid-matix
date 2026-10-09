import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_color_name.dart';

/// Row of the six color swatches of a profile.
class ColorPicker extends StatelessWidget {
  /// Creates the picker with [selected] ringed.
  const ColorPicker({
    required this.selected,
    required this.onPicked,
    super.key,
  });

  /// Ringed color.
  final ProfileColor selected;

  /// Called with the tapped color.
  final ValueChanged<ProfileColor> onPicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          context.l10n.colorPickerLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSizes.space8),
        Row(
          spacing: AppSizes.space8,
          children: <Widget>[
            for (final ProfileColor color in ProfileColor.values)
              Expanded(
                child: _ColorSwatch(
                  color: color,
                  isSelected: color == selected,
                  onTap: () => onPicked(color),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  static const double _swatchSize = 34;
  static const double _ringWidth = 3;

  final ProfileColor color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color ringColor = isSelected
        ? Theme.of(context).colorScheme.onSurface
        : Colors.transparent;
    return Semantics(
      button: true,
      selected: isSelected,
      label: color.toName(context.l10n),
      child: InkResponse(
        onTap: onTap,
        child: Container(
          height: AppSizes.minTouchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: _ringWidth),
          ),
          child: Container(
            width: _swatchSize,
            height: _swatchSize,
            decoration: BoxDecoration(
              color: context.palette.avatarBackgrounds[color.index],
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
