import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/core/entities/mascot_look.dart';
import 'package:kid_matix/core/entities/mascot_mood.dart';
import 'package:kid_matix/core/widgets/mascot_illustration.dart';
import 'package:kid_matix/core/widgets/mascot_look_scope.dart';
import 'package:kid_matix/core/widgets/mascot_painter.dart';

import '../../helpers/pump_localized.dart';

MascotPainter _painterOf(WidgetTester tester) {
  return tester
          .widget<CustomPaint>(
            find.descendant(
              of: find.byType(MascotIllustration),
              matching: find.byType(CustomPaint),
            ),
          )
          .painter!
      as MascotPainter;
}

void main() {
  group('MascotIllustration', () {
    for (int stage = 1; stage <= 5; stage++) {
      testWidgets('draws stage $stage from the scope', (
        WidgetTester tester,
      ) async {
        // Act
        await pumpLocalized(
          tester,
          MascotLookScope(
            look: MascotLook(
              stage: stage,
              accessories: const <MascotAccessory>{MascotAccessory.cap},
            ),
            child: const Center(child: MascotIllustration(size: 120)),
          ),
        );
        // Assert
        final MascotPainter actualPainter = _painterOf(tester);
        expect(actualPainter.stage, stage);
        expect(actualPainter.accessories, <MascotAccessory>{
          MascotAccessory.cap,
        });
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('shows the first stage without a scope', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpLocalized(
        tester,
        const Center(child: MascotIllustration(size: 80)),
      );
      // Assert
      expect(_painterOf(tester).stage, 1);
    });
    testWidgets('jumps for joy, and stays still when motion is reduced', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpLocalized(
        tester,
        const Center(
          child: MascotIllustration(size: 80, mood: MascotMood.happy),
        ),
      );
      final int actualMoving = tester
          .widgetList(find.byType(TweenAnimationBuilder<double>))
          .length;
      await pumpLocalized(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(
            child: MascotIllustration(size: 80, mood: MascotMood.happy),
          ),
        ),
      );
      final int actualStill = tester
          .widgetList(find.byType(TweenAnimationBuilder<double>))
          .length;
      // Assert
      expect(actualMoving, 1);
      expect(actualStill, 0);
      expect(_painterOf(tester).mood, MascotMood.happy);
    });
    testWidgets('paints every accessory at every stage', (
      WidgetTester tester,
    ) async {
      // Act
      for (final MascotMood mood in MascotMood.values) {
        await pumpLocalized(
          tester,
          Center(
            child: MascotIllustration(
              size: 120,
              mood: mood,
              look: MascotLook(
                stage: 5,
                accessories: MascotAccessory.values.toSet(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }
      // Assert
      expect(tester.takeException(), isNull);
    });
  });
}
