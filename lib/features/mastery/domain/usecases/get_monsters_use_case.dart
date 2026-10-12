import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/monster_collection_entity.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:kid_matix/features/mastery/domain/services/monster_rule.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';

/// Returns the monsters of a player: the toughest facts still to tame,
/// and the tamed ones in the natural order of the domain.
///
/// Computed from the progress of the items, with no table of its own.
/// Fails with a `ValidationException` when the domain is unknown.
class GetMonstersUseCase
    implements UseCase<DataState<MonsterCollectionEntity>, MasteryScope> {
  /// Creates the use case.
  const GetMonstersUseCase({
    required this._repository,
    required this._domains,
    this._rule = const MonsterRule(),
  });

  final ItemProgressRepository _repository;
  final DomainRegistry _domains;
  final MonsterRule _rule;

  @override
  Future<DataState<MonsterCollectionEntity>> call({
    required MasteryScope params,
  }) async {
    final LearningDomain? domain = _domains.find(params.domainId);
    if (domain == null) {
      return const DataFailed<MonsterCollectionEntity>(
        ValidationException(message: 'Unknown domain.'),
      );
    }
    final DataState<List<ItemProgressEntity>> progress = await _repository
        .getProgress(profileId: params.profileId, domainId: domain.id);
    return switch (progress) {
      DataSuccess<List<ItemProgressEntity>>(:final data) =>
        DataSuccess<MonsterCollectionEntity>(_collect(domain, data)),
      DataFailed<List<ItemProgressEntity>>(:final exception) =>
        DataFailed<MonsterCollectionEntity>(exception),
    };
  }

  MonsterCollectionEntity _collect(
    LearningDomain domain,
    List<ItemProgressEntity> progress,
  ) {
    final Map<String, ItemProgressEntity> byKey = <String, ItemProgressEntity>{
      for (final ItemProgressEntity item in progress) item.itemKey: item,
    };
    return MonsterCollectionEntity(
      wild: _rule.wildOf(progress).map(_rule.monsterOf).toList(),
      tamed: <ItemProgressEntity>[
        for (final LearningUnit unit in domain.units)
          for (final LearningItem item in unit.items)
            if (byKey[item.key] case final ItemProgressEntity tracked
                when _rule.isTamed(tracked))
              tracked,
      ].map(_rule.monsterOf).toList(),
    );
  }
}
