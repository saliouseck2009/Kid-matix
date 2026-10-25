import 'package:kid_matix/features/problem/domain/entities/problem_draw.dart';
import 'package:meta/meta.dart';

/// What fills a place of the bar model: a number of the draw (`a`, `b`,
/// `r`), or a number the story fixes, such as the 2 of « la moitié ».
@immutable
final class ProblemRef {
  /// The number named [name] in the draw.
  const ProblemRef.variable(String this.name) : constant = null;

  /// The fixed number [value].
  const ProblemRef.constant(int value) : name = null, constant = value;

  /// Name in the draw, or `null` for a constant.
  final String? name;

  /// The fixed number, or `null` for a name of the draw.
  final int? constant;

  /// The number it stands for once [values] is drawn.
  int valueIn(ProblemValues values) => constant ?? values[name]!;
}
