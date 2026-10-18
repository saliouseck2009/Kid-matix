import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/widgets/help_audio_button.dart';
import 'package:kid_matix/core/widgets/listen_button.dart';
import 'package:kid_matix/core/widgets/monster_painter.dart';
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
import 'package:kid_matix/features/quiz/presentation/widgets/clock_header.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/compare_answers.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/lives_header.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/match_pairs_answers.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/multiple_choice_answers.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/question_card.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_feedback_panel.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_header.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_help_card.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_hint_box.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_labels.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_timer_bar.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/touch_words_board.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/true_false_answers.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/word_picture_choices.dart';

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
    final Duration? totalTime = data.run.totalTimeLimit;
    final int? lives = data.run.lives;
    final Widget? listenButton = data.canReadAloud
        ? ListenButton(
            isSpeaking: data.isReading && !data.isReadingInstruction,
            onPressed: () =>
                context.read<QuizBloc>().add(const ReadAloudToggled()),
          )
        : null;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: <Widget>[
          if (totalTime != null)
            ClockHeader(
              timeLeft: totalTime - data.playedTime,
              totalTime: totalTime,
              score: data.run.correctCount,
              onQuit: onQuit,
            )
          else if (lives != null)
            LivesHeader(
              livesLeft: data.run.livesLeft ?? 0,
              lives: lives,
              score: data.run.correctCount,
              onQuit: onQuit,
            )
          else if (boss == null)
            QuizHeader(
              current: data.rank,
              answeredCount: data.run.answers.length,
              total: data.run.turnCount,
              onQuit: onQuit,
              combo: data.run.combo,
            )
          else
            BossHeader(
              title: labels.describeBoss(data.question, data.run.domainId),
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
              null when data.asksPairs && data.feedback == null =>
                MatchPairsAnswers(
                  key: ValueKey<int>(data.run.answers.length),
                  pairs: data.question.pairs,
                  results: data.question.choices,
                  onMatched: (Answer answer) => context.read<QuizBloc>().add(
                    AnswerSubmitted(answer: answer),
                  ),
                  listenButton: listenButton,
                ),
              null when data.asksTouch => TouchWordsBoard(
                sentence: data.question.sentence,
                targetKey: (data.question.expectedAnswer as WordAnswer).wordKey,
                targetAnswer: data.question.expectedAnswer,
                onUnderstood: data.feedback == null
                    ? (Answer answer) => context.read<QuizBloc>().add(
                        AnswerSubmitted(answer: answer),
                      )
                    : null,
                listenButton: listenButton,
              ),
              null when boss != null => BossArena(
                monsterNumber: _monsterNumberOf(data),
                monsterFamily: MonsterIllustration.familyOf(data.run.domainId),
                prompt: data.question.prompt,
                picture: data.question.picture,
                spokenText: labels.speakQuestion(
                  data.question,
                  data.run.domainId,
                ),
                blowCount: data.run.answers.length,
                blow: data.feedback?.bossBlow,
                outcome: data.run.bossOutcome,
                blankText: data.typedDigits,
                blankColor: data.isRight == null
                    ? null
                    : _blankColor(context, data),
                listenButton: listenButton,
              ),
              null when data.asksPairs => MatchPairsAnswers(
                pairs: data.question.pairs,
                results: data.question.choices,
                onMatched: null,
              ),
              null => QuestionCard(
                label: labels.describeQuestion(
                  data.question,
                  data.run.domainId,
                ),
                asksOperation:
                    data.question.questionTypeId ==
                    QuestionTypeIds.findOperation,
                prompt: data.question.prompt,
                picture: data.question.picture,
                spokenText: labels.speakQuestion(
                  data.question,
                  data.run.domainId,
                ),
                blankText: data.typedDigits,
                blankColor: _blankColor(context, data),
                mascotMood: _moodOf(data),
                mascotMessage: _mascotMessage(context, data),
                listenButton: listenButton,
                wrapsPrompt:
                    data.question.questionTypeId ==
                    QuestionTypeIds.whichOperation,
                extra: switch (data.question) {
                  Question(
                    questionTypeId: QuestionTypeIds.listenAndTouch,
                    expectedAnswer: WordAnswer(:final String wordKey),
                  ) =>
                    HelpAudioButton(wordKey: wordKey),
                  _ => null,
                },
              ),
            },
          ),
          if (!data.hasBoard || data.feedback != null)
            _AnswerZone(data: data, labels: labels),
        ],
      ),
    );
  }

  /// Face of the mascot: happy after a right answer, encouraging after a
  /// mistake.
  MascotMood _moodOf(_PlayData data) {
    return switch (data.isRight) {
      true => MascotMood.happy,
      false => MascotMood.encouraging,
      null => MascotMood.neutral,
    };
  }

  /// What the mascot says: a kind word after a mistake, a cheer at a
  /// combo milestone.
  String? _mascotMessage(BuildContext context, _PlayData data) {
    final int combo = data.run.combo;
    return switch (data.isRight) {
      false => context.l10n.mascotEncouragement,
      true when QuizCombo.isMilestone(combo) => context.l10n.mascotComboCheer(
        combo,
      ),
      _ => null,
    };
  }

  /// Number of the monster of a fight: the number of its table.
  int _monsterNumberOf(_PlayData data) {
    return labels.unitNumberOf(data.question, data.run.domainId) ?? 1;
  }

  /// Help card of a fact just missed for the second time, or `null`.
  ItemHelp? _helpOf(_PlayData data) {
    if (data.isRight != false || data.run.isNonStop) return null;
    final String itemKey = data.answeredItemKey;
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
    required this.playedTime,
    this.typedDigits,
    this.feedback,
    this.timer,
    this.canReadAloud = false,
    this.isReading = false,
    this.isReadingInstruction = false,
  });

  factory _PlayData.of(QuizState state) {
    return switch (state) {
      QuizShowingFeedback(:final submission) => _PlayData(
        run: submission.run,
        question: submission.turn.question,
        rank: submission.run.answers.length,
        playedTime: state.playedTime,
        typedDigits: _typedOf(state.givenAnswer, submission.turn.question),
        feedback: state,
        timer: _frozenTimer(submission.answeredTimeLimit, submission),
      ),
      _ => _PlayData(
        run: (state as QuizAsking).run,
        question: state.turn.question,
        rank: state.answeredCount + 1,
        playedTime: state.playedTime,
        typedDigits: state.typedDigits.isEmpty ? null : state.typedDigits,
        timer: switch (state.remainingFraction) {
          final double fraction => (fraction, state.isRunningOut),
          null => null,
        },
        canReadAloud: state.canReadAloud,
        isReading: state.isReading,
        isReadingInstruction: state.isReadingInstruction,
      ),
    };
  }

  final QuizRun run;
  final Question question;
  final int rank;
  final Duration playedTime;
  final String? typedDigits;
  final QuizShowingFeedback? feedback;

  /// Fraction of the time left and whether it runs out; `null` without
  /// a timer. Frozen at the answer during the feedback, so nothing jumps.
  final (double, bool)? timer;

  /// Whether the listen button shows: a voice exists and the question
  /// still waits for its answer.
  final bool canReadAloud;

  /// Whether a voice is reading, the question or its instruction.
  final bool isReading;

  /// Whether what the voice reads is the instruction under the answers.
  final bool isReadingInstruction;

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

  /// Whether the question asks to match pairs: its board takes the room
  /// of the question card and of the answers.
  bool get asksPairs => question.pairs.isNotEmpty;

  /// Whether the question asks to touch the words of a sentence: its board
  /// takes the room of the question card and of the answers.
  bool get asksTouch => question.sentence.isNotEmpty;

  /// Whether a board of its own replaces the card and the answers.
  bool get hasBoard => asksPairs || asksTouch;

  /// Item the answer was judged on: the question's, or the first pair
  /// missed when matching pairs.
  String get answeredItemKey =>
      feedback?.submission.answer.itemKey ?? question.itemKey;

  bool get isWritten =>
      question.choices.isEmpty &&
      !asksTouch &&
      question.questionTypeId != QuestionTypeIds.trueFalse;

  /// What fills the blank once answered: the digits written, or the
  /// sign picked between two numbers.
  static String? _typedOf(Answer? given, Question question) {
    return switch (given) {
      ComparisonAnswer(:final comparison) => CompareAnswers.signOf(comparison),
      NumberAnswer(:final int value) when question.choices.isEmpty => '$value',
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
        else if (question.questionTypeId == QuestionTypeIds.compare)
          CompareAnswers(feedbackOf: data.feedbackOf, onPicked: onPicked)
        else if (question.questionTypeId == QuestionTypeIds.listenAndTouch)
          WordPictureChoices(
            choices: question.choices,
            feedbackOf: data.feedbackOf,
            onPicked: onPicked,
          )
        else if (!data.isWritten && !data.asksPairs && !data.asksTouch)
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
        else if (labels.describeHint(question) case final String hint)
          QuizHintBox(
            hint: hint,
            listenButton: data.canReadAloud
                ? ListenButton(
                    isSpeaking: data.isReading && data.isReadingInstruction,
                    onPressed: () => bloc.add(
                      const ReadAloudToggled(isInstruction: true),
                    ),
                  )
                : null,
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
        : labels.describeMirror(data.answeredItemKey, data.run.domainId);
    return QuizFeedbackPanel(
      isRight: isRight,
      title: isRight
          ? context.l10n.quizFeedbackRight
          : isTimedOut
          ? context.l10n.quizFeedbackTimeUp
          : context.l10n.quizFeedbackWrong,
      detail: isRight
          ? _rightDetail(context, feedback, isLightning)
          : labels.describeItem(data.answeredItemKey, data.run.domainId),
      reminder: mirror == null ? null : context.l10n.quizMirrorReminder(mirror),
      onContinue: data.run.isNonStop
          ? null
          : () => context.read<QuizBloc>().add(const NextRequested()),
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
