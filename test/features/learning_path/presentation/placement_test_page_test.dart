import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_state.dart';
import 'package:kid_matix/features/learning_path/presentation/learning_path_pages.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_question_view.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/placement_slots.dart';
import 'package:kid_matix/features/quiz/presentation/quiz_pages.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_path_pages.dart';
import '../../../helpers/test_quiz_pages.dart';

void main() {
  late InMemoryStageProgressRepository repository;
  late LearningPathPages pages;
  late int doneCount;

  setUp(() {
    repository = InMemoryStageProgressRepository();
    pages = buildTestPathPages(repository: repository);
    doneCount = 0;
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    final QuizPages quizPages = buildTestQuizPages();
    await pumpLocalized(
      tester,
      pages.buildPlacementTestPage(
        profileId: 'p1',
        slots: PlacementSlots(
          keypad: quizPages.buildKeypad,
          questionCard: quizPages.buildQuestionCard,
        ),
        onDone: () => doneCount++,
      ),
    );
    await tester.pumpAndSettle();
  }

  PlacementAsking askingOf(WidgetTester tester) {
    return tester
            .element(find.byType(PlacementQuestionView))
            .read<PlacementBloc>()
            .state
        as PlacementAsking;
  }

  /// Answers the question shown: right on the keypad when its table is in
  /// [known], « Je ne sais pas » otherwise.
  Future<void> answerShown(WidgetTester tester, Set<int> known) async {
    final PlacementAsking asking = askingOf(tester);
    if (known.contains(asking.question.unitNumber)) {
      final NumberAnswer expected =
          asking.question.question.expectedAnswer as NumberAnswer;
      for (final String digit in '${expected.value}'.split('')) {
        await tester.tap(find.text(digit).last);
        await tester.pump();
      }
      await tester.tap(find.text('Valider'));
    } else {
      await tester.tap(find.text('Je ne sais pas'));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('offers the test with « Passer »', (WidgetTester tester) async {
    // Arrange
    await pumpPage(tester);
    // Assert
    expect(find.text('Tu connais déjà des tables ?'), findsOneWidget);
    // Act
    await tester.tap(find.text('Passer'));
    // Assert
    expect(doneCount, 1);
    expect(repository.placedUnitKeys, isEmpty);
  });

  testWidgets('shows the tables 1, 2 and 10 found, then the path', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpPage(tester);
    await tester.tap(find.text('Faire le test'));
    await tester.pumpAndSettle();
    // Act
    for (int index = 0; index < 12; index++) {
      await answerShown(tester, <int>{1, 2, 10});
    }
    // Assert
    expect(find.text('Tu connais déjà 3 tables !'), findsOneWidget);
    expect(
      find.text(
        'Elles sont ouvertes dans ton parcours. Leurs étoiles restent à '
        'gagner.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Table de 10, déjà connue'), findsOneWidget);
    expect(find.bySemanticsLabel('Table de 7, à découvrir'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
    expect(repository.placedUnitKeys, <String>{'mul:1', 'mul:2', 'mul:10'});
    // Act
    await tester.tap(find.text('Voir mon parcours'));
    // Assert
    expect(doneCount, 1);
  });

  testWidgets('says something kind when no table is known', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpPage(tester);
    await tester.tap(find.text('Faire le test'));
    await tester.pumpAndSettle();
    // Act
    for (int index = 0; index < 12; index++) {
      await answerShown(tester, const <int>{});
    }
    // Assert
    expect(find.text('Tout est à découvrir !'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('keeps the tables found when the test is left midway', (
    WidgetTester tester,
  ) async {
    // Arrange
    await pumpPage(tester);
    await tester.tap(find.text('Faire le test'));
    await tester.pumpAndSettle();
    await answerShown(tester, <int>{1});
    await answerShown(tester, <int>{2});
    // Act: the cross, then « Continuer le test », then the cross again.
    await tester.tap(find.byTooltip('Arrêter le test'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer le test'));
    await tester.pumpAndSettle();
    final int actualIndex = askingOf(tester).index;
    await tester.tap(find.byTooltip('Arrêter le test'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arrêter'));
    await tester.pumpAndSettle();
    // Assert
    expect(actualIndex, 2);
    expect(doneCount, 1);
    expect(repository.placedUnitKeys, <String>{'mul:1', 'mul:2'});
  });
}
