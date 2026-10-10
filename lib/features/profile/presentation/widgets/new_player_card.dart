import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/dashed_border_painter.dart';

/// Dashed card of "Qui joue ?" that opens the creation of a player.
class NewPlayerCard extends StatelessWidget {
  /// Creates the card; [onTap] opens the creation.
  const NewPlayerCard({required this.onTap, super.key});

  static const double _circleSize = 64;
  static const double _iconSize = 32;
  static const double _dashWidth = 3;
  static const double _gap = 10;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = context.palette.primaryText;
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusLarge);
    return Semantics(
      button: true,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: context.palette.strongBorder,
          strokeWidth: _dashWidth,
          radius: AppSizes.radiusLarge,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(borderRadius: radius),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.space12),
              // Very large system text scales the content down so it fits
              // the grid cell, which has the height of a player card.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: _circleSize,
                      height: _circleSize,
                      decoration: BoxDecoration(
                        color: context.palette.tint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: _iconSize,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: _gap),
                    Text(
                      context.l10n.newPlayerButton,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: labelColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
