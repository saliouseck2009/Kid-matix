import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/math_picture_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/number_line_view.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/objects_painter.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/ten_bundles_painter.dart';

import '../../../helpers/pump_localized.dart';

void main() {
  Future<void> pumpPicture(
    WidgetTester tester,
    MathPicture picture, {
    bool isSolved = false,
    String? blankText,
  }) async {
    await pumpLocalized(
      tester,
      Scaffold(
        body: Center(
          child: SizedBox(
            width: 340,
            height: 240,
            child: MathPictureView(
              picture: picture,
              isSolved: isSolved,
              blankText: blankText,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('hides the number of mangoes of a question', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpPicture(tester, const ObjectsPicture(count: 7));
    // Assert
    expect(find.bySemanticsLabel('Des mangues à compter'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter is ObjectsPainter,
      ),
      findsOneWidget,
    );
  });
  testWidgets('tells the number of mangoes of a help card', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpPicture(tester, const ObjectsPicture(count: 7), isSolved: true);
    // Assert
    expect(find.bySemanticsLabel('7 mangues'), findsOneWidget);
  });
  testWidgets('tells the bundles and the loose sticks', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpPicture(tester, const TenBundlesPicture(tens: 1, ones: 1));
    // Assert
    expect(
      find.bySemanticsLabel('1 paquet de dix et 1 bâtonnet'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is CustomPaint && widget.painter is TenBundlesPainter,
      ),
      findsOneWidget,
    );
  });
  testWidgets('reads a line, its hidden number said as such', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpPicture(
      tester,
      NumberLinePicture(values: const <int>[38, 39, 40], blankIndex: 2),
    );
    // Assert
    expect(
      find.bySemanticsLabel('Droite des nombres : 38, 39, nombre caché'),
      findsOneWidget,
    );
    expect(find.byType(NumberLineView), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
  });
  testWidgets('shows the digits typed in the box of the line', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpPicture(
      tester,
      NumberLinePicture(values: const <int>[38, 39, 40], blankIndex: 2),
      blankText: '4',
    );
    // Assert
    expect(find.text('4'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Droite des nombres : 38, 39, 4'),
      findsOneWidget,
    );
  });
}
