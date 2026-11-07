// Marketing scenario, about 10 seconds: a child opens the app for the
// first time, creates the player "Awa" and lands on the learning path.
//   bash tool/marketing/record.sh android first_launch

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/profile/presentation/widgets/avatar_picker.dart';
import 'package:kid_matix/features/profile/presentation/widgets/color_picker.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';

import 'support/demo_player.dart';
import 'support/marketing_harness.dart';

/// Position of the avatar picked in the grid, from 0.
const int _avatarIndex = 5;

/// Position of the color picked in the row, from 0.
const int _colorIndex = 2;

void main() {
  initMarketingBinding();

  testWidgets('creates the first player', (WidgetTester tester) async {
    // Arrange
    await startApp(tester);
    // Act
    await typeSlowly(tester, find.byType(TextField), demoNickname);
    await tapWhenShown(
      tester,
      find
          .descendant(
            of: find.byType(AvatarPicker),
            matching: find.byType(ProfileAvatarView),
          )
          .at(_avatarIndex),
    );
    await tapWhenShown(
      tester,
      find
          .descendant(
            of: find.byType(ColorPicker),
            matching: find.byType(InkResponse),
          )
          .at(_colorIndex),
    );
    await tapText(tester, "C'est parti !");
    await tapText(tester, 'Passer', before: const Duration(seconds: 1));
    await waitFor(tester, findLabel('Jouer'));
    await endScenario(tester, hold: const Duration(milliseconds: 4500));
    // Assert
    expect(findLabel('Jouer'), findsWidgets);
  });
}
