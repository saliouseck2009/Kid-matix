import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_combo.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_status.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_header.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_key.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/presentation/reward_pages.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../../../helpers/test_reward_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

QuizAnswerEntity _answer({required bool isCorrect}) {
  return QuizAnswerEntity(
    itemKey: 'mul:5x1',
    questionTypeId: 'typedAnswer',
    isCorrect: isCorrect,
    isTimedOut: false,
    isRetry: false,
    answerTime: const Duration(seconds: 4),
  );
}

void main() {
  setUpAll(registerQuizFallbacks);

  Future<void> pumpView(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(tester, Scaffold(body: Center(child: child)));
    await tester.pumpAndSettle();
  }

  group('Results rewards', () {
    testWidgets('celebrate the new badge, then show the XP and the level', (
      WidgetTester tester,
    ) async {
      // Arrange
      final InMemoryRewardRepository inputRewards = InMemoryRewardRepository(
        xpEarned: 930,
        sessionXp: (profileId: 'p1', xp: 130, earnedAt: quizStart),
        badges: <BadgeUnlockEntity>[
          BadgeUnlockEntity(
            badgeKey: BadgeKey.firstStep,
            unlockedAt: quizStart,
            sessionId: 'session-1',
          ),
        ],
      );
      final MockQuizSessionRepository mockSessions =
          MockQuizSessionRepository();
      when(
        () => mockSessions.getResult(sessionId: any(named: 'sessionId')),
      ).thenAnswer(
        (_) async => DataSuccess<QuizResultEntity>(
          QuizResultEntity(
            session: QuizSessionEntity(
              id: 'session-1',
              profileId: 'p1',
              domainId: 'multiplication',
              mode: QuizMode.path,
              status: QuizSessionStatus.completed,
              startedAt: quizStart,
              duration: const Duration(minutes: 1),
              questionCount: 10,
              correctCount: 9,
              sourceKey: 'path:mul:5:training',
            ),
            answers: <QuizAnswerEntity>[_answer(isCorrect: true)],
          ),
        ),
      );
      final RewardPages pages = buildTestRewardPages(repository: inputRewards);
      tester.view.physicalSize = const Size(1170, 2532);
      addTearDown(tester.view.reset);
      // Act
      await pumpLocalized(
        tester,
        buildTestQuizPages(repository: mockSessions).buildResultsPage(
          sessionId: 'session-1',
          onContinue: (String? sourceKey) {},
          onReplay: (String sourceKey) {},
          rewardsScope: (Widget child) => pages.buildSessionRewardsScope(
            sessionId: 'session-1',
            child: child,
          ),
          xpTile: pages.buildSessionXpTile(),
          rewardsCard: pages.buildSessionLevelCard(),
        ),
      );
      await tester.pumpAndSettle();
      // Assert: the celebration first, closed by a tap.
      expect(find.text('Nouveau badge !'), findsOneWidget);
      expect(find.text('Tu as terminé ta première étape.'), findsOneWidget);
      await tester.tap(find.text("Touche l'écran pour continuer"));
      await tester.pumpAndSettle();
      expect(find.text('+130'), findsOneWidget);
      expect(find.text('XP gagnés'), findsOneWidget);
      expect(find.text('Niveau 4'), findsOneWidget);
      expect(
        find.text('Encore 70 XP pour le niveau 5'),
        findsOneWidget,
      );
      expect(find.text('Nouveau badge'), findsOneWidget);
      expect(find.text('Premier pas'), findsOneWidget);
    });
  });

  group('Streak and daily goal', () {
    testWidgets('show the streak of the player', (WidgetTester tester) async {
      // Arrange
      final RewardPages pages = buildTestRewardPages(
        repository: InMemoryRewardRepository(
          streak: StreakEntity(
            current: 6,
            best: 6,
            lastPlayedDay: DateTime(2026, 10, 9),
          ),
        ),
      );
      // Act
      await pumpView(tester, pages.buildStreakPill(profileId: 'p1'));
      // Assert
      expect(find.bySemanticsLabel('Série de 6 jours'), findsOneWidget);
      expect(find.text('6 jours'), findsOneWidget);
    });
    testWidgets('say when there is no streak', (WidgetTester tester) async {
      // Act
      await pumpView(
        tester,
        buildTestRewardPages().buildStreakPill(profileId: 'p1'),
      );
      // Assert
      expect(find.text('Pas de série'), findsOneWidget);
    });
    testWidgets('show the XP of the day against the goal', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpView(
        tester,
        buildTestRewardPages(
          repository: InMemoryRewardRepository(xpEarned: 30),
        ).buildDailyGoalCard(profileId: 'p1'),
      );
      // Assert
      expect(find.text('Objectif du jour'), findsOneWidget);
      expect(find.text('30 / 20 XP'), findsOneWidget);
    });
  });

  group('Combo', () {
    test('counts the right answers in a row and its milestones', () {
      // Act
      final int actualCombo = QuizCombo.countOf(<QuizAnswerEntity>[
        _answer(isCorrect: true),
        _answer(isCorrect: false),
        _answer(isCorrect: true),
        _answer(isCorrect: true),
        _answer(isCorrect: true),
      ]);
      // Assert
      expect(actualCombo, 3);
      expect(QuizCombo.isMilestone(3), isTrue);
      expect(QuizCombo.isMilestone(4), isFalse);
      expect(QuizCombo.isMilestone(10), isTrue);
    });
    testWidgets('shows its pill from 2 right answers in a row', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpView(
        tester,
        QuizHeader(
          current: 4,
          answeredCount: 3,
          total: 10,
          onQuit: () {},
          combo: 3,
        ),
      );
      // Assert
      expect(find.bySemanticsLabel('Combo de 3'), findsOneWidget);
    });
  });
}
