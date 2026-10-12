import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/mastery/domain/entities/monster_collection_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/monster_entity.dart';
import 'package:kid_matix/features/mastery/presentation/bloc/monsters_cubit.dart';
import 'package:kid_matix/features/mastery/presentation/bloc/monsters_state.dart';
import 'package:kid_matix/features/mastery/presentation/widgets/monster_labels.dart';
import 'package:kid_matix/features/mastery/presentation/widgets/tamed_monsters_card.dart';
import 'package:kid_matix/features/mastery/presentation/widgets/wild_monster_card.dart';

/// « Mes monstres »: the facts the player keeps missing as little
/// monsters, the button of the hunt, and the tamed monsters.
class MonstersPage extends StatelessWidget {
  /// Creates the page; the monsters come from the enclosing Cubit.
  const MonstersPage({
    required this.labels,
    required this.huntQuestionCount,
    required this.onBack,
    required this.onHunt,
    super.key,
  });

  static const double _gap = 14;
  static const double _cardGap = 10;

  /// Texts of the monsters.
  final MonsterLabels labels;

  /// Questions of a hunt, shown on its button.
  final int huntQuestionCount;

  /// Goes back to where the screen was opened.
  final VoidCallback onBack;

  /// Starts the monster hunt.
  final VoidCallback onHunt;

  @override
  Widget build(BuildContext context) {
    final MonstersState state = context.watch<MonstersCubit>().state;
    final MonsterCollectionEntity? monsters = switch (state) {
      MonstersLoaded(:final monsters) => monsters,
      _ => null,
    };
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.space24,
                  AppSizes.space24,
                  AppSizes.space24,
                  0,
                ),
                sliver: SliverList.list(
                  children: <Widget>[
                    _Header(onBack: onBack),
                    const SizedBox(height: _gap),
                    switch (state) {
                      MonstersLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      MonstersFailure(:final errorCode) => Text(
                        labels.errorOf(errorCode),
                      ),
                      MonstersLoaded(:final monsters) => _WildMonsters(
                        monsters: monsters.wild,
                        labels: labels,
                        huntQuestionCount: huntQuestionCount,
                        onHunt: onHunt,
                      ),
                    },
                  ],
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.space24),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: monsters == null || monsters.tamed.isEmpty
                        ? null
                        : TamedMonstersCard(
                            monsters: monsters.tamed,
                            labels: labels,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSizes.space12,
      children: <Widget>[
        AppIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: context.l10n.commonBack,
          onPressed: onBack,
        ),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              context.l10n.monstersPageTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ],
    );
  }
}

/// The monsters to tame and the button of the hunt, or an encouraging
/// line when there is none.
class _WildMonsters extends StatelessWidget {
  const _WildMonsters({
    required this.monsters,
    required this.labels,
    required this.huntQuestionCount,
    required this.onHunt,
  });

  final List<MonsterEntity> monsters;
  final MonsterLabels labels;
  final int huntQuestionCount;
  final VoidCallback onHunt;

  @override
  Widget build(BuildContext context) {
    final TextStyle? introStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: context.palette.mutedText);
    if (monsters.isEmpty) {
      return Text(context.l10n.monstersEmpty, style: introStyle);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: MonstersPage._cardGap,
      children: <Widget>[
        Text(context.l10n.monstersIntro, style: introStyle),
        const SizedBox(height: AppSizes.space4),
        for (final MonsterEntity monster in monsters)
          WildMonsterCard(
            key: ValueKey<String>(monster.itemKey),
            monster: monster,
            labels: labels,
          ),
        const SizedBox(height: AppSizes.space4),
        DepthButton(
          label: context.l10n.monstersHuntButton,
          caption: context.l10n.monstersHuntQuestions(huntQuestionCount),
          onPressed: onHunt,
        ),
      ],
    );
  }
}
