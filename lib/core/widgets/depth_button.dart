import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/theme/app_feedback_palette.dart';
import 'package:kid_matix/core/theme/app_palette.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';

/// Main button of the design: a colored face sitting on a raised edge.
class DepthButton extends StatelessWidget {
  /// Creates a button showing [label]; a `null` [onPressed] disables it.
  const DepthButton({
    required this.label,
    required this.onPressed,
    this.variant = DepthButtonVariant.primary,
    this.caption,
    super.key,
  });

  /// Localized text of the button.
  final String label;

  /// A smaller second line under [label], such as "10 questions", or
  /// `null`.
  final String? caption;

  /// Called when the player taps the button.
  final VoidCallback? onPressed;

  /// Visual weight of the button.
  final DepthButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final _DepthColors colors = _resolveColors(context);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Container(
        padding: const EdgeInsets.only(bottom: AppSizes.buttonDepth),
        decoration: BoxDecoration(
          color: colors.depth,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: _DepthButtonFace(
          label: label,
          caption: caption,
          onPressed: onPressed,
          faceColor: colors.face,
          labelColor: colors.label,
          outlineColor: colors.outline,
        ),
      ),
    );
  }

  _DepthColors _resolveColors(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppPalette palette = context.palette;
    final AppFeedbackPalette feedback = context.feedbackPalette;
    return switch (variant) {
      DepthButtonVariant.primary => (
        face: colorScheme.primary,
        depth: palette.primaryDepth,
        label: colorScheme.onPrimary,
        outline: null,
      ),
      DepthButtonVariant.secondary => (
        face: colorScheme.surface,
        depth: palette.border,
        label: palette.primaryText,
        outline: palette.border,
      ),
      DepthButtonVariant.success => (
        face: feedback.right,
        depth: feedback.rightDepth,
        label: feedback.onFeedback,
        outline: null,
      ),
      DepthButtonVariant.danger => (
        face: feedback.wrong,
        depth: feedback.wrongDepth,
        label: feedback.onFeedback,
        outline: null,
      ),
    };
  }
}

/// Colors of one variant of a [DepthButton].
typedef _DepthColors = ({Color face, Color depth, Color label, Color? outline});

class _DepthButtonFace extends StatelessWidget {
  const _DepthButtonFace({
    required this.label,
    required this.caption,
    required this.onPressed,
    required this.faceColor,
    required this.labelColor,
    required this.outlineColor,
  });

  static const double _faceHeight =
      AppSizes.buttonHeight - AppSizes.buttonDepth;

  final String label;
  final String? caption;
  final VoidCallback? onPressed;
  final Color faceColor;
  final Color labelColor;
  final Color? outlineColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? caption = this.caption;
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space16,
            vertical: AppSizes.space4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(color: labelColor),
              ),
              if (caption != null)
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: textTheme.labelLarge?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
