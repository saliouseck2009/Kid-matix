import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Raised white card of the player grid, tappable as one button.
class ProfileCardFrame extends StatelessWidget {
  /// Creates a raised card around [child] that calls [onTap].
  const ProfileCardFrame({
    required this.child,
    required this.onTap,
    super.key,
  });

  /// Thickness of the raised bottom edge.
  static const double depth = 6;

  /// Content of the card.
  final Widget child;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color edgeColor = context.palette.border;
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusLarge);
    return Semantics(
      button: true,
      child: Container(
        padding: const EdgeInsets.only(bottom: depth),
        decoration: BoxDecoration(color: edgeColor, borderRadius: radius),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: edgeColor, width: AppSizes.borderWidth),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(borderRadius: radius),
            child: child,
          ),
        ),
      ),
    );
  }
}
