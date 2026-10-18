import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/help_audio.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/read_aloud_scope.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';
import 'package:kid_matix/core/widgets/word_picture/word_picture_view.dart';
import 'package:kid_matix/features/math_word/domain/services/math_word_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/pages/quiz_page.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/boss_arena.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

import '../../../helpers/fake_speech_service.dart';
import '../../../helpers/fake_word_audio_service.dart';
import '../../../helpers/pump_localized.dart';
import '../../../helpers/recording_game_feedback.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../helpers/quiz_fixtures.dart';

/// The four formats of the math words on the quiz screen (lot F28).
void main() {
  late MockQuizSessionRepository mockRepository;
  late FakeWordAudioService audio;
  late FakeSpeechService speech;

  setUpAll(registerQuizFallbacks);

  setUp(() {
    mockRepository = MockQuizSessionRepository();
    when(
      () => mockRepository.saveSession(
        session: any(named: 'session'),
        answers: any(named: 'answers'),
      ),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
    audio = FakeWordAudioService(
      recorded: <String>{'il_reste', 'ajouter'},
      withExample: <String>{'il_reste'},
    );
    speech = FakeSpeechService(isInstant: true);
  });

  Future<void> pumpQuiz(
    WidgetTester tester, {
    required String itemKey,
    required String questionTypeId,
    String helpLanguage = HelpAudio.defaultLanguage,
    bool isBossFight = false,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      ReadAloudScope(
        speech: speech,
        child: WordAudioScope(
          audio: audio,
          child: HelpAudioLanguageScope(
            language: helpLanguage,
            child: QuizPage(
              request: QuizRequest(
                profileId: 'profile-1',
                domainId: MathWordDomain.domainId,
                mode: isBossFight ? QuizMode.path : QuizMode.freeTraining,
                itemKeys: <String>[itemKey],
                questionTypeIds: <String>[questionTypeId],
                baseTimeLimit: QuizTimeLimits.freeTraining,
                isBossFight: isBossFight,
              ),
              useCases: buildTestQuizUseCases(repository: mockRepository),
              ticker: const SilentTicker(),
              domains: buildDomainRegistry(),
              feedback: RecordingGameFeedback(),
              onCompleted: (_) {},
              onLeft: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Question currentQuestion(WidgetTester tester) {
    return (BlocProvider.of<QuizBloc>(
              tester.element(find.byType(Scaffold)),
            ).state
            as QuizAsking)
        .turn
        .question;
  }

  group('Listen and touch', () {
    testWidgets('hears the word and touches its drawing among four', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.listenAndTouch,
      );
      final Question question = currentQuestion(tester);
      // Assert
      expect(find.text('Écoute et touche'), findsOneWidget);
      expect(find.text('il reste'), findsOneWidget);
      expect(find.byType(WordPictureView), findsNWidgets(4));
      expect(find.text('Touche le bon dessin'), findsOneWidget);
      // Act
      final int expectedIndex = question.choices.indexOf(
        question.expectedAnswer,
      );
      await tester.tap(find.byType(WordPictureView).at(expectedIndex));
      await tester.pumpAndSettle();
      // Assert
      expect(find.textContaining('Bravo'), findsOneWidget);
    });

    testWidgets('judges a wrong drawing', (WidgetTester tester) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.listenAndTouch,
      );
      final Question question = currentQuestion(tester);
      final int wrongIndex = question.choices.indexWhere(
        (Answer choice) => choice != question.expectedAnswer,
      );
      // Act
      await tester.tap(find.byType(WordPictureView).at(wrongIndex));
      await tester.pumpAndSettle();
      // Assert
      expect(find.textContaining('Bravo'), findsNothing);
      expect(find.text('Continuer'), findsOneWidget);
    });

    testWidgets('offers the recorded help only when it exists', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.listenAndTouch,
      );
      // Assert
      expect(find.text('Écouter en wolof'), findsOneWidget);
      // Act
      await tester.tap(find.text('Écouter en wolof'));
      await tester.pump();
      // Assert
      expect(audio.played, <String>['wo:il_reste:explanation']);
    });

    testWidgets('hides the recorded help of a word with no file', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpQuiz(
        tester,
        itemKey: 'word:total',
        questionTypeId: QuestionTypeIds.listenAndTouch,
      );
      // Assert
      expect(find.text('Écouter en wolof'), findsNothing);
    });

    testWidgets('hides the recorded help when the player chose none', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.listenAndTouch,
        helpLanguage: HelpAudio.none,
      );
      // Assert
      expect(find.text('Écouter en wolof'), findsNothing);
    });

    testWidgets('fights a boss with the word and its four drawings', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.listenAndTouch,
        isBossFight: true,
      );
      // Assert
      expect(find.byType(BossArena), findsOneWidget);
      expect(find.text('il reste'), findsOneWidget);
      expect(find.byType(WordPictureView), findsNWidgets(4));
    });
  });

  group('Which operation', () {
    testWidgets('reads a statement and picks the operation', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.whichOperation,
      );
      final Question question = currentQuestion(tester);
      // Assert
      expect(find.text('Quelle opération\u00a0?'), findsOneWidget);
      expect(
        find.textContaining('Il lui reste', findRichText: true),
        findsNothing,
      );
      for (final String sign in <String>['+', '−', '×', '÷']) {
        expect(find.text(sign), findsOneWidget, reason: sign);
      }
      expect(find.text("Touche l'opération"), findsOneWidget);
      // Act
      final String sign = switch ((question.expectedAnswer
              as ProblemOperationAnswer)
          .operation
          .name) {
        'add' => '+',
        'subtract' => '−',
        'multiply' => '×',
        _ => '÷',
      };
      await tester.tap(find.text(sign));
      await tester.pumpAndSettle();
      // Assert
      expect(find.textContaining('Bravo'), findsOneWidget);
    });

    testWidgets('judges a wrong operation', (WidgetTester tester) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.whichOperation,
      );
      final Question question = currentQuestion(tester);
      final String wrong =
          (question.expectedAnswer as ProblemOperationAnswer).operation.name ==
              'add'
          ? '−'
          : '+';
      // Act
      await tester.tap(find.text(wrong));
      await tester.pumpAndSettle();
      // Assert
      expect(find.textContaining('Bravo'), findsNothing);
    });
  });

  group('Tap to understand', () {
    DepthButton understood(WidgetTester tester) {
      return tester.widget<DepthButton>(
        find.widgetWithText(DepthButton, "J'ai compris"),
      );
    }

    testWidgets('says the word, plays its explanation and draws it', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.touchToUnderstand,
      );
      // Assert
      expect(find.text('Touche pour comprendre'), findsWidgets);
      expect(find.byType(WordPictureView), findsNothing);
      expect(understood(tester).onPressed, isNull);
      expect(find.text('Touche le mot en couleur'), findsOneWidget);
      // Act
      await tester.tap(find.text('reste'));
      await tester.pumpAndSettle();
      // Assert
      expect(speech.spoken.last, 'reste');
      expect(speech.languages.last, 'fr');
      expect(audio.played, <String>['wo:il_reste:explanation']);
      expect(find.byType(WordPictureView), findsOneWidget);
      expect(understood(tester).onPressed, isNotNull);
      expect(find.text('Écouter en wolof'), findsOneWidget);
      expect(find.text('Exemple en wolof'), findsOneWidget);
      // Act
      await tester.tap(find.text('Exemple en wolof'));
      await tester.pump();
      // Assert
      expect(audio.played.last, 'wo:il_reste:example');
    });

    testWidgets('judges the question once the word asked is touched', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.touchToUnderstand,
      );
      // Act
      await tester.tap(find.text('reste'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("J'ai compris"));
      await tester.pumpAndSettle();
      // Assert
      expect(find.textContaining('Bravo'), findsOneWidget);
    });

    testWidgets('explains another colored word without answering', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'word:en_plus',
        questionTypeId: QuestionTypeIds.touchToUnderstand,
      );
      // Act
      await tester.tap(find.text('donne'));
      await tester.pumpAndSettle();
      // Assert
      expect(speech.spoken.last, 'donne');
      expect(find.byType(WordPictureView), findsOneWidget);
      expect(understood(tester).onPressed, isNull);
    });

    testWidgets('plays no Wolof when the player chose none', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.touchToUnderstand,
        helpLanguage: HelpAudio.none,
      );
      // Act
      await tester.tap(find.text('reste'));
      await tester.pumpAndSettle();
      // Assert
      expect(speech.spoken.last, 'reste');
      expect(audio.played, isEmpty);
      expect(find.text('Écouter en wolof'), findsNothing);
    });

    testWidgets('still works with no voice and no pack', (
      WidgetTester tester,
    ) async {
      // Arrange
      speech.hasVoice = false;
      audio = FakeWordAudioService();
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.touchToUnderstand,
      );
      // Act
      await tester.tap(find.text('reste'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("J'ai compris"));
      await tester.pumpAndSettle();
      // Assert
      expect(speech.spoken, isEmpty);
      expect(find.textContaining('Bravo'), findsOneWidget);
    });
  });

  group('Word and image', () {
    testWidgets('ties every word to its drawing, then judges', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.wordAndImage,
      );
      final Question question = currentQuestion(tester);
      // Assert
      expect(find.text('Relie chaque mot à son dessin'), findsOneWidget);
      expect(find.byType(WordPictureView), findsNWidgets(4));
      expect(find.text('Touche un mot, puis son dessin'), findsOneWidget);
      // Act
      for (final QuestionPair pair in question.pairs) {
        await tester.tap(find.text(pair.word));
        await tester.pump();
        await tester.tap(
          find
              .byType(WordPictureView)
              .at(question.choices.indexOf(pair.result)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
      // Assert
      expect(find.textContaining('Bravo'), findsOneWidget);
    });

    testWidgets('counts a wrong pairing as a mistake of the word', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'word:il_reste',
        questionTypeId: QuestionTypeIds.wordAndImage,
      );
      final Question question = currentQuestion(tester);
      final QuestionPair first = question.pairs.first;
      final QuestionPair other = question.pairs[1];
      // Act
      await tester.tap(find.text(first.word));
      await tester.pump();
      await tester.tap(
        find.byType(WordPictureView).at(question.choices.indexOf(other.result)),
      );
      await tester.pump();
      // Assert
      expect(find.textContaining('Bravo'), findsNothing);
      expect(find.byType(WordPictureView), findsNWidgets(4));
    });
  });
}

extension on QuestionPair {
  String get word => (operation as WordAnswer).text;
}
