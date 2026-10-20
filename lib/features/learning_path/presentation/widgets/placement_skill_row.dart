import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/learning_path/domain/entities/skill_level.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the skills of the placement test, such as "Additions".
extension PlacementSkillNames on AppLocalizations {
  /// Name of [skill]; empty for a skill the app does not name.
  String placementSkillName(SkillLevel skill) {
    return switch (skill.id) {
      'numbers' => placementSkillNumbers,
      'addition' => placementSkillAddition,
      'subtraction' => placementSkillSubtraction,
      'multiplication' => placementSkillMultiplication,
      'division' => placementSkillDivision,
      _ => '',
    };
  }
}

/// One skill of the placement test result: violet with a yellow check when
/// the child passed it, light when it is still to discover.
class PlacementSkillRow extends StatelessWidget {
  /// Creates the row of [skill].
  const PlacementSkillRow({
    required this.skill,
    required this.isAcquired,
    super.key,
  });

  static const double _height = 56;
  static const double _checkSize = 24;

  /// Skill shown.
  final SkillLevel skill;

  /// Whether the child passed the skill.
  final bool isAcquired;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color foreground = isAcquired
        ? colors.onPrimary
        : context.palette.mutedText;
    final String name = context.l10n.placementSkillName(skill);
    final String state = isAcquired
        ? context.l10n.placementSkillAcquired
        : context.l10n.placementSkillToDiscover;
    return Semantics(
      label: context.l10n.placementSkillSemantics(name, state),
      excludeSemantics: true,
      child: Container(
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
        decoration: BoxDecoration(
          color: isAcquired ? colors.primary : context.palette.lockedFace,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Row(
          spacing: AppSizes.space12,
          children: <Widget>[
            Expanded(
              child: Text(
                name,
                style: textTheme.titleMedium?.copyWith(color: foreground),
              ),
            ),
            Text(
              state,
              style: textTheme.labelLarge?.copyWith(color: foreground),
            ),
            if (isAcquired)
              Icon(
                Icons.check_rounded,
                size: _checkSize,
                color: colors.secondary,
              ),
          ],
        ),
      ),
    );
  }
}
