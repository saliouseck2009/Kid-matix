import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/services/random_source.dart';

/// The calculation that follows from a bar model, and the answers offered
/// for it.
final class ProblemCalculation {
  /// Creates the service.
  const ProblemCalculation();

  /// Answers offered for the calculation.
  static const int choiceCount = 4;

  /// The calculation of [picture] as a prompt: `12 − 5 = 7`. The known
  /// numbers come in the order of the places of the model, which is the
  /// order of the operation (the whole before the part, the total before
  /// the group).
  List<PromptToken> tokensOf(BarModelPicture picture) {
    final List<int> known = <int>[
      for (final BarRole role in picture.knownRoles) picture.values[role]!,
    ];
    return <PromptToken>[
      NumberToken(known[0]),
      OperatorToken(picture.operator),
      NumberToken(known[1]),
      const EqualsToken(),
      NumberToken(picture.answer),
    ];
  }

  /// [choiceCount] different numbers to pick the result from, the right
  /// one among them: what the other operations give with the same two
  /// numbers come first, since they are the mistakes a child makes, then
  /// the numbers next to the answer.
  List<NumberAnswer> choicesOf(BarModelPicture picture, RandomSource random) {
    final int answer = picture.answer;
    final List<int> known = <int>[
      for (final BarRole role in picture.knownRoles) picture.values[role]!,
    ];
    final Set<int> wrong = <int>{};
    for (final MathOperator operator in _operators) {
      if (operator == picture.operator) continue;
      for (final (int, int) pair in <(int, int)>[
        (known[0], known[1]),
        (known[1], known[0]),
      ]) {
        final int? result = _apply(operator, pair.$1, pair.$2);
        if (result != null && result != answer) wrong.add(result);
      }
    }
    for (final int near in <int>[1, -1, 2, -2, 10, -10]) {
      if (answer + near > 0) wrong.add(answer + near);
    }
    final List<int> picked = random
        .shuffled(wrong.toList())
        .take(
          choiceCount - 1,
        )
        .toList();
    return random.shuffled(<NumberAnswer>[
      NumberAnswer(answer),
      for (final int value in picked) NumberAnswer(value),
    ]);
  }

  static const List<MathOperator> _operators = <MathOperator>[
    MathOperator.add,
    MathOperator.subtract,
    MathOperator.multiply,
    MathOperator.divide,
  ];

  static int? _apply(MathOperator operator, int x, int y) {
    final int? result = switch (operator) {
      MathOperator.add => x + y,
      MathOperator.subtract => x - y,
      MathOperator.multiply => x * y,
      MathOperator.divide => y != 0 && x % y == 0 ? x ~/ y : null,
      _ => null,
    };
    return result != null && result > 0 ? result : null;
  }
}
