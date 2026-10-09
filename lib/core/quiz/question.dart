import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:meta/meta.dart';

/// One question of a quiz, ready to be shown and checked.
@immutable
final class Question {
  /// Creates a question.
  Question({
    required this.itemKey,
    required this.questionTypeId,
    required List<PromptToken> prompt,
    required this.expectedAnswer,
    List<Answer> choices = const <Answer>[],
  }) : prompt = List<PromptToken>.unmodifiable(prompt),
       choices = List<Answer>.unmodifiable(choices);

  /// Key of the item the question asks about, such as `mul:7x8`.
  final String itemKey;

  /// Identifier of the question type, such as `multipleChoice`.
  final String questionTypeId;

  /// Prompt, token by token: `7 × 8 = ?`, `7 × ? = 56`, `6 × 7 = 48`.
  final List<PromptToken> prompt;

  /// Answers to pick from, in display order; empty when the player writes.
  final List<Answer> choices;

  /// The right answer.
  final Answer expectedAnswer;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Question &&
            other.itemKey == itemKey &&
            other.questionTypeId == questionTypeId &&
            _haveSameElements(other.prompt, prompt) &&
            _haveSameElements(other.choices, choices) &&
            other.expectedAnswer == expectedAnswer;
  }

  @override
  int get hashCode => Object.hash(
    itemKey,
    questionTypeId,
    Object.hashAll(prompt),
    Object.hashAll(choices),
    expectedAnswer,
  );

  @override
  String toString() => 'Question($questionTypeId, ${prompt.join(' ')})';

  static bool _haveSameElements(List<Object> a, List<Object> b) {
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
