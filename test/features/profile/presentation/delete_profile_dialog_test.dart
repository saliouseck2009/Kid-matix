import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/profile/presentation/widgets/delete_profile_dialog.dart';

import '../../../helpers/pump_localized.dart';

void main() {
  Future<bool?> openDialog(WidgetTester tester) async {
    bool? actualResult;
    await pumpLocalized(
      tester,
      Builder(
        builder: (BuildContext context) => TextButton(
          onPressed: () async => actualResult = await confirmProfileDeletion(
            context,
            nickname: 'Léa',
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return actualResult;
  }

  TextButton findConfirmButton(WidgetTester tester) {
    return tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Supprimer'),
    );
  }

  group('DeleteProfileDialog', () {
    testWidgets('asks the child to type the nickname again', (
      WidgetTester tester,
    ) async {
      // Act
      await openDialog(tester);
      // Assert
      expect(find.text('Supprimer Léa ?'), findsOneWidget);
      expect(findConfirmButton(tester).onPressed, isNull);
    });
    testWidgets('keeps the deletion locked for another nickname', (
      WidgetTester tester,
    ) async {
      // Arrange
      await openDialog(tester);
      // Act
      await tester.enterText(find.byType(TextField), 'Lina');
      await tester.pump();
      // Assert
      expect(findConfirmButton(tester).onPressed, isNull);
    });
    testWidgets('unlocks the deletion ignoring case and accents', (
      WidgetTester tester,
    ) async {
      // Arrange
      await openDialog(tester);
      // Act
      await tester.enterText(find.byType(TextField), ' LEA ');
      await tester.pump();
      // Assert
      expect(findConfirmButton(tester).onPressed, isNotNull);
    });
    testWidgets('closes without deleting on cancel', (
      WidgetTester tester,
    ) async {
      // Arrange
      await openDialog(tester);
      // Act
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
