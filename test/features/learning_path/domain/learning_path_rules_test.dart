import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/services/learning_path_builder.dart';
import 'package:kid_matix/features/learning_path/domain/services/star_policy.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

const StarPolicy _stars = StarPolicy();
const LearningPathBuilder _builder = LearningPathBuilder();
final List<LearningUnit> _units = MultiplicationDomain().path;

StageProgressEntity _done(String unitKey, StageKind stage, {int stars = 1}) {
  return StageProgressEntity(
    profileId: 'p1',
    domainId: 'multiplication',
    unitKey: unitKey,
    stage: stage,
    bestStars: stars,
    bestScore: 7,
    completedAt: DateTime(2026, 10, 10),
  );
}

LearningPathEntity _build(
  List<StageProgressEntity> progress, {
  bool isEverythingUnlocked = false,
}) {
  return _builder.build(
    domainId: 'multiplication',
    units: _units,
    progress: progress,
    isEverythingUnlocked: isEverythingUnlocked,
  );
}

List<String> _statuses(LearningPathEntity path) =>
    path.tables.map((TablePathNode table) => table.status.name).toList();

void main() {
  group('StarPolicy', () {
    final Map<int, int> expectedStars = <int, int>{
      0: 0,
      5: 0,
      6: 1,
      7: 1,
      8: 2,
      9: 2,
      10: 3,
    };
    for (final MapEntry<int, int> entry in expectedStars.entries) {
      test('gives ${entry.value} stars for ${entry.key} out of 10', () {
        // Act
        final int actualStars = _stars.starsFor(
          correctCount: entry.key,
          questionCount: 10,
        );
        // Assert
        expect(actualStars, entry.value);
      });
    }
    test('counts the 15 questions of a review', () {
      // Assert
      expect(_stars.starsFor(correctCount: 9, questionCount: 15), 1);
      expect(_stars.starsFor(correctCount: 12, questionCount: 15), 2);
      expect(_stars.starsFor(correctCount: 14, questionCount: 15), 2);
    });
    test('gives nothing for a quiz without questions', () {
      // Assert
      expect(_stars.starsFor(correctCount: 0, questionCount: 0), 0);
    });
  });

  group('LearningPathBuilder', () {
    test('opens only the first stage of the first table for a new player', () {
      // Act
      final LearningPathEntity actualPath = _build(
        const <StageProgressEntity>[],
      );
      // Assert
      final TablePathNode actualFirst = actualPath.tables.first;
      expect(actualFirst.unitKey, 'mul:1');
      expect(actualFirst.status, TableStatus.current);
      expect(
        actualFirst.stages.map((StageState stage) => stage.isPlayable),
        <bool>[true, false, false, false, false],
      );
      expect(actualFirst.nextStage?.kind, StageKind.discovery);
      expect(_statuses(actualPath).skip(1).toSet(), <String>{'locked'});
    });
    test('opens a stage once the previous one has a star', () {
      // Act
      final TablePathNode actualTable = _build(<StageProgressEntity>[
        _done('mul:1', StageKind.discovery),
      ]).tables.first;
      // Assert
      expect(actualTable.stageOf(StageKind.training).isPlayable, isTrue);
      expect(actualTable.stageOf(StageKind.writing).isPlayable, isFalse);
      expect(actualTable.nextStage?.kind, StageKind.training);
    });
    test('keeps a stage with no star closed after it', () {
      // Act
      final TablePathNode actualTable = _build(<StageProgressEntity>[
        _done('mul:1', StageKind.discovery, stars: 0),
      ]).tables.first;
      // Assert
      expect(actualTable.stageOf(StageKind.training).isPlayable, isFalse);
    });
    test('opens the next table once stage 3 has a star', () {
      // Act
      final LearningPathEntity actualPath = _build(<StageProgressEntity>[
        _done('mul:1', StageKind.discovery),
        _done('mul:1', StageKind.training),
        _done('mul:1', StageKind.writing),
      ]);
      // Assert
      expect(_statuses(actualPath).take(3), <String>[
        'done',
        'current',
        'locked',
      ]);
      expect(actualPath.tables.first.nextStage?.kind, StageKind.speed);
      expect(actualPath.currentTable?.unitKey, 'mul:2');
    });
    test('follows the path order 1, 2, 10, 5, 3, 4, 6, 9, 7, 8, 11, 12', () {
      // Act
      final List<int> actualNumbers = _build(
        const <StageProgressEntity>[],
      ).tables.map((TablePathNode table) => table.number).toList();
      // Assert
      expect(actualNumbers, <int>[1, 2, 10, 5, 3, 4, 6, 9, 7, 8, 11, 12]);
    });
    test('keeps the boss fight closed until it is delivered', () {
      // Act
      final TablePathNode actualTable = _build(<StageProgressEntity>[
        for (final StageKind stage in <StageKind>[
          StageKind.discovery,
          StageKind.training,
          StageKind.writing,
          StageKind.speed,
        ])
          _done('mul:1', stage),
      ]).tables.first;
      // Assert
      final StageState actualBoss = actualTable.stageOf(StageKind.boss);
      expect(actualBoss.isUnlocked, isTrue);
      expect(actualBoss.isComingSoon, isTrue);
      expect(actualBoss.isPlayable, isFalse);
      expect(actualTable.nextStage, isNull);
    });
    test('puts a review after every group of 3 tables', () {
      // Act
      final LearningPathEntity actualPath = _build(
        const <StageProgressEntity>[],
      );
      // Assert
      final List<String> actualKeys = actualPath.nodes
          .map((PathNode node) => node.unitKey)
          .toList();
      expect(actualKeys.indexOf('review:1'), 3);
      expect(
        actualKeys.where((String key) => key.startsWith('review')),
        <String>[
          'review:1',
          'review:2',
          'review:3',
          'review:4',
        ],
      );
      expect(actualPath.findReview('review:2')?.tableKeys, hasLength(6));
    });
    test(
      'opens a review with the last table of its group, without locking',
      () {
        // Arrange
        final List<StageProgressEntity> inputProgress = <StageProgressEntity>[
          for (final String unitKey in <String>['mul:1', 'mul:2', 'mul:10'])
            for (final StageKind stage in <StageKind>[
              StageKind.discovery,
              StageKind.training,
              StageKind.writing,
            ])
              _done(unitKey, stage),
        ];
        // Act
        final LearningPathEntity actualPath = _build(inputProgress);
        // Assert
        expect(actualPath.findReview('review:1')?.stage.isPlayable, isTrue);
        expect(actualPath.findReview('review:2')?.stage.isPlayable, isFalse);
        expect(actualPath.currentTable?.unitKey, 'mul:5');
      },
    );
    test('opens every table and stage with "Tout débloquer"', () {
      // Act
      final LearningPathEntity actualPath = _build(
        const <StageProgressEntity>[],
        isEverythingUnlocked: true,
      );
      // Assert
      expect(_statuses(actualPath).first, 'current');
      expect(_statuses(actualPath).skip(1).toSet(), <String>{'open'});
      final TablePathNode actualLast = actualPath.tables.last;
      expect(actualLast.stageOf(StageKind.speed).isPlayable, isTrue);
      expect(actualLast.stageOf(StageKind.boss).isPlayable, isFalse);
      expect(actualPath.findReview('review:4')?.stage.isPlayable, isTrue);
    });
    test('keeps the last table current once every table is done', () {
      // Arrange
      final List<StageProgressEntity> inputProgress = <StageProgressEntity>[
        for (final LearningUnit unit in _units)
          _done(unit.key, StageKind.writing),
      ];
      // Act
      final LearningPathEntity actualPath = _build(inputProgress);
      // Assert
      expect(actualPath.currentTable?.unitKey, 'mul:12');
      expect(
        _statuses(actualPath).where((String s) => s == 'done'),
        hasLength(11),
      );
    });
    test('adds up the stars of a table', () {
      // Act
      final TablePathNode actualTable = _build(<StageProgressEntity>[
        _done('mul:1', StageKind.discovery, stars: 3),
        _done('mul:1', StageKind.training, stars: 2),
      ]).tables.first;
      // Assert
      expect(actualTable.totalStars, 5);
      expect(actualTable.averageStars, 2);
      expect(actualTable.maxStars, 15);
    });
  });

  group('StageSource', () {
    test('writes and reads a source key', () {
      // Arrange
      const StageSource inputSource = StageSource(
        unitKey: 'mul:5',
        stage: StageKind.training,
      );
      // Act
      final String actualKey = inputSource.toKey();
      // Assert
      expect(actualKey, 'path:mul:5:training');
      expect(StageSource.tryParse(actualKey), inputSource);
      expect(
        StageSource.tryParse('path:review:2:review'),
        const StageSource(unitKey: 'review:2', stage: StageKind.review),
      );
    });
    test('ignores a key that is not a stage', () {
      // Assert
      expect(StageSource.tryParse(null), isNull);
      expect(StageSource.tryParse('duel:1'), isNull);
      expect(StageSource.tryParse('path:mul:5:dance'), isNull);
      expect(StageSource.tryParse('path:training'), isNull);
    });
  });
}
