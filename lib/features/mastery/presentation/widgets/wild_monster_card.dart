import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_progress_bar.dart';
import 'package:kid_matix/core/widgets/little_monster.dart';
import 'package:kid_matix/features/mastery/domain/entities/monster_entity.dart';
import 'package:kid_matix/features/mastery/presentation/widgets/monster_labels.dart';

/// A monster still to tame: its drawing, its fact, how tough it is and
/// how far it is from being tamed.
class WildMonsterCard extends StatelessWidget {
  /// Creates the card of [monster].
  const WildMonsterCard({
    required this.monster,
    required this.labels,
    super.key,
  });

  static const double _minHeight = 88;
  static const double _radius = 22;
  static const double _monsterSize = 60;
  static const double _factSize = 28;
  static const double _gap = 14;
  static const double _barGap = 6;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space16,
    vertical: AppSizes.space12,
  );

  /// Monster shown.
  final MonsterEntity monster;

  /// Texts of the monsters.
  final MonsterLabels labels;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String toughness = labels.toughnessOf(monster.box);
    return Semantics(
      label: context.l10n.monsterWildSpoken(
        labels.spokenFactOf(monster.itemKey),
        toughness,
      ),
      container: true,
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: _minHeight),
        padding: _padding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Row(
          spacing: _gap,
          children: <Widget>[
            LittleMonster(
              variant: LittleMonster.variantOf(monster.itemKey),
              size: _monsterSize,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: _barGap,
                children: <Widget>[
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: AppSizes.space8,
                    children: <Widget>[
                      Text(
                        labels.factOf(monster.itemKey),
                        style: textTheme.headlineSmall?.copyWith(
                          fontSize: _factSize,
                        ),
                      ),
                      Text(
                        toughness,
                        style: textTheme.bodySmall?.copyWith(
                          color: context.palette.mutedText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  AppProgressBar(
                    value: MonsterLabels.progressOf(monster.box),
                    semanticLabel: toughness,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
