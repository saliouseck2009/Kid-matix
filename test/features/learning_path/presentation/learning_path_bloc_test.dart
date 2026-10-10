import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/learning_path_state.dart';

import '../../../helpers/test_path_pages.dart';

const LearningPathParams _params = LearningPathParams(
  profileId: 'p1',
  domainId: 'multiplication',
);

StageProgressEntity _done(String unitKey, StageKind stage) {
  return StageProgressEntity(
    profileId: 'p1',
    domainId: 'multiplication',
    unitKey: unitKey,
    stage: stage,
    bestStars: 2,
    bestScore: 8,
    completedAt: DateTime(2026, 10, 10),
  );
}

/// A repository whose every read fails.
final class _BrokenRepository implements StageProgressRepository {
  @override
  Stream<void> watchChanges() => const Stream<void>.empty();

  @override
  Future<DataState<List<StageProgressEntity>>> getProgress({
    required String profileId,
    required String domainId,
  }) async {
    return const DataFailed<List<StageProgressEntity>>(CacheException());
  }
}

String? _currentOf(LearningPathState state) {
  return switch (state) {
    LearningPathLoaded(:final LearningPathEntity path) =>
      path.currentTable?.unitKey,
    _ => null,
  };
}

void main() {
  group('LearningPathBloc', () {
    blocTest<LearningPathBloc, LearningPathState>(
      'loads the path of a new player on the table of 1',
      build: () => LearningPathBloc(
        params: _params,
        useCases: buildTestPathUseCases(),
      ),
      act: (LearningPathBloc bloc) => bloc.add(const LearningPathStarted()),
      expect: () => <Matcher>[
        isA<LearningPathLoading>(),
        predicate<LearningPathState>(
          (LearningPathState state) => _currentOf(state) == 'mul:1',
        ),
      ],
    );

    final InMemoryStageProgressRepository inputRepository =
        InMemoryStageProgressRepository();
    blocTest<LearningPathBloc, LearningPathState>(
      'reloads the path after a session, told by the change signal',
      build: () => LearningPathBloc(
        params: _params,
        useCases: buildTestPathUseCases(repository: inputRepository),
      ),
      act: (LearningPathBloc bloc) async {
        bloc.add(const LearningPathStarted());
        await pumpEventQueue();
        inputRepository.progress.add(_done('mul:1', StageKind.writing));
        inputRepository.notifyChanged();
      },
      skip: 2,
      expect: () => <Matcher>[
        predicate<LearningPathState>(
          (LearningPathState state) => _currentOf(state) == 'mul:2',
        ),
      ],
    );

    blocTest<LearningPathBloc, LearningPathState>(
      'tells when the path cannot be read',
      build: () => LearningPathBloc(
        params: _params,
        useCases: buildTestPathUseCases(repository: _BrokenRepository()),
      ),
      act: (LearningPathBloc bloc) => bloc.add(const LearningPathStarted()),
      expect: () => <Matcher>[
        isA<LearningPathLoading>(),
        isA<LearningPathFailure>().having(
          (LearningPathFailure state) => state.errorCode,
          'errorCode',
          AppErrorCode.cache,
        ),
      ],
    );
  });
}
