import 'dart:math';

import 'package:kid_matix/core/services/random_source.dart';

/// [RandomSource] backed by `dart:math`.
final class DartRandomSource implements RandomSource {
  /// Creates a source; the same [seed] always yields the same sequence.
  DartRandomSource({int? seed}) : _random = Random(seed);

  final Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);

  @override
  List<T> shuffled<T>(List<T> items) => List<T>.of(items)..shuffle(_random);
}
