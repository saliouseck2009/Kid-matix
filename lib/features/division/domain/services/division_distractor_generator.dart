import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/division/domain/entities/division_fact.dart';

/// Builds plausible wrong answers for a division.
///
/// For 56 ÷ 7 = 8, the candidates are the quotients next to the right one
/// (7, 9, 6, 10) and the divisor itself, mixed up with the result. The
/// result never holds the right answer, a duplicate or a number below 1.
final class DivisionDistractorGenerator {
  /// Creates the generator.
  const DivisionDistractorGenerator();

  /// Wrong answers of a multiple choice question.
  static const int defaultCount = 3;

  /// Returns [count] distinct wrong answers to [fact], drawn with [random].
  List<int> generate({
    required DivisionFact fact,
    required RandomSource random,
    int count = defaultCount,
  }) {
    final int answer = fact.quotient;
    final List<int> candidates = <int>[];
    for (final int value in <int>[
      answer - 1,
      answer + 1,
      fact.divisor,
      answer + 2,
      answer - 2,
    ]) {
      _addIfValid(candidates, value, answer);
    }
    final List<int> distractors = random
        .shuffled(candidates)
        .take(count)
        .toList();
    int offset = 3;
    while (distractors.length < count) {
      _addIfValid(distractors, answer + offset, answer);
      _addIfValid(distractors, answer - offset, answer);
      offset++;
    }
    return distractors.take(count).toList();
  }

  void _addIfValid(List<int> values, int value, int answer) {
    if (value < 1 || value == answer || values.contains(value)) return;
    values.add(value);
  }
}
