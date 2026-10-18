import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_chase.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_scope.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_repository.dart';
import 'package:kid_matix/features/reward/domain/services/leaderboard_policy.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_use_case.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/test_leaderboard_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

LeaderboardEntry _entry(String id, String nickname, int xp) {
  return LeaderboardEntry(
    player: PlayerIdentity(
      id: id,
      nickname: nickname,
      avatarKey: 'avatar1',
      colorKey: 'violet',
    ),
    weeklyXp: xp,
  );
}

final class _FailingLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<DataState<List<LeaderboardEntry>>> getEntries({
    required LeaderboardScope scope,
    required DateTime from,
    required DateTime to,
  }) async {
    return const DataFailed<List<LeaderboardEntry>>(CacheException());
  }
}

void main() {
  group('LeaderboardPolicy.weekStartOf', () {
    test('returns Monday 00:00 for every day of the week', () {
      // Arrange
      final DateTime expectedStart = DateTime(2026, 10, 12);
      final List<DateTime> inputDays = <DateTime>[
        DateTime(2026, 10, 12),
        DateTime(2026, 10, 13, 8, 30),
        DateTime(2026, 10, 15, 12),
        DateTime(2026, 10, 17, 18),
        DateTime(2026, 10, 18, 23, 59, 59),
      ];
      // Act
      final List<DateTime> actualStarts = inputDays
          .map(LeaderboardPolicy.weekStartOf)
          .toList();
      // Assert
      expect(actualStarts, everyElement(expectedStart));
    });
    test('crosses a month and a year back to Monday', () {
      // Arrange
      final DateTime inputSunday = DateTime(2027, 1, 3, 10);
      // Act
      final DateTime actualStart = LeaderboardPolicy.weekStartOf(inputSunday);
      // Assert
      expect(actualStart, DateTime(2026, 12, 28));
    });
    test('keeps midnight across a daylight saving change', () {
      // Arrange
      final DateTime inputSunday = DateTime(2026, 3, 29, 20);
      // Act
      final DateTime actualStart = LeaderboardPolicy.weekStartOf(inputSunday);
      final DateTime actualNext = LeaderboardPolicy.nextWeekStartOf(
        actualStart,
      );
      // Assert
      expect(actualStart, DateTime(2026, 3, 23));
      expect(actualNext, DateTime(2026, 3, 30));
    });
  });

  group('LeaderboardPolicy.rank', () {
    test('puts the most XP first', () {
      // Arrange
      final List<LeaderboardEntry> inputEntries = <LeaderboardEntry>[
        _entry('p1', 'Awa', 310),
        _entry('p2', 'Moussa', 420),
        _entry('p3', 'Lina', 180),
      ];
      // Act
      final List<LeaderboardEntry> actualRanked = LeaderboardPolicy.rank(
        inputEntries,
      );
      // Assert
      expect(
        actualRanked.map((LeaderboardEntry entry) => entry.player.nickname),
        <String>['Moussa', 'Awa', 'Lina'],
      );
    });
    test('orders equal XP by nickname, ignoring case', () {
      // Arrange
      final List<LeaderboardEntry> inputEntries = <LeaderboardEntry>[
        _entry('p1', 'sira', 0),
        _entry('p2', 'Moussa', 90),
        _entry('p3', 'awa', 90),
        _entry('p4', 'Bintou', 0),
        _entry('p5', 'Lina', 90),
      ];
      // Act
      final List<LeaderboardEntry> actualRanked = LeaderboardPolicy.rank(
        inputEntries,
      );
      // Assert
      expect(
        actualRanked.map((LeaderboardEntry entry) => entry.player.nickname),
        <String>['awa', 'Lina', 'Moussa', 'Bintou', 'sira'],
      );
    });
    test('falls back on the id for the same nickname', () {
      // Arrange
      final List<LeaderboardEntry> inputEntries = <LeaderboardEntry>[
        _entry('p2', 'Awa', 10),
        _entry('p1', 'AWA', 10),
      ];
      // Act
      final List<LeaderboardEntry> actualRanked = LeaderboardPolicy.rank(
        inputEntries,
      );
      // Assert
      expect(
        actualRanked.map((LeaderboardEntry entry) => entry.player.id),
        <String>['p1', 'p2'],
      );
    });
  });

  group('LeaderboardEntity', () {
    final LeaderboardEntity inputBoard = LeaderboardEntity(
      entries: <LeaderboardEntry>[
        _entry('p2', 'Moussa', 420),
        _entry('p1', 'Awa', 310),
        _entry('p4', 'Sira', 310),
        _entry('p3', 'Lina', 0),
      ],
      weekStart: DateTime(2026, 10, 12),
    );

    test('gives the rank of a player from 1, null when absent', () {
      // Act
      final List<int?> actualRanks = <int?>[
        inputBoard.rankOf('p2'),
        inputBoard.rankOf('p4'),
        inputBoard.rankOf('ghost'),
      ];
      // Assert
      expect(actualRanks, <int?>[1, 3, null]);
    });
    test('tells the XP missing to catch up with the player above', () {
      // Act
      final LeaderboardChase? actualChase = inputBoard.chaseOf('p1');
      // Assert
      expect(
        actualChase,
        isA<LeaderboardChaseBehind>()
            .having(
              (LeaderboardChaseBehind chase) => chase.nickname,
              'nickname',
              'Moussa',
            )
            .having(
              (LeaderboardChaseBehind chase) => chase.missingXp,
              'missingXp',
              110,
            ),
      );
    });
    test('tells a tie with the player above', () {
      // Act
      final LeaderboardChase? actualChase = inputBoard.chaseOf('p4');
      // Assert
      expect(
        actualChase,
        isA<LeaderboardChaseTied>().having(
          (LeaderboardChaseTied chase) => chase.nickname,
          'nickname',
          'Awa',
        ),
      );
    });
    test('tells the leader, and nothing for an absent player', () {
      // Act
      final LeaderboardChase? actualLeader = inputBoard.chaseOf('p2');
      final LeaderboardChase? actualAbsent = inputBoard.chaseOf('ghost');
      // Assert
      expect(actualLeader, isA<LeaderboardChaseLeading>());
      expect(actualAbsent, isNull);
    });
    test('tells that nobody started when the first has no XP', () {
      // Arrange
      final LeaderboardEntity inputEmptyWeek = inputBoard.copyWith(
        entries: <LeaderboardEntry>[_entry('p1', 'Awa', 0)],
      );
      // Act
      final LeaderboardChase? actualChase = inputEmptyWeek.chaseOf('p1');
      // Assert
      expect(actualChase, isA<LeaderboardChaseNotStarted>());
      expect(inputEmptyWeek.weekStart, inputBoard.weekStart);
    });
    test('compares entries by value', () {
      // Arrange
      final LeaderboardEntry inputEntry = _entry('p1', 'Awa', 10);
      // Act
      final LeaderboardEntry actualCopy = inputEntry.copyWith(weeklyXp: 20);
      // Assert
      expect(actualCopy, _entry('p1', 'Awa', 20));
      expect(actualCopy.hashCode, _entry('p1', 'Awa', 20).hashCode);
      expect(actualCopy == inputEntry, isFalse);
      expect(actualCopy.copyWith(), actualCopy);
      expect(actualCopy.toString(), 'LeaderboardEntry(Awa, 20)');
    });
  });

  group('GetLeaderboardUseCase', () {
    test('ranks the XP earned since Monday 00:00 of the fake clock', () async {
      // Arrange
      final InMemoryLeaderboardRepository inputRepository =
          InMemoryLeaderboardRepository(
            entries: <LeaderboardEntry>[
              _entry('p1', 'Awa', 310),
              _entry('p2', 'Moussa', 420),
            ],
          );
      final GetLeaderboardUseCase inputUseCase = GetLeaderboardUseCase(
        repository: inputRepository,
        clock: FakeClock(DateTime(2026, 10, 15, 17)),
      );
      // Act
      final LeaderboardEntity actualBoard = (await inputUseCase(
        params: LeaderboardScope.phone,
      )).requireData;
      // Assert
      expect(actualBoard.weekStart, DateTime(2026, 10, 12));
      expect(inputRepository.lastRange, (
        from: DateTime(2026, 10, 12),
        to: DateTime(2026, 10, 19),
      ));
      expect(actualBoard.entries.first.player.nickname, 'Moussa');
    });
    test('starts a new week when Sunday turns into Monday', () async {
      // Arrange
      final InMemoryLeaderboardRepository inputRepository =
          InMemoryLeaderboardRepository();
      final FakeClock inputClock = FakeClock(
        DateTime(2026, 10, 18, 23, 59, 59),
      );
      final GetLeaderboardUseCase inputUseCase = GetLeaderboardUseCase(
        repository: inputRepository,
        clock: inputClock,
      );
      // Act
      final LeaderboardEntity actualSunday = (await inputUseCase(
        params: LeaderboardScope.phone,
      )).requireData;
      inputClock.now_ = DateTime(2026, 10, 19);
      final LeaderboardEntity actualMonday = (await inputUseCase(
        params: LeaderboardScope.phone,
      )).requireData;
      // Assert
      expect(actualSunday.weekStart, DateTime(2026, 10, 12));
      expect(actualMonday.weekStart, DateTime(2026, 10, 19));
      expect(inputRepository.lastRange?.to, DateTime(2026, 10, 26));
    });
    test('passes a failure through', () async {
      // Arrange
      final GetLeaderboardUseCase inputUseCase = GetLeaderboardUseCase(
        repository: _FailingLeaderboardRepository(),
        clock: FakeClock(quizStart),
      );
      // Act
      final DataState<LeaderboardEntity> actualRead = await inputUseCase(
        params: LeaderboardScope.phone,
      );
      // Assert
      expect(actualRead.exceptionOrNull, isA<CacheException>());
    });
  });
}
