import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';

StageProgressEntity _progress({int bestStars = 2}) {
  return StageProgressEntity(
    profileId: 'p1',
    domainId: 'multiplication',
    unitKey: 'mul:5',
    stage: StageKind.training,
    bestStars: bestStars,
    bestScore: 9,
    completedAt: DateTime(2026, 10, 10),
  );
}

void main() {
  group('StageProgressEntity', () {
    test('equals a progress with the same values', () {
      // Arrange
      final StageProgressEntity inputProgress = _progress();
      final StageProgressEntity expectedProgress = _progress();
      // Act
      final bool actualIsEqual = inputProgress == expectedProgress;
      // Assert
      expect(actualIsEqual, isTrue);
      expect(inputProgress.hashCode, expectedProgress.hashCode);
    });

    test('differs from a progress with other stars', () {
      // Arrange
      final StageProgressEntity inputProgress = _progress();
      // Act
      final bool actualIsEqual = inputProgress == _progress(bestStars: 3);
      // Assert
      expect(actualIsEqual, isFalse);
    });
  });

  group('StageSource', () {
    test('equals a source of the same stage and prints its key', () {
      // Arrange
      const StageSource inputSource = StageSource(
        unitKey: 'mul:5',
        stage: StageKind.boss,
      );
      const String expectedKey = 'path:mul:5:boss';
      // Act
      final StageSource? actualSource = StageSource.tryParse(expectedKey);
      // Assert
      expect(actualSource, inputSource);
      expect(actualSource.hashCode, inputSource.hashCode);
      expect(inputSource.toString(), expectedKey);
    });

    test('differs from a source of another stage', () {
      // Arrange
      const StageSource inputSource = StageSource(
        unitKey: 'mul:5',
        stage: StageKind.boss,
      );
      // Act
      final bool actualIsEqual =
          inputSource ==
          const StageSource(unitKey: 'mul:5', stage: StageKind.speed);
      // Assert
      expect(actualIsEqual, isFalse);
    });
  });
}
