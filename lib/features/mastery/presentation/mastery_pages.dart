import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_grid_entity.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_mastery_grid_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_monsters_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';
import 'package:kid_matix/features/mastery/domain/usecases/watch_mastery_changes_use_case.dart';
import 'package:kid_matix/features/mastery/presentation/bloc/mastery_grid_cubit.dart';
import 'package:kid_matix/features/mastery/presentation/bloc/monsters_cubit.dart';
import 'package:kid_matix/features/mastery/presentation/pages/monsters_page.dart';
import 'package:kid_matix/features/mastery/presentation/widgets/mastery_grid_card.dart';
import 'package:kid_matix/features/mastery/presentation/widgets/monster_labels.dart';

/// Builds the widgets and pages of the mastery feature for the router.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class MasteryPages {
  /// Creates the factory.
  const MasteryPages({
    required this._getGrid,
    required this._getMonsters,
    required this._watchChanges,
    required this._domains,
  });

  /// Domain of « Mes monstres », the little monsters: the hunt it starts
  /// is a challenge of the multiplication.
  static const String littleMonstersDomainId = LearningDomainIds.multiplication;

  final GetMasteryGridUseCase _getGrid;
  final GetMonstersUseCase _getMonsters;
  final WatchMasteryChangesUseCase _watchChanges;
  final DomainRegistry _domains;

  /// "Mes tables" or "Mes nombres": the mastery grid of [profileId] in
  /// [domainId], the multiplication by default.
  Widget buildGridCard({
    required String profileId,
    String domainId = LearningDomainIds.multiplication,
  }) {
    final LearningDomain? domain = _domains.find(domainId);
    if (domain == null) return const SizedBox.shrink();
    return BlocProvider<MasteryGridCubit>(
      key: ValueKey<String>('mastery-$profileId-$domainId'),
      create: (_) => MasteryGridCubit(
        scope: MasteryScope(profileId: profileId, domainId: domainId),
        getGrid: _getGrid,
        watchChanges: _watchChanges,
      )..load(),
      child: BlocBuilder<MasteryGridCubit, MasteryGridEntity?>(
        builder: (BuildContext context, MasteryGridEntity? grid) => grid == null
            ? const SizedBox.shrink()
            : MasteryGridCard(grid: grid, domain: domain),
      ),
    );
  }

  /// « Mes monstres » of [profileId]: [onHunt] starts a hunt of
  /// [huntQuestionCount] questions, [onBack] goes back.
  Widget buildMonstersPage({
    required String profileId,
    required int huntQuestionCount,
    required VoidCallback onBack,
    required VoidCallback onHunt,
  }) {
    final LearningDomain? domain = _domains.find(littleMonstersDomainId);
    if (domain == null) return const SizedBox.shrink();
    return BlocProvider<MonstersCubit>(
      key: ValueKey<String>('monsters-$profileId'),
      create: (_) => MonstersCubit(
        scope: MasteryScope(
          profileId: profileId,
          domainId: littleMonstersDomainId,
        ),
        getMonsters: _getMonsters,
        watchChanges: _watchChanges,
      )..load(),
      child: Builder(
        builder: (BuildContext context) => MonstersPage(
          labels: MonsterLabels(domain: domain, l10n: context.l10n),
          huntQuestionCount: huntQuestionCount,
          onBack: onBack,
          onHunt: onHunt,
        ),
      ),
    );
  }
}
