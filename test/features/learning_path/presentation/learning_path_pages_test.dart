import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_path_pages.dart';

StageProgressEntity _done(String unitKey, StageKind stage, {int stars = 3}) {
  return StageProgressEntity(
    profileId: 'p1',
    domainId: 'multiplication',
    unitKey: unitKey,
    stage: stage,
    bestStars: stars,
    bestScore: 10,
    completedAt: DateTime(2026, 10, 10),
  );
}

/// The table of 1 done up to stage 3, the table of 2 on its stage 2.
List<StageProgressEntity> _progress() {
  return <StageProgressEntity>[
    for (final StageKind stage in <StageKind>[
      StageKind.discovery,
      StageKind.training,
      StageKind.writing,
    ])
      _done('mul:1', stage),
    _done('mul:2', StageKind.discovery, stars: 1),
  ];
}

void main() {
  late LearningPathPages pages;
  late String? openedTable;
  late StageSource? playedStage;

  setUp(() {
    pages = buildTestPathPages(
      repository: InMemoryStageProgressRepository(_progress()),
    );
    openedTable = null;
    playedStage = null;
  });

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(tester, page);
    await tester.pumpAndSettle();
  }

  group('LearningPathPage', () {
    testWidgets('shows the done, current and locked tables', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpPage(
        tester,
        pages.buildLearningPathPage(
          profileId: 'p1',
          onOpenTable: (String unitKey) => openedTable = unitKey,
          onPlay: (StageSource source) => playedStage = source,
        ),
      );
      // Assert
      expect(
        find.bySemanticsLabel('Table de 1, terminée, 3 étoiles'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Table de 2, en cours'), findsOneWidget);
      expect(find.bySemanticsLabel('Table de 10, verrouillée'), findsOneWidget);
      expect(find.text('Étape 2 sur 5 · Entraînement'), findsOneWidget);
    });
    testWidgets('plays the next stage from the call card', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpPage(
        tester,
        pages.buildLearningPathPage(
          profileId: 'p1',
          onOpenTable: (String unitKey) => openedTable = unitKey,
          onPlay: (StageSource source) => playedStage = source,
        ),
      );
      // Act
      await tester.tap(find.text('Jouer'));
      await tester.tap(find.bySemanticsLabel(RegExp('^Table de 1,')));
      await tester.tap(find.bySemanticsLabel('Table de 10, verrouillée'));
      // Assert
      expect(
        playedStage,
        const StageSource(unitKey: 'mul:2', stage: StageKind.training),
      );
      expect(openedTable, 'mul:1');
    });
  });

  group('TableDetailPage', () {
    testWidgets('lists the five stages and plays the next one', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool isTableShown = false;
      await pumpPage(
        tester,
        pages.buildTableDetailPage(
          profileId: 'p1',
          unitKey: 'mul:2',
          onBack: () {},
          onPlay: (StageSource source) => playedStage = source,
          onShowTable: () => isTableShown = true,
        ),
      );
      // Act
      await tester.tap(find.text('Jouer'));
      await tester.tap(find.text('Voir la table'));
      // Assert
      expect(find.text('Table de 2'), findsOneWidget);
      expect(find.text('1 étoile sur 15'), findsOneWidget);
      expect(find.text('1 · Découverte'), findsOneWidget);
      expect(find.text('Entraînement'), findsOneWidget);
      expect(find.text('Écriture'), findsOneWidget);
      expect(find.text('5 · Combat de boss'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Bientôt disponible')),
        findsOneWidget,
      );
      expect(
        playedStage,
        const StageSource(unitKey: 'mul:2', stage: StageKind.training),
      );
      expect(isTableShown, isTrue);
    });
  });

  group('DiscoveryPage', () {
    testWidgets('shows the whole table and its tip, then plays', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool isPlayed = false;
      await pumpPage(
        tester,
        pages.buildDiscoveryPage(
          unitKey: 'mul:5',
          onClose: () {},
          onPlay: () => isPlayed = true,
        ),
      );
      // Act
      await tester.tap(find.text('À moi de jouer'));
      // Assert
      expect(find.text('Voici la table de 5'), findsOneWidget);
      expect(find.text('5 × 7'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
      expect(find.bySemanticsLabel('5 fois 10 égale 50'), findsOneWidget);
      expect(
        find.text(
          'Les résultats de la table de 5 finissent toujours par 0 ou par 5.',
        ),
        findsOneWidget,
      );
      expect(isPlayed, isTrue);
    });
    testWidgets('only shows the table from "Voir la table"', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpPage(
        tester,
        pages.buildDiscoveryPage(unitKey: 'mul:5', onClose: () {}),
      );
      // Assert
      expect(find.text('À moi de jouer'), findsNothing);
      expect(find.byTooltip('Retour'), findsOneWidget);
    });
  });

  group('LearningPathPages', () {
    test('turns a stage into its quiz and finds where to go back', () {
      // Act
      final String? actualReviewTable = pages.tableOf('path:review:1:review');
      // Assert
      expect(pages.specOf('path:mul:5:speed')?.itemKeys, hasLength(10));
      expect(pages.specOf('duel:1'), isNull);
      expect(pages.tableOf('path:mul:5:speed'), 'mul:5');
      expect(actualReviewTable, isNull);
      expect(
        pages.startsWithTable(
          const StageSource(unitKey: 'mul:5', stage: StageKind.discovery),
        ),
        isTrue,
      );
    });
  });
}
