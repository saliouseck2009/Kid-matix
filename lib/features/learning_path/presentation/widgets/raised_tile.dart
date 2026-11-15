import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';

/// A white surface outlined and raised by a thicker bottom edge, that
/// answers a tap: the domain button of the map and the cards of « Mes
/// parcours ».
class RaisedTile extends StatelessWidget {
  /// Creates the tile around [child].
  const RaisedTile({
    required this.child,
    required this.onTap,
    required this.outline,
    required this.depth,
    this.padding = const EdgeInsets.all(AppSizes.space12),
    super.key,
  });

  /// Height of the raised bottom edge.
  static const double depthHeight = 4;

  /// Corner radius of the tile.
  static const double radius = 20;

  /// Content of the tile.
  final Widget child;

  /// Called when the tile is tapped.
  final VoidCallback onTap;

  /// Color of the outline.
  final Color outline;

  /// Color of the bottom edge.
  final Color depth;

  /// Space between the outline and [child].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final BorderRadius corners = BorderRadius.circular(radius);
    return Container(
      padding: const EdgeInsets.only(bottom: depthHeight),
      decoration: BoxDecoration(color: depth, borderRadius: corners),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: corners,
          side: BorderSide(color: outline, width: AppSizes.borderWidth),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(borderRadius: corners),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
