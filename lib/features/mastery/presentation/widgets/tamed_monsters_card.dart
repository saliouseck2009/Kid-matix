import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/little_monster.dart';
import 'package:kid_matix/features/mastery/domain/entities/monster_entity.dart';
import 'package:kid_matix/features/mastery/presentation/widgets/monster_labels.dart';

/// « Apprivoisés »: the collection of the tamed monsters, each with its
/// fact.
class TamedMonstersCard extends StatelessWidget {
  /// Creates the collection of [monsters].
  const TamedMonstersCard({
    required this.monsters,
    required this.labels,
    super.key,
  });

  static const int _columns = 4;
  static const double _gap = 8;
  static const double _radius = 24;

  /// Tamed monsters, in the order to show them.
  final List<MonsterEntity> monsters;

  /// Texts of the monsters.
  final MonsterLabels labels;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _gap,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    context.l10n.monstersTamedTitle,
                    style: textTheme.titleMedium,
                  ),
                ),
              ),
              Text(
                context.l10n.monstersTamedCount(monsters.length),
                style: textTheme.bodySmall?.copyWith(
                  color: context.palette.mutedText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          for (int first = 0; first < monsters.length; first += _columns)
            Row(
              spacing: _gap,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int index = first; index < first + _columns; index++)
                  Expanded(
                    child: index < monsters.length
                        ? _TamedMonster(
                            key: ValueKey<String>(monsters[index].itemKey),
                            itemKey: monsters[index].itemKey,
                            labels: labels,
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TamedMonster extends StatelessWidget {
  const _TamedMonster({
    required this.itemKey,
    required this.labels,
    super.key,
  });

  static const double _monsterSize = 48;
  static const double _factSize = 16;
  static const double _radius = 16;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space4,
    vertical: 10,
  );

  final String itemKey;
  final MonsterLabels labels;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.monsterTamedSpoken(labels.spokenFactOf(itemKey)),
      container: true,
      excludeSemantics: true,
      child: Container(
        padding: _padding,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Column(
          spacing: AppSizes.space4,
          children: <Widget>[
            LittleMonster(
              variant: LittleMonster.variantOf(itemKey),
              size: _monsterSize,
              isTamed: true,
            ),
            Text(
              labels.factOf(itemKey),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: _factSize),
            ),
          ],
        ),
      ),
    );
  }
}
