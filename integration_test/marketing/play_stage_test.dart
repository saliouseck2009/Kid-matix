// Marketing scenario, about 45 seconds: Awa, three crowned tables behind
// her, discovers the table of 5 and wins its first stage.
//   bash tool/marketing/record.sh android play_stage

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_play_view.dart';

import 'support/demo_player.dart';
import 'support/marketing_harness.dart';

void main() {
  initMarketingBinding();

  testWidgets('plays the discovery of a table', (WidgetTester tester) async {
    // Arrange
    await startApp(tester, seed: seedDemoPlayer);
    await waitFor(tester, findLabel('Jouer'));
    await pause(tester, const Duration(seconds: 2));
    // Act
    await tapText(tester, 'Jouer');
    await tapText(
      tester,
      'À moi de jouer',
      before: const Duration(seconds: 3),
    );
    await playQuiz(tester);
    await endScenario(tester, hold: const Duration(seconds: 5));
    // Assert
    expect(find.byType(QuizPlayView), findsNothing);
  });
}
