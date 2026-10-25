import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/entities/word_audio_kind.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/services/word_audio_service.dart';
import 'package:kid_matix/core/widgets/read_aloud_scope.dart';
import 'package:kid_matix/core/widgets/word_audio_scope.dart';
import 'package:kid_matix/core/widgets/word_picture/word_picture_view.dart';
import 'package:kid_matix/features/math_word/domain/entities/audio_pack_manifest.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_player.dart';
import 'package:kid_matix/features/math_word/domain/services/word_audio_service_impl.dart';
import 'package:kid_matix/features/problem/domain/services/problem_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/pages/quiz_page.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/bar_model_view.dart';
import 'package:mocktail/mocktail.dart' hide Answer;

import '../../../helpers/fake_speech_service.dart';
import '../../../helpers/fake_word_audio_service.dart';
import '../../../helpers/pump_localized.dart';
import '../../../helpers/recording_game_feedback.dart';
import '../../../helpers/test_quiz_pages.dart';
import '../helpers/quiz_fixtures.dart';

/// The three formats of the word problems on the quiz screen (lot F30):
/// the bar model, the guided steps and the choice of the operation, with
/// the touchable words and the recorded statement.
void main() {
  late MockQuizSessionRepository mockRepository;
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
    speech = FakeSpeechService(isInstant: true);
  });

  Future<void> pumpQuiz(
    WidgetTester tester, {
    required String itemKey,
    required String questionTypeId,
    required WordAudioService audio,
    bool isBossFight = false,
    Size size = const Size(1170, 2532),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpLocalized(
      tester,
      ReadAloudScope(
        speech: speech,
        child: WordAudioScope(
          audio: audio,
          child: HelpAudioLanguageScope(
            language: 'wo',
            child: QuizPage(
              request: QuizRequest(
                profileId: 'profile-1',
                domainId: ProblemDomain.domainId,
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

  /// Puts [number] on the place named [place] of the bar model.
  Future<void> place(WidgetTester tester, String number, String place) async {
    await tester.tap(find.text(number));
    await tester.pump();
    await tester.ensureVisible(find.text(place));
    await tester.pump();
    await tester.tap(find.text(place));
    await tester.pumpAndSettle();
  }

  group('the recorded statement', () {
    testWidgets('is heard in the help language when its file exists', (
      WidgetTester tester,
    ) async {
      // Arrange
      final FakeWordAudioService audio = FakeWordAudioService(
        recorded: <String>{'problem_mangues_donnees'},
      );
      await pumpQuiz(
        tester,
        itemKey: 'problem:mangues_donnees',
        questionTypeId: QuestionTypeIds.solveProblem,
        audio: audio,
      );
      // Act
      await tester.tap(find.textContaining('wolof'));
      await tester.pump();
      // Assert
      expect(audio.played, <String>['wo:problem_mangues_donnees:explanation']);
    });

    testWidgets('has no button while the pack holds no file', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'problem:mangues_donnees',
        questionTypeId: QuestionTypeIds.solveProblem,
        audio: FakeWordAudioService(),
      );
      // Assert
      expect(find.textContaining('wolof'), findsNothing);
      expect(find.textContaining('Awa a 12 mangues'), findsOneWidget);
    });

    testWidgets('is never offered for a statement with drawn numbers', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'problem:mangues_donnees',
        questionTypeId: QuestionTypeIds.problemOperation,
        audio: FakeWordAudioService(
          recorded: <String>{
            'problem_mangues_donnees',
          },
        ),
      );
      // Assert
      expect(currentQuestion(tester).recordingKey, isNull);
      expect(find.textContaining('wolof'), findsNothing);
    });
  });

  group('the guided steps', () {
    testWidgets('go from the listening to the check, and answer right', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'problem:mangues_donnees',
        questionTypeId: QuestionTypeIds.solveProblem,
        audio: FakeWordAudioService(),
      );
      // Assert
      expect(find.text('Résous le problème'), findsOneWidget);
      expect(find.text('Étape 1 sur 5'), findsOneWidget);
      // Act: listen, put the numbers, pick the operation, the result.
      await tester.tap(find.text("J'ai écouté"));
      await tester.pumpAndSettle();
      expect(find.text('Étape 2 sur 5'), findsOneWidget);
      await place(tester, '12', 'le tout');
      await place(tester, '5', 'une partie');
      expect(find.text('Étape 3 sur 5'), findsOneWidget);
      await tester.tap(find.text('−'));
      await tester.pumpAndSettle();
      expect(find.text('Étape 4 sur 5'), findsOneWidget);
      await tester.tap(find.text('7'));
      await tester.pumpAndSettle();
      // Assert: the check step shows the sentence of the table.
      expect(find.text('Étape 5 sur 5'), findsOneWidget);
      expect(
        find.textContaining(
          '5 + 7 = 12, c\'est bien le nombre de mangues d\'Awa',
        ),
        findsOneWidget,
      );
      // Act
      await tester.tap(find.text("J'ai vérifié"));
      await tester.pumpAndSettle();
      // Assert
      expect(find.textContaining('Bravo'), findsOneWidget);
    });
  });

  group('the bar model', () {
    testWidgets('keeps a wrong touch as a mistake and says so kindly', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'problem:mangues_donnees',
        questionTypeId: QuestionTypeIds.barModel,
        audio: FakeWordAudioService(),
      );
      final BarModelPicture model =
          currentQuestion(tester).picture! as BarModelPicture;
      expect(find.byType(BarModelView), findsOneWidget);
      // Act: the part put on the whole is wrong, the board goes on.
      await place(tester, '${model.values[BarRole.partA]}', 'le tout');
      // Assert
      expect(find.textContaining('Relis'), findsOneWidget);
      expect(find.text('Étape 1 sur 3'), findsOneWidget);
    });

    testWidgets('is right when no step is missed, and wrong otherwise', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'problem:mangues_donnees',
        questionTypeId: QuestionTypeIds.barModel,
        audio: FakeWordAudioService(),
      );
      final BarModelPicture model =
          currentQuestion(tester).picture! as BarModelPicture;
      final int whole = model.values.values.first;
      final int part = model.values.values.elementAt(1);
      // Act: the part first on the whole (a mistake), then the right ones.
      await place(tester, '$part', 'le tout');
      await place(tester, '$whole', 'le tout');
      await place(tester, '$part', 'une partie');
      await tester.tap(find.text('+'));
      await tester.pump();
      await tester.tap(find.text('−'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('${whole - part}'));
      await tester.pumpAndSettle();
      // Assert: two mistakes make the problem wrong, and its correction
      // shows the finished bar model.
      expect(find.textContaining('Presque'), findsOneWidget);
      expect(find.text("Le schéma de l'histoire"), findsOneWidget);
      expect(find.byType(BarModelView), findsOneWidget);
    });

    testWidgets('solves the trap: the whole is the answer, parts either way', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpQuiz(
        tester,
        itemKey: 'problem:mangues_donnees_piege',
        questionTypeId: QuestionTypeIds.barModel,
        audio: FakeWordAudioService(),
      );
      final BarModelPicture model =
          currentQuestion(tester).picture! as BarModelPicture;
      final int given = model.values[model.shape.roles[1]]!;
      final int left = model.values[model.shape.roles[2]]!;
      // Act: the two parts are interchangeable, the sum is asked.
      await place(tester, '$left', 'une partie');
      await place(tester, '$given', "l'autre partie");
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('${given + left}'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.textContaining('Bravo'), findsOneWidget);
    });
  });

  group('the operation of a statement', () {
    testWidgets('has touchable words, then shows the model once answered', (
      WidgetTester tester,
    ) async {
      // Arrange
      final FakeWordAudioService audio = FakeWordAudioService(
        recorded: <String>{'donner'},
      );
      await pumpQuiz(
        tester,
        itemKey: 'problem:mangues_donnees',
        questionTypeId: QuestionTypeIds.problemOperation,
        audio: audio,
      );
      // Act: the colored words explain themselves.
      await tester.tap(find.text('donne').first);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(WordPictureView), findsOneWidget);
      expect(audio.played, <String>['wo:donner:explanation']);
      expect(find.byType(BarModelView), findsNothing);
      // Act: the real operation is a subtraction, whatever the words say.
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      // Assert: a wrong answer shows the finished bar model.
      expect(find.textContaining('Presque'), findsOneWidget);
      expect(find.byType(BarModelView), findsOneWidget);
    });
  });

  group('the "done when" of the lot, with a test manifest', () {
    /// The audio service over a Wolof pack, played by [player].
    WordAudioServiceImpl packOf(
      _RecordingPlayer player, {
      required Map<String, Map<WordAudioKind, String>> files,
    }) {
      return WordAudioServiceImpl(
        packs: <AudioPackManifest>[
          AudioPackManifest(language: 'wo', files: files),
        ],
        player: player,
      );
    }

    testWidgets('has no recording to hear while the Wolof pack is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      final _RecordingPlayer player = _RecordingPlayer();
      await pumpQuiz(
        tester,
        itemKey: 'problem:mangues_donnees',
        questionTypeId: QuestionTypeIds.solveProblem,
        audio: packOf(
          player,
          files: const <String, Map<WordAudioKind, String>>{},
        ),
      );
      // Assert
      expect(find.textContaining('Awa a 12 mangues'), findsOneWidget);
      expect(find.textContaining('wolof'), findsNothing);
      expect(player.played, isEmpty);
    });

    testWidgets(
      'hears « Awa a 12 mangues » in Wolof, draws it, then the trap',
      (
        WidgetTester tester,
      ) async {
        // Arrange
        final _RecordingPlayer player = _RecordingPlayer();
        final WordAudioServiceImpl audio = packOf(
          player,
          files: const <String, Map<WordAudioKind, String>>{
            'problem_mangues_donnees': <WordAudioKind, String>{
              WordAudioKind.explanation: 'wo_problem_mangues_donnees.m4a',
            },
          },
        );
        await pumpQuiz(
          tester,
          itemKey: 'problem:mangues_donnees',
          questionTypeId: QuestionTypeIds.solveProblem,
          audio: audio,
        );
        // Act: the recorded statement is played.
        await tester.tap(find.textContaining('wolof'));
        await tester.pump();
        // Assert
        expect(player.played, <String>[
          'audio/wo/wo_problem_mangues_donnees.m4a',
        ]);
        // Act: the bar model, 12 - 5 = 7, with no mistake.
        await tester.tap(find.text("J'ai écouté"));
        await tester.pumpAndSettle();
        await place(tester, '12', 'le tout');
        await place(tester, '5', 'une partie');
        await tester.tap(find.text('−'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('7'));
        await tester.pumpAndSettle();
        await tester.tap(find.text("J'ai vérifié"));
        await tester.pumpAndSettle();
        // Assert
        expect(find.textContaining('Bravo'), findsOneWidget);
      },
    );

    testWidgets('shows the bar model in the correction of the trap', (
      WidgetTester tester,
    ) async {
      // Arrange: « Awa donne 5 mangues, il lui en reste 7 » (the whole is
      // asked); the child subtracts, as the word « donne » suggests.
      await pumpQuiz(
        tester,
        itemKey: 'problem:mangues_donnees_piege',
        questionTypeId: QuestionTypeIds.problemOperation,
        audio: FakeWordAudioService(),
      );
      final BarModelPicture model =
          currentQuestion(tester).picture! as BarModelPicture;
      // Act
      await tester.tap(find.text('−'));
      await tester.pumpAndSettle();
      // Assert: the answer is wrong, and the drawing shows the story.
      expect(find.textContaining('Presque'), findsOneWidget);
      expect(find.text("Le schéma de l'histoire"), findsOneWidget);
      expect(model.operator, MathOperator.add);
      expect(model.unknown, BarRole.whole);
    });
  });

  group('at 130 % on a small phone', () {
    for (final String typeId in <String>[
      QuestionTypeIds.solveProblem,
      QuestionTypeIds.barModel,
      QuestionTypeIds.problemOperation,
    ]) {
      for (final bool isBoss in <bool>[false, true]) {
        if (isBoss && typeId != QuestionTypeIds.problemOperation) continue;
        testWidgets('cuts nothing of $typeId${isBoss ? ' (boss)' : ''}', (
          WidgetTester tester,
        ) async {
          // Act
          await pumpQuiz(
            tester,
            itemKey: 'problem:mangues_de_plus_que_piege',
            questionTypeId: typeId,
            audio: FakeWordAudioService(),
            isBossFight: isBoss,
            size: const Size(1080, 2220),
            textScale: 1.3,
          );
          // Assert
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}

/// A player that makes no sound and keeps the files it was asked to play.
final class _RecordingPlayer implements WordAudioPlayer {
  final List<String> played = <String>[];

  @override
  Future<void> play(String assetPath) async => played.add(assetPath);

  @override
  Future<void> playFile(String path) async => played.add(path);

  @override
  Future<void> stop() async {}
}
