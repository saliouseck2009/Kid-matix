import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/monster_painter.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_state.dart';

/// "Mes monstres" on the Profile tab: the monster of every table, in
/// color once its boss is defeated, as a gray shadow before.
class MonstersCard extends StatelessWidget {
  /// Creates the card; the path comes from the enclosing Bloc.
  const MonstersCard({super.key});

  static const int _columns = 4;
  static const double _gap = 10;
  static const double _radius = 20;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space16,
    vertical: 14,
  );

  @override
  Widget build(BuildContext context) {
    final LearningPathEntity? path = switch (context
        .watch<LearningPathBloc>()
        .state) {
      LearningPathLoaded(:final path) => path,
      _ => null,
    };
    if (path == null) return const SizedBox.shrink();
    final List<TablePathNode> tables = path.tables;
    final int defeated = path.defeatedBosses.length;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.space12,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    context.l10n.pathMonstersTitle,
                    style: textTheme.titleMedium,
                  ),
                ),
              ),
              Text(
                context.l10n.pathMonstersCount(defeated, tables.length),
                style: textTheme.labelLarge?.copyWith(
                  color: context.palette.mutedText,
                ),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double width =
                  (constraints.maxWidth - _gap * (_columns - 1)) / _columns;
              return Wrap(
                spacing: _gap,
                runSpacing: _gap,
                children: <Widget>[
                  for (final TablePathNode table in tables)
                    _Monster(
                      number: table.number,
                      width: width,
                      isDefeated: table.crown != TableCrown.none,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Monster extends StatelessWidget {
  const _Monster({
    required this.number,
    required this.width,
    required this.isDefeated,
  });

  static const double _drawingShare = 0.8;

  final int number;
  final double width;
  final bool isDefeated;

  @override
  Widget build(BuildContext context) {
    final Widget drawing = MonsterIllustration(
      number: number,
      width: width * _drawingShare,
    );
    return Semantics(
      label: isDefeated
          ? context.l10n.pathMonsterDefeatedSpoken(number)
          : context.l10n.pathMonsterHiddenSpoken(number),
      child: SizedBox(
        width: width,
        child: Center(
          child: isDefeated
              ? drawing
              : ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    context.palette.lockedFace,
                    BlendMode.srcIn,
                  ),
                  child: drawing,
                ),
        ),
      ),
    );
  }
}
