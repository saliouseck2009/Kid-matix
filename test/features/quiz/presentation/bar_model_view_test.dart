import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/quiz/bar_model.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_templates.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/bar_model_layouts.dart';
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
      find.bySemanticsLabel(RegExp('le tout.*à remplir')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('autre partie.*à trouver')),
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

  /// The valid draw of [problem] whose model is the most lopsided: the
  /// smallest part against its whole, the most groups, the most times.
  BarModelPicture mostLopsided(ProblemTemplate problem) {
    double score(BarModelPicture picture) {
      return switch (picture.shape) {
        BarModelShape.partWhole || BarModelShape.compare =>
          picture.shape == BarModelShape.partWhole
              ? math.min(
                      picture.values[BarRole.partA]!,
                      picture.values[BarRole.partB]!,
                    ) /
                    picture.values[BarRole.whole]!
              : math.min(
                      picture.values[BarRole.small]!,
                      picture.values[BarRole.gap]!,
                    ) /
                    picture.values[BarRole.big]!,
        BarModelShape.groups => -picture.values[BarRole.groups]!.toDouble(),
        BarModelShape.ratio => -picture.values[BarRole.times]!.toDouble(),
      };
    }

    return problem.validValues
        .map((Map<String, int> v) => problem.instanceOf(v).picture)
        .reduce((a, b) => score(a) <= score(b) ? a : b);
  }

  for (final ProblemTemplate problem in ProblemTemplates.all) {
    testWidgets(
      'keeps every place of the most lopsided ${problem.problemKey} '
      'touchable on 320 dp at 130 %',
      (WidgetTester tester) async {
        // Arrange
        final BarModelPicture picture = mostLopsided(problem);
        // Act
        await pump(tester, picture, showsAnswer: true, textScale: 1.3);
        // Assert
        expect(tester.takeException(), isNull);
        for (final BarRole role in picture.shape.roles) {
          final Size size = tester.getSize(
            find.byKey(ValueKey<String>('slot-${role.name}')),
          );
          expect(
            size.width,
            greaterThanOrEqualTo(AppSizes.minTouchTarget),
            reason: '${problem.problemKey} $role in ${picture.values}',
          );
        }
      },
    );
  }

  testWidgets('draws every group of the story, never fewer than its label', (
    WidgetTester tester,
  ) async {
    // Arrange
    final ProblemTemplate problem = ProblemTemplates.all.firstWhere(
      (ProblemTemplate p) => p.problemKey == 'rangees_tabaski',
    );
    final BarModelPicture picture = problem.validValues
        .map((Map<String, int> v) => problem.instanceOf(v).picture)
        .reduce(
          (a, b) =>
              a.values[BarRole.groups]! >= b.values[BarRole.groups]! ? a : b,
        );
    // Act
    await pump(tester, picture, showsAnswer: true);
    // Assert
    expect(picture.values[BarRole.groups], GroupsModel.mostBars);
    expect(find.byType(GroupBar), findsNWidgets(GroupsModel.mostBars));
    for (final ProblemTemplate other in ProblemTemplates.all) {
      for (final Map<String, int> v in other.validValues) {
        final BarModelPicture drawn = other.instanceOf(v).picture;
        if (drawn.shape != BarModelShape.groups) continue;
        expect(
          drawn.values[BarRole.groups],
          lessThanOrEqualTo(GroupsModel.mostBars),
          reason: other.problemKey,
        );
      }
    }
  });

  testWidgets('marks a wrong place with a cross and says so', (
    WidgetTester tester,
  ) async {
    // Arrange
    final SemanticsHandle handle = tester.ensureSemantics();
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    await pumpLocalized(
      tester,
      Scaffold(
        body: BarModelView(
          picture: modelOf('mangues_donnees'),
          placed: const <BarRole, int>{},
          wrongRole: BarRole.whole,
          wrongCount: 1,
        ),
      ),
    );
    // Assert
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('pas la bonne place')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('draws a dashed border for a part taken away and a gap', (
    WidgetTester tester,
  ) async {
    // Act
    await pump(tester, modelOf('mangues_donnees'));
    final int taken = find
        .byWidgetPredicate(
          (Widget w) =>
              w is CustomPaint &&
              w.foregroundPainter.runtimeType.toString() ==
                  '_DashedBorderPainter',
        )
        .evaluate()
        .length;
    await pump(tester, modelOf('mangues_difference'));
    final int gap = find
        .byWidgetPredicate(
          (Widget w) =>
              w is CustomPaint &&
              w.foregroundPainter.runtimeType.toString() ==
                  '_DashedBorderPainter',
        )
        .evaluate()
        .length;
    // Assert
    expect(taken, 1);
    expect(gap, 1);
  });

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
