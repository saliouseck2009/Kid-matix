import 'package:meta/meta.dart';

/// A drawing that goes with a question or a help card, such as objects to
/// count or a number line.
///
/// Pictures are data, never text: the screens draw them and give each one
/// a label for screen readers.
@immutable
sealed class MathPicture {
  /// Creates a picture.
  const MathPicture();
}

/// [count] objects to count, drawn in rows of five, ten to a block.
final class ObjectsPicture extends MathPicture {
  /// Creates the picture of [count] objects.
  const ObjectsPicture({required this.count})
    : assert(count > 0, 'at least one object');

  /// Number of objects drawn.
  final int count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ObjectsPicture && other.count == count;

  @override
  int get hashCode => count.hashCode;

  @override
  String toString() => 'ObjectsPicture($count)';
}

/// [tens] bundles of ten sticks and [ones] loose sticks: 3 bundles and 4
/// sticks show 34.
final class TenBundlesPicture extends MathPicture {
  /// Creates the picture of [tens] bundles and [ones] sticks.
  const TenBundlesPicture({required this.tens, required this.ones})
    : assert(tens >= 0 && ones >= 0, 'no negative count');

  /// Sticks tied in one bundle.
  static const int sticksPerBundle = 10;

  /// Bundles of ten sticks.
  final int tens;

  /// Loose sticks.
  final int ones;

  /// Number shown: ten per bundle plus the loose sticks.
  int get value => tens * sticksPerBundle + ones;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TenBundlesPicture && other.tens == tens && other.ones == ones;
  }

  @override
  int get hashCode => Object.hash(tens, ones);

  @override
  String toString() => 'TenBundlesPicture($tens, $ones)';
}

/// A number line: one tick per value of [values], from left to right,
/// each labeled with its number except the tick of [blankIndex].
final class NumberLinePicture extends MathPicture {
  /// Creates the line of [values] with the tick [blankIndex] left blank,
  /// or none when [blankIndex] is `null`; [highlightIndex] marks the tick
  /// the question or the help is about.
  NumberLinePicture({
    required List<int> values,
    this.blankIndex,
    this.highlightIndex,
  }) : assert(values.length > 1, 'a line has at least two ticks'),
       values = List<int>.unmodifiable(values);

  /// Number of each tick, from left to right, always increasing.
  final List<int> values;

  /// Position of the tick whose number is to find, or `null`.
  final int? blankIndex;

  /// Position of the tick to highlight, or `null`.
  final int? highlightIndex;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NumberLinePicture) return false;
    if (other.blankIndex != blankIndex) return false;
    if (other.highlightIndex != highlightIndex) return false;
    if (other.values.length != values.length) return false;
    for (int index = 0; index < values.length; index++) {
      if (other.values[index] != values[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(values), blankIndex, highlightIndex);

  @override
  String toString() => 'NumberLinePicture($values, blank: $blankIndex)';
}

/// The drawing of a math word (lot F28), found by its key; [label] is the
/// word as the child reads it, said by a screen reader in place of the
/// drawing.
final class WordPicture extends MathPicture {
  /// Creates the picture of the word [wordKey].
  const WordPicture({required this.wordKey, required this.label});

  /// Key of the math word, such as `il_reste`.
  final String wordKey;

  /// The word written in French, such as "il reste".
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordPicture && other.wordKey == wordKey;

  @override
  int get hashCode => wordKey.hashCode;

  @override
  String toString() => 'WordPicture($wordKey)';
}
