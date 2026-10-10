import 'package:kid_matix/features/quiz/domain/entities/boss_fight.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
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
    this.sourceKey,
    this.boss,
  }) : questionTypeIds = List<String>.unmodifiable(questionTypeIds),
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

  /// Time to answer each question, or `null` without a timer.
  final Duration? timeLimit;

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

  /// Answers that count in the score: every answer of a boss fight,
  /// second chances excluded otherwise.
  List<QuizAnswerEntity> get scoredAnswers => boss != null
      ? answers
      : answers.where((QuizAnswerEntity answer) => !answer.isRetry).toList();

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
      sourceKey: sourceKey,
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
            other.boss == boss &&
            _isSameList(other.queue, queue) &&
            _isSameList(other.answers, answers);
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    timeLimit,
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
