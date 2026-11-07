// Marketing scenario: a mistake on 7 × 8 in a training on the table of
// 7, the reminder "Retiens aussi : 8 × 7 = 56", the same fact back two
// questions later and answered right, then the mastery grid of the
// Profile tab. Cut the recording around those moments.
//   bash tool/marketing/record.sh android review_mistake

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/table_toggle.dart';
import 'package:kid_matix/features/quiz/presentation/bloc/quiz_state.dart';

import 'support/demo_player.dart';
import 'support/marketing_harness.dart';

/// The fact missed once; its mirror is the reminder.
const String _missedFact = 'mul:7x8';

/// Draw of the training: 7 × 8 comes as a question of its own, not among
/// pairs to match.
const int _randomSeed = 2;

/// Mark of the table in the training form.
const String _tableMark = '×7';

void main() {
  initMarketingBinding();

  testWidgets('misses a fact and gets it back', (WidgetTester tester) async {
    // Arrange: the recording opens on the first question.
    await startApp(
      tester,
      seed: seedDemoPlayer,
      randomSeed: _randomSeed,
      beforeRecording: () async {
        await tapText(tester, "S'entraîner", before: Duration.zero);
        // Only the table of 7: the current table is selected by default.
        await waitFor(tester, find.byType(TableToggle));
        for (final Element element in find.byType(TableToggle).evaluate()) {
          final TableToggle toggle = element.widget as TableToggle;
          if (toggle.isSelected != (toggle.mark == _tableMark)) {
            await tester.tap(find.byWidget(toggle));
            await tester.pump();
          }
        }
        await tapText(tester, 'Lancer', before: Duration.zero);
      },
    );
    // Act
    bool missed = false;
    await playQuiz(
      tester,
      answerRight: (QuizAsking state) {
        final Question question = state.turn.question;
        if (missed ||
            question.itemKey != _missedFact ||
            question.questionTypeId == QuestionTypeIds.matchPairs) {
          return true;
        }
        missed = true;
        return false;
      },
    );
    await waitFor(tester, findLabel('Continuer'));
    await closeCelebrations(tester);
    await pause(tester, const Duration(seconds: 2));
    await pressButton(tester, 'Continuer');
    await pressTab(tester, 'Profil');
    await tapWhenShown(
      tester,
      findLabel('Mes tables'),
      before: const Duration(milliseconds: 800),
    );
    await endScenario(tester, hold: const Duration(seconds: 4));
    // Assert
    expect(missed, isTrue);
  });
}
