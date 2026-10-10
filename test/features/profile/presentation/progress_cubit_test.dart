import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_stats_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_stats_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_progress_changes_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/progress_cubit.dart';

import '../../../helpers/fixed_progress_services.dart';

void main() {
  group('ProgressCubit', () {
    late FixedRewardService rewards;
    late FixedCrownService crowns;
    late ProgressCubit cubit;

    setUp(() {
      rewards = FixedRewardService(streak: 1);
      crowns = FixedCrownService();
      cubit = ProgressCubit(
        profileId: 'p1',
        getStats: GetProfileStatsUseCase(rewards: rewards, crowns: crowns),
        watchChanges: WatchProgressChangesUseCase(
          rewards: rewards,
          crowns: crowns,
        ),
      );
    });

    tearDown(() => cubit.close());

    test('reads the figures of the player', () async {
      // Act
      await cubit.load();
      // Assert
      expect(
        cubit.state,
        const ProfileStatsEntity(streak: 1, crownCount: 0, badgeCount: 0),
      );
    });
    test('reads them again after a quiz is rewarded', () async {
      // Arrange
      await cubit.load();
      rewards
        ..streak = 2
        ..badges = <String>{'firstStep'};
      // Act
      rewards.changes.add(null);
      await pumpEventQueue();
      // Assert
      expect(
        cubit.state,
        const ProfileStatsEntity(streak: 2, crownCount: 0, badgeCount: 1),
      );
    });
  });
}
