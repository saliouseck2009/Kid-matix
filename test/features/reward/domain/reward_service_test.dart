import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/services/reward_service_impl.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_badges_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/get_player_level_use_case.dart';
import 'package:kid_matix/features/reward/domain/usecases/watch_reward_changes_use_case.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/test_reward_pages.dart';

void main() {
  test('reads the level and the badges of a player', () async {
    // Arrange
    final InMemoryRewardRepository inputRewards = InMemoryRewardRepository(
      xpEarned: 1000,
      badges: <BadgeUnlockEntity>[
        BadgeUnlockEntity(badgeKey: 'regular', unlockedAt: DateTime(2026)),
      ],
    );
    final RewardServiceImpl service = RewardServiceImpl(
      getLevel: GetPlayerLevelUseCase(repository: inputRewards),
      getBadges: GetBadgesUseCase(repository: inputRewards),
      watchChanges: WatchRewardChangesUseCase(repository: inputRewards),
    );
    // Act
    final int actualLevel = (await service.readLevel(profileId: 'p1'))
        .requireData;
    final Set<String> actualBadges = (await service.readBadgeKeys(
      profileId: 'p1',
    )).requireData;
    // Assert
    expect(actualLevel, 5);
    expect(actualBadges, <String>{'regular'});
  });
}
