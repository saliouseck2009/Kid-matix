import 'package:kid_matix/core/services/random_source.dart';

/// Picks the wrong answers of a question about a number.
///
/// They come from the plausible mistakes of the item, the typical one
/// always first when valid, then numbers next to the answer when the
/// mistakes run out. The result never holds the answer, a duplicate or a
/// number out of [smallest]..[largest].
final class NumberDistractorGenerator {
  /// Creates the generator.
  const NumberDistractorGenerator();

  /// Wrong answers of a question with four choices.
  static const int defaultCount = 3;

  /// Smallest number offered.
  static const int smallest = 1;

  /// Largest number offered: a little over 100, so that 110 can trick a
  /// child counting 10 bundles.
  static const int largest = 110;

  /// Returns [count] distinct wrong answers to [answer], drawn with
  /// [random] among [mistakes], [typicalMistake] kept when valid.
  List<int> generate({
    required int answer,
    required List<int> mistakes,
    required RandomSource random,
    int? typicalMistake,
    int count = defaultCount,
  }) {
    final List<int> chosen = <int>[];
    if (typicalMistake != null) _addIfValid(chosen, typicalMistake, answer);
    final List<int> others = <int>[];
    for (final int mistake in mistakes) {
      if (!chosen.contains(mistake)) _addIfValid(others, mistake, answer);
    }
    chosen.addAll(random.shuffled(others));
    int offset = 1;
    while (chosen.length < count) {
      _addIfValid(chosen, answer + offset, answer);
      _addIfValid(chosen, answer - offset, answer);
      offset++;
    }
    return chosen.take(count).toList();
  }

  void _addIfValid(List<int> values, int value, int answer) {
    final bool isInRange = value >= smallest && value <= largest;
    if (!isInRange || value == answer || values.contains(value)) return;
    values.add(value);
  }
}
