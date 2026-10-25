import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_draw.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:meta/meta.dart';

/// A template with its numbers decided: the statement to read and the bar
/// model that solves it.
@immutable
final class ProblemInstance {
  /// Creates the instance of [template] with [values].
  const ProblemInstance({
    required this.template,
    required this.values,
    required this.statement,
    required this.picture,
    required this.isRecorded,
  });

  /// The template it comes from.
  final ProblemTemplate template;

  /// The numbers drawn (or fixed), by name.
  final ProblemValues values;

  /// The statement in French with the numbers written in.
  final String statement;

  /// The bar model of the story, the answer included.
  final BarModelPicture picture;

  /// Whether these are the fixed numbers of the recorded statement.
  final bool isRecorded;

  /// The number the child looks for.
  int get answer => picture.answer;
}
