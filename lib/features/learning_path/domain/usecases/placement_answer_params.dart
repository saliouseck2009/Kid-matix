import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:meta/meta.dart';

/// The answer of a player to one question of the placement test.
@immutable
final class PlacementAnswerParams {
  /// Creates the parameters; a `null` [answer] means the player said they
  /// do not know.
  const PlacementAnswerParams({
    required this.profileId,
    required this.domainId,
    required this.question,
    required this.answer,
    required this.answerTime,
  });

  /// Player.
  final String profileId;

  /// Learning domain of the test.
  final String domainId;

  /// Question answered.
  final Question question;

  /// Number typed, or `null` for "Je ne sais pas".
  final Answer? answer;

  /// Time taken to answer.
  final Duration answerTime;
}
