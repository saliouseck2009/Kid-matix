import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/theme/app_colors.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/core/widgets/depth_button_variant.dart';

void main() {
  group('DepthButton', () {
    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      // Arrange
      const String inputLabel = 'Jouer';
      int actualTapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: DepthButton(
              label: inputLabel,
              onPressed: () => actualTapCount++,
            ),
          ),
        ),
      );
      // Act
      await tester.tap(find.text(inputLabel));
      await tester.pump();
      // Assert
      expect(actualTapCount, 1);
    });
    for (final (DepthButtonVariant variant, Color face)
        in <(DepthButtonVariant, Color)>[
          (DepthButtonVariant.primary, AppColors.violet),
          (DepthButtonVariant.secondary, AppColors.white),
          (DepthButtonVariant.success, AppColors.green),
          (DepthButtonVariant.danger, AppColors.red),
        ]) {
      testWidgets('paints the ${variant.name} face', (
        WidgetTester tester,
      ) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: DepthButton(
                label: 'Continuer',
                variant: variant,
                onPressed: () {},
              ),
            ),
          ),
        );
        // Assert
        final Material actualFace = tester.widget<Material>(
          find
              .ancestor(
                of: find.text('Continuer'),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(actualFace.color, face);
      });
    }
  });
}
