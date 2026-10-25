/// The grammar of the column « Plages » of `docs/product/problems.md`,
/// read as data so the typed templates can be checked against it:
///
/// - `x ∈ [lo, hi]`: an integer drawn from `lo` to `hi`, both included;
///   the bounds may use the numbers drawn before (`a − 2`, `20 − a`).
/// - `x ∈ {v1, v2}`: one value of the list.
/// - `x = expression [≤ cap]`: a number worked out, never drawn.
/// - `x < y`: a condition on the numbers drawn so far.
///
/// The statements come in the order of the draw. The cap of the level
/// applies to every number, and every number is at least 1.
final class RangesGrammar {
  RangesGrammar._(this.statements);

  /// Reads the text of a « Plages » cell.
  factory RangesGrammar.parse(String text) {
    return RangesGrammar._(
      text.split(';').map((String part) => part.trim()).toList(),
    );
  }

  /// The statements, in the order of the draw.
  final List<String> statements;

  static final RegExp _range = RegExp(r'^(\w) ∈ \[(.+), (.+)\]$');
  static final RegExp _choice = RegExp(r'^(\w) ∈ \{(.+)\}$');
  static final RegExp _derived = RegExp(r'^(\w) = (.+?)(?: ≤ (\d+))?$');
  static final RegExp _condition = RegExp(r'^(\w) < (\w)$');

  /// The names of the numbers, in the order they are decided.
  List<String> get names => <String>[
    for (final String statement in statements)
      if (!_condition.hasMatch(statement)) statement[0],
  ];

  /// Every set of numbers the grammar allows under the cap [levelCap].
  List<Map<String, int>> enumerate(int levelCap) {
    final List<Map<String, int>> found = <Map<String, int>>[];
    void walk(int index, Map<String, int> drawn) {
      if (index == statements.length) {
        if (drawn.values.every((int v) => v >= 1 && v <= levelCap)) {
          found.add(Map<String, int>.of(drawn));
        }
        return;
      }
      final String statement = statements[index];
      final RegExpMatch? range = _range.firstMatch(statement);
      if (range != null) {
        final int low = _evaluate(range.group(2)!, drawn);
        final int high = _evaluate(range.group(3)!, drawn);
        for (int value = low; value <= high; value++) {
          walk(index + 1, <String, int>{...drawn, range.group(1)!: value});
        }
        return;
      }
      final RegExpMatch? choice = _choice.firstMatch(statement);
      if (choice != null) {
        for (final String value in choice.group(2)!.split(',')) {
          walk(index + 1, <String, int>{
            ...drawn,
            choice.group(1)!: int.parse(value.trim()),
          });
        }
        return;
      }
      final RegExpMatch? condition = _condition.firstMatch(statement);
      if (condition != null) {
        if (drawn[condition.group(1)!]! < drawn[condition.group(2)!]!) {
          walk(index + 1, drawn);
        }
        return;
      }
      final RegExpMatch derived = _derived.firstMatch(statement)!;
      final int value = _evaluate(derived.group(2)!, drawn);
      final String? cap = derived.group(3);
      if (cap != null && value > int.parse(cap)) return;
      walk(index + 1, <String, int>{...drawn, derived.group(1)!: value});
    }

    walk(0, <String, int>{});
    return found;
  }

  /// `a`, `12`, `a − 2`, `20 − a`, `b × r`, `2 × a`, `a + b`.
  static int _evaluate(String expression, Map<String, int> drawn) {
    int operand(String token) => int.tryParse(token) ?? drawn[token]!;
    final List<String> tokens = expression.trim().split(' ');
    if (tokens.length == 1) return operand(tokens.first);
    final int left = operand(tokens[0]);
    final int right = operand(tokens[2]);
    return switch (tokens[1]) {
      '+' => left + right,
      '−' => left - right,
      '×' => left * right,
      _ => throw FormatException('Unknown operator in $expression'),
    };
  }
}
