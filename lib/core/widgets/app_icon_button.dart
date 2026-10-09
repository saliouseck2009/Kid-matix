import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Round icon-only button (back, close, settings).
///
/// The [tooltip] is mandatory: it is what a screen reader announces.
class AppIconButton extends StatelessWidget {
  /// Creates a round button showing [icon] and described by [tooltip].
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  /// Icon of the button.
  final IconData icon;

  /// Localized description of the action.
  final String tooltip;

  /// Called when the player taps the button; `null` disables it.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: context.palette.mutedText,
        minimumSize: const Size.square(AppSizes.minTouchTarget),
      ),
    );
  }
}
