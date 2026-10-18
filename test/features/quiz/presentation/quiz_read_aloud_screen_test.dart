import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/widgets/listen_button.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/number/domain/services/numbers_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/pages/quiz_page.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/boss_arena.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

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
    bool readsByItself = false,
    String domainId = MultiplicationDomain.domainId,
    List<String> itemKeys = const <String>['mul:4x6', 'mul:5x8'],
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      QuizPage(
        request: QuizRequest(
          profileId: 'profile-1',
          domainId: domainId,
          mode: isBossFight ? QuizMode.path : QuizMode.freeTraining,
          itemKeys: itemKeys,
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
        readAloud: buildReadAloudUseCases(
          speech: speech,
          readsByItself: readsByItself,
        ),
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
        await tester.tap(find.byTooltip('Écouter').first);
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
      expect(find.byIcon(Icons.volume_up_rounded), findsNWidgets(2));
      expect(
        tester.getSemantics(find.byType(ListenButton).first),
        isSemantics(isButton: true, tooltip: 'Écouter', hasTapAction: true),
      );
      final Size actualSize = tester.getSize(find.byType(ListenButton).first);
      expect(actualSize.width, greaterThanOrEqualTo(48));
      expect(actualSize.height, greaterThanOrEqualTo(48));
    });
    testWidgets('becomes a stop button while the voice speaks', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester);
      // Act
      await tester.tap(find.byTooltip('Écouter').first);
      await tester.pump();
      // Assert: only the button of the question is a stop sign.
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(find.byTooltip('Arrêter la lecture'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
      // Act: the voice is done.
      speech.finishReading();
      await tester.pump();
      // Assert
      expect(find.byIcon(Icons.volume_up_rounded), findsNWidgets(2));
    });
    testWidgets('stops the voice when tapped while it speaks', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester);
      await tester.tap(find.byTooltip('Écouter').first);
      await tester.pump();
      // Act
      await tester.tap(find.byTooltip('Arrêter la lecture'));
      await tester.pump();
      // Assert
      expect(speech.isSpeaking, isFalse);
      expect(find.byTooltip('Écouter'), findsNWidgets(2));
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
      expect(find.byType(ListenButton), findsNWidgets(2));
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

  group('The listen button of the formats of the numbers', () {
    for (final (
          String name,
          String itemKey,
          String typeId,
          String sentence,
          String hint,
        )
        in <(String, String, String, String, String)>[
          (
            'count the objects',
            'num:count:7',
            QuestionTypeIds.countObjects,
            'Combien de mangues\u00a0?',
            'Touche la bonne réponse',
          ),
          (
            'tens and ones',
            'num:place:34',
            QuestionTypeIds.tensAndOnes,
            '3 paquets de dix et 4 bâtonnets\u00a0: quel nombre\u00a0?',
            '',
          ),
          (
            'compare',
            'num:compare:34:43',
            QuestionTypeIds.compare,
            '34 est-il plus petit, égal ou plus grand que '
                '43\u00a0?',
            'Touche le bon signe',
          ),
          (
            'number line',
            'num:line:8:2',
            QuestionTypeIds.numberLine,
            'Droite des nombres\u00a0: 2, 4, 6, nombre caché, 10. '
                'Quel nombre manque\u00a0?',
            'Touche la bonne réponse',
          ),
        ]) {
      testWidgets('reads the $name question with its sentence', (
        WidgetTester tester,
      ) async {
        // Arrange
        await pumpQuiz(
          tester,
          domainId: NumbersDomain.domainId,
          itemKeys: <String>[itemKey],
          questionTypeId: typeId,
        );
        // Act
        await tester.tap(find.byTooltip('Écouter').first);
        await tester.pump();
        // Assert: the voice and the screen reader say the same sentence.
        expect(speech.spoken, <String>[sentence]);
        expect(find.bySemanticsLabel(sentence), findsOneWidget);
        if (hint.isNotEmpty) {
          expect(find.text(hint), findsOneWidget);
          await tester.tap(find.byTooltip('Écouter').last);
          await tester.pump();
          expect(speech.spoken.last, hint);
        }
      });
    }
    testWidgets('has no instruction button on the keypad format', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpQuiz(
        tester,
        domainId: NumbersDomain.domainId,
        itemKeys: const <String>['num:place:34'],
        questionTypeId: QuestionTypeIds.typedAnswer,
      );
      // Assert
      expect(find.byType(ListenButton), findsOneWidget);
    });
    testWidgets('reads a numbers question by itself when the setting is on', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpQuiz(
        tester,
        domainId: NumbersDomain.domainId,
        itemKeys: const <String>['num:compare:34:43'],
        questionTypeId: QuestionTypeIds.compare,
        readsByItself: true,
      );
      // Assert
      expect(speech.spoken, <String>[
        '34 est-il plus petit, égal ou plus grand que 43\u00a0?',
      ]);
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    });
    testWidgets('reads a drawn question by itself when the setting is on', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpQuiz(
        tester,
        domainId: NumbersDomain.domainId,
        itemKeys: const <String>['num:count:7'],
        questionTypeId: QuestionTypeIds.countObjects,
        readsByItself: true,
      );
      // Assert
      expect(speech.spoken, <String>['Combien de mangues\u00a0?']);
    });
    testWidgets('gives the boss fight of a numbers unit its listen button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        domainId: NumbersDomain.domainId,
        itemKeys: const <String>['num:tens:30'],
        questionTypeId: QuestionTypeIds.tensAndOnes,
        isBossFight: true,
      );
      expect(find.byType(BossArena), findsOneWidget);
      // Act
      await tester.tap(find.byTooltip('Écouter').first);
      await tester.pump();
      // Assert
      expect(speech.spoken, <String>[
        '3 paquets de dix et aucun bâtonnet\u00a0: quel nombre\u00a0?',
      ]);
    });
    testWidgets('gives the boss fight of a number line its listen button', (
      WidgetTester tester,
    ) async {
      // Arrange: the prompt of a number line is empty.
      await pumpQuiz(
        tester,
        domainId: NumbersDomain.domainId,
        itemKeys: const <String>['num:after:39'],
        questionTypeId: QuestionTypeIds.typedAnswer,
        isBossFight: true,
      );
      // Act
      await tester.tap(find.byTooltip('Écouter').first);
      await tester.pump();
      // Assert
      expect(speech.spoken.single, startsWith('Droite des nombres'));
      expect(
        find.bySemanticsLabel(RegExp('^Droite des nombres')),
        findsOneWidget,
      );
    });
  });

  group('The listen button of the instruction', () {
    testWidgets('reads "Touche la bonne réponse"', (WidgetTester tester) async {
      // Arrange
      await pumpQuiz(tester);
      expect(find.byType(ListenButton), findsNWidgets(2));
      // Act
      await tester.tap(find.byType(ListenButton).last);
      await tester.pump();
      // Assert
      expect(speech.spoken, <String>['Touche la bonne réponse']);
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    });
    testWidgets('reads the instruction of a true or false question', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.trueFalse);
      // Act
      await tester.tap(find.byType(ListenButton).last);
      await tester.pump();
      // Assert
      expect(speech.spoken, <String>['Ce calcul est-il juste\u00a0?']);
    });
    testWidgets('is absent where the answer is written on the keypad', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpQuiz(tester, questionTypeId: QuestionTypeIds.typedAnswer);
      // Assert
      expect(find.byType(ListenButton), findsOneWidget);
    });
    testWidgets('is hidden with the other button when no voice exists', (
      WidgetTester tester,
    ) async {
      // Arrange
      speech.hasVoice = false;
      // Act
      await pumpQuiz(tester);
      // Assert
      expect(find.byType(ListenButton), findsNothing);
      expect(find.text('Touche la bonne réponse'), findsOneWidget);
    });
  });

  group('A quiz of a player who has the questions read by themselves', () {
    testWidgets('reads the first question as soon as it shows', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpQuiz(tester, readsByItself: true);
      // Assert
      expect(speech.spoken.single, matches(_operation));
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    });
    testWidgets('reads nothing by itself when no voice is installed', (
      WidgetTester tester,
    ) async {
      // Arrange
      speech.hasVoice = false;
      // Act
      await pumpQuiz(tester, readsByItself: true);
      // Assert
      expect(speech.spoken, isEmpty);
      expect(find.byType(ListenButton), findsNothing);
    });
    testWidgets('reads the next question once the first one is answered', (
      WidgetTester tester,
    ) async {
      // Arrange
      speech.isInstant = true;
      await pumpQuiz(tester, readsByItself: true);
      final QuizAsking inputAsking =
          BlocProvider.of<QuizBloc>(tester.element(find.byType(Scaffold))).state
              as QuizAsking;
      final int inputResult =
          (inputAsking.turn.question.expectedAnswer as NumberAnswer).value;
      // Act
      await tester.tap(find.text('$inputResult'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      // Assert
      expect(speech.spoken, hasLength(2));
    });
  });
}
