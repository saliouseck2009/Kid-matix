// Marketing scenario, about 25 seconds: Awa fights the boss of the table
// of 5. Critical hits, one mistake and the boss strikes back, then the
// victory, the results and the new crown on the map.
//   bash tool/marketing/record.sh android boss_fight
//
// The rules of the fight are the app's own: a right answer under 3
// seconds is an "Éclair", a critical hit worth 2 of the 12 hit points; a
// slower one is worth 1; a mistake makes the boss strike back.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/stage_card.dart';
import 'package:kid_matix/features/learning_path/presentation/widgets/table_node.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/quiz_play_view.dart';
import 'package:kid_matix/features/reward/presentation/widgets/reward_celebration.dart';

import 'support/demo_player.dart';
import 'support/marketing_harness.dart';

/// The fight, blow by blow: 1 + 2 + 2 + 0 + 2 + 2 + 2 + 1 = 12 hit points.
const List<BossMove> _fight = <BossMove>[
  BossMove.hit,
  BossMove.critical,
  BossMove.critical,
  BossMove.miss,
  BossMove.critical,
  BossMove.critical,
  BossMove.critical,
  BossMove.hit,
];

/// Draw of the fight.
const int _randomSeed = 4;

/// Tooltip of the arrow from a table back to the map.
const String _backToPath = 'Retour au parcours';

/// Position of the boss fight among the stages of a table, from 0.
const int _bossStageIndex = 4;

void main() {
  initMarketingBinding();

  testWidgets('defeats the boss of a table', (WidgetTester tester) async {
    // Arrange: the recording opens on the boss.
    await startApp(
      tester,
      seed: seedBossChallenger,
      randomSeed: _randomSeed,
      beforeRecording: () async {
        await tapWhenShown(
          tester,
          _tableNode(bossTable),
          before: Duration.zero,
        );
        await tapWhenShown(
          tester,
          find.byType(StageCard).at(_bossStageIndex),
          before: Duration.zero,
        );
        await waitFor(tester, find.byType(QuizPlayView));
      },
    );
    // Act
    await playMoves(tester, _fight);
    // A slow pairing may have cost a critical hit: finish the boss off.
    if (find.byType(QuizPlayView).evaluate().isNotEmpty) {
      await playMoves(tester, List<BossMove>.filled(6, BossMove.critical));
    }
    await waitFor(tester, findLabel('Boss vaincu !'));
    await _closeCelebrations(tester);
    await pause(tester, const Duration(milliseconds: 2500));
    await pressButton(tester, 'Continuer');
    // The results lead back to the table; the map shows its new crown.
    await pressIconButton(
      tester,
      _backToPath,
      before: const Duration(milliseconds: 1000),
    );
    await waitFor(tester, findLabel('Jouer'));
    await endScenario(tester, hold: const Duration(seconds: 3));
    // Assert
    expect(findLabel('Jouer'), findsWidgets);
  });
}

/// Closes the badge sheets shown over the results, one by one, after a
/// pause to read them. The sheets follow one another through route
/// transitions, so the wait goes on until none has shown for a while.
Future<void> _closeCelebrations(WidgetTester tester) async {
  const Duration readTime = Duration(milliseconds: 1200);
  DateTime lastSeen = DateTime.now();
  while (DateTime.now().difference(lastSeen) < const Duration(seconds: 2)) {
    final Element? element = _currentSheet(tester);
    if (element == null) {
      await pause(tester, const Duration(milliseconds: 100));
      continue;
    }
    lastSeen = DateTime.now();
    await pause(tester, readTime);
    // A tap no longer reaches the sheet (see pressButton): close it as
    // its own tap would.
    Navigator.of(element).pop();
    await pause(tester, gesturePause);
  }
}

/// The sheet on top, or `null` while none is shown or the last one is
/// still fading out.
Element? _currentSheet(WidgetTester tester) {
  for (final Element element in find.byType(RewardCelebration).evaluate()) {
    if (ModalRoute.of(element)?.isCurrent ?? false) return element;
  }
  return null;
}

Finder _tableNode(int number) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is TableNode && widget.table.number == number,
    description: 'node of the table of $number',
  );
}
