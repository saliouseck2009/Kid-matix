import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/review_overview.dart';
import 'package:kid_matix/features/challenge/domain/entities/record_entity.dart';
import 'package:kid_matix/features/challenge/presentation/challenge_pages.dart';
import 'package:kid_matix/l10n/app_localizations_fr.dart';

import '../../../helpers/fake_mastery_service.dart';
import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_challenge_pages.dart';
import '../helpers/challenge_fakes.dart';

RecordEntity _record({
  String sessionId = 's1',
  int? previousBest,
  QuizMode mode = QuizMode.timeAttack,
  int bestScore = 18,
}) {
  return RecordEntity(
    mode: mode,
    bestScore: bestScore,
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
      TimerMode timerMode = TimerMode.normal,
      ReviewOverview review = const ReviewOverview(dueCount: 0, seenCount: 0),
      int monsterCount = 0,
    }) async {
      final List<String> played = <String>[];
      final ChallengePages pages = buildTestChallengePages(
        useCases: buildTestChallengeUseCases(
          records: InMemoryRecordRepository(records),
          openUnits: const FixedOpenUnits(<String>['mul:1', 'mul:2']),
          timerMode: timerMode,
          mastery: FakeMasteryService()
            ..reviewOverview = review
            ..monsterCount = monsterCount,
        ),
      );
      await pumpLocalized(
        tester,
        Scaffold(
          body: pages.buildChallengesPage(
            profileId: 'p1',
            onPlay: played.add,
            onOpenMonsters: () => played.add('monsters'),
          ),
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
    testWidgets('shows survival and plays it on the open tables', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> played = await pumpChallenges(tester);
      // Act
      await tester.tap(find.text('Survie'));
      // Assert
      expect(find.text('3\u00a0vies, de plus en plus vite'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.text('Ici, le chrono reste actif.'), findsNothing);
      expect(played, <String>['survival:mul:1+mul:2']);
    });
    testWidgets('says survival keeps its timer when it is turned off', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpChallenges(tester, timerMode: TimerMode.off);
      // Assert
      expect(find.text('Ici, le chrono reste actif.'), findsOneWidget);
    });
    testWidgets('shows the survival record apart', (WidgetTester tester) async {
      // Act
      await pumpChallenges(
        tester,
        records: <RecordEntity>[
          _record(),
          _record(sessionId: 's2', mode: QuizMode.survival, bestScore: 24),
        ],
      );
      // Assert
      expect(find.text('Record 18'), findsOneWidget);
      expect(find.text('Record 24'), findsOneWidget);
    });
    testWidgets('sends survival back to the challenges', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ChallengePages inputPages = buildTestChallengePages();
      // Act
      final ChallengeOrigin? actualOrigin = inputPages.originOf(
        'survival:mul:1',
      );
      // Assert
      expect(actualOrigin, ChallengeOrigin.challenges);
    });
    testWidgets('opens the monsters with how many wait to be tamed', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> played = await pumpChallenges(
        tester,
        monsterCount: 3,
      );
      // Act
      await tester.tap(find.text('Chasse aux monstres'));
      // Assert
      expect(find.text('3 monstres à apprivoiser'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      expect(played, <String>['monsters']);
    });
    testWidgets('says when no monster waits', (WidgetTester tester) async {
      // Act
      await pumpChallenges(tester);
      // Assert
      expect(find.text("Aucun monstre pour l'instant"), findsOneWidget);
    });
    testWidgets('shows the record of the player', (WidgetTester tester) async {
      // Act
      await pumpChallenges(tester, records: <RecordEntity>[_record()]);
      // Assert
      expect(find.text('Record 18'), findsOneWidget);
    });
    testWidgets('opens the daily review with the facts to review', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> played = await pumpChallenges(
        tester,
        review: const ReviewOverview(dueCount: 8, seenCount: 30),
      );
      // Act
      await tester.tap(find.text('Révision du jour'));
      // Assert
      expect(find.text('10 questions choisies pour toi'), findsOneWidget);
      expect(find.text('8 à revoir'), findsOneWidget);
      expect(played, <String>['dailyReview']);
    });
    testWidgets('opens the daily review without pill when none is due', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> played = await pumpChallenges(
        tester,
        review: const ReviewOverview(dueCount: 0, seenCount: 4),
      );
      // Act
      await tester.tap(find.text('Révision du jour'));
      // Assert
      expect(find.textContaining('à revoir'), findsNothing);
      expect(played, <String>['dailyReview']);
    });
    testWidgets('locks the daily review before any fact was seen', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> played = await pumpChallenges(tester);
      // Act
      await tester.tap(find.text('Révision du jour'));
      // Assert
      expect(find.text("Joue d'abord une étape du parcours"), findsOneWidget);
      expect(find.textContaining('à revoir'), findsNothing);
      expect(played, isEmpty);
    });
    testWidgets('shows the error when the review cannot be read', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ChallengePages pages = buildTestChallengePages(
        useCases: buildTestChallengeUseCases(
          mastery: FakeMasteryService(failure: const CacheException()),
        ),
      );
      // Act
      await pumpLocalized(
        tester,
        Scaffold(
          body: pages.buildChallengesPage(
            profileId: 'p1',
            onPlay: (_) {},
            onOpenMonsters: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Révision du jour'), findsNothing);
      expect(find.text('Contre-la-montre'), findsNothing);
    });
    test('sends the daily review back to the challenges', () {
      // Arrange
      final ChallengePages pages = buildTestChallengePages();
      // Act & Assert
      expect(pages.originOf('dailyReview'), ChallengeOrigin.challenges);
      expect(pages.specOf('dailyReview')?.mode, QuizMode.dailyReview);
      expect(
        pages.describeSource('dailyReview', AppLocalizationsFr()),
        'Révision du jour',
      );
    });
    test('names the monster hunt and plays it', () {
      // Arrange
      final ChallengePages pages = buildTestChallengePages();
      final String inputFromProfile = pages.monsterHuntKeyOf(
        isFromProfile: true,
      );
      // Act & Assert
      expect(pages.monsterHuntQuestionCount, 10);
      expect(pages.monsterHuntKeyOf(isFromProfile: false), 'monsterHunt');
      expect(pages.originOf('monsterHunt'), ChallengeOrigin.challengeMonsters);
      expect(pages.originOf(inputFromProfile), ChallengeOrigin.profileMonsters);
      expect(pages.specOf(inputFromProfile)?.mode, QuizMode.monsterHunt);
      expect(pages.specOf('monsterHunt')?.mode, QuizMode.monsterHunt);
      expect(
        pages.describeSource('monsterHunt', AppLocalizationsFr()),
        'Chasse aux monstres',
      );
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
