import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';

/// Builds plausible wrong operations for a "find the operation" question.
///
/// For 4 x 6 = 24, the candidates are the operations next to it: one
/// operand moved by 1 or 2 (4 x 5, 4 x 7, 3 x 6, 5 x 6...), or both moved
/// in opposite directions (3 x 7, 5 x 5). Every operation returned is a
/// fact of the tables, and no two of them, nor the right one, give the
/// same result: exactly one choice is right and none repeats another.
final class OperationDistractorGenerator {
  /// Creates the generator; facts go from 1 x 1 to [lastTable] x
  /// [lastMultiplier].
  const OperationDistractorGenerator({
    required this.lastTable,
    required this.lastMultiplier,
  });

  /// Wrong operations of a question.
  static const int defaultCount = 3;

  /// Highest table of a fact.
  final int lastTable;

  /// Highest multiplier of a fact.
  final int lastMultiplier;

  static const List<(int, int)> _offsets = <(int, int)>[
    (0, -1),
    (0, 1),
    (-1, 0),
    (1, 0),
    (-1, 1),
    (1, -1),
    (0, -2),
    (0, 2),
    (-2, 0),
    (2, 0),
  ];

  /// Returns [count] wrong operations of [fact], drawn with [random].
  List<MultiplicationFact> generate({
    required MultiplicationFact fact,
    required RandomSource random,
    int count = defaultCount,
  }) {
    final List<MultiplicationFact> distractors = <MultiplicationFact>[];
    final Set<int> products = <int>{fact.product};
    final List<MultiplicationFact> candidates = <MultiplicationFact>[
      ...random.shuffled(_findNeighbors(fact)),
      ..._findAllByCloseness(fact),
    ];
    for (final MultiplicationFact candidate in candidates) {
      if (distractors.length == count) break;
      if (products.add(candidate.product)) distractors.add(candidate);
    }
    return distractors;
  }

  List<MultiplicationFact> _findNeighbors(MultiplicationFact fact) {
    return <MultiplicationFact>[
      for (final (int tableOffset, int multiplierOffset) in _offsets)
        if (_isFact(
          fact.table + tableOffset,
          fact.multiplier + multiplierOffset,
        ))
          MultiplicationFact(
            table: fact.table + tableOffset,
            multiplier: fact.multiplier + multiplierOffset,
          ),
    ];
  }

  /// Every fact, the closest results to [fact] first: the fallback when
  /// the neighbors share too few results.
  List<MultiplicationFact> _findAllByCloseness(MultiplicationFact fact) {
    return <MultiplicationFact>[
      for (int table = 1; table <= lastTable; table++)
        for (int multiplier = 1; multiplier <= lastMultiplier; multiplier++)
          MultiplicationFact(table: table, multiplier: multiplier),
    ]..sort(
      (MultiplicationFact a, MultiplicationFact b) => (a.product - fact.product)
          .abs()
          .compareTo((b.product - fact.product).abs()),
    );
  }

  bool _isFact(int table, int multiplier) {
    return table >= 1 &&
        table <= lastTable &&
        multiplier >= 1 &&
        multiplier <= lastMultiplier;
  }
}
