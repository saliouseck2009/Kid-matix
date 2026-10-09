import 'package:kid_matix/features/quiz/domain/entities/quiz_answer_entity.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_session_entity.dart';
import 'package:meta/meta.dart';

/// A saved session with its answers, as the results screen shows it.
@immutable
final class QuizResultEntity {
  /// Creates the result of [session].
  QuizResultEntity({
    required this.session,
    required List<QuizAnswerEntity> answers,
  }) : answers = List<QuizAnswerEntity>.unmodifiable(answers);

  /// The saved session.
  final QuizSessionEntity session;

  /// Its answers, in order.
  final List<QuizAnswerEntity> answers;

  /// Average time of the scored answers given before the timer ran out,
  /// or `null` when there is none.
  Duration? get averageAnswerTime {
    final List<QuizAnswerEntity> timed = answers
        .where(
          (QuizAnswerEntity answer) => !answer.isRetry && !answer.isTimedOut,
        )
        .toList();
    if (timed.isEmpty) return null;
    final int totalMs = timed.fold(
      0,
      (int sum, QuizAnswerEntity answer) =>
          sum + answer.answerTime.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ timed.length);
  }

  /// Items answered wrong at least once, without duplicates, in order.
  List<String> get missedItemKeys {
    return answers
        .where((QuizAnswerEntity answer) => !answer.isCorrect)
        .map((QuizAnswerEntity answer) => answer.itemKey)
        .toSet()
        .toList();
  }

  /// Items asked, without duplicates, in order.
  List<String> get askedItemKeys {
    return answers
        .map((QuizAnswerEntity answer) => answer.itemKey)
        .toSet()
        .toList();
  }
}
