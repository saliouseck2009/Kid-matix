import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/currency.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:kid_matix/features/math_word/domain/entities/math_word_catalog.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_instance.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_ref.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_templates.dart';
import 'package:kid_matix/features/problem/domain/services/problem_calculation.dart';

import '../math_word/helpers/math_word_fixtures.dart';
import 'helpers/problems_table.dart';

/// The typed content of `ProblemTemplates` against the table
/// `docs/product/problems.md`, which the owner edits: a difference in a
/// key, a level, an operation, a form, a role, a statement, a check
/// sentence, a trap or a touchable word fails here.
void main() {
  final List<ProblemRow> rows = readProblemsTable();
  final MathWordCatalog words = loadMathWordCatalog();
  final Map<String, ProblemTemplate> templates = <String, ProblemTemplate>{
    for (final ProblemTemplate problem in ProblemTemplates.all)
      problem.problemKey: problem,
  };

  /// Role names of each form, mapped to the places of the model.
  const Map<String, Map<String, BarRole>> roleNames =
      <String, Map<String, BarRole>>{
        'reunir': <String, BarRole>{
          'tout': BarRole.whole,
          'partie1': BarRole.partA,
          'partie2': BarRole.partB,
        },
        'retirer': <String, BarRole>{
          'tout': BarRole.whole,
          'partie': BarRole.partA,
          'reste': BarRole.partB,
        },
        'comparer': <String, BarRole>{
          'grand': BarRole.big,
          'petit': BarRole.small,
          'ecart': BarRole.gap,
          'fois': BarRole.times,
        },
        'groupes': <String, BarRole>{
          'groupes': BarRole.groups,
          'taille': BarRole.each,
          'tout': BarRole.total,
        },
        'groupement': <String, BarRole>{
          'tout': BarRole.total,
          'taille': BarRole.each,
          'groupes': BarRole.groups,
        },
        'partage': <String, BarRole>{
          'tout': BarRole.total,
          'parts': BarRole.groups,
          'part': BarRole.each,
        },
      };
  const Map<String, MathOperator> signs = <String, MathOperator>{
    '+': MathOperator.add,
    '−': MathOperator.subtract,
    '×': MathOperator.multiply,
    '÷': MathOperator.divide,
  };
  final String unit = Currency.cfaFranc.unitName;

  /// Differences between the column « Mots des maths » of the table and
  /// the words the rule finds in the statement (first whole-word match of
  /// the word or its form): to report to the table, then to delete here.
  const Map<String, ({Set<String> add, Set<String> remove})> tableGaps =
      <String, ({Set<String> add, Set<String> remove})>{
        'mangues_donnees_piege': (add: <String>{'combien'}, remove: <String>{}),
        'mangues_partagees': (
          add: <String>{'combien', 'recevoir'},
          remove: <String>{},
        ),
        'billes_chacun_piege': (add: <String>{'combien'}, remove: <String>{}),
        'fatou_sachets': (add: <String>{'combien'}, remove: <String>{}),
        'biscuits_range': (add: <String>{'combien'}, remove: <String>{}),
        'biscuits_partages_piege': (
          add: <String>{},
          remove: <String>{'partager'},
        ),
        'achat_sachet_eau': (add: <String>{'combien'}, remove: <String>{}),
      };

  test('has the 30 problems of the table, in its order, ten per level', () {
    // Assert
    expect(rows, hasLength(30));
    expect(
      ProblemTemplates.all.map((ProblemTemplate p) => p.problemKey).toList(),
      rows.map((ProblemRow row) => row.key).toList(),
    );
    for (int level = 1; level <= 3; level++) {
      expect(
        ProblemTemplates.all.where((ProblemTemplate p) => p.level == level),
        hasLength(10),
      );
    }
  });

  test('pins the released keys', () {
    // Assert
    expect(
      ProblemTemplates.all.map((ProblemTemplate p) => p.key).toSet(),
      containsAll(<String>[
        'problem:mangues_donnees',
        'problem:mangues_donnees_piege',
        'problem:billes_recues',
        'problem:achat_sachet_eau',
        'problem:billes_difference',
        'problem:billes_mamadou_moins_piege',
        'problem:pains_vendus',
      ]),
    );
  });

  for (final ProblemRow row in rows) {
    group(row.key, () {
      final ProblemTemplate template = templates[row.key]!;
      final ProblemInstance recorded = template.fixedInstance();

      test('has the level, the operation and the shape of the table', () {
        // Assert
        expect(template.level, row.level);
        expect(template.operation, signs[row.operation]);
        expect(template.shape, switch (row.form) {
          'reunir' || 'retirer' => BarModelShape.partWhole,
          'comparer' =>
            row.roles.containsKey('fois')
                ? BarModelShape.ratio
                : BarModelShape.compare,
          _ => BarModelShape.groups,
        });
      });

      test('puts each placeholder in the role the table says', () {
        // Arrange
        final Map<String, BarRole> names = roleNames[row.form]!;
        // Assert
        expect(row.roles.keys.toSet().difference(names.keys.toSet()), isEmpty);
        expect(
          row.roles.keys.map((String name) => names[name]).toSet(),
          template.shape.roles.toSet(),
        );
        for (final MapEntry<String, String> role in row.roles.entries) {
          final ProblemRef ref = template.roles[names[role.key]]!;
          final int? literal = int.tryParse(role.value);
          expect(
            literal == null ? ref.name : ref.constant,
            literal ?? role.value,
            reason: role.key,
          );
        }
      });

      test('writes the recorded statement of the table', () {
        // Assert
        expect(recorded.statement, row.statement);
        expect(recorded.isRecorded, isTrue);
      });

      test('writes the template and the check sentence of the table', () {
        // Assert
        expect(template.statement.replaceAll('{currency}', unit), row.template);
        expect(template.check.replaceAll('{currency}', unit), row.check);
      });

      test('makes the calculation of the table with the recorded numbers', () {
        // Arrange
        final List<String> expected = RegExp(
          r'\d+',
        ).allMatches(row.calculation).map((m) => m.group(0)!).toList();
        final List<String> actual = const ProblemCalculation()
            .tokensOf(recorded.picture)
            .whereType<Object>()
            .map((Object token) => token.toString())
            .where((String text) => RegExp(r'^\d+$').hasMatch(text))
            .toList();
        // Assert
        expect(actual.toSet(), expected.toSet());
        expect(actual.last, expected.last);
        expect(recorded.picture.operator, signs[row.operation]);
        expect(
          template.validValues.any(
            (Map<String, int> v) => mapEquals(v, recorded.values),
          ),
          isTrue,
          reason: 'the recorded numbers follow the ranges',
        );
      });

      test('makes touchable the math words the table lists', () {
        // Act
        final List<SentencePart> parts = words.splitText(row.template);
        // Assert
        expect(
          parts.map((SentencePart p) => p.wordKey).nonNulls.toSet(),
          row.wordKeys
              .union(tableGaps[row.key]?.add ?? <String>{})
              .difference(tableGaps[row.key]?.remove ?? <String>{}),
        );
      });
    });
  }

  test('names the same trap twins as the table', () {
    // Arrange
    final Map<String, String> twins = readTrapTwins();
    // Assert
    expect(twins, hasLength(8));
    expect(<String, String>{
      for (final ProblemTemplate p in ProblemTemplates.all)
        if (p.trapOf != null) p.problemKey: p.trapOf!,
    }, twins);
  });
}
