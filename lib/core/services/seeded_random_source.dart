import 'package:kid_matix/core/services/random_source.dart';

/// [RandomSource] whose sequence is written out here, so the same seed
/// gives the same numbers on every phone and every Dart version.
///
/// `dart:math` does not promise its algorithm, so a quiz that must be the
/// same on two phones (a challenge code) draws from this one. The
/// algorithm is Mulberry32 on 32-bit unsigned integers; the products are
/// split in 16-bit halves so they never leave the exact integer range of
/// any platform. Never change it: codes already shared depend on it.
final class SeededRandomSource implements RandomSource {
  /// Creates a source starting from [seed].
  SeededRandomSource({required int seed}) : _state = seed & _mask32;

  static const int _mask32 = 0xFFFFFFFF;
  static const int _mask16 = 0xFFFF;
  static const int _increment = 0x6D2B79F5;
  static const int _range = 0x100000000;

  int _state;

  /// Returns the next 32-bit unsigned integer of the sequence.
  int nextUint32() {
    _state = (_state + _increment) & _mask32;
    int value = _state;
    value = _multiply(value ^ (value >> 15), value | 1);
    value ^= (value + _multiply(value ^ (value >> 7), value | 61)) & _mask32;
    return (value ^ (value >> 14)) & _mask32;
  }

  @override
  int nextInt(int max) {
    if (max <= 0) throw RangeError.range(max, 1, null, 'max');
    return nextUint32() * max ~/ _range;
  }

  /// Fisher-Yates from the last position down, one [nextInt] per step.
  @override
  List<T> shuffled<T>(List<T> items) {
    final List<T> result = List<T>.of(items);
    for (int index = result.length - 1; index > 0; index--) {
      final int other = nextInt(index + 1);
      final T value = result[index];
      result[index] = result[other];
      result[other] = value;
    }
    return result;
  }

  /// The low 32 bits of [a] × [b], both 32-bit unsigned.
  static int _multiply(int a, int b) {
    final int high = (a >> 16) & _mask16;
    final int low = a & _mask16;
    return (low * b + (((high * b) & _mask16) << 16)) & _mask32;
  }
}
