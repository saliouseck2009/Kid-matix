import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:meta/meta.dart';

/// One player during a duel: their tables, the question in front of them,
/// their score and how long their buttons stay blocked after a mistake.
@immutable
final class DuelContender {
  /// Creates the contender.
  DuelContender({
    required this.player,
    required List<String> unitKeys,
    required this.question,
    this.score = 0,
    this.blockedFor = Duration.zero,
    this.wrongAnswer,
  }) : unitKeys = List<String>.unmodifiable(unitKeys);

  /// Who plays.
  final DuelPlayer player;

  /// Keys of the units the questions come from, such as `mul:5`.
  final List<String> unitKeys;

  /// The question to answer, or the one just missed while blocked.
  final Question question;

  /// Right answers so far.
  final int score;

  /// Time left before the buttons answer again; zero when free.
  final Duration blockedFor;

  /// The wrong answer given, shown while blocked; `null` otherwise.
  final Answer? wrongAnswer;

  /// Whether the buttons ignore taps.
  bool get isBlocked => blockedFor > Duration.zero;

  /// Returns a copy with the given fields replaced; [clearWrongAnswer]
  /// forgets the wrong answer.
  DuelContender copyWith({
    Question? question,
    int? score,
    Duration? blockedFor,
    Answer? wrongAnswer,
    bool clearWrongAnswer = false,
  }) {
    return DuelContender(
      player: player,
      unitKeys: unitKeys,
      question: question ?? this.question,
      score: score ?? this.score,
      blockedFor: blockedFor ?? this.blockedFor,
      wrongAnswer: clearWrongAnswer ? null : wrongAnswer ?? this.wrongAnswer,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DuelContender &&
            other.player == player &&
            _haveSameKeys(other.unitKeys, unitKeys) &&
            other.question == question &&
            other.score == score &&
            other.blockedFor == blockedFor &&
            other.wrongAnswer == wrongAnswer;
  }

  @override
  int get hashCode => Object.hash(
    player,
    Object.hashAll(unitKeys),
    question,
    score,
    blockedFor,
    wrongAnswer,
  );

  static bool _haveSameKeys(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
