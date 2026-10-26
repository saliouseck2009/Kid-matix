import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/classroom/presentation/widgets/open_assessment_dialog.dart';

import '../../../helpers/pump_localized.dart';

void main() {
  testWidgets('a preset fills the name of the period', (
    WidgetTester tester,
  ) async {
    // Arrange
    String? actual;
    await pumpLocalized(
      tester,
      Scaffold(
        body: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async => actual = await askAssessmentLabel(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    // Act
    await tester.tap(find.text("Fin d'année"));
    await tester.pump();
    await tester.tap(find.text('Lancer'));
    await tester.pumpAndSettle();
    // Assert
    expect(actual, "Fin d'année");
  });
}
