import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
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

/// The bar model of a word problem (lot F30): the numbers of the story on
/// a whole and its parts, two bars to compare or equal groups.
///
/// It holds every number of the drawing, the one to find included
/// ([unknown]); the screens hide that one while the child works and show
/// it in the correction. It is also the data of the interactive board:
/// the places to fill, the operation and the check sentence.
final class BarModelPicture extends MathPicture {
  /// Creates the model of [shape] holding [values].
  BarModelPicture({
    required this.shape,
    required Map<BarRole, int> values,
    required this.unknown,
    required this.operator,
    required this.check,
    this.isRemoval = false,
    Set<BarRole> prefilled = const <BarRole>{},
  }) : assert(
         shape.roles.every(values.containsKey),
         'every place holds a number',
       ),
       assert(values.length == shape.roles.length, 'no place of another shape'),
       values = Map<BarRole, int>.unmodifiable(values),
       prefilled = Set<BarRole>.unmodifiable(prefilled);

  /// Which drawing it is.
  final BarModelShape shape;

  /// The number of each place, by role.
  final Map<BarRole, int> values;

  /// The place whose number the child looks for.
  final BarRole unknown;

  /// The operation that finds it.
  final MathOperator operator;

  /// The sentence of the last step, in French, such as « Vérifie : 5 + 7 =
  /// 12 ».
  final String check;

  /// Whether the story takes a part away: the part is drawn cut out.
  final bool isRemoval;

  /// The places the story fills for the child with a number it does not
  /// write, such as the 2 of « la moitié »: they start filled and are not
  /// among the numbers to place.
  final Set<BarRole> prefilled;

  /// The number the child looks for.
  int get answer => values[unknown]!;

  /// The places the story gives, in the order they are shown.
  List<BarRole> get knownRoles => <BarRole>[
    for (final BarRole role in shape.roles)
      if (role != unknown) role,
  ];

  /// The known places the child fills, in the order they are shown.
  List<BarRole> get placeableRoles => <BarRole>[
    for (final BarRole role in knownRoles)
      if (!prefilled.contains(role)) role,
  ];

  /// The calculation that finds the answer as a prompt: `12 − 5 = 7`. The
  /// known numbers come in the order of the places of the model, which is
  /// the order of the operation (the whole before the part, the total
  /// before the group).
  List<PromptToken> get calculation {
    final List<int> known = <int>[
      for (final BarRole role in knownRoles) values[role]!,
    ];
    return <PromptToken>[
      NumberToken(known[0]),
      OperatorToken(operator),
      NumberToken(known[1]),
      const EqualsToken(),
      NumberToken(answer),
    ];
  }

  /// Whether the two known places can be filled in either order: the two
  /// parts of a whole whose total is the question.
  bool get hasInterchangeableParts =>
      shape == BarModelShape.partWhole && unknown == BarRole.whole;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BarModelPicture) return false;
    if (other.shape != shape ||
        other.unknown != unknown ||
        other.operator != operator ||
        other.check != check ||
        other.isRemoval != isRemoval ||
        other.prefilled.length != prefilled.length ||
        !other.prefilled.containsAll(prefilled)) {
      return false;
    }
    return shape.roles.every(
      (BarRole role) => other.values[role] == values[role],
    );
  }

  @override
  int get hashCode => Object.hash(
    shape,
    unknown,
    operator,
    check,
    isRemoval,
    Object.hashAllUnordered(prefilled),
    Object.hashAll(shape.roles.map((BarRole role) => values[role])),
  );

  @override
  String toString() => 'BarModelPicture($shape, $values, ?$unknown)';
}
