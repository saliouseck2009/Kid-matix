import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_contender.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_rules.dart';

/// Runs a duel: draws each player's questions from their own tables,
/// counts the right answers and blocks a player after a mistake.
///
/// Every question is a multiple choice. A right answer brings the next
/// question at once; a wrong one shows the right answer while the
/// buttons stay blocked, then a new question comes. The mastery of the
/// facts is never touched.
final class DuelReferee {
  /// Creates the referee drawing from [domain] with [random].
  const DuelReferee({required this._domain, required this._random});

  final LearningDomain _domain;
  final RandomSource _random;

  /// Opens a duel where [top] and [bottom] play the units of
  /// [topUnitKeys] and [bottomUnitKeys].
  DuelGameEntity start({
    required DuelPlayer top,
    required DuelPlayer bottom,
    required List<String> topUnitKeys,
    required List<String> bottomUnitKeys,
  }) {
    return DuelGameEntity(
      top: _open(top, topUnitKeys),
      bottom: _open(bottom, bottomUnitKeys),
      winningScore: DuelRules.winningScore,
    );
  }

  /// Judges [answer] of the player of [side]; ignored once the duel is
  /// over or while their buttons are blocked.
  DuelGameEntity answer(DuelGameEntity game, DuelSide side, Answer answer) {
    final DuelContender contender = game.of(side);
    if (game.isOver || contender.isBlocked) return game;
    if (answer != contender.question.expectedAnswer) {
      return game.withContender(
        side,
        contender.copyWith(
          blockedFor: DuelRules.wrongAnswerBlock,
          wrongAnswer: answer,
        ),
      );
    }
    return game.withContender(
      side,
      contender.copyWith(
        score: contender.score + 1,
        question: _nextQuestion(contender),
      ),
    );
  }

  /// Lets [elapsed] pass: the blocks shorten, and a player whose block
  /// ends gets a new question.
  DuelGameEntity elapse(DuelGameEntity game, Duration elapsed) {
    if (game.isOver) return game;
    return game.copyWith(
      top: _elapseFor(game.top, elapsed),
      bottom: _elapseFor(game.bottom, elapsed),
    );
  }

  DuelContender _elapseFor(DuelContender contender, Duration elapsed) {
    if (!contender.isBlocked) return contender;
    final Duration left = contender.blockedFor - elapsed;
    if (left > Duration.zero) return contender.copyWith(blockedFor: left);
    return contender.copyWith(
      blockedFor: Duration.zero,
      question: _nextQuestion(contender),
      clearWrongAnswer: true,
    );
  }

  DuelContender _open(DuelPlayer player, List<String> unitKeys) {
    return DuelContender(
      player: player,
      unitKeys: unitKeys,
      question: _drawQuestion(unitKeys, previousItemKey: null),
    );
  }

  Question _nextQuestion(DuelContender contender) {
    return _drawQuestion(
      contender.unitKeys,
      previousItemKey: contender.question.itemKey,
    );
  }

  /// A multiple choice question on an item of [unitKeys], drawn by the
  /// weights of the domain, never [previousItemKey] when another exists.
  Question _drawQuestion(
    List<String> unitKeys, {
    required String? previousItemKey,
  }) {
    final List<LearningItem> items = <LearningItem>[
      for (final String key in unitKeys) ...?_domain.findUnit(key)?.items,
    ];
    if (items.isEmpty) throw ArgumentError.value(unitKeys, 'unitKeys');
    final List<LearningItem> others = items
        .where((LearningItem item) => item.key != previousItemKey)
        .toList();
    return _domain.buildQuestion(
      item: _drawWeighted(others.isEmpty ? items : others),
      questionTypeId: QuestionTypeIds.multipleChoice,
      random: _random,
    );
  }

  LearningItem _drawWeighted(List<LearningItem> items) {
    final List<int> weights = items.map(_domain.drawWeightOf).toList();
    int draw = _random.nextInt(weights.fold(0, (int a, int b) => a + b));
    for (int index = 0; index < items.length; index++) {
      draw -= weights[index];
      if (draw < 0) return items[index];
    }
    return items.last;
  }
}
