import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/delete_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/profile_fixtures.dart';

void main() {
  late MockProfileRepository mockRepository;

  setUp(() => mockRepository = MockProfileRepository());

  group('GetProfilesUseCase', () {
    test('returns the profiles of the repository', () async {
      // Arrange
      final List<ProfileEntity> expectedProfiles = <ProfileEntity>[
        buildProfile(),
        buildProfile(id: 'profile-2', nickname: 'Lina'),
      ];
      when(mockRepository.getProfiles).thenAnswer(
        (_) async => DataSuccess<List<ProfileEntity>>(expectedProfiles),
      );
      final GetProfilesUseCase useCase = GetProfilesUseCase(
        repository: mockRepository,
      );
      // Act
      final DataState<List<ProfileEntity>> actualState = await useCase();
      // Assert
      expect(
        (actualState as DataSuccess<List<ProfileEntity>>).data,
        expectedProfiles,
      );
    });
  });

  group('DeleteProfileUseCase', () {
    test('deletes the given profile', () async {
      // Arrange
      when(
        () => mockRepository.deleteProfile(profileId: any(named: 'profileId')),
      ).thenAnswer((_) async => const DataSuccess<void>(null));
      final DeleteProfileUseCase useCase = DeleteProfileUseCase(
        repository: mockRepository,
      );
      // Act
      final DataState<void> actualState = await useCase(params: 'profile-1');
      // Assert
      expect(actualState, isA<DataSuccess<void>>());
      verify(() => mockRepository.deleteProfile(profileId: 'profile-1'))
          .called(1);
    });
  });

  group('SelectProfileUseCase', () {
    late SelectProfileUseCase useCase;

    setUp(() {
      when(
        () => mockRepository.setActiveProfileId(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer((_) async => const DataSuccess<void>(null));
      useCase = SelectProfileUseCase(repository: mockRepository);
    });

    test('remembers the chosen player and returns it', () async {
      // Arrange
      final ProfileEntity expectedProfile = buildProfile();
      when(
        () => mockRepository.getProfile(profileId: any(named: 'profileId')),
      ).thenAnswer((_) async => DataSuccess<ProfileEntity>(expectedProfile));
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: 'profile-1',
      );
      // Assert
      expect((actualState as DataSuccess<ProfileEntity>).data, expectedProfile);
      verify(
        () => mockRepository.setActiveProfileId(profileId: 'profile-1'),
      ).called(1);
    });
    test('does not remember a profile that does not exist', () async {
      // Arrange
      when(
        () => mockRepository.getProfile(profileId: any(named: 'profileId')),
      ).thenAnswer(
        (_) async => const DataFailed<ProfileEntity>(NotFoundException()),
      );
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: 'missing',
      );
      // Assert
      expect(
        (actualState as DataFailed<ProfileEntity>).exception,
        isA<NotFoundException>(),
      );
      verifyNever(
        () => mockRepository.setActiveProfileId(
          profileId: any(named: 'profileId'),
        ),
      );
    });
    test('reports a failure to remember the player', () async {
      // Arrange
      const CacheException expectedException = CacheException();
      when(
        () => mockRepository.getProfile(profileId: any(named: 'profileId')),
      ).thenAnswer((_) async => DataSuccess<ProfileEntity>(buildProfile()));
      when(
        () => mockRepository.setActiveProfileId(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer((_) async => const DataFailed<void>(expectedException));
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: 'profile-1',
      );
      // Assert
      expect(
        (actualState as DataFailed<ProfileEntity>).exception,
        expectedException,
      );
    });
  });
}
