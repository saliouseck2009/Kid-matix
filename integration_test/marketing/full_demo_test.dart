// Marketing scenario, about 60 seconds: the app from its first launch to
// the first results. Awa is created, the placement test skipped, the map
// shown, then the Discovery stage of the first table: the table and its
// tip, its questions, the results and the "Premier pas" celebration.
//   bash tool/marketing/record.sh android full_demo
// Cut the questions in the edit to keep four or five.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/profile/presentation/widgets/avatar_picker.dart';
import 'package:kid_matix/features/profile/presentation/widgets/color_picker.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';
import 'package:kid_matix/features/reward/presentation/widgets/reward_celebration.dart';

import 'support/demo_player.dart';
import 'support/marketing_harness.dart';

/// Position of the avatar picked in the grid, from 0.
const int _avatarIndex = 5;

/// Position of the color picked in the row, from 0.
const int _colorIndex = 2;

/// Pause before each step of the creation, so the viewer follows.
const Duration _step = Duration(milliseconds: 1200);

void main() {
  initMarketingBinding();

  testWidgets('from the first launch to the first results', (
    WidgetTester tester,
  ) async {
    // Arrange
    await startApp(tester);
    // Act: the player.
    await pause(tester, _step);
    await typeSlowly(
      tester,
      find.byType(TextField),
      demoNickname,
      perLetter: const Duration(milliseconds: 400),
    );
    await tapWhenShown(
      tester,
      find
          .descendant(
            of: find.byType(AvatarPicker),
            matching: find.byType(ProfileAvatarView),
          )
          .at(_avatarIndex),
      before: _step,
    );
    await tapWhenShown(
      tester,
      find
          .descendant(
            of: find.byType(ColorPicker),
            matching: find.byType(InkResponse),
          )
          .at(_colorIndex),
      before: _step,
    );
    await tapText(tester, "C'est parti !", before: _step);
    await tapText(tester, 'Passer', before: const Duration(seconds: 3));
    // The map, then the first stage.
    await tapText(tester, 'Jouer', before: const Duration(seconds: 4));
    await tapText(
      tester,
      'À moi de jouer',
      before: const Duration(seconds: 5),
    );
    await playQuiz(tester);
    // The "Premier pas" celebration over the results, then the results.
    await waitFor(tester, find.byType(RewardCelebration));
    await pause(tester, const Duration(milliseconds: 2500));
    await closeCelebrations(tester);
    await endScenario(tester, hold: const Duration(seconds: 4));
    // Assert
    expect(findLabel('Étape terminée !'), findsOneWidget);
  });
}
