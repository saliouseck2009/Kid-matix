import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/services/reward_service_impl.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_badges_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_player_level_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_streak_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_reward_changes_use_case.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../quiz/helpers/quiz_fixtures.dart';
import '../../../helpers/test_reward_pages.dart';

void main() {
  test('reads the level, the streak and the badges of a player', () async {
    // Arrange
    final InMemoryRewardRepository inputRewards = InMemoryRewardRepository(
      xpEarned: 1000,
      streak: StreakEntity(
        current: 4,
        best: 6,
        lastPlayedDay: DateTime(2026, 10, 10),
      ),
      badges: <BadgeUnlockEntity>[
        BadgeUnlockEntity(badgeKey: 'regular', unlockedAt: DateTime(2026)),
      ],
    );
    final RewardServiceImpl service = RewardServiceImpl(
      getLevel: GetPlayerLevelUseCase(repository: inputRewards),
      getBadges: GetBadgesUseCase(repository: inputRewards),
      getStreak: GetStreakUseCase(
        repository: inputRewards,
        clock: FakeClock(DateTime(2026, 10, 10, 18)),
      ),
      watchChanges: WatchRewardChangesUseCase(repository: inputRewards),
    );
    // Act
    final int actualLevel = (await service.readLevel(profileId: 'p1'))
        .requireData;
    final Set<String> actualBadges = (await service.readBadgeKeys(
      profileId: 'p1',
    )).requireData;
    final int actualStreak = (await service.readStreak(
      profileId: 'p1',
    )).requireData;
    // Assert
    expect(actualLevel, 5);
    expect(actualBadges, <String>{'regular'});
    expect(actualStreak, 4);
  });
}
