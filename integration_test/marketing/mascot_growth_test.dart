// Marketing shot: Awa wins a stage, reaches level 5 and her mascot grows
// to its second stage on the map; then her mascot's page, where she puts
// the cap on. Cut the recording around those moments.
//   bash tool/marketing/record.sh android mascot_growth

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/entities/mascot_accessory.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_accessory_tile.dart';
import 'package:kid_matix/features/mascot/presentation/widgets/mascot_growth_celebration.dart';

import 'support/demo_player.dart';
import 'support/marketing_harness.dart';

/// Tooltip of the arrow from a table back to the map.
const String _backToPath = 'Retour au parcours';

/// Accessory put on, earned with the first crown.
const MascotAccessory _accessory = MascotAccessory.cap;

void main() {
  initMarketingBinding();

  testWidgets('grows the mascot and dresses it', (WidgetTester tester) async {
    // Arrange
    await startApp(tester, seed: seedMascotGrower);
    await waitFor(tester, findLabel('Jouer'));
    // Act: a stage, then back to the map where the mascot grows.
    await tapText(tester, 'Jouer');
    await tapText(tester, 'À moi de jouer', before: const Duration(seconds: 1));
    await playQuiz(tester);
    await waitFor(tester, findLabel('Continuer'));
    await closeCelebrations(tester);
    await pressButton(tester, 'Continuer');
    await pressIconButton(tester, _backToPath);
    await waitFor(tester, find.byType(MascotGrowthCelebration));
    await pause(tester, const Duration(seconds: 3));
    Navigator.of(
      tester.element(find.byType(MascotGrowthCelebration).last),
    ).pop();
    await pause(tester, gesturePause);
    // The mascot's page, and the cap on.
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .go(AppRoutes.mascot);
    final Finder cap = find.byWidgetPredicate(
      (Widget widget) =>
          widget is MascotAccessoryTile && widget.accessory == _accessory,
    );
    await waitFor(tester, cap);
    await pause(tester, const Duration(milliseconds: 1500));
    tester.widget<MascotAccessoryTile>(cap).onTap();
    await endScenario(tester, hold: const Duration(seconds: 3));
    // Assert
    expect(
      tester.widget<MascotAccessoryTile>(cap).isWorn,
      isTrue,
    );
  });
}
