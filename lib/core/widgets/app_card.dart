import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';

/// White rounded surface that groups related content.
class AppCard extends StatelessWidget {
  /// Creates a card around [child].
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.space16),
    super.key,
  });

  /// Content of the card.
  final Widget child;

  /// Space between the edge of the card and [child].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: child,
    );
  }
}
