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

import '../../../helpers/fake_speech_service.dart';
import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_path_pages.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

void main() {
  late InMemoryStageProgressRepository repository;
  late InMemoryPlacementResultRepository results;
  late LearningPathPages pages;
  late int doneCount;

  setUp(() {
    repository = InMemoryStageProgressRepository();
    results = InMemoryPlacementResultRepository(clock: FakeClock(quizStart));
    pages = buildTestPathPages(repository: repository, results: results);
    doneCount = 0;
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    FakeSpeechService? speech,
    bool readsByItself = false,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    final QuizPages quizPages = buildTestQuizPages(
      speech: speech,
      readsByItself: readsByItself,
    );
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

  /// Answers the question shown: right on the keypad when [isRight],
  /// « Je ne sais pas » otherwise.
  Future<void> answerShown(
    WidgetTester tester, {
    required bool isRight,
  }) async {
    final PlacementAsking asking = askingOf(tester);
    if (isRight) {
      final NumberAnswer expected =
          asking.question.expectedAnswer as NumberAnswer;
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

  Future<void> startTest(WidgetTester tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Faire le test'));
    await tester.pumpAndSettle();
  }

  testWidgets('offers the test with « Passer »', (WidgetTester tester) async {
    // Arrange
    await pumpPage(tester);
    // Assert
    expect(find.text('Voyons où tu en es !'), findsOneWidget);
    // Act
    await tester.tap(find.text('Passer'));
    // Assert
    expect(doneCount, 1);
    expect(repository.placedUnitKeys, isEmpty);
    expect(results.saved, isEmpty);
  });

  testWidgets('asks the counting question with its drawing', (
    WidgetTester tester,
  ) async {
    // Act
    await startTest(tester);
    // Assert
    expect(askingOf(tester).question.unitKey, 'num:count20');
    expect(find.text('Je ne sais pas'), findsOneWidget);
    expect(find.text('Valider'), findsOneWidget);
  });

  testWidgets('shows the levels found and where to start, then the path', (
    WidgetTester tester,
  ) async {
    // Arrange
    await startTest(tester);
    // Act: the child counts but cannot add.
    for (final bool isRight in <bool>[true, true, true, false, false]) {
      await answerShown(tester, isRight: isRight);
    }
    // Assert
    expect(find.text('1 niveau réussi !'), findsOneWidget);
    expect(find.bySemanticsLabel('Nombres, Acquis'), findsOneWidget);
    expect(find.bySemanticsLabel('Additions, À découvrir'), findsOneWidget);
    expect(find.bySemanticsLabel('Divisions, À découvrir'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.text('Tu commences par'), findsOneWidget);
    expect(results.saved, hasLength(1));
    expect(repository.placedUnitKeys, contains('num:count20'));
    expect(repository.placedUnitKeys, contains('addsub:add5'));
    // Act
    await tester.tap(find.text('Voir mon parcours'));
    // Assert
    expect(doneCount, 1);
  });

  testWidgets('says something kind when nothing is known', (
    WidgetTester tester,
  ) async {
    // Arrange
    await startTest(tester);
    // Act
    await answerShown(tester, isRight: false);
    await answerShown(tester, isRight: false);
    // Assert
    expect(find.text('Ton aventure commence !'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('congratulates a child who passes every level', (
    WidgetTester tester,
  ) async {
    // Arrange
    await startTest(tester);
    // Act
    for (int index = 0; index < 15; index++) {
      await answerShown(tester, isRight: true);
    }
    // Assert
    expect(find.text('5 niveaux réussis !'), findsOneWidget);
    expect(
      find.text('Tu connais tout ce que le test demande. Bravo !'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(5));
  });

  testWidgets('keeps the units found but no result when left midway', (
    WidgetTester tester,
  ) async {
    // Arrange
    await startTest(tester);
    await answerShown(tester, isRight: true);
    // Act: the cross, then « Continuer le test », then the cross again.
    await tester.tap(find.byTooltip('Arrêter le test'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer le test'));
    await tester.pumpAndSettle();
    final int actualAnswered = askingOf(tester).journey.answeredCount;
    await tester.tap(find.byTooltip('Arrêter le test'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arrêter'));
    await tester.pumpAndSettle();
    // Assert
    expect(actualAnswered, 1);
    expect(doneCount, 1);
    expect(repository.placedUnitKeys, <String>{'num:count10', 'num:count20'});
    expect(results.saved, isEmpty);
  });

  group('read aloud', () {
    Future<void> startReading(
      WidgetTester tester,
      FakeSpeechService speech, {
      bool readsByItself = false,
    }) async {
      await pumpPage(tester, speech: speech, readsByItself: readsByItself);
      await tester.tap(find.text('Faire le test'));
      await tester.pumpAndSettle();
    }

    testWidgets('reads the question when the child taps « Écouter »', (
      WidgetTester tester,
    ) async {
      // Arrange
      final FakeSpeechService speech = FakeSpeechService();
      await startReading(tester, speech);
      // Assert
      expect(speech.spoken, isEmpty);
      expect(find.byTooltip('Écouter'), findsOneWidget);
      // Act
      await tester.tap(find.byTooltip('Écouter'));
      await tester.pump();
      // Assert
      expect(speech.spoken.single, startsWith('Combien de'));
      expect(speech.languages, <String>['fr']);
      expect(find.byTooltip('Arrêter la lecture'), findsOneWidget);
      // Act
      await tester.tap(find.byTooltip('Arrêter la lecture'));
      await tester.pump();
      // Assert
      expect(speech.isSpeaking, isFalse);
    });

    testWidgets('reads every new question when the child asked for it', (
      WidgetTester tester,
    ) async {
      // Arrange
      final FakeSpeechService speech = FakeSpeechService(isInstant: true);
      await startReading(tester, speech, readsByItself: true);
      // Assert
      expect(speech.spoken, hasLength(1));
      // Act: the next question is the tens and ones.
      await answerShown(tester, isRight: true);
      // Assert
      expect(speech.spoken, hasLength(2));
      expect(speech.spoken.last, isNot(speech.spoken.first));
    });

    testWidgets('stops the voice when the question is answered', (
      WidgetTester tester,
    ) async {
      // Arrange
      final FakeSpeechService speech = FakeSpeechService();
      await startReading(tester, speech, readsByItself: true);
      // Assert
      expect(speech.isSpeaking, isTrue);
      // Act
      await answerShown(tester, isRight: false);
      // Assert
      expect(speech.stopCount, greaterThan(0));
    });

    testWidgets('shows no button when the phone has no voice', (
      WidgetTester tester,
    ) async {
      // Arrange
      final FakeSpeechService speech = FakeSpeechService(hasVoice: false);
      await startReading(tester, speech);
      // Assert
      expect(find.byTooltip('Écouter'), findsNothing);
      expect(speech.spoken, isEmpty);
    });

    testWidgets('shows no button where no voice is wired', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpPage(tester);
      await tester.tap(find.text('Faire le test'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.byTooltip('Écouter'), findsNothing);
    });
  });
}
