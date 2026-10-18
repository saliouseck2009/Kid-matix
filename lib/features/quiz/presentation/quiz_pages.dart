import 'package:flutter/widgets.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/services/game_feedback_service.dart';
import 'package:kid_matix/core/services/ticker.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_request.dart';
import 'package:kid_matix/features/quiz/domain/usecases/get_quiz_result_use_case.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_read_aloud_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_use_cases.dart';
import 'package:kid_matix/features/quiz/presentation/pages/quiz_page.dart';
import 'package:kid_matix/features/quiz/presentation/pages/results_page.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/answer_keypad.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/question_card.dart';

/// Builds the pages of the quiz feature for the router.
///
/// Created at the composition root with the dependencies resolved there,
/// so no widget ever reads the service locator.
final class QuizPages {
  /// Creates the factory.
  const QuizPages({
    required this._useCases,
    required this._getResult,
    required this._ticker,
    required this._domains,
    required this._feedback,
    this._readAloud,
  });

  final QuizUseCases _useCases;
  final GetQuizResultUseCase _getResult;
  final Ticker _ticker;
  final DomainRegistry _domains;
  final GameFeedbackService _feedback;

  // Reads the questions aloud; `null` where no voice is wired.
  final QuizReadAloudUseCases? _readAloud;

  /// Quiz of [profileId] described by [spec].
  Widget buildQuizPage({
    required String profileId,
    required QuizSpec spec,
    required ValueChanged<String> onCompleted,
    required VoidCallback onLeft,
  }) {
    return QuizPage(
      request: QuizRequest.fromSpec(profileId: profileId, spec: spec),
      useCases: _useCases,
      ticker: _ticker,
      domains: _domains,
      feedback: _feedback,
      onCompleted: onCompleted,
      onLeft: onLeft,
      readAloud: _readAloud,
    );
  }

  /// Results of the session [sessionId]; [describeSource] names what the
  /// session was played for, the reward slots show what it earned,
  /// [recordCard] the record it set, [actionOf] a last button and
  /// [outcomeOf] a screen in place of the results.
  Widget buildResultsPage({
    required String sessionId,
    required ValueChanged<String?> onContinue,
    required ValueChanged<String> onReplay,
    SourceDescriber? describeSource,
    Widget Function(Widget child)? rewardsScope,
    Widget? xpTile,
    Widget? rewardsCard,
    Widget? recordCard,
    SessionScoreSlot? actionOf,
    SessionScoreSlot? outcomeOf,
  }) {
    return ResultsPage(
      sessionId: sessionId,
      getResult: _getResult,
      domains: _domains,
      onContinue: onContinue,
      onReplay: onReplay,
      describeSource: describeSource,
      rewardsScope: rewardsScope,
      xpTile: xpTile,
      rewardsCard: rewardsCard,
      recordCard: recordCard,
      actionOf: actionOf,
      outcomeOf: outcomeOf,
    );
  }

  /// The app keypad of the quiz, for a screen of another feature;
  /// [onValidate] is `null` while nothing is typed.
  Widget buildKeypad({
    required ValueChanged<int> onDigit,
    required VoidCallback onErase,
    required VoidCallback? onValidate,
  }) {
    return AnswerKeypad(
      onDigit: onDigit,
      onErase: onErase,
      onValidate: onValidate,
    );
  }

  /// The question card of the quiz, for a screen of another feature:
  /// [label] above [prompt], with [typedDigits] in place of its blank.
  Widget buildQuestionCard({
    required String label,
    required List<PromptToken> prompt,
    String? typedDigits,
  }) {
    return QuestionCard(label: label, prompt: prompt, blankText: typedDigits);
  }
}
