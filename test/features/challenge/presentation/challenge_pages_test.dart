import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/presentation/challenge_pages.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_challenge_pages.dart';
import '../helpers/challenge_fakes.dart';

RecordEntity _record({String sessionId = 's1', int? previousBest}) {
  return RecordEntity(
    mode: QuizMode.timeAttack,
    bestScore: 18,
    sessionId: sessionId,
    achievedAt: DateTime(2026, 10, 10),
    previousBest: previousBest,
  );
}

void main() {
  group('TrainingPage', () {
    Future<List<String>> pumpTraining(
      WidgetTester tester, {
      TimerMode timerMode = TimerMode.normal,
    }) async {
      final List<String> launched = <String>[];
      final ChallengePages pages = buildTestChallengePages(
        useCases: buildTestChallengeUseCases(
          openUnits: const FixedOpenUnits(<String>['mul:1', 'mul:2']),
          timerMode: timerMode,
        ),
      );
      await pumpLocalized(
        tester,
        Scaffold(
          body: pages.buildTrainingPage(
            profileId: 'p1',
            onLaunch: launched.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return launched;
    }

    testWidgets('offers the current table, 10 questions and the timer', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpTraining(tester);
      // Assert
      expect(find.text('×12'), findsOneWidget);
      expect(find.text('1 table · 10 questions'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Table de 2')),
        isSemantics(
          label: 'Table de 2',
          isButton: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
    });
    testWidgets('launches the tables, count and timer chosen', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> launched = await pumpTraining(tester);
      // Act
      await tester.tap(find.text('×5'));
      await tester.tap(find.text('20'));
      await tester.tap(find.text('Sans chrono'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lancer'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('2 tables · 20 questions'), findsOneWidget);
      expect(launched, <String>['training:20:free:mul:2+mul:5']);
    });
    testWidgets('asks for a table before launching', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> launched = await pumpTraining(tester);
      // Act
      await tester.tap(find.text('×2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lancer'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Choisis au moins une table'), findsOneWidget);
      expect(launched, isEmpty);
    });
    testWidgets('starts without timer when the player turned it off', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> launched = await pumpTraining(
        tester,
        timerMode: TimerMode.off,
      );
      // Act
      await tester.tap(find.text('Lancer'));
      await tester.pumpAndSettle();
      // Assert
      expect(launched, <String>['training:10:free:mul:2']);
    });
  });

  group('ChallengesPage', () {
    Future<List<String>> pumpChallenges(
      WidgetTester tester, {
      List<RecordEntity> records = const <RecordEntity>[],
    }) async {
      final List<String> played = <String>[];
      final ChallengePages pages = buildTestChallengePages(
        useCases: buildTestChallengeUseCases(
          records: InMemoryRecordRepository(records),
          openUnits: const FixedOpenUnits(<String>['mul:1', 'mul:2']),
        ),
      );
      await pumpLocalized(
        tester,
        Scaffold(
          body: pages.buildChallengesPage(profileId: 'p1', onPlay: played.add),
        ),
      );
      await tester.pumpAndSettle();
      return played;
    }

    testWidgets('shows the time attack and plays it on the open tables', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> played = await pumpChallenges(tester);
      // Act
      await tester.tap(find.text('Contre-la-montre'));
      // Assert
      expect(find.text('Défis'), findsOneWidget);
      expect(find.textContaining('Record'), findsNothing);
      expect(played, <String>['timeAttack:mul:1+mul:2']);
    });
    testWidgets('shows the record of the player', (WidgetTester tester) async {
      // Act
      await pumpChallenges(tester, records: <RecordEntity>[_record()]);
      // Assert
      expect(find.text('Record 18'), findsOneWidget);
    });
  });

  group('NewRecordCard', () {
    Future<void> pumpCard(WidgetTester tester, RecordEntity record) async {
      final ChallengePages pages = buildTestChallengePages(
        useCases: buildTestChallengeUseCases(
          records: InMemoryRecordRepository(<RecordEntity>[record]),
        ),
      );
      await pumpLocalized(
        tester,
        Scaffold(
          body: Column(
            children: <Widget>[
              pages.buildRecordCard(sessionId: 's1'),
              pages.buildRecordCard(sessionId: 'other'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('celebrates the record a session beat', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpCard(tester, _record(previousBest: 15));
      // Assert
      expect(find.text('Nouveau record !'), findsOneWidget);
      expect(find.text('18 bonnes réponses'), findsOneWidget);
      expect(find.text('Ancien record : 15'), findsOneWidget);
    });
    testWidgets('celebrates a first record', (WidgetTester tester) async {
      // Act
      await pumpCard(tester, _record());
      // Assert
      expect(find.text('Ton premier record'), findsOneWidget);
    });
  });
}
