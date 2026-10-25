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

  /// Slug of each level inside a unit key: problems told with images,
  /// short sentences, full statements.
  static const Map<int, String> levelSlugs = <int, String>{
    1: 'img',
    2: 'short',
    3: 'full',
  };

  /// Slug of the unit of the traps, before the level.
  static const String trapSlug = 'trap';

  /// Units of plain problems in a level: additions and subtractions first,
  /// then multiplications and divisions.
  static const int partsPerLevel = 2;

  /// Every problem, in the order of the content table.
  final List<ProblemTemplate> problems;

  /// The units, in the order of the path.
  final List<ProblemUnit> units;

  late final Map<String, ProblemTemplate> _byKey = <String, ProblemTemplate>{
    for (final ProblemTemplate problem in problems) problem.problemKey: problem,
  };

  /// The problem of [problemKey], or `null`.
  ProblemTemplate? problemOf(String problemKey) => _byKey[problemKey];

  /// The unit slug of [problem]: `img1` (images, additions and
  /// subtractions), `short2` (short sentences, multiplications and
  /// divisions), or `trap1` for a trap.
  static String slugOf(ProblemTemplate problem) {
    if (problem.isTrap) return '$trapSlug${problem.level}';
    final bool isAdditive =
        problem.operation == MathOperator.add ||
        problem.operation == MathOperator.subtract;
    return '${levelSlugs[problem.level]}${isAdditive ? 1 : 2}';
  }

  static List<ProblemUnit> _unitsOf(List<ProblemTemplate> problems) {
    final List<ProblemUnit> units = <ProblemUnit>[];
    for (int level = 1; level <= levelSlugs.length; level++) {
      final List<String> slugs = <String>[
        for (int part = 1; part <= partsPerLevel; part++)
          '${levelSlugs[level]}$part',
        '$trapSlug$level',
      ];
      for (final String slug in slugs) {
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
