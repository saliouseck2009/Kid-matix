import 'package:kid_matix/core/entities/currency.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_draw.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_instance.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_ref.dart';

/// One word problem of `docs/product/problems.md`: a story whose numbers
/// can be drawn, the item the mastery engine follows (`problem:<key>`).
///
/// The recorded statement keeps its [fixed] numbers; every other instance
/// draws its numbers with [draws]. The content is written in Dart (see
/// `ProblemTemplates`) and a test checks it against the table.
final class ProblemTemplate implements LearningItem {
  /// Creates a template. [statement] and [check] write the numbers as `{a}`,
  /// `{b}`, `{r}` and the money as `{currency}`.
  ProblemTemplate({
    required this.problemKey,
    required this.level,
    required this.operation,
    required this.shape,
    required this.unknown,
    required Map<BarRole, ProblemRef> roles,
    required this.statement,
    required this.check,
    required Map<String, int> fixed,
    required List<ProblemDraw> draws,
    this.isRemoval = false,
    this.trapOf,
    this.accepts,
  }) : roles = Map<BarRole, ProblemRef>.unmodifiable(roles),
       fixed = Map<String, int>.unmodifiable(fixed),
       draws = List<ProblemDraw>.unmodifiable(draws),
       assert(level >= 1 && level <= 3, 'three levels'),
       assert(
         roles.length == shape.roles.length &&
             shape.roles.every(roles.containsKey),
         'a number for every place of the model',
       );

  /// Prefix of every key of the domain.
  static const String keyPrefix = 'problem';

  /// Greatest number of each level (`a`, `b` and the answer).
  static const Map<int, int> levelCaps = <int, int>{1: 20, 2: 50, 3: 100};

  /// Stable short name, the name of the recording: `mangues_donnees`.
  final String problemKey;

  /// 1 with images, 2 short sentence, 3 full statement.
  final int level;

  /// The operation that gives the answer.
  final MathOperator operation;

  /// The drawing of the model.
  final BarModelShape shape;

  /// The place whose number is asked.
  final BarRole unknown;

  /// Where each number of the draw goes in the model.
  final Map<BarRole, ProblemRef> roles;

  /// The statement with `{a}`, `{b}`, `{r}` and `{currency}`.
  final String statement;

  /// The sentence of the last guided step, with the same placeholders.
  final String check;

  /// The numbers of the recorded statement.
  final Map<String, int> fixed;

  /// How the numbers are drawn, in order.
  final List<ProblemDraw> draws;

  /// Whether the story takes a part away.
  final bool isRemoval;

  /// For a trap problem, the key of its plain twin; `null` otherwise. The
  /// code never reads it to decide an operation, only to group and test.
  final String? trapOf;

  /// An extra rule on the numbers drawn, such as `b < a`.
  final bool Function(ProblemValues values)? accepts;

  /// Whether this is a trap of the keyword.
  bool get isTrap => trapOf != null;

  @override
  String get key => '$keyPrefix:$problemKey';

  /// Name of the recording of the statement in the audio packs.
  String get recordingKey => '${keyPrefix}_$problemKey';

  late final List<ProblemValues> _valid = _enumerate();

  /// Every set of numbers the draw allows, without ambiguity.
  List<ProblemValues> get validValues => _valid;

  /// The recorded statement, with its fixed numbers.
  ProblemInstance fixedInstance({
    Currency currency = Currency.defaultCurrency,
  }) {
    return _instanceOf(fixed, currency, isRecorded: true);
  }

  /// Most tries of the step-by-step draw before it falls back on the list.
  static const int drawAttempts = 40;

  /// An instance with drawn numbers. Each number is drawn uniformly in its
  /// range, from left to right as the table gives them, and a draw that
  /// breaks a rule (the level cap, a constraint, an ambiguity) is rejected
  /// and made again; after [drawAttempts] failures, a set of numbers is
  /// picked in the list of every valid one, so a draw always ends.
  ProblemInstance drawnInstance(
    RandomSource random, {
    Currency currency = Currency.defaultCurrency,
  }) {
    for (int attempt = 0; attempt < drawAttempts; attempt++) {
      final ProblemValues drawn = <String, int>{};
      for (final ProblemDraw draw in draws) {
        final List<int> options = draw.options(drawn).toList();
        if (options.isEmpty) break;
        drawn[draw.name] = options[random.nextInt(options.length)];
      }
      if (drawn.length == draws.length && isValid(drawn)) {
        return instanceOf(drawn, currency: currency);
      }
    }
    return instanceOf(
      _valid[random.nextInt(_valid.length)],
      currency: currency,
    );
  }

  /// The instance of [values], numbers that are not the recorded ones.
  ProblemInstance instanceOf(
    ProblemValues values, {
    Currency currency = Currency.defaultCurrency,
  }) {
    return _instanceOf(values, currency, isRecorded: false);
  }

  /// Whether [values] respects the caps and the draw rules, and leaves only
  /// one operation that gives the answer.
  bool isValid(ProblemValues values) {
    for (final int value in values.values) {
      if (value < 1 || value > levelCaps[level]!) return false;
    }
    if (accepts != null && !accepts!(values)) return false;
    final BarModelPicture picture = _pictureOf(
      values,
      Currency.defaultCurrency,
    );
    return _isUnambiguous(picture);
  }

  ProblemInstance _instanceOf(
    ProblemValues values,
    Currency currency, {
    required bool isRecorded,
  }) {
    return ProblemInstance(
      template: this,
      values: Map<String, int>.unmodifiable(values),
      statement: _write(statement, values, currency),
      picture: _pictureOf(values, currency),
      isRecorded: isRecorded,
    );
  }

  BarModelPicture _pictureOf(ProblemValues values, Currency currency) {
    return BarModelPicture(
      shape: shape,
      values: <BarRole, int>{
        for (final MapEntry<BarRole, ProblemRef> entry in roles.entries)
          entry.key: entry.value.valueIn(values),
      },
      unknown: unknown,
      operator: operation,
      check: _write(check, values, currency),
      isRemoval: isRemoval,
      prefilled: <BarRole>{
        for (final MapEntry<BarRole, ProblemRef> entry in roles.entries)
          if (entry.value.constant != null) entry.key,
      },
    );
  }

  static String _write(String text, ProblemValues values, Currency currency) {
    String written = text.replaceAll('{currency}', currency.unitName);
    for (final MapEntry<String, int> entry in values.entries) {
      written = written.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return written;
  }

  List<ProblemValues> _enumerate() {
    final List<ProblemValues> found = <ProblemValues>[];
    void walk(int step, ProblemValues drawn) {
      if (step == draws.length) {
        if (isValid(drawn)) found.add(Map<String, int>.of(drawn));
        return;
      }
      final ProblemDraw draw = draws[step];
      for (final int value in draw.options(drawn)) {
        walk(step + 1, <String, int>{...drawn, draw.name: value});
      }
    }

    walk(0, <String, int>{});
    return found;
  }

  /// One operation only gives the answer from the two known numbers, taken
  /// in either order: 2 + 2 and 2 × 2 would both fit, so such numbers are
  /// never drawn.
  bool _isUnambiguous(BarModelPicture picture) {
    final List<int> known = <int>[
      for (final BarRole role in picture.knownRoles) picture.values[role]!,
    ];
    final int answer = picture.answer;
    for (final MathOperator other in _operations) {
      if (other == operation) continue;
      if (_apply(other, known[0], known[1]) == answer ||
          _apply(other, known[1], known[0]) == answer) {
        return false;
      }
    }
    return true;
  }

  static const List<MathOperator> _operations = <MathOperator>[
    MathOperator.add,
    MathOperator.subtract,
    MathOperator.multiply,
    MathOperator.divide,
  ];

  /// `x op y`, or `null` when the result is not a whole number above 0.
  static int? _apply(MathOperator operator, int x, int y) {
    final int? result = switch (operator) {
      MathOperator.add => x + y,
      MathOperator.subtract => x - y,
      MathOperator.multiply => x * y,
      MathOperator.divide => y != 0 && x % y == 0 ? x ~/ y : null,
      _ => null,
    };
    return result != null && result > 0 ? result : null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemTemplate && other.problemKey == problemKey;

  @override
  int get hashCode => problemKey.hashCode;

  @override
  String toString() => key;
}
