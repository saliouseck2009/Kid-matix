import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/core/widgets/monster_painter.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/pages/quiz_page.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/boss_monster.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

import '../../../helpers/pump_localized.dart';
import '../../../helpers/recording_game_feedback.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../helpers/quiz_fixtures.dart';

/// [Ticker] whose ticks the test sends by hand.
final class _ManualTicker implements Ticker {
  final StreamController<int> controller = StreamController<int>.broadcast();

  @override
  Stream<int> tick({required Duration interval}) => controller.stream;
}

QuizRequest _bossRequest() {
  return QuizRequest(
    profileId: 'profile-1',
    domainId: 'multiplication',
    mode: QuizMode.path,
    itemKeys: tableKeys(5),
    questionTypeIds: const <String>[QuestionTypeIds.typedAnswer],
    selection: QuizSelection.shuffled,
    followUpItemKeys: tableKeys(5),
    followUpQuestionCount: 10,
    isBossFight: true,
    baseTimeLimit: const Duration(seconds: 8),
    sourceKey: 'path:mul:5:boss',
  );
}

void main() {
  late MockQuizSessionRepository mockRepository;

  setUpAll(registerQuizFallbacks);

  setUp(() {
    mockRepository = MockQuizSessionRepository();
    when(
      () => mockRepository.saveSession(
        session: any(named: 'session'),
        answers: any(named: 'answers'),
      ),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
  });

  group('QuizBloc in a boss fight', () {
    late _ManualTicker ticker;
    late QuizBloc bloc;

    setUp(() {
      ticker = _ManualTicker();
      bloc = QuizBloc(
        useCases: buildTestQuizUseCases(repository: mockRepository),
        ticker: ticker,
      );
    });

    tearDown(() async {
      await bloc.close();
      await ticker.controller.close();
    });

    Future<QuizShowingFeedback> answer({
      bool isRight = true,
      int ticks = 0,
    }) async {
      for (int index = 0; index < ticks; index++) {
        ticker.controller.add(index);
      }
      await pumpEventQueue();
      final Answer expected =
          (bloc.state as QuizAsking).turn.question.expectedAnswer;
      bloc.add(
        AnswerSubmitted(answer: isRight ? expected : const NumberAnswer(-1)),
      );
      await pumpEventQueue();
      return bloc.state as QuizShowingFeedback;
    }

    Future<void> next() async {
      bloc.add(const NextRequested());
      await pumpEventQueue();
    }

    test('hits, hits hard and takes a strike back', () async {
      // Arrange
      bloc.add(QuizStarted(request: _bossRequest()));
      await pumpEventQueue();
      // Act
      final QuizShowingFeedback actualHit = await answer(ticks: 35);
      await next();
      final QuizShowingFeedback actualCritical = await answer();
      await next();
      final QuizShowingFeedback actualStrikeBack = await answer(
        isRight: false,
      );
      // Assert
      expect(actualHit.bossBlow, BossBlow.hit);
      expect(actualHit.submission.run.boss!.remainingHitPoints, 11);
      expect(actualCritical.bossBlow, BossBlow.criticalHit);
      expect(actualCritical.submission.run.boss!.remainingHitPoints, 9);
      expect(actualStrikeBack.bossBlow, BossBlow.strikeBack);
      expect(actualStrikeBack.submission.run.boss!.remainingHitPoints, 9);
    });
    test('saves a defeated boss once it falls', () async {
      // Arrange
      bloc.add(QuizStarted(request: _bossRequest()));
      await pumpEventQueue();
      // Act
      QuizShowingFeedback last = await answer();
      for (int index = 0; index < 5; index++) {
        await next();
        last = await answer();
      }
      await next();
      // Assert
      expect(last.submission.run.bossOutcome, BossOutcome.defeated);
      expect(
        (bloc.state as QuizCompleted).session.bossOutcome,
        BossOutcome.defeated,
      );
    });
    test('saves a fled boss after the 20th question', () async {
      // Arrange
      bloc.add(QuizStarted(request: _bossRequest()));
      await pumpEventQueue();
      // Act
      QuizShowingFeedback last = await answer(isRight: false);
      while (!last.submission.run.isFinished) {
        await next();
        last = await answer(isRight: false);
      }
      await next();
      // Assert
      expect(last.submission.run.answers, hasLength(20));
      expect(
        (bloc.state as QuizCompleted).session.bossOutcome,
        BossOutcome.fled,
      );
    });
  });

  group('Boss fight screen', () {
    testWidgets('shows the monster, its life and the critical hit', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1170, 2532);
      addTearDown(tester.view.reset);
      await pumpLocalized(
        tester,
        QuizPage(
          request: _bossRequest(),
          useCases: buildTestQuizUseCases(repository: mockRepository),
          ticker: const SilentTicker(),
          domains: buildDomainRegistry(),
          feedback: RecordingGameFeedback(),
          onCompleted: (String sessionId) {},
          onLeft: () {},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Boss de la table de 5'), findsOneWidget);
      expect(find.text('12 / 12'), findsOneWidget);
      expect(find.bySemanticsLabel('Vie du boss : 12 sur 12'), findsOneWidget);
      expect(find.byType(MonsterIllustration), findsOneWidget);
      final QuizBloc bloc = BlocProvider.of<QuizBloc>(
        tester.element(find.byType(Scaffold)),
      );
      final int expected =
          ((bloc.state as QuizAsking).turn.question.expectedAnswer
                  as NumberAnswer)
              .value;
      // Act
      for (final String digit in '$expected'.split('')) {
        await tester.tap(find.widgetWithText(InkWell, digit).first);
        await tester.pump();
      }
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Coup critique !\n−2'), findsOneWidget);
      expect(find.text('10 / 12'), findsOneWidget);
    });
    testWidgets('keeps the monster still when motion is reduced', (
      WidgetTester tester,
    ) async {
      // Arrange
      Widget monster({required bool isReduced}) => MediaQuery(
        data: MediaQueryData(disableAnimations: isReduced),
        child: const BossMonster(number: 5, blow: BossBlow.criticalHit),
      );
      // Act
      await pumpLocalized(tester, monster(isReduced: true));
      final int actualStillBuilders = tester
          .widgetList(find.byType(TweenAnimationBuilder<double>))
          .length;
      await pumpLocalized(tester, monster(isReduced: false));
      final int actualMovingBuilders = tester
          .widgetList(find.byType(TweenAnimationBuilder<double>))
          .length;
      // Assert
      expect(actualStillBuilders, 0);
      expect(actualMovingBuilders, 1);
      await tester.pumpAndSettle();
    });
  });
}
