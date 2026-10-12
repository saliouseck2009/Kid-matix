import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/game_feedback.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_bloc.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_state.dart';
import 'package:kid_matix/features/challenge/presentation/pages/duel_page.dart';
import 'package:kid_matix/features/challenge/presentation/widgets/duel_half.dart';

import '../../../helpers/pump_localized.dart';
import '../../../helpers/recording_game_feedback.dart';
import '../../../helpers/test_duel_pages.dart';

const Size _phone = Size(390, 844);

/// The duel page of [players], with Awa active; returns what was left.
Future<List<String>> _pumpDuel(
  WidgetTester tester, {
  required RecordingGameFeedback feedback,
  List<PlayerIdentity>? players = const <PlayerIdentity>[awa, moussa],
}) async {
  tester.view
    ..physicalSize = _phone
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final List<String> closed = <String>[];
  await pumpLocalized(
    tester,
    buildTestDuelPages(
      useCases: buildTestDuelUseCases(players: FixedPlayerDirectory(players)),
      feedback: feedback,
    ).buildDuelPage(
      activeProfileId: awa.id,
      avatarOf: (PlayerIdentity player, double size) =>
          SizedBox.square(dimension: size),
      onClose: () => closed.add('closed'),
    ),
  );
  await tester.pumpAndSettle();
  return closed;
}

DuelBloc _blocOf(WidgetTester tester) {
  return tester.element(find.byType(DuelPage)).read<DuelBloc>();
}

Finder _halfOf(DuelSide side) {
  final Finder halves = find.byType(DuelHalf);
  return side == DuelSide.top ? halves.first : halves.last;
}

Future<void> _tapAnswer(
  WidgetTester tester,
  DuelSide side, {
  required bool isRight,
}) async {
  final Question question = (_blocOf(tester).state as DuelRunning).game
      .of(side)
      .question;
  final Answer answer = isRight
      ? question.expectedAnswer
      : question.choices.firstWhere(
          (Answer choice) => choice != question.expectedAnswer,
        );
  await tester.tap(
    find.descendant(
      of: _halfOf(side),
      matching: find.text('${(answer as NumberAnswer).value}'),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _startWithMoussaOnTop(WidgetTester tester) async {
  await tester.tap(find.text('Moussa').first);
  await tester.pump();
  await tester.ensureVisible(find.text("C'est parti !"));
  await tester.tap(find.text("C'est parti !"));
  await tester.pumpAndSettle();
}

void main() {
  group('DuelPage', () {
    testWidgets('asks for two players before the duel', (
      WidgetTester tester,
    ) async {
      // Act
      await _pumpDuel(tester, feedback: RecordingGameFeedback());
      // Assert
      expect(find.text('Duel'), findsOneWidget);
      expect(find.text('Joueur du haut'), findsOneWidget);
      expect(find.text('Joueur du bas'), findsOneWidget);
      expect(find.text('Invité'), findsNWidgets(2));
      expect(find.text('Choisissez deux joueurs différents.'), findsOneWidget);
    });
    testWidgets('plays head to tail, one question per player', (
      WidgetTester tester,
    ) async {
      // Arrange
      await _pumpDuel(tester, feedback: RecordingGameFeedback());
      // Act
      await _startWithMoussaOnTop(tester);
      // Assert
      final RotatedBox actualTop = tester.widget<RotatedBox>(
        find.ancestor(
          of: _halfOf(DuelSide.top),
          matching: find.byType(RotatedBox),
        ),
      );
      expect(actualTop.quarterTurns, 2);
      expect(
        find.descendant(
          of: _halfOf(DuelSide.top),
          matching: find.text('Moussa'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: _halfOf(DuelSide.bottom),
          matching: find.text('Awa'),
        ),
        findsOneWidget,
      );
      expect(find.text('0 / 10'), findsNWidgets(2));
      expect(find.byTooltip('Mettre le duel en pause'), findsOneWidget);
    });
    testWidgets('scores a right answer, blocks after a mistake', (
      WidgetTester tester,
    ) async {
      // Arrange
      final RecordingGameFeedback feedback = RecordingGameFeedback();
      await _pumpDuel(tester, feedback: feedback);
      await _startWithMoussaOnTop(tester);
      // Act
      await _tapAnswer(tester, DuelSide.bottom, isRight: true);
      await _tapAnswer(tester, DuelSide.top, isRight: false);
      // Assert
      expect(
        find.descendant(
          of: _halfOf(DuelSide.bottom),
          matching: find.text('1 / 10'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: _halfOf(DuelSide.top),
          matching: find.byIcon(Icons.close_rounded),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: _halfOf(DuelSide.top),
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
      expect(feedback.played, <GameFeedback>[
        GameFeedback.rightAnswer,
        GameFeedback.wrongAnswer,
      ]);
    });
    testWidgets('the pause can stop the duel', (WidgetTester tester) async {
      // Arrange
      await _pumpDuel(tester, feedback: RecordingGameFeedback());
      await _startWithMoussaOnTop(tester);
      // Act
      await tester.tap(find.byTooltip('Mettre le duel en pause'));
      await tester.pumpAndSettle();
      expect(find.text('Duel en pause'), findsOneWidget);
      await tester.tap(find.text('Arrêter le duel'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Joueur du haut'), findsOneWidget);
    });
    testWidgets('shows the winner and the XP, then plays again', (
      WidgetTester tester,
    ) async {
      // Arrange
      final RecordingGameFeedback feedback = RecordingGameFeedback();
      final List<String> closed = await _pumpDuel(
        tester,
        feedback: feedback,
        players: const <PlayerIdentity>[awa],
      );
      await tester.ensureVisible(find.text("C'est parti !"));
      await tester.tap(find.text("C'est parti !"));
      await tester.pumpAndSettle();
      // Act
      for (int index = 0; index < 10; index++) {
        await _tapAnswer(tester, DuelSide.bottom, isRight: true);
      }
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Awa gagne !'), findsOneWidget);
      expect(find.text('+120 XP'), findsOneWidget);
      expect(find.text("Pas d'XP pour un invité"), findsOneWidget);
      expect(feedback.played.last, GameFeedback.celebration);
      await tester.tap(find.text('Rejouer'));
      await tester.pumpAndSettle();
      expect(find.text('0 / 10'), findsNWidgets(2));
      expect(closed, isEmpty);
    });
    testWidgets('"Quitter" leaves the duel', (WidgetTester tester) async {
      // Arrange
      final List<String> closed = await _pumpDuel(
        tester,
        feedback: RecordingGameFeedback(),
        players: const <PlayerIdentity>[awa],
      );
      await tester.ensureVisible(find.text("C'est parti !"));
      await tester.tap(find.text("C'est parti !"));
      await tester.pumpAndSettle();
      for (int index = 0; index < 10; index++) {
        await _tapAnswer(tester, DuelSide.top, isRight: true);
      }
      await tester.pumpAndSettle();
      // Act
      await tester.ensureVisible(find.text('Quitter'));
      await tester.tap(find.text('Quitter'));
      // Assert
      expect(find.text('Invité gagne !'), findsOneWidget);
      expect(closed, <String>['closed']);
    });
    testWidgets('leaves from the choice of the players', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> closed = await _pumpDuel(
        tester,
        feedback: RecordingGameFeedback(),
      );
      // Act
      await tester.tap(find.byTooltip('Retour'));
      // Assert
      expect(closed, <String>['closed']);
    });
    testWidgets('says when the players cannot be read', (
      WidgetTester tester,
    ) async {
      // Arrange
      final List<String> closed = await _pumpDuel(
        tester,
        feedback: RecordingGameFeedback(),
        players: null,
      );
      // Act
      await tester.tap(find.text('Retour'));
      // Assert
      expect(
        find.text("Oups, on n'a pas pu lire ou enregistrer tes données."),
        findsOneWidget,
      );
      expect(closed, <String>['closed']);
    });
  });
}
