import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/services/open_units_service_impl.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../../../helpers/test_path_pages.dart';
import '../../../helpers/test_quiz_pages.dart';

void main() {
  OpenUnitsServiceImpl serviceOver(List<StageProgressEntity> progress) {
    return OpenUnitsServiceImpl(
      getPath: GetLearningPathUseCase(
        repository: InMemoryStageProgressRepository(progress),
        domains: DomainRegistry()..register(MultiplicationDomain()),
        settings: const FixedPlayerSettings(),
        mastery: FakeMasteryService(),
      ),
      domainId: 'multiplication',
    );
  }

  test('opens only the first table to a new player', () async {
    // Act
    final List<String> actualUnits = (await serviceOver(
      const <StageProgressEntity>[],
    ).readOpenUnitKeys(profileId: 'p1')).requireData;
    // Assert
    expect(actualUnits, <String>[MultiplicationDomain().path.first.key]);
  });
  test('opens the tables done and the current one', () async {
    // Arrange
    final List<StageProgressEntity> inputProgress = <StageProgressEntity>[
      for (final StageKind stage in <StageKind>[
        StageKind.discovery,
        StageKind.training,
        StageKind.writing,
      ])
        StageProgressEntity(
          profileId: 'p1',
          domainId: 'multiplication',
          unitKey: 'mul:1',
          stage: stage,
          bestStars: 3,
          bestScore: 10,
          completedAt: DateTime(2026, 10, 10),
        ),
    ];
    // Act
    final List<String> actualUnits = (await serviceOver(
      inputProgress,
    ).readOpenUnitKeys(profileId: 'p1')).requireData;
    // Assert
    expect(actualUnits, <String>[
      for (final LearningUnit unit in MultiplicationDomain().path.take(2))
        unit.key,
    ]);
  });
}
