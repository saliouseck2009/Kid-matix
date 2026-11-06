// Marketing scenario: three players on one phone. "Qui joue ?" with Awa,
// Moussa and Lina, then a duel between Awa and Moussa, face to face.
//   bash tool/marketing/record.sh android duel

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_contender.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_answer_button.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_arena.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_half.dart';

import 'support/demo_player.dart';
import 'support/marketing_harness.dart';

/// Length of the duel on screen.
const Duration _duelTime = Duration(seconds: 8);

/// Time between two answers, both players together.
const Duration _answerEvery = Duration(milliseconds: 900);

void main() {
  initMarketingBinding();

  testWidgets('three players, one phone', (WidgetTester tester) async {
    // Arrange: the recording opens on "Qui joue ?". The app started on
    // the creation of a first player; the players came after.
    await startApp(
      tester,
      seed: seedThreePlayers,
      beforeRecording: () async {
        GoRouter.of(
          tester.element(find.byType(Scaffold).first),
        ).go(AppRoutes.whoIsPlaying);
        await waitFor(tester, findLabel('Qui joue ?'));
      },
    );
    // Act
    await pause(tester, const Duration(milliseconds: 2500));
    await tapText(tester, demoNickname);
    await tapText(tester, 'Défis');
    await tapText(tester, 'Duel');
    // The picker lists every player for the top side, then for the bottom.
    await tapWhenShown(tester, findLabel(demoFriends.first.$1).first);
    await tapWhenShown(tester, findLabel(demoNickname).last);
    await tapText(tester, "C'est parti !");
    await waitFor(tester, find.byType(DuelArena));
    final DateTime end = DateTime.now().add(_duelTime);
    while (DateTime.now().isBefore(end)) {
      await pause(tester, _answerEvery);
      for (final Element half in find.byType(DuelHalf).evaluate()) {
        if (find.byType(DuelArena).evaluate().isEmpty) break;
        final DuelContender contender = (half.widget as DuelHalf).contender;
        final Answer expected = contender.question.expectedAnswer;
        if (expected is! NumberAnswer || contender.isBlocked) continue;
        await tester.tap(
          find.descendant(
            of: find.byWidget(half.widget),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is DuelAnswerButton && widget.value == expected.value,
            ),
          ),
        );
        await pause(tester, const Duration(milliseconds: 350));
      }
    }
    await endScenario(tester, hold: Duration.zero);
    // Assert
    expect(find.byType(DuelArena), findsOneWidget);
  });
}
