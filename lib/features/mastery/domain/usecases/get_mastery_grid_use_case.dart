import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_mastery_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/entities/mastery_grid_entity.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:kid_matix/features/mastery/domain/services/mastery_policy.dart';
import 'package:kid_matix/features/mastery/domain/usecases/mastery_scope.dart';

/// Returns the status of every item of a domain for a player, items never
/// presented included.
///
/// Fails with a `ValidationException` when the domain is unknown.
class GetMasteryGridUseCase
    implements UseCase<DataState<MasteryGridEntity>, MasteryScope> {
  /// Creates the use case.
  const GetMasteryGridUseCase({
    required this._repository,
    required this._domains,
    this._policy = const MasteryPolicy(),
  });

  final ItemProgressRepository _repository;
  final DomainRegistry _domains;
  final MasteryPolicy _policy;

  @override
  Future<DataState<MasteryGridEntity>> call({
    required MasteryScope params,
  }) async {
    final LearningDomain? domain = _domains.find(params.domainId);
    if (domain == null) {
      return const DataFailed<MasteryGridEntity>(
        ValidationException(message: 'Unknown domain.'),
      );
    }
    final DataState<List<ItemProgressEntity>> progress = await _repository
        .getProgress(profileId: params.profileId, domainId: domain.id);
    return switch (progress) {
      DataSuccess<List<ItemProgressEntity>>(:final data) =>
        DataSuccess<MasteryGridEntity>(_buildGrid(params, domain, data)),
      DataFailed<List<ItemProgressEntity>>(:final exception) =>
        DataFailed<MasteryGridEntity>(exception),
    };
  }

  MasteryGridEntity _buildGrid(
    MasteryScope scope,
    LearningDomain domain,
    List<ItemProgressEntity> progress,
  ) {
    final Map<String, ItemProgressEntity> byKey = <String, ItemProgressEntity>{
      for (final ItemProgressEntity item in progress) item.itemKey: item,
    };
    ItemMasteryEntity cellOf(LearningItem item) => ItemMasteryEntity(
      itemKey: item.key,
      status: _policy.statusOf(
        byKey[item.key] ??
            ItemProgressEntity.notSeen(
              profileId: scope.profileId,
              domainId: domain.id,
              itemKey: item.key,
            ),
      ),
    );
    return MasteryGridEntity(
      domainId: domain.id,
      rows: <String, List<ItemMasteryEntity>>{
        for (final LearningUnit unit in domain.units)
          unit.key: unit.items.map(cellOf).toList(),
      },
    );
  }
}
