import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_unit.dart';

/// The problems of the domain and the units of their path.
///
/// The path goes level by level; inside a level, one unit per operation
/// (+, −, ×, ÷) that has problems, then the traps of the level.
final class ProblemCatalog {
  /// Creates the catalog of [problems], in the order of the content table;
  /// throws a [FormatException] when two share a key or a trap names a twin
  /// that does not exist.
  factory ProblemCatalog(List<ProblemTemplate> problems) {
    final Set<String> keys = problems
        .map((ProblemTemplate problem) => problem.problemKey)
        .toSet();
    if (keys.length != problems.length) {
      throw const FormatException('Two problems share a key');
    }
    for (final ProblemTemplate problem in problems) {
      final String? twin = problem.trapOf;
      if (twin != null && !keys.contains(twin)) {
        throw FormatException('${problem.problemKey} has no twin $twin');
      }
    }
    return ProblemCatalog._(problems);
  }

  ProblemCatalog._(List<ProblemTemplate> problems)
    : problems = List<ProblemTemplate>.unmodifiable(problems),
      units = List<ProblemUnit>.unmodifiable(_unitsOf(problems));

  /// Slug of the operation inside a unit key.
  static const Map<MathOperator, String> operationSlugs =
      <MathOperator, String>{
        MathOperator.add: 'add',
        MathOperator.subtract: 'sub',
        MathOperator.multiply: 'mul',
        MathOperator.divide: 'div',
      };

  /// Slug of the unit of the traps, before the level.
  static const String trapSlug = 'trap';

  /// Every problem, in the order of the content table.
  final List<ProblemTemplate> problems;

  /// The units, in the order of the path.
  final List<ProblemUnit> units;

  late final Map<String, ProblemTemplate> _byKey = <String, ProblemTemplate>{
    for (final ProblemTemplate problem in problems) problem.problemKey: problem,
  };

  /// The problem of [problemKey], or `null`.
  ProblemTemplate? problemOf(String problemKey) => _byKey[problemKey];

  /// The unit slug of [problem]: `add1`, or `trap1` for a trap.
  static String slugOf(ProblemTemplate problem) {
    final String name = problem.isTrap
        ? trapSlug
        : operationSlugs[problem.operation]!;
    return '$name${problem.level}';
  }

  static List<ProblemUnit> _unitsOf(List<ProblemTemplate> problems) {
    final List<ProblemUnit> units = <ProblemUnit>[];
    for (int level = 1; level <= 3; level++) {
      final List<String> names = <String>[
        ...operationSlugs.values,
        trapSlug,
      ];
      for (final String name in names) {
        final String slug = '$name$level';
        final List<ProblemTemplate> inUnit = <ProblemTemplate>[
          for (final ProblemTemplate problem in problems)
            if (slugOf(problem) == slug) problem,
        ];
        if (inUnit.isEmpty) continue;
        units.add(
          ProblemUnit(slug: slug, number: units.length + 1, problems: inUnit),
        );
      }
    }
    return units;
  }
}
