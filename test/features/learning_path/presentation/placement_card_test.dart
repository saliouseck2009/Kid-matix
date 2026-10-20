import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_journey.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_path_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

PlacementJourney _play(List<bool> answers) {
  PlacementJourney journey = PlacementJourney.start();
  for (final bool isCorrect in answers) {
    if (journey.isOver) break;
    journey = journey.answered(isCorrect: isCorrect);
  }
  return journey;
}

void main() {
  late FakeClock clock;
  late InMemoryPlacementResultRepository results;
  late LearningPathPages pages;
  late int retakeCount;

  setUp(() {
    clock = FakeClock(DateTime(2026, 10, 12, 9));
    results = InMemoryPlacementResultRepository(clock: clock);
    pages = buildTestPathPages(results: results);
    retakeCount = 0;
  });

  Future<void> pumpCard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: pages.buildPlacementCard(
            profileId: 'p1',
            onRetake: () => retakeCount++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('invites a player who never took the test', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpCard(tester);
    // Assert
    expect(find.text('Mon niveau de départ'), findsOneWidget);
    expect(
      find.text("Tu n'as pas encore fait le test de niveau."),
      findsOneWidget,
    );
    // Act
    await tester.tap(find.text('Refaire le test'));
    // Assert
    expect(retakeCount, 1);
  });

  testWidgets('shows the dated level of each domain', (
    WidgetTester tester,
  ) async {
    // Arrange: the child counts but cannot add.
    await results.save(
      profileId: 'p1',
      outcome: _play(<bool>[true, true, true, false, false]).outcome,
    );
    // Act
    await pumpCard(tester);
    // Assert
    expect(find.text('Test du 12 oct. 2026'), findsOneWidget);
    expect(find.text('Nombres'), findsOneWidget);
    expect(find.text('niveau 1 sur 1'), findsNWidgets(1));
    expect(find.text('niveau 0 sur 2'), findsOneWidget);
    expect(find.text('Multiplication'), findsOneWidget);
    expect(find.text('+ et −'), findsOneWidget);
  });

  testWidgets('lists the earlier tests under the latest one', (
    WidgetTester tester,
  ) async {
    // Arrange
    await results.save(
      profileId: 'p1',
      outcome: _play(<bool>[false, false]).outcome,
    );
    clock.now_ = DateTime(2026, 12, 14, 9);
    await results.save(
      profileId: 'p1',
      outcome: _play(List<bool>.filled(15, true)).outcome,
    );
    // Act
    await pumpCard(tester);
    // Assert
    expect(find.text('Test du 14 déc. 2026'), findsOneWidget);
    expect(find.text('12 oct. 2026 : aucun niveau'), findsOneWidget);
  });

  testWidgets('shows a test finished while the card is on screen', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpCard(tester);
    // Act
    await results.save(
      profileId: 'p1',
      outcome: _play(<bool>[false, false]).outcome,
    );
    await tester.pumpAndSettle();
    // Assert
    expect(find.text('Test du 12 oct. 2026'), findsOneWidget);
  });
}
