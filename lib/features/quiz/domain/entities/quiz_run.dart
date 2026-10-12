import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_time_schedule.dart';
import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_combo.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:meta/meta.dart';

/// A quiz being played: the questions left and the answers given.
///
/// It lives in memory; the session is written once, when it is completed
/// or abandoned.
@immutable
final class QuizRun {
  /// Creates a run.
  QuizRun({
    required this.sessionId,
    required this.profileId,
    required this.domainId,
    required this.mode,
    required this.startedAt,
    required this.scoredQuestionCount,
    required List<String> questionTypeIds,
    required List<QuizTurn> queue,
    List<QuizAnswerEntity> answers = const <QuizAnswerEntity>[],
    this.timeLimit,
    this.totalTimeLimit,
    this.sourceKey,
    this.boss,
    this.lives,
    this.timeSchedule,
    Map<String, int> timeFactors = const <String, int>{},
  }) : questionTypeIds = List<String>.unmodifiable(questionTypeIds),
       timeFactors = Map<String, int>.unmodifiable(timeFactors),
       queue = List<QuizTurn>.unmodifiable(queue),
       answers = List<QuizAnswerEntity>.unmodifiable(answers);

  /// Mistakes on the same fact after which its help card shows.
  static const int helpMistakeCount = 2;

  /// Identifier the session will be saved under.
  final String sessionId;

  /// Player of the quiz.
  final String profileId;

  /// Learning domain of the questions.
  final String domainId;

  /// How the quiz was started.
  final QuizMode mode;

  /// When the quiz was built.
  final DateTime startedAt;

  /// Questions that count in the score; second chances are extra.
  final int scoredQuestionCount;

  /// Question types allowed, also used for second chances.
  final List<String> questionTypeIds;

  /// Time to answer the first question, or `null` without a timer.
  final Duration? timeLimit;

  /// How the time per question shrinks with the right answers, or `null`
  /// when every question has [timeLimit].
  final QuizTimeSchedule? timeSchedule;

  /// Mistakes the player may make, or `null` for a quiz without lives.
  final int? lives;

  /// How many times the time per question each question type gets, by
  /// type identifier; a type left out gets the time once.
  final Map<String, int> timeFactors;

  /// Time to play the whole quiz, or `null` when it ends with its last
  /// question.
  final Duration? totalTimeLimit;

  /// What the quiz is played for, or `null`.
  final String? sourceKey;

  /// The boss of a boss fight, or `null` for another quiz.
  final BossFight? boss;

  /// Questions left, the current one first.
  final List<QuizTurn> queue;

  /// Answers given so far, in order.
  final List<QuizAnswerEntity> answers;

  /// Question to answer now, or `null` once the quiz is over.
  QuizTurn? get currentTurn => queue.isEmpty ? null : queue.first;

  /// Whether every question has been answered.
  bool get isFinished => queue.isEmpty;

  /// Questions of the whole quiz so far, second chances included.
  int get turnCount => answers.length + queue.length;

  /// Whether the quiz is against the clock: it ends when
  /// [totalTimeLimit] runs out, and a missed fact does not come back.
  bool get isAgainstTheClock => totalTimeLimit != null;

  /// Whether the quiz never waits: against the clock or with [lives], the
  /// next question comes by itself, the question shown is replaced when
  /// the app comes back, and a missed fact does not come back.
  bool get isNonStop => isAgainstTheClock || lives != null;

  /// Lives left, or `null` for a quiz without lives: each wrong answer
  /// takes one.
  int? get livesLeft {
    final int? total = lives;
    if (total == null) return null;
    final int left = total - (answers.length - correctCount);
    return left < 0 ? 0 : left;
  }

  /// Time to answer the current question, or `null` without a timer.
  Duration? get currentTimeLimit {
    final QuizTurn? turn = currentTurn;
    return turn == null ? null : timeLimitOf(turn, correctCount);
  }

  /// Time to answer [turn] after [correctBefore] right answers, scaled by
  /// the time factor of its question type; `null` without a timer.
  Duration? timeLimitOf(QuizTurn turn, int correctBefore) {
    final Duration? limit =
        timeSchedule?.limitAfter(correctBefore) ?? timeLimit;
    if (limit == null) return null;
    return limit * (timeFactors[turn.question.questionTypeId] ?? 1);
  }

  /// Answers that count in the score: every answer of a boss fight or of
  /// a non-stop quiz, second chances excluded otherwise.
  List<QuizAnswerEntity> get scoredAnswers => boss != null || isNonStop
      ? answers
      : answers.where((QuizAnswerEntity answer) => !answer.isRetry).toList();

  /// Right answers in a row so far.
  int get combo => QuizCombo.countOf(answers);

  /// Right answers among the scored questions.
  int get correctCount =>
      scoredAnswers.where((QuizAnswerEntity answer) => answer.isCorrect).length;

  /// How the boss fight ended, or `null` while it goes on or for another
  /// quiz.
  BossOutcome? get bossOutcome {
    final BossFight? fight = boss;
    if (fight == null || !isFinished) return null;
    return fight.isDefeated ? BossOutcome.defeated : BossOutcome.fled;
  }

  /// Wrong answers given on the fact [itemKey] so far.
  int mistakeCountOf(String itemKey) => answers
      .where(
        (QuizAnswerEntity answer) =>
            answer.itemKey == itemKey && !answer.isCorrect,
      )
      .length;

  /// Whether the fact [itemKey] was missed often enough to show its help
  /// card.
  bool needsHelp(String itemKey) => mistakeCountOf(itemKey) >= helpMistakeCount;

  /// Whether the fact [itemKey] already had or awaits its second chance.
  bool hasRetry(String itemKey) {
    return answers.any(
          (QuizAnswerEntity answer) =>
              answer.isRetry && answer.itemKey == itemKey,
        ) ||
        queue.any(
          (QuizTurn turn) => turn.isRetry && turn.question.itemKey == itemKey,
        );
  }

  /// Returns the quiz without its current question, unanswered: the next
  /// one replaces it.
  QuizRun withoutCurrentTurn() => copyWith(queue: queue.skip(1).toList());

  /// Returns the quiz ended now: the questions left are dropped.
  QuizRun stopped() => copyWith(queue: const <QuizTurn>[]);

  /// Returns a copy with [queue] and [answers] replaced.
  QuizRun copyWith({
    List<QuizTurn>? queue,
    List<QuizAnswerEntity>? answers,
    BossFight? boss,
  }) {
    return QuizRun(
      sessionId: sessionId,
      profileId: profileId,
      domainId: domainId,
      mode: mode,
      startedAt: startedAt,
      scoredQuestionCount: scoredQuestionCount,
      questionTypeIds: questionTypeIds,
      timeLimit: timeLimit,
      totalTimeLimit: totalTimeLimit,
      sourceKey: sourceKey,
      lives: lives,
      timeSchedule: timeSchedule,
      timeFactors: timeFactors,
      boss: boss ?? this.boss,
      queue: queue ?? this.queue,
      answers: answers ?? this.answers,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuizRun &&
            other.sessionId == sessionId &&
            other.timeLimit == timeLimit &&
            other.totalTimeLimit == totalTimeLimit &&
            other.lives == lives &&
            other.timeSchedule == timeSchedule &&
            other.boss == boss &&
            _isSameList(other.queue, queue) &&
            _isSameList(other.answers, answers);
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    timeLimit,
    totalTimeLimit,
    lives,
    timeSchedule,
    boss,
    Object.hashAll(queue),
    Object.hashAll(answers),
  );

  static bool _isSameList(List<Object> a, List<Object> b) {
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
