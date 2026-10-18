import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/addition/domain/entities/arithmetic_fact.dart';

/// Builds plausible wrong answers for an addition or a subtraction.
///
/// The classic mistakes come first: the carry or the borrow forgotten, the
/// digits swapped, the other operation. The answers next to the right one
/// (1 more or less) complete the list. The result never holds the right
/// answer, a duplicate or a negative number.
final class ArithmeticDistractorGenerator {
  /// Creates the generator.
  const ArithmeticDistractorGenerator();

  /// Wrong answers of a multiple choice question.
  static const int defaultCount = 3;

  /// Largest number offered: a little over the largest result (99), so the
  /// choices stay in the range a child knows.
  static const int largest = 110;

  /// Returns [count] distinct wrong answers to [fact], the classic
  /// mistakes of the fact first when the draw keeps them; [random] orders
  /// the ones that are not typical.
  List<int> generate({
    required ArithmeticFact fact,
    required RandomSource random,
    int count = defaultCount,
  }) {
    final List<int> chosen = <int>[];
    final int? typical = typicalMistake(fact);
    if (typical != null) _addIfValid(chosen, typical, fact.result);
    final List<int> others = <int>[];
    for (final int mistake in mistakesOf(fact)) {
      if (!chosen.contains(mistake)) _addIfValid(others, mistake, fact.result);
    }
    chosen.addAll(random.shuffled(others));
    int offset = 1;
    while (chosen.length < count) {
      _addIfValid(chosen, fact.result + offset, fact.result);
      _addIfValid(chosen, fact.result - offset, fact.result);
      offset++;
    }
    return chosen.take(count).toList();
  }

  /// A wrong result to show in a true or false statement, drawn among the
  /// plausible mistakes of [fact] (not always the typical one); never 0,
  /// which would read as an obvious joke.
  int wrongStatementResult({
    required ArithmeticFact fact,
    required RandomSource random,
  }) {
    final List<int> candidates = <int>[];
    for (final int mistake in mistakesOf(fact)) {
      if (mistake >= 1) _addIfValid(candidates, mistake, fact.result);
    }
    if (candidates.isEmpty) return fact.result + 1;
    return random.shuffled(candidates).first;
  }

  /// The mistake of [fact] a child makes most often, or `null`: the carry
  /// or the borrow forgotten when the fact needs one.
  int? typicalMistake(ArithmeticFact fact) {
    if (!fact.crossesTen) return null;
    return fact.isAddition ? _withoutCarry(fact) : _withoutBorrow(fact);
  }

  /// Plausible wrong answers of [fact], without the right one; some may be
  /// invalid, [generate] keeps the right ones.
  List<int> mistakesOf(ArithmeticFact fact) {
    return <int>[
      ?typicalMistake(fact),
      ?_swappedDigits(fact.result),
      _otherOperation(fact),
      fact.result - 1,
      fact.result + 1,
      fact.result + ArithmeticFact.ten,
      fact.result - ArithmeticFact.ten,
    ];
  }

  /// The ones added, the ten they make forgotten: 5 for 7 + 8.
  int _withoutCarry(ArithmeticFact fact) => fact.result - ArithmeticFact.ten;

  /// The smaller ones taken from the larger, the borrow forgotten: 35 for
  /// 42 − 17, 12 for 15 − 7.
  int _withoutBorrow(ArithmeticFact fact) {
    final int tens =
        fact.left ~/ ArithmeticFact.ten - fact.right ~/ ArithmeticFact.ten;
    final int ones =
        (fact.left % ArithmeticFact.ten - fact.right % ArithmeticFact.ten)
            .abs();
    return tens * ArithmeticFact.ten + ones;
  }

  /// The subtraction taken for an addition and the other way round; never
  /// negative.
  int _otherOperation(ArithmeticFact fact) {
    return fact.isAddition
        ? (fact.left - fact.right).abs()
        : fact.left + fact.right;
  }

  /// 24 for 42; `null` unless [value] has two different digits and does not
  /// end in 0, since other swaps are not mistakes a child makes.
  int? _swappedDigits(int value) {
    if (value < ArithmeticFact.ten ||
        value >= ArithmeticFact.ten * ArithmeticFact.ten) {
      return null;
    }
    final int tens = value ~/ ArithmeticFact.ten;
    final int ones = value % ArithmeticFact.ten;
    if (ones == 0 || ones == tens) return null;
    return ones * ArithmeticFact.ten + tens;
  }

  void _addIfValid(List<int> values, int value, int answer) {
    final bool isInRange = value >= 0 && value <= largest;
    if (!isInRange || value == answer || values.contains(value)) return;
    values.add(value);
  }
}
