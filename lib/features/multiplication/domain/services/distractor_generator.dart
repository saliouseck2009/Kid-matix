import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';

/// Builds plausible wrong answers for a multiplication fact.
///
/// For 7 x 8 = 56, the candidates are the neighbors in the same table
/// (7 x 7, 7 x 9), the same multiplier in the neighbor tables (6 x 8,
/// 8 x 8), the addition mix-up (7 + 8) and the swapped digits (65). The
/// result never holds the right answer, a duplicate or a number below 1.
final class DistractorGenerator {
  /// Creates the generator.
  const DistractorGenerator();

  /// Wrong answers of a multiple choice question.
  static const int defaultCount = 3;

  static const int _base = 10;

  /// Returns [count] distinct wrong answers to [fact], drawn with [random].
  List<int> generate({
    required MultiplicationFact fact,
    required RandomSource random,
    int count = defaultCount,
  }) {
    final List<int> candidates = random.shuffled(_findCandidates(fact));
    final List<int> distractors = candidates.take(count).toList();
    int offset = 1;
    while (distractors.length < count) {
      _addIfValid(distractors, fact.product + offset, fact.product);
      _addIfValid(distractors, fact.product - offset, fact.product);
      offset++;
    }
    return distractors.take(count).toList();
  }

  /// Plausible wrong answers of [fact], without duplicates.
  List<int> _findCandidates(MultiplicationFact fact) {
    final int table = fact.table;
    final int multiplier = fact.multiplier;
    final List<int> candidates = <int>[];
    for (final int value in <int>[
      table * (multiplier - 1),
      table * (multiplier + 1),
      (table - 1) * multiplier,
      (table + 1) * multiplier,
      table + multiplier,
      ?_swapDigits(fact.product),
    ]) {
      _addIfValid(candidates, value, fact.product);
    }
    return candidates;
  }

  void _addIfValid(List<int> values, int value, int product) {
    if (value < 1 || value == product || values.contains(value)) return;
    values.add(value);
  }

  /// 65 for 56; `null` unless [product] has two digits and does not end
  /// in 0, since other swaps are not mistakes a child makes.
  int? _swapDigits(int product) {
    final bool hasTwoDigits = product >= _base && product < _base * _base;
    if (!hasTwoDigits || product % _base == 0) return null;
    final int swapped = int.parse(product.toString().split('').reversed.join());
    return swapped;
  }
}
