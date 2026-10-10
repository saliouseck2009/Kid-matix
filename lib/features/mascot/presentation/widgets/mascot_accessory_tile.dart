import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/core/entities/mascot_look.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_labels.dart';

/// One accessory of the mascot screen: a small mascot wearing it and its
/// name; worn ones are outlined, locked ones say how to earn them.
class MascotAccessoryTile extends StatelessWidget {
  /// Creates the tile of [accessory].
  const MascotAccessoryTile({
    required this.accessory,
    required this.isUnlocked,
    required this.isWorn,
    required this.labels,
    required this.onTap,
    super.key,
  });

  static const double _width = 104;
  static const double _previewSize = 64;
  static const double _radius = 18;
  static const double _wornBorder = 3;

  /// Accessory shown.
  final MascotAccessory accessory;

  /// Whether the player earned it.
  final bool isUnlocked;

  /// Whether the mascot wears it.
  final bool isWorn;

  /// Names of the accessories.
  final MascotLabels labels;

  /// Puts it on or takes it off.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String name = labels.accessoryName(accessory);
    final String hint = labels.unlockHint(accessory);
    return Semantics(
      button: isUnlocked,
      selected: isWorn,
      label: isUnlocked
          ? (isWorn ? context.l10n.mascotAccessoryWorn(name) : name)
          : context.l10n.mascotAccessoryLocked(name, hint),
      excludeSemantics: true,
      child: Material(
        color: isUnlocked ? scheme.surface : context.palette.lockedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: isWorn
              ? BorderSide(color: scheme.primary, width: _wornBorder)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: isUnlocked ? onTap : null,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: SizedBox(
            width: _width,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.space8),
              child: Column(
                spacing: AppSizes.space4,
                children: <Widget>[
                  Opacity(
                    opacity: isUnlocked ? 1 : 0.4,
                    child: MascotIllustration(
                      size: _previewSize,
                      look: MascotLook(
                        stage: 2,
                        accessories: <MascotAccessory>{accessory},
                      ),
                    ),
                  ),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (!isUnlocked)
                    Text(
                      hint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.palette.mutedText,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
