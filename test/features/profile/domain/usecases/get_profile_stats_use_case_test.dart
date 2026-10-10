import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_stats_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_stats_use_case.dart';

import '../../../../helpers/data_state_test_extension.dart';
import '../../../../helpers/fixed_progress_services.dart';

void main() {
  group('GetProfileStatsUseCase', () {
    test('gathers the streak, the crowns and the badges', () async {
      // Arrange
      final GetProfileStatsUseCase useCase = GetProfileStatsUseCase(
        rewards: FixedRewardService(
          streak: 6,
          badges: <String>{'firstStep', 'perfect'},
        ),
        crowns: FixedCrownService(crowns: 3),
      );
      // Act
      final ProfileStatsEntity actualStats = (await useCase(
        params: 'p1',
      )).requireData;
      // Assert
      expect(
        actualStats,
        const ProfileStatsEntity(streak: 6, crownCount: 3, badgeCount: 2),
      );
    });
    test('fails when the rewards cannot be read', () async {
      // Arrange
      final FixedRewardService inputRewards = FixedRewardService()
        ..failure = const CacheException(message: 'down');
      final GetProfileStatsUseCase useCase = GetProfileStatsUseCase(
        rewards: inputRewards,
        crowns: FixedCrownService(),
      );
      // Act
      final AppException? actualException = (await useCase(
        params: 'p1',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });
}
