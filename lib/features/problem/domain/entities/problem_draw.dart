/// The numbers drawn so far for a problem, by name (`a`, `b`, `r`).
typedef ProblemValues = Map<String, int>;

/// One step of the draw of the numbers of a problem template: the numbers
/// are decided one after the other, in the order the content table gives,
/// each one possibly depending on the previous ones.
sealed class ProblemDraw {
  /// Creates a step that decides [name].
  const ProblemDraw(this.name);

  /// Name of the number decided, such as `a`.
  final String name;

  /// Every value [name] can take once [drawn] is decided.
  Iterable<int> options(ProblemValues drawn);
}

/// A whole number from [min] to [max], both included.
final class RangeDraw extends ProblemDraw {
  /// Creates the range of [name].
  const RangeDraw(super.name, {required this.min, required this.max});

  /// Smallest value, given the numbers drawn before.
  final int Function(ProblemValues drawn) min;

  /// Greatest value, given the numbers drawn before.
  final int Function(ProblemValues drawn) max;

  @override
  Iterable<int> options(ProblemValues drawn) sync* {
    final int last = max(drawn);
    for (int value = min(drawn); value <= last; value++) {
      yield value;
    }
  }
}

/// One value among a short list, such as the sums of money 25, 50 or 75.
final class ChoiceDraw extends ProblemDraw {
  /// Creates the choice of [name] among [values].
  const ChoiceDraw(super.name, this.values);

  /// The values allowed.
  final List<int> values;

  @override
  Iterable<int> options(ProblemValues drawn) => values;
}

/// A number worked out from the others, such as the answer of an addition
/// or the dividend of a division.
final class DeriveDraw extends ProblemDraw {
  /// Creates the number [name] computed by [compute].
  const DeriveDraw(super.name, this.compute);

  /// How the number follows from the numbers drawn before.
  final int Function(ProblemValues drawn) compute;

  @override
  Iterable<int> options(ProblemValues drawn) => <int>[compute(drawn)];
}
