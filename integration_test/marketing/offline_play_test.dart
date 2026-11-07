// Marketing scenario: the app works without Internet. Film it with the
// airplane mode on, so the status bar shows the icon:
//   AIRPLANE_MODE=1 bash tool/marketing/record.sh android offline_play
// Awa opens her learning path and plays the first questions of a stage.

import 'package:flutter_test/flutter_test.dart';

import 'support/demo_player.dart';
import 'support/marketing_harness.dart';

/// Questions played before the clip ends.
const int _questionCount = 4;

void main() {
  initMarketingBinding();

  testWidgets('plays with the airplane mode on', (WidgetTester tester) async {
    // Arrange
    await startApp(tester, seed: seedDemoPlayer);
    await waitFor(tester, findLabel('Jouer'));
    // Act
    await pause(tester, const Duration(milliseconds: 1500));
    await tapText(tester, 'Jouer');
    await tapText(
      tester,
      'À moi de jouer',
      before: const Duration(milliseconds: 1500),
    );
    await playQuiz(tester, maxQuestions: _questionCount);
    await endScenario(tester, hold: const Duration(milliseconds: 1500));
    // Assert
    expect(findLabel('Jouer'), findsNothing);
  });
}
