import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/mastery/domain/entities/item_progress_entity.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_mastery_pages.dart';

ItemProgressEntity _progress(String itemKey, int box, {Duration? time}) {
  return ItemProgressEntity(
    profileId: 'p1',
    domainId: 'multiplication',
    itemKey: itemKey,
    presentationCount: 6,
    correctCount: 5,
    lastAnswerTimes: List<Duration>.filled(
      5,
      time ?? const Duration(seconds: 5),
    ),
    box: box,
  );
}

void main() {
  group('MasteryGridCard', () {
    late InMemoryItemProgressRepository repository;

    Future<void> pumpGrid(WidgetTester tester) async {
      await pumpLocalized(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: buildTestMasteryPages(
              repository: repository,
            ).buildGridCard(profileId: 'p1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    setUp(() {
      repository = InMemoryItemProgressRepository(<ItemProgressEntity>[
        _progress('mul:5x1', 1),
        _progress('mul:5x2', 2),
        _progress('mul:5x3', 4),
        _progress('mul:5x4', 5, time: const Duration(seconds: 1)),
      ]);
    });

    testWidgets('shows 12 rows of 10 facts and the legend', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpGrid(tester);
      // Assert
      expect(find.text('Mes tables'), findsOneWidget);
      expect(find.text('×10'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      for (final String status in <String>[
        'Nouveau',
        'À revoir',
        'En cours',
        'Acquis',
        'Maîtrisé',
      ]) {
        expect(find.text(status), findsOneWidget);
      }
    });
    testWidgets('reads each fact with its status', (
      WidgetTester tester,
    ) async {
      // Arrange
      final SemanticsHandle handle = tester.ensureSemantics();
      // Act
      await pumpGrid(tester);
      // Assert
      expect(
        find.bySemanticsLabel('5 fois 1 égale 5, À revoir'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('5 fois 2 égale 10, En cours'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('5 fois 3 égale 15, Acquis'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('5 fois 4 égale 20, Maîtrisé'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('7 fois 8 égale 56, Nouveau'),
        findsOneWidget,
      );
      handle.dispose();
    });
    testWidgets('colors a fact again after an answer', (
      WidgetTester tester,
    ) async {
      // Arrange
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpGrid(tester);
      // Act
      await repository.saveProgress(progress: _progress('mul:7x8', 2));
      await tester.pumpAndSettle();
      // Assert
      expect(
        find.bySemanticsLabel('7 fois 8 égale 56, En cours'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
