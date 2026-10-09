import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Small rounded label, optionally led by an icon (streak, level, score).
class AppPill extends StatelessWidget {
  /// Creates a pill showing [label]; it uses the tint color by default.
  const AppPill({
    required this.label,
    this.icon,
    this.backgroundColor,
    super.key,
  });

  /// Localized text of the pill.
  final String label;

  /// Optional icon shown before [label].
  final IconData? icon;

  /// Background of the pill; defaults to the palette tint.
  final Color? backgroundColor;

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final IconData? leadingIcon = icon;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.space12,
        vertical: AppSizes.space8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.palette.tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSizes.space4,
        children: <Widget>[
          if (leadingIcon != null) Icon(leadingIcon, size: _iconSize),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
