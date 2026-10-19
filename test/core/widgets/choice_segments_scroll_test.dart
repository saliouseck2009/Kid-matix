import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/widgets/choice_segments.dart';

import '../../helpers/pump_localized.dart';

/// Five domains do not fit side by side on a small phone at a large text:
/// the segments then scroll sideways instead of wrapping and overflowing.
void main() {
  const List<String> names = <String>[
    'Multiplication',
    'Nombres',
    '+ et −',
    'Division',
    'Mots des maths',
  ];

  testWidgets('scrolls five segments at 130 % on a small phone', (
    WidgetTester tester,
  ) async {
    // Arrange
    tester.view.physicalSize = const Size(1080, 2220);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    String selected = names.first;
    await pumpLocalized(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Scaffold(
          body: ChoiceSegments<String>(
            choices: names,
            selected: selected,
            labelOf: (String name) => name,
            onSelected: (String name) => setState(() => selected = name),
            isScrollable: true,
          ),
        ),
      ),
    );
    // Assert
    expect(tester.takeException(), isNull);
    // Act
    await tester.ensureVisible(find.text('Mots des maths'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mots des maths'));
    await tester.pump();
    // Assert
    expect(selected, 'Mots des maths');
  });

  testWidgets('shares the width when it is not scrollable', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpLocalized(
      tester,
      Scaffold(
        body: ChoiceSegments<String>(
          choices: names.take(2).toList(),
          selected: names.first,
          labelOf: (String name) => name,
          onSelected: (_) {},
        ),
      ),
    );
    // Assert
    expect(find.byType(SingleChildScrollView), findsNothing);
  });
}
