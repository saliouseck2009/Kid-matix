import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/widgets/listen_button.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/presentation/pages/quiz_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_speech_service.dart';
import '../../../helpers/pump_localized.dart';
import '../../../helpers/recording_game_feedback.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../helpers/quiz_fixtures.dart';

/// A question type and the sentence the voice says for it.
typedef _Format = ({
  String name,
  String questionTypeId,
  bool isBossFight,
  RegExp sentence,
});

final RegExp _operation = RegExp(r'^\d+ fois \d+ égale combien$');

final List<_Format> _formats = <_Format>[
  (
    name: 'multiple choice',
    questionTypeId: QuestionTypeIds.multipleChoice,
    isBossFight: false,
    sentence: _operation,
  ),
  (
    name: 'written answer',
    questionTypeId: QuestionTypeIds.typedAnswer,
    isBossFight: false,
    sentence: _operation,
  ),
  (
    name: 'missing number',
    questionTypeId: QuestionTypeIds.missingNumber,
    isBossFight: false,
    sentence: RegExp(
      r'^(\d+ fois combien égale \d+|combien fois \d+ égale \d+)$',
    ),
  ),
  (
    name: 'true or false',
    questionTypeId: QuestionTypeIds.trueFalse,
    isBossFight: false,
    sentence: RegExp('^\\d+ fois \\d+ égale \\d+\\. Vrai ou faux \\?\$'),
  ),
  (
    name: 'find the operation',
    questionTypeId: QuestionTypeIds.findOperation,
    isBossFight: false,
    sentence: RegExp('^Quelle multiplication donne \\d+\u00a0\\?\$'),
  ),
  (
    name: 'match the pairs',
    questionTypeId: QuestionTypeIds.matchPairs,
    isBossFight: false,
    sentence: RegExp('^Relie chaque opération à son résultat\$'),
  ),
  (
    name: 'boss fight',
    questionTypeId: QuestionTypeIds.typedAnswer,
    isBossFight: true,
    sentence: _operation,
  ),
];

void main() {
  late MockQuizSessionRepository mockRepository;
  late FakeSpeechService speech;

  setUpAll(registerQuizFallbacks);

  setUp(() {
    speech = FakeSpeechService();
    mockRepository = MockQuizSessionRepository();
    when(
      () => mockRepository.saveSession(
        session: any(named: 'session'),
        answers: any(named: 'answers'),
      ),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
  });

  Future<void> pumpQuiz(
    WidgetTester tester, {
    String questionTypeId = QuestionTypeIds.multipleChoice,
    bool isBossFight = false,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      QuizPage(
        request: QuizRequest(
          profileId: 'profile-1',
          domainId: MultiplicationDomain.domainId,
          mode: isBossFight ? QuizMode.path : QuizMode.freeTraining,
          itemKeys: const <String>['mul:4x6', 'mul:5x8'],
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
        readAloud: buildReadAloudUseCases(speech: speech),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('The listen button of the question', () {
    for (final _Format format in _formats) {
      testWidgets('reads a ${format.name} question as a sentence', (
        WidgetTester tester,
      ) async {
        // Arrange
        await pumpQuiz(
          tester,
          questionTypeId: format.questionTypeId,
          isBossFight: format.isBossFight,
        );
        // Act
        await tester.tap(find.byTooltip('Écouter'));
        await tester.pump();
        // Assert
        expect(speech.spoken, hasLength(1));
        expect(speech.spoken.single, matches(format.sentence));
        expect(speech.languages.single, 'fr');
      });
    }
    testWidgets('has a speaker icon, a tooltip and a 48 dp target', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpQuiz(tester);
      // Assert
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(ListenButton)),
        isSemantics(isButton: true, tooltip: 'Écouter', hasTapAction: true),
      );
      final Size actualSize = tester.getSize(find.byType(ListenButton));
      expect(actualSize.width, greaterThanOrEqualTo(48));
      expect(actualSize.height, greaterThanOrEqualTo(48));
    });
    testWidgets('becomes a stop button while the voice speaks', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester);
      // Act
      await tester.tap(find.byTooltip('Écouter'));
      await tester.pump();
      // Assert
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(find.byTooltip('Arrêter la lecture'), findsOneWidget);
      // Act: the voice is done.
      speech.finishReading();
      await tester.pump();
      // Assert
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });
    testWidgets('stops the voice when tapped while it speaks', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester);
      await tester.tap(find.byTooltip('Écouter'));
      await tester.pump();
      // Act
      await tester.tap(find.byTooltip('Arrêter la lecture'));
      await tester.pump();
      // Assert
      expect(speech.isSpeaking, isFalse);
      expect(find.byTooltip('Écouter'), findsOneWidget);
    });
    testWidgets('is hidden, without a message, when no voice is installed', (
      WidgetTester tester,
    ) async {
      // Arrange
      speech.hasVoice = false;
      // Act
      await pumpQuiz(tester);
      // Assert
      expect(find.byType(ListenButton), findsNothing);
      expect(find.byIcon(Icons.volume_up_rounded), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Touche la bonne réponse'), findsOneWidget);
    });
    testWidgets('is hidden when the quiz has no voice wired', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1170, 2532);
      addTearDown(tester.view.reset);
      await pumpLocalized(
        tester,
        QuizPage(
          request: const QuizRequest(
            profileId: 'profile-1',
            domainId: MultiplicationDomain.domainId,
            mode: QuizMode.freeTraining,
            itemKeys: <String>['mul:4x6'],
            questionTypeIds: <String>[QuestionTypeIds.multipleChoice],
          ),
          useCases: buildTestQuizUseCases(repository: mockRepository),
          ticker: const SilentTicker(),
          domains: buildDomainRegistry(),
          feedback: RecordingGameFeedback(),
          onCompleted: (_) {},
          onLeft: () {},
        ),
      );
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(ListenButton), findsNothing);
    });
    testWidgets('goes away once the question is answered', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.trueFalse);
      expect(find.byType(ListenButton), findsOneWidget);
      // Act
      await tester.tap(find.text('Vrai'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(ListenButton), findsNothing);
    });
    testWidgets('speaks the language of the interface', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1170, 2532);
      addTearDown(tester.view.reset);
      await pumpLocalized(
        tester,
        QuizPage(
          request: const QuizRequest(
            profileId: 'profile-1',
            domainId: MultiplicationDomain.domainId,
            mode: QuizMode.freeTraining,
            itemKeys: <String>['mul:4x6'],
            questionTypeIds: <String>[QuestionTypeIds.typedAnswer],
          ),
          useCases: buildTestQuizUseCases(repository: mockRepository),
          ticker: const SilentTicker(),
          domains: buildDomainRegistry(),
          feedback: RecordingGameFeedback(),
          onCompleted: (_) {},
          onLeft: () {},
          readAloud: buildReadAloudUseCases(speech: speech),
        ),
        locale: const Locale('en'),
      );
      await tester.pumpAndSettle();
      // Act
      await tester.tap(find.byTooltip('Listen'));
      await tester.pump();
      // Assert
      expect(
        speech.spoken.single,
        anyOf('4 times 6 equals what', '6 times 4 equals what'),
      );
      expect(speech.languages.single, 'en');
    });
  });
}
