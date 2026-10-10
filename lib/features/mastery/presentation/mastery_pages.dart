import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_grid_entity.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_mastery_grid_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';
import 'package:kid_matix/features/mastery/domain/usecases/watch_mastery_changes_use_case.dart';
import 'package:kid_matix/features/mastery/presentation/bloc/mastery_grid_cubit.dart';
import 'package:kid_matix/features/mastery/presentation/widgets/mastery_grid_card.dart';

/// Builds the widgets of the mastery feature for the router.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class MasteryPages {
  /// Creates the factory.
  const MasteryPages({
    required this._getGrid,
    required this._watchChanges,
    required this._domains,
  });

  /// Domain of the grid on the Profile tab.
  static const String domainId = LearningDomainIds.multiplication;

  final GetMasteryGridUseCase _getGrid;
  final WatchMasteryChangesUseCase _watchChanges;
  final DomainRegistry _domains;

  /// "Mes tables": the mastery grid of [profileId].
  Widget buildGridCard({required String profileId}) {
    final LearningDomain? domain = _domains.find(domainId);
    if (domain == null) return const SizedBox.shrink();
    return BlocProvider<MasteryGridCubit>(
      key: ValueKey<String>('mastery-$profileId'),
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
}
