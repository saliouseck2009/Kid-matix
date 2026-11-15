import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/core/storage/local_storage.dart';
import 'package:kid_matix/features/learning_path/data/datasources/path_domain_local_data_source_impl.dart';
import 'package:kid_matix/features/learning_path/data/repositories/path_domain_repository_impl.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/path_domain_repository.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_domain_choice_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_path_overview_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/select_domain_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_domain_choice_use_case.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/domain_choice_use_cases.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/answer_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/build_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/save_placement_result_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_placement_history_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_placement_results_use_case.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_history_use_cases.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/placement_result_repository.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_learning_path_changes_use_case.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_use_cases.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';

import '../features/quiz/helpers/quiz_fixtures.dart';
import 'fake_mastery_service.dart';
import 'in_memory_local_storage.dart';
import 'test_quiz_pages.dart';
import 'no_assigned_units.dart';

/// [StageProgressRepository] over a list the test fills, which tells its
/// watchers when [notifyChanged] is called.
final class InMemoryStageProgressRepository implements StageProgressRepository {
  /// Creates the repository holding [progress].
  InMemoryStageProgressRepository([
    List<StageProgressEntity> progress = const <StageProgressEntity>[],
  ]) : progress = List<StageProgressEntity>.of(progress);

  /// Stored stages.
  final List<StageProgressEntity> progress;

  /// Units opened by the placement test.
  final Set<String> placedUnitKeys = <String>{};

  /// Failure of [openUnit], or `null` for success.
  AppException? openFailure;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Tells the watchers that [progress] changed.
  void notifyChanged() => _changes.add(null);

  @override
  Future<DataState<List<StageProgressEntity>>> getProgress({
    required String profileId,
    required String domainId,
  }) async {
    return DataSuccess<List<StageProgressEntity>>(<StageProgressEntity>[
      for (final StageProgressEntity stage in progress)
        if (stage.domainId == domainId) stage,
    ]);
  }

  @override
  Future<DataState<Set<String>>> getPlacedUnitKeys({
    required String profileId,
    required String domainId,
  }) async {
    return DataSuccess<Set<String>>(Set<String>.of(placedUnitKeys));
  }

  @override
  Future<DataState<void>> openUnit({
    required String profileId,
    required String domainId,
    required String unitKey,
  }) async {
    final AppException? failure = openFailure;
    if (failure != null) return DataFailed<void>(failure);
    placedUnitKeys.add(unitKey);
    notifyChanged();
    return const DataSuccess<void>(null);
  }

  @override
  Stream<void> watchChanges() => _changes.stream;
}

/// [PlacementResultRepository] over a list, dated by [clock].
final class InMemoryPlacementResultRepository
    implements PlacementResultRepository {
  /// Creates the repository, which dates results with [clock], a stopped
  /// clock by default.
  InMemoryPlacementResultRepository({Clock? clock})
    : clock = clock ?? FakeClock(quizStart);

  /// Dates the results.
  final Clock clock;

  /// Results kept, oldest first.
  final List<({String profileId, DateTime takenAt, PlacementOutcome outcome})>
  saved = <({String profileId, DateTime takenAt, PlacementOutcome outcome})>[];

  /// Failure of [save], or `null` for success.
  AppException? saveFailure;

  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<DataState<void>> save({
    required String profileId,
    required PlacementOutcome outcome,
  }) async {
    final AppException? failure = saveFailure;
    if (failure != null) return DataFailed<void>(failure);
    saved.add((profileId: profileId, takenAt: clock.now(), outcome: outcome));
    _changes.add(null);
    return const DataSuccess<void>(null);
  }

  @override
  Future<DataState<List<PlacementResultEntity>>> getHistory({
    required String profileId,
  }) async {
    return DataSuccess<List<PlacementResultEntity>>(<PlacementResultEntity>[
      for (final result in saved.reversed)
        if (result.profileId == profileId)
          PlacementResultEntity(
            takenAt: result.takenAt,
            domains: <DomainResultEntity>[
              for (final DomainLevel level in result.outcome.domains)
                DomainResultEntity(
                  domainId: level.domainId,
                  level: level.level,
                  skillCount: level.skillCount,
                  unitCount: level.openedUnitKeys.length,
                  startUnitKey:
                      level.domainId == result.outcome.recommendedDomainId
                      ? result.outcome.recommendedUnitKey
                      : null,
                ),
            ],
          ),
    ]);
  }

  @override
  Stream<void> watchChanges() => _changes.stream;
}

/// Use cases of the learning path over [repository] and [settings].
LearningPathUseCases buildTestPathUseCases({
  StageProgressRepository? repository,
  PlayerSettingsService settings = const FixedPlayerSettings(),
  PlacementResultRepository? placements,
}) {
  final StageProgressRepository stages =
      repository ?? InMemoryStageProgressRepository();
  return LearningPathUseCases(
    getLearningPath: GetLearningPathUseCase(
      assigned: const NoAssignedUnits(),
      repository: stages,
      domains: buildDomainRegistry(),
      settings: settings,
      mastery: FakeMasteryService(),
      placements: placements ?? InMemoryPlacementResultRepository(),
    ),
    watchChanges: WatchLearningPathChangesUseCase(repository: stages),
  );
}

/// Use cases of the placement test over [repository], [mastery] and
/// [results], with questions drawn from [seed]; the domain recommended is
/// chosen in [storage].
PlacementUseCases buildTestPlacementUseCases({
  required StageProgressRepository repository,
  MasteryService? mastery,
  PlacementResultRepository? results,
  LocalStorage? storage,
  int seed = 1,
}) {
  return PlacementUseCases(
    buildQuestion: BuildPlacementQuestionUseCase(
      domains: buildDomainRegistry(),
      random: DartRandomSource(seed: seed),
    ),
    answerQuestion: AnswerPlacementQuestionUseCase(
      repository: repository,
      mastery: mastery ?? FakeMasteryService(),
    ),
    saveResult: SavePlacementResultUseCase(
      stages: repository,
      results:
          results ??
          InMemoryPlacementResultRepository(clock: FakeClock(quizStart)),
      domains: PathDomainRepositoryImpl(
        domains: PathDomainLocalDataSourceImpl(
          storage: storage ?? InMemoryLocalStorage(),
        ),
      ),
    ),
  );
}

/// « Mes parcours » over the paths of [repository] and the placement
/// tests of [results].
GetPathOverviewUseCase buildTestOverviewUseCase({
  StageProgressRepository? repository,
  PlayerSettingsService settings = const FixedPlayerSettings(),
  PlacementResultRepository? results,
}) {
  final PlacementResultRepository placements =
      results ?? InMemoryPlacementResultRepository();
  return GetPathOverviewUseCase(
    getLearningPath: buildTestPathUseCases(
      repository: repository,
      settings: settings,
      placements: placements,
    ).getLearningPath,
    placements: placements,
    domains: buildDomainRegistry(),
  );
}

/// Use cases of the domain choice over [storage], the device preferences
/// of the test; « Mes parcours » reads [repository] and [results].
DomainChoiceUseCases buildTestDomainChoiceUseCases({
  LocalStorage? storage,
  StageProgressRepository? repository,
  PlayerSettingsService settings = const FixedPlayerSettings(),
  PlacementResultRepository? results,
}) {
  final PathDomainRepository domainRepository = PathDomainRepositoryImpl(
    domains: PathDomainLocalDataSourceImpl(
      storage: storage ?? InMemoryLocalStorage(),
    ),
  );
  return DomainChoiceUseCases(
    getChoice: GetDomainChoiceUseCase(
      repository: domainRepository,
      domains: buildDomainRegistry(),
    ),
    selectDomain: SelectDomainUseCase(repository: domainRepository),
    watchChoice: WatchDomainChoiceUseCase(repository: domainRepository),
    getOverview: buildTestOverviewUseCase(
      repository: repository,
      settings: settings,
      results: results,
    ),
  );
}

/// Learning path pages over the real domains of the app; the domain
/// choices go to [storage].
LearningPathPages buildTestPathPages({
  StageProgressRepository? repository,
  PlayerSettingsService settings = const FixedPlayerSettings(),
  MasteryService? mastery,
  LocalStorage? storage,
  PlacementResultRepository? results,
}) {
  final StageProgressRepository stages =
      repository ?? InMemoryStageProgressRepository();
  final LocalStorage domainStorage = storage ?? InMemoryLocalStorage();
  final PlacementResultRepository placementResults =
      results ?? InMemoryPlacementResultRepository(clock: FakeClock(quizStart));
  return LearningPathPages(
    useCases: buildTestPathUseCases(
      repository: stages,
      settings: settings,
      placements: placementResults,
    ),
    placement: buildTestPlacementUseCases(
      repository: stages,
      mastery: mastery,
      results: placementResults,
      storage: domainStorage,
    ),
    placementHistory: PlacementHistoryUseCases(
      getHistory: GetPlacementHistoryUseCase(repository: placementResults),
      watchResults: WatchPlacementResultsUseCase(repository: placementResults),
    ),
    domainChoice: buildTestDomainChoiceUseCases(
      storage: domainStorage,
      repository: stages,
      settings: settings,
      results: placementResults,
    ),
    domains: buildDomainRegistry(),
    clock: FakeClock(quizStart),
  );
}

/// Opens « Mes parcours » with the domain button and taps the card of the
/// domain named [name], such as « Nombres ».
Future<void> chooseDomain(WidgetTester tester, String name) async {
  await tester.tap(find.text('Changer'));
  await tester.pumpAndSettle();
  final Finder card = find.text(name).last;
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(card);
  await tester.pumpAndSettle();
}
