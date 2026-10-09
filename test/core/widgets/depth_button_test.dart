import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';

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
  });
}
