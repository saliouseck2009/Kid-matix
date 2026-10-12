import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_contender.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_game_entity.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_lineup.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_outcome.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_referee.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_rules.dart';
import 'package:kid_matix/features/challenge/domain/services/duel_xp_policy.dart';
import 'package:kid_matix/features/challenge/domain/usecases/answer_duel_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/duel_answer_params.dart';
import 'package:kid_matix/features/challenge/domain/usecases/duel_elapse_params.dart';
import 'package:kid_matix/features/challenge/domain/usecases/elapse_duel_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/finish_duel_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_duel_players_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/start_duel_use_case.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/test_duel_pages.dart';
import '../helpers/challenge_fakes.dart';

const ProfileDuelPlayer _awa = ProfileDuelPlayer(awa);
const ProfileDuelPlayer _moussa = ProfileDuelPlayer(moussa);
const GuestDuelPlayer _guest = GuestDuelPlayer();

final MultiplicationDomain _domain = MultiplicationDomain();

DuelReferee _referee({int seed = 3}) {
  return DuelReferee(
    domain: _domain,
    random: DartRandomSource(seed: seed),
  );
}

DuelGameEntity _start({
  DuelPlayer top = _moussa,
  DuelPlayer bottom = _awa,
  List<String> topUnits = const <String>['mul:5'],
  List<String> bottomUnits = const <String>['mul:2'],
}) {
  return _referee().start(
    top: top,
    bottom: bottom,
    topUnitKeys: topUnits,
    bottomUnitKeys: bottomUnits,
  );
}

Answer _wrongOf(Question question) {
  return question.choices.firstWhere(
    (Answer choice) => choice != question.expectedAnswer,
  );
}

DuelGameEntity _answerRight(
  DuelReferee referee,
  DuelGameEntity game,
  DuelSide side,
) {
  return referee.answer(game, side, game.of(side).question.expectedAnswer);
}

void main() {
  group('DuelLineup', () {
    test('takes two profiles, or a profile and a guest', () {
      // Assert
      expect(DuelLineup.isValid(top: _moussa, bottom: _awa), isTrue);
      expect(DuelLineup.isValid(top: _guest, bottom: _awa), isTrue);
      expect(DuelLineup.isValid(top: _awa, bottom: _guest), isTrue);
    });
    test('refuses the same profile twice and two guests', () {
      // Assert
      expect(DuelLineup.isValid(top: _awa, bottom: _awa), isFalse);
      expect(DuelLineup.isValid(top: _guest, bottom: _guest), isFalse);
      expect(
        () => DuelLineup(top: _awa, bottom: _awa),
        throwsA(isA<ArgumentError>()),
      );
    });
    test('names the player of each side and compares by value', () {
      // Arrange
      final DuelLineup inputLineup = DuelLineup(top: _moussa, bottom: _awa);
      // Act
      final DuelLineup actualCopy = inputLineup.copyWith(top: _guest);
      // Assert
      expect(inputLineup.playerOf(DuelSide.top), _moussa);
      expect(inputLineup.playerOf(DuelSide.bottom), _awa);
      expect(actualCopy.top, _guest);
      expect(actualCopy.copyWith(top: _moussa), inputLineup);
      expect(actualCopy.copyWith(top: _moussa).hashCode, inputLineup.hashCode);
      expect(DuelSide.top.opponent, DuelSide.bottom);
      expect(_guest.hashCode, const GuestDuelPlayer().hashCode);
      expect(_awa.hashCode, const ProfileDuelPlayer(awa).hashCode);
    });
  });

  group('DuelReferee', () {
    test('gives each player a multiple choice on their own tables', () {
      // Act
      final DuelGameEntity actualGame = _start();
      // Assert
      expect(actualGame.top.question.unitKey, 'mul:5');
      expect(actualGame.bottom.question.unitKey, 'mul:2');
      for (final DuelSide side in DuelSide.values) {
        final Question question = actualGame.of(side).question;
        expect(question.questionTypeId, QuestionTypeIds.multipleChoice);
        expect(question.choices, hasLength(4));
        expect(actualGame.of(side).score, 0);
      }
      expect(actualGame.winningScore, DuelRules.winningScore);
      expect(actualGame.winner, isNull);
    });
    test('scores a right answer and asks a new fact at once', () {
      // Arrange
      final DuelReferee referee = _referee();
      final DuelGameEntity inputGame = _start();
      // Act
      final DuelGameEntity actualGame = _answerRight(
        referee,
        inputGame,
        DuelSide.bottom,
      );
      // Assert
      expect(actualGame.bottom.score, 1);
      expect(actualGame.bottom.isBlocked, isFalse);
      expect(
        actualGame.bottom.question.itemKey,
        isNot(inputGame.bottom.question.itemKey),
      );
      expect(actualGame.top, inputGame.top);
    });
    test('blocks a player 2 seconds after a mistake', () {
      // Arrange
      final DuelReferee referee = _referee();
      final DuelGameEntity inputGame = _start();
      final Answer inputWrong = _wrongOf(inputGame.top.question);
      // Act
      final DuelGameEntity actualGame = referee.answer(
        inputGame,
        DuelSide.top,
        inputWrong,
      );
      // Assert
      expect(actualGame.top.isBlocked, isTrue);
      expect(actualGame.top.blockedFor, const Duration(seconds: 2));
      expect(actualGame.top.wrongAnswer, inputWrong);
      expect(actualGame.top.question, inputGame.top.question);
      expect(actualGame.top.score, 0);
      expect(actualGame.hasBlockedContender, isTrue);
      expect(actualGame.bottom.isBlocked, isFalse);
    });
    test('ignores taps while blocked, accepts them after 2 seconds', () {
      // Arrange
      final DuelReferee referee = _referee();
      final DuelGameEntity blocked = referee.answer(
        _start(),
        DuelSide.top,
        _wrongOf(_start().top.question),
      );
      // Act
      final DuelGameEntity actualIgnored = _answerRight(
        referee,
        blocked,
        DuelSide.top,
      );
      final DuelGameEntity actualStill = referee.elapse(
        blocked,
        const Duration(milliseconds: 1900),
      );
      final DuelGameEntity actualFree = referee.elapse(
        actualStill,
        const Duration(milliseconds: 100),
      );
      // Assert
      expect(actualIgnored, blocked);
      expect(actualStill.top.isBlocked, isTrue);
      expect(actualFree.top.isBlocked, isFalse);
      expect(actualFree.top.wrongAnswer, isNull);
      expect(
        actualFree.top.question.itemKey,
        isNot(blocked.top.question.itemKey),
      );
      expect(_answerRight(referee, actualFree, DuelSide.top).top.score, 1);
    });
    test('ends at 10 right answers and ignores what follows', () {
      // Arrange
      final DuelReferee referee = _referee();
      DuelGameEntity game = _start();
      // Act
      for (int index = 0; index < DuelRules.winningScore; index++) {
        game = _answerRight(referee, game, DuelSide.bottom);
      }
      // Assert
      expect(game.winner, DuelSide.bottom);
      expect(game.isOver, isTrue);
      expect(_answerRight(referee, game, DuelSide.top), game);
      expect(referee.elapse(game, const Duration(seconds: 1)), game);
      expect(
        game.copyWith(top: game.top.copyWith(score: 10)).winner,
        DuelSide.top,
      );
    });
    test('draws only the tables of the player, never twice in a row', () {
      // Arrange
      final DuelReferee referee = _referee(seed: 11);
      DuelGameEntity game = _start(
        bottomUnits: const <String>['mul:3', 'mul:4'],
      ).copyWith(winningScore: 1000);
      final List<String> actualItems = <String>[];
      // Act
      for (int index = 0; index < 60; index++) {
        actualItems.add(game.bottom.question.itemKey);
        game = _answerRight(referee, game, DuelSide.bottom);
      }
      // Assert
      expect(
        actualItems.every(
          (String key) => key.startsWith('mul:3x') || key.startsWith('mul:4x'),
        ),
        isTrue,
      );
      for (int index = 1; index < actualItems.length; index++) {
        expect(actualItems[index], isNot(actualItems[index - 1]));
      }
    });
    test('refuses a player without tables', () {
      // Assert
      expect(
        () => _start(topUnits: const <String>[]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('DuelXpPolicy', () {
    test('gives 10 XP per right answer and 20 more to the winner', () {
      // Arrange
      final DuelGameEntity inputGame = _start(top: _guest);
      final DuelGameEntity won = inputGame.copyWith(
        top: inputGame.top.copyWith(score: 4),
        bottom: inputGame.bottom.copyWith(score: 10),
      );
      final DuelGameEntity lost = won.copyWith(top: won.top);
      // Act
      final DuelOutcome actualOutcome = const DuelXpPolicy().outcomeOf(
        won,
        winner: DuelSide.bottom,
      );
      final int actualLoserXp = const DuelXpPolicy().xpOf(
        contender: lost.bottom.copyWith(score: 6),
        isWinner: false,
      );
      // Assert
      expect(actualOutcome.bottomXp, 120);
      expect(actualOutcome.topXp, 0);
      expect(actualOutcome.xpOf(DuelSide.top), 0);
      expect(actualLoserXp, 60);
    });
  });

  group('entities', () {
    test('compare by value', () {
      // Arrange
      final DuelGameEntity inputGame = _start();
      const DuelOutcome inputOutcome = DuelOutcome(
        winner: DuelSide.top,
        topXp: 120,
        bottomXp: 40,
      );
      // Act
      final DuelContender actualContender = inputGame.top.copyWith(score: 3);
      // Assert
      expect(actualContender, isNot(inputGame.top));
      expect(actualContender.copyWith(score: 0), inputGame.top);
      expect(
        actualContender.copyWith(score: 0).hashCode,
        inputGame.top.hashCode,
      );
      expect(
        inputGame.withContender(DuelSide.top, inputGame.top),
        inputGame,
      );
      expect(inputGame.copyWith().hashCode, inputGame.hashCode);
      expect(inputOutcome.copyWith(isXpSaved: false).isXpSaved, isFalse);
      expect(inputOutcome.copyWith(), inputOutcome);
      expect(inputOutcome.copyWith().hashCode, inputOutcome.hashCode);
      expect(inputOutcome.xpOf(DuelSide.bottom), 40);
    });
  });

  group('use cases', () {
    final DomainRegistry domains = DomainRegistry()..register(_domain);

    test('lists the players of the phone', () async {
      // Act
      final List<PlayerIdentity> actualPlayers =
          (await const GetDuelPlayersUseCase(
            players: FixedPlayerDirectory(),
          )()).requireData;
      // Assert
      expect(actualPlayers, const <PlayerIdentity>[awa, moussa]);
    });
    test('a profile plays its open tables, a guest the 12 tables', () async {
      // Arrange
      final StartDuelUseCase start = StartDuelUseCase(
        openUnits: const FixedOpenUnits(<String>['mul:1', 'mul:2']),
        domains: domains,
        random: DartRandomSource(seed: 1),
      );
      // Act
      final DuelGameEntity actualGame = (await start(
        params: DuelLineup(top: _guest, bottom: _awa),
      )).requireData;
      // Assert
      expect(actualGame.bottom.unitKeys, <String>['mul:1', 'mul:2']);
      expect(actualGame.top.unitKeys, <String>[
        for (int table = 1; table <= 12; table++) 'mul:$table',
      ]);
    });
    test('falls back on the first table when none is open', () async {
      // Act
      final DuelGameEntity actualGame =
          (await StartDuelUseCase(
                openUnits: const FixedOpenUnits(<String>[]),
                domains: domains,
                random: DartRandomSource(seed: 1),
              )(
                params: DuelLineup(top: _moussa, bottom: _awa),
              ))
              .requireData;
      // Assert
      expect(actualGame.top.unitKeys, <String>['mul:1']);
    });
    test('fails when the tables cannot be read', () async {
      // Act
      final AppException? actualException =
          (await StartDuelUseCase(
                openUnits: const FixedOpenUnits(null),
                domains: domains,
                random: DartRandomSource(seed: 1),
              )(
                params: DuelLineup(top: _guest, bottom: _awa),
              ))
              .exceptionOrNull;
      final AppException? actualTopException =
          (await StartDuelUseCase(
                openUnits: const FixedOpenUnits(null),
                domains: domains,
                random: DartRandomSource(seed: 1),
              )(
                params: DuelLineup(top: _awa, bottom: _guest),
              ))
              .exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
      expect(actualTopException, isA<CacheException>());
    });
    test('without the domain, starts nothing and changes nothing', () async {
      // Arrange
      final DomainRegistry inputEmpty = DomainRegistry();
      final DuelGameEntity inputGame = _start();
      // Act
      final AppException? actualException =
          (await StartDuelUseCase(
                openUnits: const FixedOpenUnits(),
                domains: inputEmpty,
                random: DartRandomSource(seed: 1),
              )(
                params: DuelLineup(top: _guest, bottom: _awa),
              ))
              .exceptionOrNull;
      final DuelGameEntity actualAnswered =
          await AnswerDuelUseCase(
            domains: inputEmpty,
            random: DartRandomSource(seed: 1),
          )(
            params: DuelAnswerParams(
              game: inputGame,
              side: DuelSide.top,
              answer: inputGame.top.question.expectedAnswer,
            ),
          );
      final DuelGameEntity actualElapsed =
          await ElapseDuelUseCase(
            domains: inputEmpty,
            random: DartRandomSource(seed: 1),
          )(
            params: DuelElapseParams(game: inputGame, elapsed: Duration.zero),
          );
      // Assert
      expect(actualException, isA<NotFoundException>());
      expect(actualAnswered, inputGame);
      expect(actualElapsed, inputGame);
    });
    test('params compare by value', () {
      // Arrange
      final DuelGameEntity inputGame = _start();
      final DuelAnswerParams inputAnswer = DuelAnswerParams(
        game: inputGame,
        side: DuelSide.top,
        answer: const NumberAnswer(1),
      );
      final DuelElapseParams inputElapse = DuelElapseParams(
        game: inputGame,
        elapsed: Duration.zero,
      );
      // Assert
      expect(
        inputAnswer,
        DuelAnswerParams(
          game: inputGame,
          side: DuelSide.top,
          answer: const NumberAnswer(1),
        ),
      );
      expect(inputAnswer.hashCode, isA<int>());
      expect(
        inputElapse,
        DuelElapseParams(game: inputGame, elapsed: Duration.zero),
      );
      expect(inputElapse.hashCode, isA<int>());
    });
    test('gives the XP to the profiles, none to a guest', () async {
      // Arrange
      final RecordingXpAwards xpAwards = RecordingXpAwards();
      final DuelGameEntity inputGame = _start(top: _guest);
      final DuelGameEntity won = inputGame.copyWith(
        top: inputGame.top.copyWith(score: 9),
        bottom: inputGame.bottom.copyWith(score: 10),
      );
      // Act
      final DuelOutcome actualOutcome = await FinishDuelUseCase(
        xpAwards: xpAwards,
      )(params: won);
      // Assert
      expect(actualOutcome.winner, DuelSide.bottom);
      expect(actualOutcome.isXpSaved, isTrue);
      expect(xpAwards.awarded, <String, int>{awa.id: 120});
    });
    test('the loser keeps their XP', () async {
      // Arrange
      final RecordingXpAwards xpAwards = RecordingXpAwards();
      final DuelGameEntity inputGame = _start();
      final DuelGameEntity won = inputGame.copyWith(
        top: inputGame.top.copyWith(score: 10),
        bottom: inputGame.bottom.copyWith(score: 3),
      );
      // Act
      await FinishDuelUseCase(xpAwards: xpAwards)(params: won);
      // Assert
      expect(xpAwards.awarded, <String, int>{moussa.id: 120, awa.id: 30});
    });
    test('says when the XP were not saved', () async {
      // Arrange
      final DuelGameEntity inputGame = _start();
      final DuelGameEntity won = inputGame.copyWith(
        top: inputGame.top.copyWith(score: 10),
      );
      // Act
      final DuelOutcome actualOutcome = await FinishDuelUseCase(
        xpAwards: RecordingXpAwards(isFailing: true),
      )(params: won);
      // Assert
      expect(actualOutcome.isXpSaved, isFalse);
      expect(actualOutcome.topXp, 120);
    });
    test('refuses a duel nobody has won', () {
      // Assert
      expect(
        () =>
            FinishDuelUseCase(xpAwards: RecordingXpAwards())(params: _start()),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
