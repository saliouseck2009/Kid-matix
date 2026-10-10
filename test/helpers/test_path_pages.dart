import 'dart:async';

import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_learning_path_changes_use_case.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';

import '../features/quiz/helpers/quiz_fixtures.dart';
import 'test_quiz_pages.dart';

/// [StageProgressRepository] over a list the test fills, which tells its
/// watchers when [notifyChanged] is called.
final class InMemoryStageProgressRepository implements StageProgressRepository {
  /// Creates the repository holding [progress].
  InMemoryStageProgressRepository([
    List<StageProgressEntity> progress = const <StageProgressEntity>[],
  ]) : progress = List<StageProgressEntity>.of(progress);

  /// Stored stages.
  final List<StageProgressEntity> progress;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Tells the watchers that [progress] changed.
  void notifyChanged() => _changes.add(null);

  @override
  Future<DataState<List<StageProgressEntity>>> getProgress({
    required String profileId,
    required String domainId,
  }) async {
    return DataSuccess<List<StageProgressEntity>>(
      List<StageProgressEntity>.of(progress),
    );
  }

  @override
  Stream<void> watchChanges() => _changes.stream;
}

/// Use cases of the learning path over [repository] and [settings].
LearningPathUseCases buildTestPathUseCases({
  StageProgressRepository? repository,
  PlayerSettingsService settings = const FixedPlayerSettings(),
}) {
  final StageProgressRepository stages =
      repository ?? InMemoryStageProgressRepository();
  return LearningPathUseCases(
    getLearningPath: GetLearningPathUseCase(
      repository: stages,
      domains: buildDomainRegistry(),
      settings: settings,
    ),
    watchChanges: WatchLearningPathChangesUseCase(repository: stages),
  );
}

/// Learning path pages over the real multiplication domain.
LearningPathPages buildTestPathPages({
  StageProgressRepository? repository,
  PlayerSettingsService settings = const FixedPlayerSettings(),
}) {
  return LearningPathPages(
    useCases: buildTestPathUseCases(repository: repository, settings: settings),
    domains: buildDomainRegistry(),
  );
}
