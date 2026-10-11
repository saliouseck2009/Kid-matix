// Plays a Discovery stage on a real phone and records the frame times
// of the quiz, to check it keeps 60 frames per second (F11-02).
// See test_driver/perf_driver.dart for the command.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/multiple_choice_answers.dart';
import 'package:kid_matix/main.dart' as app;

import '../test/helpers/data_state_test_extension.dart';

/// Questions of the Discovery stage.
const int _questionCount = 10;

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  /// Lets the screen react; the quiz never settles, as its timer ticks.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Pumps until [text] is on screen, for at most [timeout].
  Future<bool> waitFor(
    WidgetTester tester,
    String text, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final DateTime end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (find.text(text).evaluate().isNotEmpty) return true;
      await tester.pump(const Duration(milliseconds: 250));
    }
    final Iterable<String?> texts = find
        .byType(Text)
        .evaluate()
        .map((Element element) => (element.widget as Text).data);
    debugPrint('Not found "$text"; on screen: ${texts.toList()}');
    return false;
  }

  /// Taps [text] once it is on screen; returns whether it was.
  Future<bool> tapIfFound(WidgetTester tester, String text) async {
    if (!await waitFor(tester, text)) return false;
    await tester.ensureVisible(find.text(text).first);
    await settle(tester);
    await tester.tap(find.text(text).first);
    await settle(tester);
    return true;
  }

  /// Makes "Perf" the active player, created on the first run: the
  /// creation form is not what this test measures.
  Future<void> reachTheMap(WidgetTester tester) async {
    if (sl<ProfileSessionService>().activeProfileId == null) {
      DataState<ProfileEntity> player = await sl<CreateProfileUseCase>()(
        params: const CreateProfileParams(
          nickname: 'Perf',
          avatar: ProfileAvatar.avatar1,
          color: ProfileColor.violet,
        ),
      );
      if (player is DataFailed<ProfileEntity>) {
        final List<ProfileEntity> players =
            (await sl<GetProfilesUseCase>()()).requireData;
        player = DataSuccess<ProfileEntity>(players.first);
      }
      await sl<SelectProfileUseCase>()(params: player.requireData.id);
    }
    expect(await waitFor(tester, 'Parcours'), isTrue);
  }

  Future<void> answerCurrentQuestion(WidgetTester tester) async {
    final Finder answers = find.byType(MultipleChoiceAnswers);
    expect(answers, findsOneWidget);
    final QuizState state = BlocProvider.of<QuizBloc>(
      tester.element(answers),
    ).state;
    final NumberAnswer expected =
        (state as QuizAsking).turn.question.expectedAnswer as NumberAnswer;
    await tester.tap(
      find.descendant(of: answers, matching: find.text('${expected.value}')),
    );
    await settle(tester);
    await tapIfFound(tester, 'Continuer');
    await settle(tester);
  }

  testWidgets('plays a stage at full speed', (WidgetTester tester) async {
    // Arrange
    await app.main();
    await settle(tester);
    await reachTheMap(tester);
    await tapIfFound(tester, 'Jouer');
    await tapIfFound(tester, 'À moi de jouer');
    // Act
    await binding.traceAction(() async {
      for (int index = 0; index < _questionCount; index++) {
        await waitFor(tester, 'Touche la bonne réponse');
        if (find.byType(MultipleChoiceAnswers).evaluate().isEmpty) break;
        await answerCurrentQuestion(tester);
      }
    }, reportKey: 'quiz');
    // Assert
    expect(find.text('Parcours'), findsNothing);
  });
}
