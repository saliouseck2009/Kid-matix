import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_combo.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_submission.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_time_limits.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/answer_feedback.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/answer_keypad.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/boss_arena.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/boss_header.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/multiple_choice_answers.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/question_card.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_feedback_panel.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_header.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_help_card.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_hint_box.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_timer_bar.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/true_false_answers.dart';

/// A question of the quiz, waiting for an answer or showing its feedback.
class QuizPlayView extends StatelessWidget {
  /// Creates the view of [state], a [QuizAsking] or [QuizShowingFeedback].
  const QuizPlayView({
    required this.state,
    required this.labels,
    required this.onQuit,
    super.key,
  });

  /// State shown.
  final QuizState state;

  /// Texts that depend on the learning domain.
  final QuizLabels labels;

  /// Called by the quit cross.
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final _PlayData data = _PlayData.of(state);
    final BossFight? boss = data.run.boss;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          if (boss == null)
            QuizHeader(
              current: data.rank,
              answeredCount: data.run.answers.length,
              total: data.run.turnCount,
              onQuit: onQuit,
              combo: data.run.combo,
            )
          else
            BossHeader(
              title: labels.describeBoss(
                _monsterNumberOf(data),
                data.run.domainId,
              ),
              boss: boss,
              onQuit: onQuit,
            ),
          if (data.timer case (
            final double remainingFraction,
            final bool isRunningOut,
          ))
            QuizTimerBar(
              remainingFraction: remainingFraction,
              isRunningOut: isRunningOut,
            ),
          Expanded(
            child: switch (_helpOf(data)) {
              final ItemHelp help => QuizHelpCard(
                help: help,
                unitName: labels.describeUnitOf(
                  data.question,
                  data.run.domainId,
                ),
              ),
              null when boss != null => BossArena(
                monsterNumber: _monsterNumberOf(data),
                prompt: data.question.prompt,
                blowCount: data.run.answers.length,
                blow: data.feedback?.bossBlow,
                outcome: data.run.bossOutcome,
                blankText: data.typedDigits,
                blankColor: data.isRight == null
                    ? null
                    : _blankColor(context, data),
              ),
              null => QuestionCard(
                label: labels.describeQuestion(
                  data.question,
                  data.run.domainId,
                ),
                prompt: data.question.prompt,
                blankText: data.typedDigits,
                blankColor: _blankColor(context, data),
              ),
            },
          ),
          _AnswerZone(data: data, labels: labels),
        ],
      ),
    );
  }

  /// Number of the monster of a fight: the number of its table.
  int _monsterNumberOf(_PlayData data) {
    return labels.unitNumberOf(data.question, data.run.domainId) ?? 1;
  }

  /// Help card of a fact just missed for the second time, or `null`.
  ItemHelp? _helpOf(_PlayData data) {
    if (data.isRight != false) return null;
    final String itemKey = data.question.itemKey;
    if (!data.run.needsHelp(itemKey)) return null;
    return labels.helpOf(itemKey, data.run.domainId);
  }

  Color? _blankColor(BuildContext context, _PlayData data) {
    final bool? isRight = data.isRight;
    if (isRight == null) return context.palette.primaryText;
    return isRight
        ? context.feedbackPalette.right
        : context.feedbackPalette.wrong;
  }
}

/// What the view needs from a [QuizAsking] or [QuizShowingFeedback].
final class _PlayData {
  const _PlayData({
    required this.run,
    required this.question,
    required this.rank,
    this.typedDigits,
    this.feedback,
    this.timer,
  });

  factory _PlayData.of(QuizState state) {
    return switch (state) {
      QuizShowingFeedback(:final submission) => _PlayData(
        run: submission.run,
        question: submission.turn.question,
        rank: submission.run.answers.length,
        typedDigits: _typedOf(state.givenAnswer, submission.turn.question),
        feedback: state,
        timer: _frozenTimer(submission.run.timeLimit, submission),
      ),
      _ => _PlayData(
        run: (state as QuizAsking).run,
        question: state.turn.question,
        rank: state.answeredCount + 1,
        typedDigits: state.typedDigits.isEmpty ? null : state.typedDigits,
        timer: switch (state.remainingFraction) {
          final double fraction => (fraction, state.isRunningOut),
          null => null,
        },
      ),
    };
  }

  final QuizRun run;
  final Question question;
  final int rank;
  final String? typedDigits;
  final QuizShowingFeedback? feedback;

  /// Fraction of the time left and whether it runs out; `null` without
  /// a timer. Frozen at the answer during the feedback, so nothing jumps.
  final (double, bool)? timer;

  static (double, bool)? _frozenTimer(
    Duration? limit,
    QuizSubmission submission,
  ) {
    if (limit == null) return null;
    final Duration left = limit - submission.answer.answerTime;
    final double fraction = left.inMilliseconds / limit.inMilliseconds;
    return (fraction.clamp(0, 1), left <= QuizTimeLimits.warning);
  }

  bool? get isRight => feedback?.submission.answer.isCorrect;

  bool get isWritten =>
      question.choices.isEmpty &&
      question.questionTypeId != QuestionTypeIds.trueFalse;

  static String? _typedOf(Answer? given, Question question) {
    if (question.choices.isNotEmpty) return null;
    return switch (given) {
      NumberAnswer(:final int value) => '$value',
      _ => null,
    };
  }

  AnswerFeedback feedbackOf(Answer answer) {
    final QuizShowingFeedback? shown = feedback;
    if (shown == null) return AnswerFeedback.none;
    if (answer == question.expectedAnswer) return AnswerFeedback.right;
    if (answer == shown.givenAnswer) return AnswerFeedback.wrong;
    return AnswerFeedback.none;
  }
}

class _AnswerZone extends StatelessWidget {
  const _AnswerZone({required this.data, required this.labels});

  final _PlayData data;
  final QuizLabels labels;

  @override
  Widget build(BuildContext context) {
    final QuizBloc bloc = context.read<QuizBloc>();
    final bool isAsking = data.feedback == null;
    final ValueChanged<Answer>? onPicked = isAsking
        ? (Answer answer) => bloc.add(AnswerSubmitted(answer: answer))
        : null;
    final Question question = data.question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: <Widget>[
        if (question.questionTypeId == QuestionTypeIds.trueFalse)
          TrueFalseAnswers(feedbackOf: data.feedbackOf, onPicked: onPicked)
        else if (!data.isWritten)
          MultipleChoiceAnswers(
            choices: question.choices,
            feedbackOf: data.feedbackOf,
            onPicked: onPicked,
          ),
        if (!isAsking)
          _Feedback(data: data, labels: labels)
        else if (data.isWritten)
          AnswerKeypad(
            onDigit: (int digit) => bloc.add(DigitTyped(digit: digit)),
            onErase: () => bloc.add(const DigitErased()),
            onValidate: data.typedDigits == null
                ? null
                : () => bloc.add(const TypedAnswerValidated()),
          )
        else
          QuizHintBox(
            hint: question.questionTypeId == QuestionTypeIds.trueFalse
                ? context.l10n.quizHintTrueFalse
                : context.l10n.quizHintMultipleChoice,
          ),
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.data, required this.labels});

  final _PlayData data;
  final QuizLabels labels;

  @override
  Widget build(BuildContext context) {
    final QuizShowingFeedback feedback = data.feedback!;
    final bool isRight = feedback.submission.answer.isCorrect;
    final bool isTimedOut = feedback.submission.answer.isTimedOut;
    final bool isLightning = feedback.submission.answer.isLightning;
    final String? mirror = isRight
        ? null
        : labels.describeMirror(data.question.itemKey, data.run.domainId);
    return QuizFeedbackPanel(
      isRight: isRight,
      title: isRight
          ? context.l10n.quizFeedbackRight
          : isTimedOut
          ? context.l10n.quizFeedbackTimeUp
          : context.l10n.quizFeedbackWrong,
      detail: isRight
          ? _rightDetail(context, feedback, isLightning)
          : labels.describeItem(data.question.itemKey, data.run.domainId),
      reminder: mirror == null ? null : context.l10n.quizMirrorReminder(mirror),
      onContinue: () => context.read<QuizBloc>().add(const NextRequested()),
    );
  }

  /// "Combo de 5 !" at a combo milestone, "Éclair !" for a fast answer.
  String _rightDetail(
    BuildContext context,
    QuizShowingFeedback feedback,
    bool isLightning,
  ) {
    final int combo = feedback.submission.run.combo;
    if (QuizCombo.isMilestone(combo)) {
      return context.l10n.quizComboMilestone(combo);
    }
    return isLightning ? context.l10n.quizLightning : '';
  }
}
