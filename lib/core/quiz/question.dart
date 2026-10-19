import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:meta/meta.dart';

/// One question of a quiz, ready to be shown and checked.
@immutable
final class Question {
  /// Creates a question.
  Question({
    required this.itemKey,
    required this.unitKey,
    required this.questionTypeId,
    required List<PromptToken> prompt,
    required this.expectedAnswer,
    List<Answer> choices = const <Answer>[],
    List<QuestionPair> pairs = const <QuestionPair>[],
    List<SentencePart> sentence = const <SentencePart>[],
    this.picture,
  }) : prompt = List<PromptToken>.unmodifiable(prompt),
       choices = List<Answer>.unmodifiable(choices),
       pairs = List<QuestionPair>.unmodifiable(pairs),
       sentence = List<SentencePart>.unmodifiable(sentence);

  /// Key of the item the question asks about, such as `mul:7x8`.
  final String itemKey;

  /// Key of the unit of the item, such as `mul:7`.
  final String unitKey;

  /// Identifier of the question type, such as `multipleChoice`.
  final String questionTypeId;

  /// Prompt, token by token: `7 × 8 = ?`, `7 × ? = 56`, `6 × 7 = 48`.
  final List<PromptToken> prompt;

  /// Answers to pick from, in display order; empty when the player writes.
  /// For a match-pairs question, the results of [pairs] in display order.
  final List<Answer> choices;

  /// Pairs to match, in the display order of their operations; empty
  /// unless the question asks to match pairs. [itemKey] is one of them.
  final List<QuestionPair> pairs;

  /// Sentence to read and touch, piece by piece, for a question that asks
  /// to touch the math words of a sentence; empty otherwise.
  final List<SentencePart> sentence;

  /// Keys of the items the question asks about: those of its [pairs], or
  /// [itemKey] alone.
  List<String> get itemKeys => pairs.isEmpty
      ? <String>[itemKey]
      : pairs.map((QuestionPair pair) => pair.itemKey).toList();

  /// The right answer.
  final Answer expectedAnswer;

  /// Drawing shown above [prompt], such as objects to count, or `null`.
  final MathPicture? picture;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Question &&
            other.itemKey == itemKey &&
            other.unitKey == unitKey &&
            other.questionTypeId == questionTypeId &&
            _haveSameElements(other.prompt, prompt) &&
            _haveSameElements(other.choices, choices) &&
            _haveSameElements(other.pairs, pairs) &&
            _haveSameElements(other.sentence, sentence) &&
            other.expectedAnswer == expectedAnswer &&
            other.picture == picture;
  }

  @override
  int get hashCode => Object.hash(
    itemKey,
    unitKey,
    questionTypeId,
    Object.hashAll(prompt),
    Object.hashAll(choices),
    Object.hashAll(pairs),
    Object.hashAll(sentence),
    expectedAnswer,
    picture,
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
