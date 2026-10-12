import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_entry.dart';
import 'package:kid_matix/features/reward/domain/entities/leaderboard_scope.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_repository.dart';
import 'package:kid_matix/features/reward/domain/repositories/leaderboard_visibility_repository.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_leaderboard_use_case.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_state.dart';
import 'package:kid_matix/features/reward/presentation/bloc/leaderboard_visibility_cubit.dart';
import 'package:kid_matix/features/reward/presentation/bloc/reward_value_state.dart';
import 'package:kid_matix/features/reward/presentation/leaderboard_pages.dart';

import '../../../helpers/pump_localized.dart';
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

/// The players of mockup 19.
final List<LeaderboardEntry> _mockupEntries = <LeaderboardEntry>[
  _entry('awa', 'Awa', 310),
  _entry('lina', 'Lina', 180),
  _entry('moussa', 'Moussa', 420),
  _entry('sira', 'Sira', 90),
];

/// [LeaderboardRepository] failing once, then returning [entries].
final class _FlakyLeaderboardRepository implements LeaderboardRepository {
  _FlakyLeaderboardRepository(this.entries);

  final List<LeaderboardEntry> entries;
  bool _hasFailed = false;

  @override
  Future<DataState<List<LeaderboardEntry>>> getEntries({
    required LeaderboardScope scope,
    required DateTime from,
    required DateTime to,
  }) async {
    if (_hasFailed) return DataSuccess<List<LeaderboardEntry>>(entries);
    _hasFailed = true;
    return const DataFailed<List<LeaderboardEntry>>(CacheException());
  }
}

/// [LeaderboardVisibilityRepository] whose writes fail.
final class _ReadOnlyVisibility implements LeaderboardVisibilityRepository {
  @override
  Future<DataState<bool>> isShown() async => const DataSuccess<bool>(true);

  @override
  Future<DataState<void>> setShown({required bool isShown}) async {
    return const DataFailed<void>(CacheException());
  }

  @override
  Stream<bool> watchShown() => const Stream<bool>.empty();
}

Widget _avatarOf(PlayerIdentity player, double size) {
  return SizedBox.square(dimension: size);
}

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    required LeaderboardRepository leaderboard,
    required String profileId,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    final LeaderboardPages inputPages = buildTestLeaderboardPages(
      leaderboard: leaderboard,
    );
    // A new page, never the Cubit of the previous one.
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpLocalized(
      tester,
      inputPages.buildLeaderboardPage(
        profileId: profileId,
        avatarOf: _avatarOf,
        onBack: () {},
      ),
    );
    await tester.pumpAndSettle();
  }

  group('LeaderboardPage', () {
    testWidgets('shows the podium, the others and the chase of mockup 19', (
      WidgetTester tester,
    ) async {
      // Arrange
      final SemanticsHandle semantics = tester.ensureSemantics();
      // Act
      await pumpPage(
        tester,
        leaderboard: InMemoryLeaderboardRepository(entries: _mockupEntries),
        profileId: 'awa',
      );
      // Assert
      for (final String text in <String>[
        'Classement',
        'XP gagnés cette semaine',
        'Remise à zéro lundi',
        "C'est toi",
        '420 XP',
        '310 XP',
        '180 XP',
        '90 XP',
        'Sira',
        'Encore 110 XP et tu rattrapes Moussa !',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(
        find.bySemanticsLabel('Awa, c\'est toi, place 2, 310 XP'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Moussa, place 1, 420 XP'), findsOneWidget);
      expect(find.bySemanticsLabel('Sira, place 4, 90 XP'), findsOneWidget);
      semantics.dispose();
    });
    testWidgets('highlights the active player under the podium', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpPage(
        tester,
        leaderboard: InMemoryLeaderboardRepository(entries: _mockupEntries),
        profileId: 'sira',
      );
      // Assert
      expect(find.text("C'est toi"), findsOneWidget);
      expect(
        find.text('Encore 90 XP et tu rattrapes Lina !'),
        findsOneWidget,
      );
    });
    testWidgets('cheers the leader and a week not started', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpPage(
        tester,
        leaderboard: InMemoryLeaderboardRepository(entries: _mockupEntries),
        profileId: 'moussa',
      );
      // Assert
      expect(find.text('Tu es en tête cette semaine !'), findsOneWidget);
      await pumpPage(
        tester,
        leaderboard: InMemoryLeaderboardRepository(
          entries: <LeaderboardEntry>[
            _entry('awa', 'Awa', 0),
            _entry('lina', 'Lina', 0),
          ],
        ),
        profileId: 'lina',
      );
      expect(
        find.text('Tu es à égalité avec Awa !'),
        findsOneWidget,
      );
    });
    testWidgets('shows the error, then the ranking after a retry', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpPage(
        tester,
        leaderboard: _FlakyLeaderboardRepository(<LeaderboardEntry>[
          _entry('awa', 'Awa', 0),
        ]),
        profileId: 'awa',
      );
      expect(
        find.text("Oups, on n'a pas pu lire ou enregistrer tes données."),
        findsOneWidget,
      );
      // Act
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      // Assert
      expect(
        find.text('Joue pour gagner tes premiers XP de la semaine !'),
        findsOneWidget,
      );
    });
  });

  group('LeaderboardCubit', () {
    test('reads the ranking again when XP change', () async {
      // Arrange
      final InMemoryLeaderboardRepository inputRepository =
          InMemoryLeaderboardRepository(
            entries: <LeaderboardEntry>[_entry('awa', 'Awa', 10)],
          );
      final StreamController<void> inputChanges = StreamController<void>();
      final LeaderboardCubit inputCubit = LeaderboardCubit(
        profileId: 'awa',
        getLeaderboard: GetLeaderboardUseCase(
          repository: inputRepository,
          clock: FakeClock(quizStart),
        ),
        changes: inputChanges.stream,
      );
      await inputCubit.load();
      // Act
      inputRepository.entries = <LeaderboardEntry>[_entry('awa', 'Awa', 60)];
      inputChanges.add(null);
      await Future<void>.delayed(Duration.zero);
      // Assert
      final LeaderboardLoaded actualState =
          inputCubit.state as LeaderboardLoaded;
      expect(actualState.leaderboard.entries.single.weeklyXp, 60);
      expect(actualState.activeProfileId, 'awa');
      await inputCubit.close();
      await inputChanges.close();
    });
    test('fails with the code of the error', () async {
      // Arrange
      final LeaderboardCubit inputCubit = LeaderboardCubit(
        profileId: 'awa',
        getLeaderboard: GetLeaderboardUseCase(
          repository: _FlakyLeaderboardRepository(const <LeaderboardEntry>[]),
          clock: FakeClock(quizStart),
        ),
      );
      // Act
      await inputCubit.load();
      // Assert
      expect(
        (inputCubit.state as LeaderboardFailure).errorCode,
        AppErrorCode.cache,
      );
      await inputCubit.close();
    });
  });

  group('Leaderboard setting', () {
    testWidgets('hides the Profile card when switched off', (
      WidgetTester tester,
    ) async {
      // Arrange
      int actualOpenings = 0;
      final LeaderboardPages inputPages = buildTestLeaderboardPages(
        visibility: buildTestVisibilityRepository(),
      );
      await pumpLocalized(
        tester,
        Scaffold(
          body: Column(
            children: <Widget>[
              inputPages.buildEntryCard(onOpen: () => actualOpenings++),
              inputPages.buildVisibilitySwitch(),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Classement'));
      expect(actualOpenings, 1);
      expect(
        find.text("Qui a gagné le plus d'XP cette semaine ?"),
        findsOneWidget,
      );
      // Act
      await tester.tap(find.text('Afficher le classement'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Classement'), findsNothing);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
      await tester.tap(find.text('Afficher le classement'));
      await tester.pumpAndSettle();
      expect(find.text('Classement'), findsOneWidget);
    });
    testWidgets('keeps the card hidden after a restart', (
      WidgetTester tester,
    ) async {
      // Arrange
      final LeaderboardVisibilityRepository inputVisibility =
          buildTestVisibilityRepository();
      await inputVisibility.setShown(isShown: false);
      final LeaderboardPages inputPages = buildTestLeaderboardPages(
        visibility: inputVisibility,
      );
      // Act
      await pumpLocalized(
        tester,
        Scaffold(body: inputPages.buildEntryCard(onOpen: () {})),
      );
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Classement'), findsNothing);
    });
    test('goes back to the previous value when saving fails', () async {
      // Arrange
      final LeaderboardVisibilityRepository inputRepository =
          _ReadOnlyVisibility();
      final LeaderboardVisibilityCubit inputCubit = LeaderboardVisibilityCubit(
        get: buildTestLeaderboardUseCases(
          visibility: inputRepository,
        ).getVisibility,
        set: buildTestLeaderboardUseCases(
          visibility: inputRepository,
        ).setVisibility,
        watch: buildTestLeaderboardUseCases(
          visibility: inputRepository,
        ).watchVisibility,
      );
      await inputCubit.load();
      // Act
      await inputCubit.setShown(isShown: false);
      // Assert
      expect(
        (inputCubit.state as RewardValueLoaded<bool>).value,
        isTrue,
      );
      await inputCubit.close();
    });
  });
}
