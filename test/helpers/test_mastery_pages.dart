import 'dart:async';

import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';
import 'package:kid_matix/features/mastery/domain/repositories/item_progress_repository.dart';
import 'package:kid_matix/features/mastery/domain/usecases/get_mastery_grid_use_case.dart';
import 'package:kid_matix/features/mastery/domain/usecases/watch_mastery_changes_use_case.dart';
import 'package:kid_matix/features/mastery/presentation/mastery_pages.dart';

import '../features/quiz/helpers/quiz_fixtures.dart';

/// [ItemProgressRepository] kept in memory.
final class InMemoryItemProgressRepository implements ItemProgressRepository {
  /// Creates the repository holding [progress].
  InMemoryItemProgressRepository([
    List<ItemProgressEntity> progress = const <ItemProgressEntity>[],
  ]) : progress = List<ItemProgressEntity>.of(progress);

  /// Stored progress, of any player.
  final List<ItemProgressEntity> progress;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<DataState<List<ItemProgressEntity>>> getProgress({
    required String profileId,
    required String domainId,
  }) async {
    return DataSuccess<List<ItemProgressEntity>>(
      progress
          .where((ItemProgressEntity item) => item.profileId == profileId)
          .toList(),
    );
  }

  @override
  Future<DataState<ItemProgressEntity>> getItemProgress({
    required String profileId,
    required String domainId,
    required String itemKey,
  }) async {
    return DataSuccess<ItemProgressEntity>(
      progress.firstWhere(
        (ItemProgressEntity item) =>
            item.profileId == profileId && item.itemKey == itemKey,
        orElse: () => ItemProgressEntity.notSeen(
          profileId: profileId,
          domainId: domainId,
          itemKey: itemKey,
        ),
      ),
    );
  }

  @override
  Future<DataState<void>> saveProgress({
    required ItemProgressEntity progress,
  }) async {
    this.progress
      ..removeWhere(
        (ItemProgressEntity item) =>
            item.profileId == progress.profileId &&
            item.itemKey == progress.itemKey,
      )
      ..add(progress);
    _changes.add(null);
    return const DataSuccess<void>(null);
  }

  @override
  Stream<void> watchChanges() => _changes.stream;
}

/// Mastery pages over [repository], an empty one by default.
MasteryPages buildTestMasteryPages({ItemProgressRepository? repository}) {
  final ItemProgressRepository progress =
      repository ?? InMemoryItemProgressRepository();
  return MasteryPages(
    getGrid: GetMasteryGridUseCase(
      repository: progress,
      domains: buildDomainRegistry(),
    ),
    watchChanges: WatchMasteryChangesUseCase(repository: progress),
    domains: buildDomainRegistry(),
  );
}
