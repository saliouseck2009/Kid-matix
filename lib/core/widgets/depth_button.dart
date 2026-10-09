import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/theme/app_palette.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';

/// Main button of the design: a colored face sitting on a raised edge.
class DepthButton extends StatelessWidget {
  /// Creates a button showing [label]; a `null` [onPressed] disables it.
  const DepthButton({
    required this.label,
    required this.onPressed,
    this.variant = DepthButtonVariant.primary,
    super.key,
  });

  /// Localized text of the button.
  final String label;

  /// Called when the player taps the button.
  final VoidCallback? onPressed;

  /// Visual weight of the button.
  final DepthButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppPalette palette = context.palette;
    final bool isPrimary = variant == DepthButtonVariant.primary;
    final Color depthColor = isPrimary ? palette.primaryDepth : palette.border;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Container(
        padding: const EdgeInsets.only(bottom: AppSizes.buttonDepth),
        decoration: BoxDecoration(
          color: depthColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: _DepthButtonFace(
          label: label,
          onPressed: onPressed,
          faceColor: isPrimary ? colorScheme.primary : colorScheme.surface,
          labelColor: isPrimary ? colorScheme.onPrimary : palette.primaryText,
          outlineColor: isPrimary ? null : palette.border,
        ),
      ),
    );
  }
}

class _DepthButtonFace extends StatelessWidget {
  const _DepthButtonFace({
    required this.label,
    required this.onPressed,
    required this.faceColor,
    required this.labelColor,
    required this.outlineColor,
  });

  static const double _faceHeight =
      AppSizes.buttonHeight - AppSizes.buttonDepth;

  final String label;
  final VoidCallback? onPressed;
  final Color faceColor;
  final Color labelColor;
  final Color? outlineColor;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.titleLarge;
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusMedium);
    final Color? outline = outlineColor;
    final BorderSide side = outline == null
        ? BorderSide.none
        : BorderSide(color: outline, width: AppSizes.borderWidth);
    return Material(
      color: faceColor,
      shape: RoundedRectangleBorder(borderRadius: radius, side: side),
      child: InkWell(
        onTap: onPressed,
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        child: Container(
          constraints: const BoxConstraints(minHeight: _faceHeight),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: labelStyle?.copyWith(color: labelColor),
          ),
        ),
      ),
    );
  }
}
