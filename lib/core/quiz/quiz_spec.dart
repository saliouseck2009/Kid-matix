import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_time_schedule.dart';
import 'package:kid_matix/core/quiz/seeded_draw.dart';
import 'package:meta/meta.dart';

/// A quiz to play, as the feature that starts it describes it.
///
/// The quiz knows nothing of stages or challenges: [sourceKey] is an
/// opaque key, stored with the session, that lets the starting feature
/// find what the quiz was played for.
@immutable
final class QuizSpec {
  /// Creates the spec.
  QuizSpec({
    required this.domainId,
    required this.mode,
    required List<String> itemKeys,
    required List<String> questionTypeIds,
    this.selection = QuizSelection.mastery,
    this.questionCount,
    this.baseTimeLimit,
    this.sourceKey,
    List<String> followUpItemKeys = const <String>[],
    this.followUpQuestionCount = 0,
    this.isBossFight = false,
    this.totalTimeLimit,
    this.keepsTimer = false,
    this.lives,
    this.timeSchedule,
    this.seededDraw,
  }) : assert(
         timeSchedule == null || baseTimeLimit == timeSchedule.start,
         'a time schedule starts at the base time limit',
       ),
       followUpItemKeys = List<String>.unmodifiable(followUpItemKeys),
       itemKeys = List<String>.unmodifiable(itemKeys),
       questionTypeIds = List<String>.unmodifiable(questionTypeIds);

  /// Learning domain, such as `multiplication`.
  final String domainId;

  /// How the quiz is started.
  final QuizMode mode;

  /// Items to ask or draw the questions from.
  final List<String> itemKeys;

  /// Question types allowed.
  final List<String> questionTypeIds;

  /// How the questions are chosen among [itemKeys].
  final QuizSelection selection;

  /// Scored questions to ask, or `null` for as many as [itemKeys].
  final int? questionCount;

  /// Time per question with the normal timer, or `null` for a quiz that
  /// never has a timer; the player's timer mode then applies.
  final Duration? baseTimeLimit;

  /// What the quiz is played for, such as a stage of the learning path,
  /// or `null`.
  final String? sourceKey;

  /// Items the mastery engine draws the follow-up questions from, after
  /// the main ones: the weakest first, each once.
  final List<String> followUpItemKeys;

  /// Most follow-up questions; 0 for none.
  final int followUpQuestionCount;

  /// Whether the quiz is a boss fight: every right answer hits the boss,
  /// and the fight ends when it falls or flees.
  final bool isBossFight;

  /// Time to play the whole quiz, or `null` when it ends with its last
  /// question. With it, the quiz is against the clock: it ends when the
  /// time runs out, every answer counts and no question comes back.
  final Duration? totalTimeLimit;

  /// Whether the player chose to play with [baseTimeLimit]: the timer then
  /// stays even when their setting turns it off.
  final bool keepsTimer;

  /// Mistakes the player may make, or `null` for a quiz without lives.
  /// With lives, the quiz ends at the last one lost, goes on by itself
  /// after each answer and no question comes back.
  final int? lives;

  /// How the time per question shrinks with the right answers, or `null`
  /// for a time that never changes; it starts at [baseTimeLimit].
  final QuizTimeSchedule? timeSchedule;

  /// The draw fixing the questions, or `null` to choose them by
  /// [selection]. With it, the frozen generator of its version asks
  /// [questionCount] questions among [itemKeys], the same on every phone.
  final SeededDraw? seededDraw;
}
