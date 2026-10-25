import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_templates.dart';
import 'package:kid_matix/features/problem/domain/services/problem_domain.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/problem_board.dart';

import '../../../helpers/pump_localized.dart';
import '../../problem/helpers/problem_fixtures.dart';

/// The board of the word problems (F30-03, F30-04) over the 30 problems of
/// the table: each one can be solved on its bar model, in three steps or in
/// five, with the numbers of its story only.
void main() {
  final ProblemDomain domain = buildProblemDomain();

  Question question(ProblemTemplate problem, String typeId, int seed) {
    return domain.buildQuestion(
      item: problem,
      questionTypeId: typeId,
      random: DartRandomSource(seed: seed),
    );
  }

  Future<Answer?> pumpBoard(
    WidgetTester tester,
    Question asked, {
    required bool isGuided,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    Answer? solved;
    await pumpLocalized(
      tester,
      Scaffold(
        body: ProblemBoard(
          question: asked,
          isGuided: isGuided,
          languageCode: 'fr',
          onSolved: (Answer answer) => solved = answer,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return solved;
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final Finder finder = find.byKey(ValueKey<String>(key));
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Solves [asked] with no mistake and returns what the board answered.
  Future<Answer?> solve(
    WidgetTester tester,
    Question asked, {
    required bool isGuided,
  }) async {
    Answer? solved;
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      Scaffold(
        body: ProblemBoard(
          question: asked,
          isGuided: isGuided,
          languageCode: 'fr',
          onSolved: (Answer answer) => solved = answer,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final BarModelPicture model = asked.picture! as BarModelPicture;
    if (isGuided) await tester.tap(find.text("J'ai écouté"));
    await tester.pumpAndSettle();
    final List<BarRole> known = model.knownRoles;
    for (int index = 0; index < known.length; index++) {
      await tapKey(tester, 'tile-$index');
      await tapKey(tester, 'slot-${known[index].name}');
    }
    await tapKey(tester, 'operator-${model.operator.name}');
    await tapKey(tester, 'number-${model.answer}');
    if (isGuided) {
      await tester.tap(find.text("J'ai vérifié"));
      await tester.pumpAndSettle();
    }
    return solved;
  }

  for (final ProblemTemplate problem in ProblemTemplates.all) {
    testWidgets('${problem.problemKey} is solved on the bar model', (
      WidgetTester tester,
    ) async {
      // Act
      final Answer? actual = await solve(
        tester,
        question(problem, QuestionTypeIds.barModel, 3),
        isGuided: false,
      );
      // Assert
      expect(actual, const ProblemAnswer());
      expect(tester.takeException(), isNull);
    });

    testWidgets('${problem.problemKey} is solved step by step', (
      WidgetTester tester,
    ) async {
      // Act
      final Answer? actual = await solve(
        tester,
        question(problem, QuestionTypeIds.solveProblem, 4),
        isGuided: true,
      );
      // Assert
      expect(actual, const ProblemAnswer());
    });
  }

  testWidgets('counts every wrong touch and keeps going', (
    WidgetTester tester,
  ) async {
    // Arrange
    final ProblemTemplate problem = problemTemplate('mangues_donnees');
    final Question asked = question(problem, QuestionTypeIds.solveProblem, 1);
    final BarModelPicture model = asked.picture! as BarModelPicture;
    Answer? solved;
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      Scaffold(
        body: ProblemBoard(
          question: asked,
          isGuided: false,
          languageCode: 'fr',
          onSolved: (Answer answer) => solved = answer,
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Act: the part on the whole, a wrong sign, a wrong result.
    await tapKey(tester, 'tile-1');
    await tapKey(tester, 'slot-whole');
    await tapKey(tester, 'tile-0');
    await tapKey(tester, 'slot-whole');
    await tapKey(tester, 'tile-1');
    await tapKey(tester, 'slot-partA');
    await tapKey(tester, 'operator-add');
    await tapKey(tester, 'operator-subtract');
    final int wrong = asked.choices
        .whereType<NumberAnswer>()
        .map((NumberAnswer choice) => choice.value)
        .firstWhere((int value) => value != model.answer);
    await tapKey(tester, 'number-$wrong');
    expect(solved, isNull);
    await tapKey(tester, 'number-${model.answer}');
    // Assert
    expect(solved, const ProblemAnswer(mistakeCount: 3));
    expect(solved, isNot(asked.expectedAnswer));
  });

  testWidgets('says kindly where to look after a wrong touch', (
    WidgetTester tester,
  ) async {
    // Arrange
    final Question asked = question(
      problemTemplate('mangues_donnees'),
      QuestionTypeIds.barModel,
      1,
    );
    await pumpBoard(tester, asked, isGuided: false);
    // Act
    await tapKey(tester, 'tile-1');
    await tapKey(tester, 'slot-whole');
    // Assert
    expect(find.textContaining('Relis'), findsOneWidget);
    expect(find.text('Étape 1 sur 3'), findsOneWidget);
    expect(
      find.text('Pas là. Relis l\'histoire et regarde le schéma.'),
      findsOneWidget,
    );
  });
}
