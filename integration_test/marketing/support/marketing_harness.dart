// Shared setup and gestures of the marketing scenarios: a clean phone, a
// seeded draw of the questions, a silent game, French texts, and pauses a
// viewer can follow. See tool/marketing/README.md.
//
// A scenario erases every player of the phone it runs on. Run it on an
// emulator or a simulator only, through tool/marketing/record.sh.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/services/seeded_random_source.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/answer_keypad.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/multiple_choice_answers.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_play_view.dart';
import 'package:kid_matix/features/setting/data/datasources/language_local_data_source_impl.dart';
import 'package:kid_matix/features/setting/domain/services/sound_player.dart';
import 'package:kid_matix/features/setting/domain/services/vibrator.dart';
import 'package:kid_matix/main.dart' as app;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Seed of the questions: the same scenario draws the same quiz on every
/// run. Change it to film another draw.
const int marketingSeed = 20261106;

/// Line printed once the first screen is shown; `record.sh` starts the
/// screen recording when it reads it.
const String startMarker = 'MARKETING:START';

/// Line printed after the last pause; `record.sh` stops the recording.
const String endMarker = 'MARKETING:END';

/// Pause before each answer, so the viewer reads the question.
const Duration answerPause = Duration(milliseconds: 800);

/// Pause between two ordinary gestures.
const Duration gesturePause = Duration(milliseconds: 600);

/// Time the recorder needs to start and to stop around the markers.
const Duration _recorderMargin = Duration(milliseconds: 1500);

/// Step of the waits: one frame at 30 frames per second, the rate of the
/// exported video.
const Duration _frame = Duration(milliseconds: 33);

/// Seeds the phone once the app has registered its dependencies, before
/// the recording starts.
typedef MarketingSeeder = Future<void> Function();

/// Sets the test binding up for filming: every frame is drawn, as in the
/// real app.
IntegrationTestWidgetsFlutterBinding initMarketingBinding() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  return binding;
}

/// Starts the app on a clean phone and holds the first screen until the
/// recorder runs.
///
/// The overrides are registered before the app's own registrations, which
/// `skipDoubleRegistration` then ignores: nothing in `lib/` knows about
/// the marketing run.
Future<void> startApp(WidgetTester tester, {MarketingSeeder? seed}) async {
  _ignoreGameServices(tester);
  // Letters are sent straight to the text field: the system keyboard would
  // cover half of the screen.
  tester.testTextInput.register();
  await _erasePhoneData();
  sl.skipDoubleRegistration = true;
  sl.registerLazySingleton<RandomSource>(
    () => SeededRandomSource(seed: marketingSeed),
  );
  sl.registerLazySingleton<SoundPlayer>(() => const _SilentSoundPlayer());
  sl.registerLazySingleton<Vibrator>(() => const _StillVibrator());
  await SharedPreferencesAsync().setString(
    LanguageLocalDataSourceImpl.languageKey,
    'fr',
  );
  await app.main();
  if (seed != null) {
    await seed();
    await _skipPlacementOffer(tester);
  }
  await pause(tester, gesturePause);
  // ignore: avoid_print
  print(startMarker);
  await pause(tester, _recorderMargin);
}

/// A player selected from the creation screen is offered the placement
/// test; a seeded player skips it before the recording starts.
Future<void> _skipPlacementOffer(WidgetTester tester) async {
  final Finder skip = findLabel('Passer');
  await waitFor(tester, skip);
  await tester.tap(skip);
  while (skip.evaluate().isNotEmpty) {
    await tester.pump(_frame);
  }
}

/// Holds the last screen, then tells the recorder to stop.
Future<void> endScenario(
  WidgetTester tester, {
  Duration hold = const Duration(seconds: 2),
}) async {
  await pause(tester, hold);
  // ignore: avoid_print
  print(endMarker);
  await pause(tester, _recorderMargin);
}

/// Lets the app run for [duration], drawing every frame.
Future<void> pause(WidgetTester tester, Duration duration) async {
  final DateTime end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(_frame);
  }
}

/// Waits until [finder] finds a widget; fails after [timeout].
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final DateTime end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      final List<String?> texts = find
          .byType(Text)
          .evaluate()
          .map((Element element) => (element.widget as Text).data)
          .toList();
      fail('Not found: $finder. On screen: $texts');
    }
    await tester.pump(_frame);
  }
}

/// Waits for [finder], scrolls to it, pauses, then taps it.
Future<void> tapWhenShown(
  WidgetTester tester,
  Finder finder, {
  Duration before = gesturePause,
}) async {
  await waitFor(tester, finder);
  await tester.ensureVisible(finder.first);
  await pause(tester, before);
  await tester.tap(finder.first);
  await tester.pump(_frame);
}

/// Finds the label showing [text]. French typography puts a no-break
/// space before "!" and "?"; an ordinary space in [text] matches it.
Finder findLabel(String text) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is Text && _plainSpaces(widget.data ?? '') == text,
    description: 'label "$text"',
  );
}

String _plainSpaces(String text) =>
    text.replaceAll(RegExp('[\u00A0\u202F]'), ' ');

/// Taps the button or label showing [text].
Future<void> tapText(
  WidgetTester tester,
  String text, {
  Duration before = gesturePause,
}) {
  return tapWhenShown(tester, findLabel(text), before: before);
}

/// Writes [text] in [field] one letter at a time.
Future<void> typeSlowly(
  WidgetTester tester,
  Finder field,
  String text, {
  Duration perLetter = const Duration(milliseconds: 280),
}) async {
  await waitFor(tester, field);
  for (int length = 1; length <= text.length; length++) {
    await tester.enterText(field, text.substring(0, length));
    await pause(tester, perLetter);
  }
}

/// Answers every question of the quiz on screen with the right answer,
/// after [answerPause] each; returns once the quiz has left the screen.
/// [maxQuestions] stops earlier, for a short clip.
Future<void> playQuiz(WidgetTester tester, {int? maxQuestions}) async {
  await waitFor(tester, find.byType(QuizPlayView));
  int answered = 0;
  while (find.byType(QuizPlayView).evaluate().isNotEmpty) {
    if (maxQuestions != null && answered >= maxQuestions) return;
    final QuizState state = BlocProvider.of<QuizBloc>(
      tester.element(find.byType(QuizPlayView)),
    ).state;
    if (findLabel(_continueLabel).evaluate().isNotEmpty) {
      await tapText(tester, _continueLabel);
    } else if (state is QuizAsking && await _answer(tester, state)) {
      answered++;
    }
    await pause(tester, const Duration(milliseconds: 300));
  }
}

const String _continueLabel = 'Continuer';
const String _validateLabel = 'Valider';

/// Gives the right answer of the question of [state]; returns `false`
/// when the question is not ready to be answered yet.
Future<bool> _answer(WidgetTester tester, QuizAsking state) async {
  final Answer expected = state.turn.question.expectedAnswer;
  if (expected is! NumberAnswer) {
    fail('The marketing scenarios only answer number questions.');
  }
  final Finder choices = find.byType(MultipleChoiceAnswers);
  final Finder keypad = find.byType(AnswerKeypad);
  if (choices.evaluate().isNotEmpty) {
    final Finder right = find.descendant(
      of: choices,
      matching: find.text('${expected.value}'),
    );
    if (right.evaluate().isEmpty) return false;
    await pause(tester, answerPause);
    await tester.tap(right.first);
    return true;
  }
  if (keypad.evaluate().isEmpty) return false;
  await pause(tester, answerPause);
  for (final String digit in '${expected.value}'.split('')) {
    await tester.tap(
      find.descendant(of: keypad, matching: find.text(digit)).first,
    );
    await pause(tester, const Duration(milliseconds: 250));
  }
  await tester.tap(
    find.descendant(of: keypad, matching: find.text(_validateLabel)),
  );
  return true;
}

/// Empties the database and the preferences, so each take starts from the
/// same phone.
Future<void> _erasePhoneData() async {
  await deleteDatabase(join(await getDatabasesPath(), AppDatabase.fileName));
  await SharedPreferencesAsync().clear();
}

/// Answers the Play Games channel locally: no sign-in sheet covers the
/// take, and nothing leaves the emulator.
void _ignoreGameServices(WidgetTester tester) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('games_services'),
    (MethodCall call) async => null,
  );
}

final class _SilentSoundPlayer implements SoundPlayer {
  const _SilentSoundPlayer();

  @override
  Future<void> play(GameFeedback feedback) async {}
}

final class _StillVibrator implements Vibrator {
  const _StillVibrator();

  @override
  Future<void> vibrate(VibrationStrength strength) async {}
}
