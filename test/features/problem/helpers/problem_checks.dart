import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';

/// Whether the relation the bar model of each shape holds is true.
bool modelHolds(BarModelPicture picture) {
  final Map<BarRole, int> v = picture.values;
  return switch (picture.shape) {
    BarModelShape.partWhole =>
      v[BarRole.whole] == v[BarRole.partA]! + v[BarRole.partB]!,
    BarModelShape.compare =>
      v[BarRole.big] == v[BarRole.small]! + v[BarRole.gap]!,
    BarModelShape.groups =>
      v[BarRole.total] == v[BarRole.groups]! * v[BarRole.each]!,
    BarModelShape.ratio =>
      v[BarRole.big] == v[BarRole.small]! * v[BarRole.times]!,
  };
}

/// Every operation that gives the answer of [picture] from its two known
/// numbers, taken in either order.
Set<MathOperator> operationsGiving(BarModelPicture picture) {
  final List<int> known = <int>[
    for (final BarRole role in picture.knownRoles) picture.values[role]!,
  ];
  final int answer = picture.answer;
  bool gives(int x, int y, MathOperator operator) => switch (operator) {
    MathOperator.add => x + y == answer,
    MathOperator.subtract => x - y == answer,
    MathOperator.multiply => x * y == answer,
    _ => y != 0 && x % y == 0 && x ~/ y == answer,
  };
  return <MathOperator>{
    for (final MathOperator operator in <MathOperator>[
      MathOperator.add,
      MathOperator.subtract,
      MathOperator.multiply,
      MathOperator.divide,
    ])
      if (gives(known[0], known[1], operator) ||
          gives(known[1], known[0], operator))
        operator,
  };
}
