import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:meta/meta.dart';

/// A world of the path « Problèmes »: the problems of one level told one
/// way (`img1`, `short2`, `full1`), or the trap problems of one level
/// (`trap1`). Its name says the level, never an operation.
///
/// The traps have a unit of their own after the plain problems of their
/// level, so a trap is only met once the plain twin has been played.
@immutable
final class ProblemUnit implements LearningUnit {
  /// Creates the unit [slug], the [number]th of the path.
  ProblemUnit({
    required this.slug,
    required this.number,
    required List<ProblemTemplate> problems,
  }) : problems = List<ProblemTemplate>.unmodifiable(problems);

  /// Prefix of every key of a unit.
  static const String keyPrefix = 'probs';

  /// Short stable name inside the key, such as `img1` or `trap2`.
  final String slug;

  /// Position of the unit on the path, from 1.
  @override
  final int number;

  /// The problems of the unit, in the order of the content table.
  final List<ProblemTemplate> problems;

  /// Stable key, such as `probs:img1`; never changes once released.
  @override
  String get key => '$keyPrefix:$slug';

  @override
  List<LearningItem> get items => problems;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProblemUnit && other.slug == slug;

  @override
  int get hashCode => slug.hashCode;

  @override
  String toString() => key;
}
