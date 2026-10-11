import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/widgets/app_width_limit.dart';

import '../../helpers/pump_localized.dart';

void main() {
  Future<Size> pumpOn(WidgetTester tester, Size screen) async {
    tester.view
      ..physicalSize = screen
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Size seen = Size.zero;
    await pumpLocalized(
      tester,
      AppWidthLimit(
        child: Builder(
          builder: (BuildContext context) {
            seen = MediaQuery.sizeOf(context);
            return const SizedBox.expand();
          },
        ),
      ),
    );
    return seen;
  }

  group('AppWidthLimit', () {
    testWidgets('keeps the full width of a phone', (WidgetTester tester) async {
      // Act
      final Size actualSize = await pumpOn(tester, const Size(390, 844));
      // Assert
      expect(actualSize, const Size(390, 844));
    });
    testWidgets('narrows a tablet to the width of a large phone', (
      WidgetTester tester,
    ) async {
      // Act
      final Size actualSize = await pumpOn(tester, const Size(820, 1180));
      // Assert
      expect(actualSize, const Size(AppWidthLimit.maxWidth, 1180));
      expect(
        tester.getSize(find.byType(SizedBox).last).width,
        AppWidthLimit.maxWidth,
      );
    });
  });
}
