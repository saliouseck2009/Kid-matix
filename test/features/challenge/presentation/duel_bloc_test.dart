import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/services/open_units_service.dart';
import 'package:kid_matix/core/services/player_directory_service.dart';
import 'package:kid_matix/core/services/xp_award_service.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_lineup.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_player.dart';
import 'package:kid_matix/features/challenge/domain/entities/duel_side.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_bloc.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_event.dart';
import 'package:kid_matix/features/challenge/presentation/bloc/duel_state.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_local_data_source_impl.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_repository_impl.dart';
import 'package:kid_matix/features/reward/domain/services/xp_award_service_impl.dart';
import 'package:kid_matix/features/reward/domain/usecases/award_xp_use_case.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/test_duel_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';
import '../helpers/challenge_fakes.dart';

const ProfileDuelPlayer _awa = ProfileDuelPlayer(awa);
const ProfileDuelPlayer _moussa = ProfileDuelPlayer(moussa);
const GuestDuelPlayer _guest = GuestDuelPlayer();

/// A duel Bloc with Awa active, its ticker driven by hand.
DuelBloc _buildBloc({
  ManualTicker? ticker,
  PlayerDirectoryService players = const FixedPlayerDirectory(),
  OpenUnitsService openUnits = const FixedOpenUnits(<String>['mul:2']),
  XpAwardService? xpAwards,
}) {
  return DuelBloc(
    useCases: buildTestDuelUseCases(
      players: players,
      openUnits: openUnits,
      xpAwards: xpAwards,
    ),
    ticker: ticker ?? ManualTicker(),
    activeProfileId: awa.id,
  );
}

Future<void> _settle() => pumpEventQueue();

/// Starts a duel of [lineup] and waits for its first questions.
Future<DuelRunning> _run(DuelBloc bloc, DuelLineup lineup) async {
  bloc.add(DuelStarted(lineup: lineup));
  await _settle();
  return bloc.state as DuelRunning;
}

Question _questionOf(DuelBloc bloc, DuelSide side) {
  return (bloc.state as DuelRunning).game.of(side).question;
}

PlayerAnswered _right(DuelBloc bloc, DuelSide side) {
  return PlayerAnswered(
    side: side,
    answer: _questionOf(bloc, side).expectedAnswer,
  );
}

PlayerAnswered _wrong(DuelBloc bloc, DuelSide side) {
  final Question question = _questionOf(bloc, side);
  return PlayerAnswered(
    side: side,
    answer: question.choices.firstWhere(
      (Answer choice) => choice != question.expectedAnswer,
    ),
  );
}

Future<void> _winWith(DuelBloc bloc, DuelSide side, {int from = 0}) async {
  for (int index = from; index < 10; index++) {
    bloc.add(_right(bloc, side));
    await _settle();
  }
}

void main() {
  group('DuelBloc · choice of the players', () {
    test('offers the active player at the bottom', () async {
      // Arrange
      final DuelBloc bloc = _buildBloc();
      // Act
      bloc.add(const DuelOpened());
      await _settle();
      // Assert
      final DuelChoosingPlayers actualState = bloc.state as DuelChoosingPlayers;
      expect(actualState.players, const <PlayerIdentity>[awa, moussa]);
      expect(actualState.bottom, _awa);
      expect(actualState.top, isNull);
      expect(actualState.lineup, isNull);
      await bloc.close();
    });
    test('offers the guest at the top when nobody else can play', () async {
      // Arrange
      final DuelBloc bloc = _buildBloc(
        players: const FixedPlayerDirectory(<PlayerIdentity>[awa]),
      );
      // Act
      bloc.add(const DuelOpened());
      await _settle();
      // Assert
      final DuelChoosingPlayers actualState = bloc.state as DuelChoosingPlayers;
      expect(actualState.lineup, DuelLineup(top: _guest, bottom: _awa));
      await bloc.close();
    });
    test('never puts the same profile on both halves', () async {
      // Arrange
      final DuelBloc bloc = _buildBloc()..add(const DuelOpened());
      await _settle();
      // Act
      bloc.add(const DuelPlayerPicked(side: DuelSide.top, player: _awa));
      await _settle();
      final DuelChoosingPlayers actualRefused =
          bloc.state as DuelChoosingPlayers;
      bloc.add(const DuelPlayerPicked(side: DuelSide.top, player: _moussa));
      await _settle();
      // Assert
      expect(actualRefused.top, isNull);
      expect(
        (bloc.state as DuelChoosingPlayers).lineup,
        DuelLineup(top: _moussa, bottom: _awa),
      );
      await bloc.close();
    });
    test('says when the players cannot be read', () async {
      // Arrange
      final DuelBloc bloc = _buildBloc(
        players: const FixedPlayerDirectory(null),
      );
      // Act
      bloc.add(const DuelOpened());
      await _settle();
      // Assert
      expect(
        (bloc.state as DuelFailure).errorCode,
        AppErrorCode.cache,
      );
      await bloc.close();
    });
    test('says when the tables cannot be read', () async {
      // Arrange
      final DuelBloc bloc = _buildBloc(openUnits: const FixedOpenUnits(null));
      // Act
      bloc.add(
        DuelStarted(
          lineup: DuelLineup(top: _moussa, bottom: _awa),
        ),
      );
      await _settle();
      // Assert
      expect(bloc.state, isA<DuelFailure>());
      await bloc.close();
    });
  });

  group('DuelBloc · race', () {
    test('judges two taps at the same time, each on its own half', () async {
      // Arrange
      final DuelBloc bloc = _buildBloc();
      await _run(bloc, DuelLineup(top: _moussa, bottom: _awa));
      // Act
      bloc
        ..add(_right(bloc, DuelSide.top))
        ..add(_right(bloc, DuelSide.bottom));
      await _settle();
      // Assert
      final DuelRunning actualState = bloc.state as DuelRunning;
      expect(actualState.game.top.score, 1);
      expect(actualState.game.bottom.score, 1);
      expect(actualState.answerCount, 2);
      expect(actualState.isLastAnswerRight, isTrue);
      await bloc.close();
    });
    test('a mistake on one half never blocks the other', () async {
      // Arrange
      final DuelBloc bloc = _buildBloc();
      await _run(bloc, DuelLineup(top: _moussa, bottom: _awa));
      // Act
      bloc
        ..add(_wrong(bloc, DuelSide.top))
        ..add(_right(bloc, DuelSide.bottom));
      await _settle();
      // Assert
      final DuelRunning actualState = bloc.state as DuelRunning;
      expect(actualState.game.top.isBlocked, isTrue);
      expect(actualState.game.bottom.isBlocked, isFalse);
      expect(actualState.game.bottom.score, 1);
      await bloc.close();
    });
    test('ignores the taps of a blocked player for 2 seconds', () async {
      // Arrange
      final ManualTicker ticker = ManualTicker();
      final DuelBloc bloc = _buildBloc(ticker: ticker);
      await _run(bloc, DuelLineup(top: _moussa, bottom: _awa));
      bloc.add(_wrong(bloc, DuelSide.top));
      await _settle();
      final bool? actualLastRight =
          (bloc.state as DuelRunning).isLastAnswerRight;
      // Act
      for (int tick = 0; tick < 19; tick++) {
        ticker.controller.add(tick);
        await _settle();
      }
      bloc.add(_right(bloc, DuelSide.top));
      await _settle();
      final DuelRunning actualBlocked = bloc.state as DuelRunning;
      ticker.controller.add(19);
      await _settle();
      bloc.add(_right(bloc, DuelSide.top));
      await _settle();
      // Assert
      expect(actualLastRight, isFalse);
      expect(actualBlocked.game.top.isBlocked, isTrue);
      expect(actualBlocked.game.top.score, 0);
      expect(actualBlocked.answerCount, 1);
      final DuelRunning actualState = bloc.state as DuelRunning;
      expect(actualState.game.top.isBlocked, isFalse);
      expect(actualState.game.top.score, 1);
      await bloc.close();
    });
    test('the first to 10 wins and both profiles get their XP', () async {
      // Arrange
      final RecordingXpAwards xpAwards = RecordingXpAwards();
      final DuelBloc bloc = _buildBloc(xpAwards: xpAwards);
      await _run(bloc, DuelLineup(top: _moussa, bottom: _awa));
      for (int index = 0; index < 4; index++) {
        bloc.add(_right(bloc, DuelSide.top));
        await _settle();
      }
      final List<DuelState> actualStates = <DuelState>[];
      bloc.stream.listen(actualStates.add);
      final PlayerAnswered inputTooLate = _right(bloc, DuelSide.top);
      // Act
      await _winWith(bloc, DuelSide.bottom);
      bloc.add(inputTooLate);
      await _settle();
      // Assert
      expect(actualStates.whereType<DuelSaving>(), hasLength(1));
      final DuelFinished actualState = bloc.state as DuelFinished;
      expect(actualState.outcome.winner, DuelSide.bottom);
      expect(actualState.outcome.bottomXp, 120);
      expect(actualState.outcome.topXp, 40);
      expect(actualState.game.top.score, 4);
      expect(xpAwards.awarded, <String, int>{awa.id: 120, moussa.id: 40});
      await bloc.close();
    });
    test('a guest earns nothing', () async {
      // Arrange
      final RecordingXpAwards xpAwards = RecordingXpAwards();
      final DuelBloc bloc = _buildBloc(xpAwards: xpAwards);
      await _run(bloc, DuelLineup(top: _guest, bottom: _awa));
      // Act
      await _winWith(bloc, DuelSide.top);
      // Assert
      final DuelFinished actualState = bloc.state as DuelFinished;
      expect(actualState.outcome.winner, DuelSide.top);
      expect(actualState.outcome.topXp, 0);
      expect(xpAwards.awarded, isEmpty);
      await bloc.close();
    });
    test('"Rejouer" starts again between the same players', () async {
      // Arrange
      final DuelBloc bloc = _buildBloc();
      final DuelLineup inputLineup = DuelLineup(top: _moussa, bottom: _awa);
      await _run(bloc, inputLineup);
      await _winWith(bloc, DuelSide.top);
      // Act
      bloc.add(const DuelRestarted());
      await _settle();
      // Assert
      final DuelRunning actualState = bloc.state as DuelRunning;
      expect(actualState.lineup, inputLineup);
      expect(actualState.game.top.score, 0);
      expect(actualState.answerCount, 0);
      await bloc.close();
    });
    test('stopping gives no XP and goes back to the players', () async {
      // Arrange
      final RecordingXpAwards xpAwards = RecordingXpAwards();
      final DuelBloc bloc = _buildBloc(xpAwards: xpAwards)
        ..add(const DuelOpened());
      await _settle();
      await _run(bloc, DuelLineup(top: _moussa, bottom: _awa));
      bloc.add(_right(bloc, DuelSide.top));
      await _settle();
      // Act
      bloc
        ..add(const DuelAbandoned())
        ..add(const DuelTicked());
      await _settle();
      // Assert
      final DuelChoosingPlayers actualState = bloc.state as DuelChoosingPlayers;
      expect(actualState.lineup, DuelLineup(top: _moussa, bottom: _awa));
      expect(actualState.players, hasLength(2));
      expect(xpAwards.awarded, isEmpty);
      await bloc.close();
    });
  });

  group('DuelBloc · with the database', () {
    late AppDatabase appDatabase;
    late TableChangeBus changeBus;

    setUpAll(sqfliteFfiInit);

    setUp(() async {
      appDatabase = AppDatabase(
        databaseFactory: databaseFactoryFfi,
        resolvePath: () async => inMemoryDatabasePath,
        migrationRunner: MigrationRunner(migrations: appMigrations),
      );
      final Database database = await appDatabase.database;
      for (final PlayerIdentity player in <PlayerIdentity>[awa, moussa]) {
        await database.insert('profile', <String, Object?>{
          'id': player.id,
          'nickname': player.nickname,
          'normalized_nickname': player.nickname.toLowerCase(),
          'avatar': player.avatarKey,
          'color': player.colorKey,
          'created_at': 0,
          'updated_at': 0,
        });
      }
      changeBus = TableChangeBus();
    });

    tearDown(() async {
      await changeBus.dispose();
      await appDatabase.close();
    });

    test('writes the XP and never touches the mastery', () async {
      // Arrange
      int awardCount = 0;
      final XpAwardServiceImpl xpAwards = XpAwardServiceImpl(
        awardXp: AwardXpUseCase(
          repository: RewardRepositoryImpl(
            rewards: RewardLocalDataSourceImpl(database: appDatabase),
            changeBus: changeBus,
          ),
          ids: _CountingIds(() => 'award-${awardCount++}'),
          clock: FakeClock(DateTime(2026, 10, 12, 17)),
        ),
      );
      final DuelBloc bloc = _buildBloc(xpAwards: xpAwards);
      await _run(bloc, DuelLineup(top: _moussa, bottom: _awa));
      bloc.add(_wrong(bloc, DuelSide.bottom));
      await _settle();
      // Act
      await _winWith(bloc, DuelSide.top);
      if (bloc.state is! DuelFinished) {
        // The XP are written by the real database, slower than the
        // event queue.
        await bloc.stream.firstWhere(
          (DuelState state) => state is DuelFinished,
        );
      }
      // Assert
      final Database database = await appDatabase.database;
      expect((bloc.state as DuelFinished).outcome.isXpSaved, isTrue);
      expect(await database.query('item_progress'), isEmpty);
      expect(await database.query('quiz_session'), isEmpty);
      expect(await database.query('streak'), isEmpty);
      expect(await database.query('xp_award'), hasLength(1));
      final Map<String, Object?> actualMoussa = (await database.query(
        'profile',
        where: 'id = ?',
        whereArgs: <Object>[moussa.id],
      )).single;
      expect(actualMoussa['total_xp'], 120);
      expect(actualMoussa['level'], 2);
      await bloc.close();
    });
  });
}

/// [IdGenerator] calling [next] for each identifier.
final class _CountingIds implements IdGenerator {
  _CountingIds(this.next);

  final String Function() next;

  @override
  String generateId() => next();
}
