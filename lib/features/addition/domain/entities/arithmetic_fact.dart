import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:meta/meta.dart';

/// Which number of a fact a prompt hides.
enum HiddenPart {
  /// The result: `7 + 8 = ?`.
  result,

  /// The left number: `? + 8 = 15`.
  left,

  /// The right number: `7 + ? = 15`.
  right,
}

/// One addition or subtraction to master, such as `7 + 8 = 15` or
/// `15 − 7 = 8`.
///
/// Its key never changes once released, since the stored progress refers
/// to it: `add:7+8` and `sub:15-7`. A subtraction never goes below zero.
@immutable
final class ArithmeticFact implements LearningItem {
  /// The addition of [left] and [right].
  const ArithmeticFact.add(this.left, this.right)
    : operator = MathOperator.add,
      assert(left >= 0 && right >= 0, 'no negative number');

  /// The subtraction of [right] from [left], never negative.
  const ArithmeticFact.subtract(this.left, this.right)
    : operator = MathOperator.subtract,
      assert(right >= 0 && left >= right, 'no negative result');

  /// Key prefix of the additions.
  static const String addPrefix = 'add';

  /// Key prefix of the subtractions.
  static const String subtractPrefix = 'sub';

  /// Base of the digits.
  static const int ten = 10;

  /// [MathOperator.add] or [MathOperator.subtract].
  final MathOperator operator;

  /// Number on the left: the first term, or the number to take from.
  final int left;

  /// Number on the right.
  final int right;

  /// Whether the fact is an addition.
  bool get isAddition => operator == MathOperator.add;

  /// The result of the operation.
  int get result => isAddition ? left + right : left - right;

  @override
  String get key =>
      isAddition ? '$addPrefix:$left+$right' : '$subtractPrefix:$left-$right';

  /// Whether the operation crosses a ten: the ones of an addition make 10
  /// or more, or a subtraction takes more ones than the number has.
  bool get crossesTen {
    final int leftOnes = left % ten;
    final int rightOnes = right % ten;
    return isAddition ? leftOnes + rightOnes >= ten : leftOnes < rightOnes;
  }

  /// The facts of the same family: with the parts 7 and 8 of 15, `7 + 8`,
  /// `8 + 7`, `15 − 7` and `15 − 8`. Two equal parts give only two facts.
  /// The fact itself is one of them.
  List<ArithmeticFact> get family {
    final int whole = isAddition ? result : left;
    final int partA = isAddition ? left : right;
    final int partB = whole - partA;
    final bool hasTwoParts = partA != partB;
    return <ArithmeticFact>[
      ArithmeticFact.add(partA, partB),
      if (hasTwoParts) ArithmeticFact.add(partB, partA),
      ArithmeticFact.subtract(whole, partA),
      if (hasTwoParts) ArithmeticFact.subtract(whole, partB),
    ];
  }

  /// The fact written with [hidden] as the blank: `7 + 8 = ?`.
  List<PromptToken> prompt({HiddenPart hidden = HiddenPart.result}) {
    PromptToken shown(int value, HiddenPart part) =>
        hidden == part ? const BlankToken() : NumberToken(value);
    return <PromptToken>[
      shown(left, HiddenPart.left),
      OperatorToken(operator),
      shown(right, HiddenPart.right),
      const EqualsToken(),
      shown(result, HiddenPart.result),
    ];
  }

  /// The fact with [shownResult] after the equals sign, right or not.
  List<PromptToken> promptWithResult(int shownResult) {
    return <PromptToken>[
      NumberToken(left),
      OperatorToken(operator),
      NumberToken(right),
      const EqualsToken(),
      NumberToken(shownResult),
    ];
  }

  /// The whole fact with its result, such as `15 − 7 = 8`.
  List<PromptToken> describe() => promptWithResult(result);

  /// Two facts are the same when they have the same key: the progress
  /// stored under a key belongs to one fact only.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ArithmeticFact && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => key;
}
