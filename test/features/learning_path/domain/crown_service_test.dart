import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/services/crown_service_impl.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/watch_learning_path_changes_use_case.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../../../helpers/test_path_pages.dart';
import '../../../helpers/test_quiz_pages.dart';

void main() {
  test('counts the crowned tables of a player', () async {
    // Arrange
    final InMemoryStageProgressRepository inputRepository =
        InMemoryStageProgressRepository(<StageProgressEntity>[
          for (final String unitKey in <String>['mul:1', 'mul:2'])
            StageProgressEntity(
              profileId: 'p1',
              domainId: 'multiplication',
              unitKey: unitKey,
              stage: StageKind.boss,
              bestStars: 1,
              bestScore: 12,
              completedAt: DateTime(2026, 10, 10),
            ),
        ]);
    final CrownServiceImpl service = CrownServiceImpl(
      getPath: GetLearningPathUseCase(
        repository: inputRepository,
        domains: DomainRegistry()..register(MultiplicationDomain()),
        settings: const FixedPlayerSettings(),
        mastery: FakeMasteryService(),
      ),
      watchChanges: WatchLearningPathChangesUseCase(
        repository: inputRepository,
      ),
      domainId: 'multiplication',
    );
    // Act
    final int actualCrowns = (await service.readCrownCount(
      profileId: 'p1',
    )).requireData;
    // Assert
    expect(actualCrowns, 2);
    expect(service.watchChanges(), isA<Stream<void>>());
  });
}
