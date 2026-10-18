import 'package:kid_matix/core/quiz/comparison.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:meta/meta.dart';

/// One thing to master with the numbers up to 100, such as counting 7
/// objects or comparing 34 and 43.
///
/// Its key never changes once released, since the stored progress refers
/// to it: `num:<skill>:<values>`, such as `num:count:7`.
@immutable
sealed class NumberItem implements LearningItem {
  const NumberItem();

  /// Prefix of every key of the numbers domain.
  static const String keyPrefix = 'num';

  /// Gap of a mistake on the tens digit, such as 50 for 40.
  static const int tenGap = 10;

  /// The question types fit for the item, in the order of the domain.
  List<String> get questionTypeIds;

  /// The whole item with its answer, such as `30 + 4 = 34` or `34 < 43`.
  List<PromptToken> describe();

  /// Drawing of the item with its answer, for the help card, or `null`.
  MathPicture? get solvedPicture;

  /// Two items are the same when they have the same key: the progress
  /// stored under a key belongs to one item only.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NumberItem && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => key;
}

/// An item whose answer is a number read from a drawing: picked among
/// four or written on the keypad.
sealed class PictureNumberItem extends NumberItem {
  const PictureNumberItem();

  /// The number to find.
  int get answer;

  /// Drawing of the question.
  MathPicture get picture;

  /// Prompt under the drawing: the blank to fill, or nothing when the
  /// blank is part of the drawing, such as on a number line.
  List<PromptToken> get prompt => const <PromptToken>[BlankToken()];

  /// Plausible wrong answers, the most telling first; some may be
  /// invalid, the domain keeps the right ones.
  List<int> get mistakes;

  /// The mistake a child makes most often, always offered when valid, or
  /// `null`.
  int? get typicalMistake => null;
}

/// Count [count] objects: `num:count:7`.
final class CountItem extends PictureNumberItem {
  /// Creates the item of [count] objects.
  const CountItem(this.count);

  /// Number of objects drawn.
  final int count;

  @override
  String get key => '${NumberItem.keyPrefix}:count:$count';

  @override
  int get answer => count;

  @override
  MathPicture get picture => ObjectsPicture(count: count);

  @override
  MathPicture? get solvedPicture => picture;

  @override
  List<String> get questionTypeIds => const <String>[
    QuestionTypeIds.countObjects,
    QuestionTypeIds.typedAnswer,
  ];

  @override
  List<int> get mistakes => <int>[count - 1, count + 1, count - 2, count + 2];

  @override
  List<PromptToken> describe() => <PromptToken>[NumberToken(count)];
}

/// Read a number of tens and its ones from bundles of ten and loose
/// sticks: `num:tens:30` for whole tens, `num:place:34` for a number with
/// ones.
final class TensOnesItem extends PictureNumberItem {
  /// Creates the item of [value]; [isWholeTens] tells which key it has.
  const TensOnesItem(this.value, {this.isWholeTens = false});

  /// Number shown, from 10 to 100.
  final int value;

  /// Whether the item counts tens only, `num:tens:30`.
  final bool isWholeTens;

  int get _tens => value ~/ TenBundlesPicture.sticksPerBundle;

  int get _ones => value % TenBundlesPicture.sticksPerBundle;

  @override
  String get key =>
      '${NumberItem.keyPrefix}:${isWholeTens ? 'tens' : 'place'}:$value';

  @override
  int get answer => value;

  @override
  MathPicture get picture => TenBundlesPicture(tens: _tens, ones: _ones);

  @override
  MathPicture? get solvedPicture => picture;

  @override
  List<String> get questionTypeIds => const <String>[
    QuestionTypeIds.tensAndOnes,
    QuestionTypeIds.typedAnswer,
  ];

  /// The digits swapped, 43 for 34: the classic mistake; `null` for whole
  /// tens.
  @override
  int? get typicalMistake {
    if (_ones == 0) return null;
    return _ones * TenBundlesPicture.sticksPerBundle + _tens;
  }

  @override
  List<int> get mistakes => <int>[
    if (_ones == 0) _tens else _tens + _ones,
    value - TenBundlesPicture.sticksPerBundle,
    value + TenBundlesPicture.sticksPerBundle,
    value - 1,
    value + 1,
  ];

  @override
  List<PromptToken> describe() {
    if (_ones == 0) return <PromptToken>[NumberToken(value)];
    return <PromptToken>[
      NumberToken(_tens * TenBundlesPicture.sticksPerBundle),
      const OperatorToken(MathOperator.add),
      NumberToken(_ones),
      const EqualsToken(),
      NumberToken(value),
    ];
  }
}

/// Find the number missing on a number line: ticks [step] apart, such as
/// `2 4 6 ? 10` for `num:line:8:2`.
final class NumberLineItem extends PictureNumberItem {
  /// Creates the line of [tickCount] ticks [step] apart whose tick
  /// [blankIndex] holds [missing].
  const NumberLineItem({
    required this.missing,
    required this.step,
    required this.blankIndex,
    this.tickCount = defaultTickCount,
  });

  /// Ticks of a line.
  static const int defaultTickCount = 5;

  /// Number to find.
  final int missing;

  /// Gap between two ticks.
  final int step;

  /// Position of the blank tick, from 0.
  final int blankIndex;

  /// Ticks of the line.
  final int tickCount;

  /// Number of every tick, from left to right.
  List<int> get values => <int>[
    for (int index = 0; index < tickCount; index++)
      missing + (index - blankIndex) * step,
  ];

  @override
  String get key => '${NumberItem.keyPrefix}:line:$missing:$step';

  @override
  int get answer => missing;

  @override
  MathPicture get picture =>
      NumberLinePicture(values: values, blankIndex: blankIndex);

  @override
  MathPicture? get solvedPicture =>
      NumberLinePicture(values: values, highlightIndex: blankIndex);

  @override
  List<PromptToken> get prompt => const <PromptToken>[];

  @override
  List<String> get questionTypeIds => const <String>[
    QuestionTypeIds.numberLine,
    QuestionTypeIds.typedAnswer,
  ];

  @override
  List<int> get mistakes => <int>[
    missing - 1,
    missing + 1,
    missing + step,
    missing - step,
    missing + NumberItem.tenGap,
    missing - NumberItem.tenGap,
  ];

  @override
  List<PromptToken> describe() => values.map(NumberToken.new).toList();
}

/// Find the number just before or just after [reference]: `num:after:39`
/// asks 40, `num:before:30` asks 29, on a line of three ticks.
final class NeighborItem extends PictureNumberItem {
  /// Creates the item of the number after [reference], or before it when
  /// [isAfter] is false.
  const NeighborItem({required this.reference, required this.isAfter});

  /// Number given, in the middle of the line.
  final int reference;

  /// Whether the number to find comes after [reference].
  final bool isAfter;

  static const int _firstIndex = 0;
  static const int _middleIndex = 1;
  static const int _lastIndex = 2;

  List<int> get _values => <int>[reference - 1, reference, reference + 1];

  int get _blankIndex => isAfter ? _lastIndex : _firstIndex;

  @override
  String get key =>
      '${NumberItem.keyPrefix}:${isAfter ? 'after' : 'before'}:$reference';

  @override
  int get answer => isAfter ? reference + 1 : reference - 1;

  @override
  MathPicture get picture => NumberLinePicture(
    values: _values,
    blankIndex: _blankIndex,
    highlightIndex: _middleIndex,
  );

  @override
  MathPicture? get solvedPicture =>
      NumberLinePicture(values: _values, highlightIndex: _blankIndex);

  @override
  List<PromptToken> get prompt => const <PromptToken>[];

  @override
  List<String> get questionTypeIds => const <String>[
    QuestionTypeIds.numberLine,
    QuestionTypeIds.typedAnswer,
  ];

  /// The other neighbor and the numbers ten apart, such as 38, 41, 50 and
  /// 30 for the number after 39.
  @override
  List<int> get mistakes => <int>[
    if (isAfter) reference - 1 else reference + 1,
    if (isAfter) answer + 1 else answer - 1,
    answer + NumberItem.tenGap,
    answer - NumberItem.tenGap,
  ];

  @override
  List<PromptToken> describe() => _values.map(NumberToken.new).toList();
}

/// Compare [first] with [second]: `num:compare:34:43`.
final class CompareItem extends NumberItem {
  /// Creates the comparison of [first] with [second].
  const CompareItem(this.first, this.second);

  /// Number on the left.
  final int first;

  /// Number on the right.
  final int second;

  /// How [first] compares with [second].
  Comparison get comparison => Comparison.of(first, second);

  @override
  String get key => '${NumberItem.keyPrefix}:compare:$first:$second';

  @override
  List<String> get questionTypeIds => const <String>[QuestionTypeIds.compare];

  /// Both numbers on a line, the greater on the right; `null` when they
  /// are equal.
  @override
  MathPicture? get solvedPicture {
    if (first == second) return null;
    final bool isFirstSmaller = first < second;
    return NumberLinePicture(
      values: isFirstSmaller ? <int>[first, second] : <int>[second, first],
      highlightIndex: isFirstSmaller ? 0 : 1,
    );
  }

  @override
  List<PromptToken> describe() {
    return <PromptToken>[
      NumberToken(first),
      switch (comparison) {
        Comparison.less => const OperatorToken(MathOperator.lessThan),
        Comparison.equal => const OperatorToken(MathOperator.equalTo),
        Comparison.greater => const OperatorToken(MathOperator.greaterThan),
      },
      NumberToken(second),
    ];
  }
}
