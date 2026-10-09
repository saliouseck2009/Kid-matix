import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_session_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_session_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/profile_fixtures.dart';

void main() {
  late MockProfileRepository mockRepository;
  late GetProfileSessionUseCase useCase;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetProfileSessionUseCase(repository: mockRepository);
    when(mockRepository.countProfiles).thenAnswer(
      (_) async => const DataSuccess<int>(2),
    );
    when(mockRepository.getActiveProfileId).thenAnswer(
      (_) async => const DataSuccess<String?>('profile-1'),
    );
  });

  group('GetProfileSessionUseCase', () {
    test('combines the profile count and the active player', () async {
      // Arrange
      const ProfileSessionEntity expectedSession = ProfileSessionEntity(
        profileCount: 2,
        activeProfileId: 'profile-1',
      );
      // Act
      final DataState<ProfileSessionEntity> actualState = await useCase();
      // Assert
      expect(
        (actualState as DataSuccess<ProfileSessionEntity>).data,
        expectedSession,
      );
    });
    test('fails when the profiles cannot be counted', () async {
      // Arrange
      when(mockRepository.countProfiles).thenAnswer(
        (_) async => const DataFailed<int>(CacheException()),
      );
      // Act
      final DataState<ProfileSessionEntity> actualState = await useCase();
      // Assert
      expect(
        (actualState as DataFailed<ProfileSessionEntity>).exception,
        isA<CacheException>(),
      );
    });
    test('fails when the active player cannot be read', () async {
      // Arrange
      when(mockRepository.getActiveProfileId).thenAnswer(
        (_) async => const DataFailed<String?>(CacheException()),
      );
      // Act
      final DataState<ProfileSessionEntity> actualState = await useCase();
      // Assert
      expect(
        (actualState as DataFailed<ProfileSessionEntity>).exception,
        isA<CacheException>(),
      );
    });
  });
}
