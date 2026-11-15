import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/placement_result_repository.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';

import '../../../helpers/in_memory_local_storage.dart';
import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_path_pages.dart';

/// A placement history that recommended the division.
final class _DivisionRecommended implements PlacementResultRepository {
  @override
  Future<DataState<List<PlacementResultEntity>>> getHistory({
    required String profileId,
  }) async {
    return DataSuccess<List<PlacementResultEntity>>(<PlacementResultEntity>[
      PlacementResultEntity(
        takenAt: DateTime(2026, 11, 1),
        domains: const <DomainResultEntity>[
          DomainResultEntity(
            domainId: 'division',
            level: 0,
            skillCount: 2,
            unitCount: 0,
            startUnitKey: 'div:2',
          ),
        ],
      ),
    ]);
  }

  @override
  Future<DataState<void>> save({
    required String profileId,
    required PlacementOutcome outcome,
  }) async => const DataSuccess<void>(null);

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

StageProgressEntity _done(String domainId, String unitKey) {
  return StageProgressEntity(
    profileId: 'p1',
    domainId: domainId,
    unitKey: unitKey,
    stage: StageKind.writing,
    bestStars: 3,
    bestScore: 10,
    completedAt: DateTime(2026, 11, 1),
  );
}

void main() {
  late InMemoryLocalStorage storage;
  late LearningPathPages pages;

  setUp(() {
    storage = InMemoryLocalStorage();
    pages = buildTestPathPages(
      storage: storage,
      results: _DivisionRecommended(),
      repository: InMemoryStageProgressRepository(<StageProgressEntity>[
        _done('multiplication', 'mul:1'),
        _done('multiplication', 'mul:2'),
        for (final String key in <String>[
          'num:count10',
          'num:count20',
          'num:count100',
          'num:tensones',
          'num:compare',
          'num:order',
          'num:beforeafter',
        ])
          _done('numbers', key),
      ]),
    );
  });

  Future<void> pumpMap(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      pages.buildLearningPathPage(
        profileId: 'p1',
        onOpenTable: (_) {},
        onPlay: (_) {},
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('Changer'));
    await tester.pumpAndSettle();
  }

  testWidgets('the map shows the domain followed and « Changer »', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpMap(tester);
    // Assert
    expect(find.text('Multiplication'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Parcours Multiplication. Changer de parcours'),
      findsOneWidget,
    );
    expect(find.text('Mes parcours'), findsNothing);
  });

  testWidgets('lists every domain with its progress and badge', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpMap(tester);
    // Act
    await openSheet(tester);
    // Assert
    expect(find.text('Mes parcours'), findsOneWidget);
    expect(find.text('Touche un parcours pour le suivre.'), findsOneWidget);
    expect(find.text('En cours'), findsOneWidget);
    expect(find.text('2 / 12'), findsOneWidget);
    expect(find.text('Terminé'), findsOneWidget);
    expect(find.text('7 / 7'), findsOneWidget);
    expect(find.text('Conseillé'), findsOneWidget);
    expect(find.text('Pas encore commencé'), findsNWidgets(4));
    expect(find.text('Problèmes'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp('^Multiplication\\nEn cours\\n2 sur 12 terminées'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping a domain follows it and closes the sheet', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpMap(tester);
    await openSheet(tester);
    // Act
    await tester.tap(find.text('Division').last);
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Mes parcours'), findsNothing);
    expect(await storage.readString(key: 'path_domain.p1'), 'division');
    expect(find.text('Division'), findsOneWidget);
    expect(find.text('Multiplication'), findsNothing);
  });

  testWidgets('the cross closes the sheet without changing the domain', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpMap(tester);
    await openSheet(tester);
    // Act
    await tester.tap(find.byTooltip('Fermer'));
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Mes parcours'), findsNothing);
    expect(await storage.readString(key: 'path_domain.p1'), isNull);
  });

  testWidgets('fits a small phone at a large text size', (
    WidgetTester tester,
  ) async {
    // Arrange
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpMap(tester);
    tester.view.physicalSize = const Size(1080, 1920);
    await tester.pumpAndSettle();
    // Act
    await openSheet(tester);
    // Assert
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Problèmes'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
