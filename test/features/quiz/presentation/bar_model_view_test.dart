import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_templates.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/bar_model_view.dart';

import '../../../helpers/pump_localized.dart';

/// The drawing of the bar model: it shows what the story gives, hides the
/// answer until asked, and fits a small phone at a large text size.
void main() {
  Future<void> pump(
    WidgetTester tester,
    BarModelPicture picture, {
    Map<BarRole, int>? placed,
    bool showsAnswer = false,
    ValueChanged<BarRole>? onSlotTap,
    double textScale = 1,
    double width = 320,
  }) async {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpLocalized(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: width,
            child: BarModelView(
              picture: picture,
              placed: placed,
              showsAnswer: showsAnswer,
              onSlotTap: onSlotTap,
            ),
          ),
        ),
      ),
    );
  }

  BarModelPicture modelOf(String key) {
    return ProblemTemplates.all
        .firstWhere((ProblemTemplate p) => p.problemKey == key)
        .fixedInstance()
        .picture;
  }

  testWidgets('hides the answer behind a question mark until asked', (
    WidgetTester tester,
  ) async {
    // Arrange
    final BarModelPicture picture = modelOf('mangues_donnees');
    // Act
    await pump(tester, picture);
    // Assert
    expect(find.text('12'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
    expect(find.text('7'), findsNothing);
    // Act
    await pump(tester, picture, showsAnswer: true);
    // Assert
    expect(find.text('7'), findsOneWidget);
    expect(find.text('?'), findsNothing);
  });

  testWidgets('leaves a place empty until the child fills it', (
    WidgetTester tester,
  ) async {
    // Arrange
    final BarModelPicture picture = modelOf('mangues_donnees');
    final List<BarRole> tapped = <BarRole>[];
    // Act
    await pump(
      tester,
      picture,
      placed: const <BarRole, int>{BarRole.whole: 12},
      onSlotTap: tapped.add,
    );
    await tester.tap(find.byKey(const ValueKey<String>('slot-partA')));
    await tester.tap(find.byKey(const ValueKey<String>('slot-whole')));
    // Assert: only the empty place answers a touch.
    expect(find.text('12'), findsOneWidget);
    expect(find.text('5'), findsNothing);
    expect(tapped, <BarRole>[BarRole.partA]);
  });

  testWidgets('says each place to a screen reader', (
    WidgetTester tester,
  ) async {
    // Arrange
    final SemanticsHandle handle = tester.ensureSemantics();
    final BarModelPicture picture = modelOf('mangues_donnees');
    // Act
    await pump(tester, picture, placed: const <BarRole, int>{});
    // Assert
    expect(
      find.bySemanticsLabel(RegExp('le tout .*à remplir')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('autre partie .*à trouver')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('draws the four shapes of the table', (
    WidgetTester tester,
  ) async {
    // Arrange
    final Set<BarModelShape> shapes = <BarModelShape>{
      for (final ProblemTemplate problem in ProblemTemplates.all) problem.shape,
    };
    // Assert
    expect(shapes, BarModelShape.values.toSet());
  });

  for (final ProblemTemplate problem in ProblemTemplates.all) {
    testWidgets('fits ${problem.problemKey} on a small phone at 130 %', (
      WidgetTester tester,
    ) async {
      // Act
      await pump(
        tester,
        problem.fixedInstance().picture,
        showsAnswer: true,
        textScale: 1.3,
      );
      // Assert
      expect(tester.takeException(), isNull);
      expect(
        find.text('${problem.fixedInstance().picture.answer}'),
        findsWidgets,
      );
    });
  }

  test('holds the calculation of the story', () {
    // Assert
    expect(
      modelOf('mangues_donnees').calculation.join(' '),
      '12 subtract 5 = 7',
    );
    expect(
      modelOf('mangues_donnees_piege').operator,
      MathOperator.add,
    );
  });
}
