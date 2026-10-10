import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_settings_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_settings_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_profile_changes_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/profile_fixtures.dart';

const ProfileSettingsEntity _settings = ProfileSettingsEntity.defaults(
  profileId: 'profile-1',
);

void main() {
  late MockProfileRepository mockRepository;

  setUpAll(() => registerFallbackValue(_settings));

  setUp(() => mockRepository = MockProfileRepository());

  group('GetSettingsUseCase', () {
    test('reads the settings of the given player', () async {
      // Arrange
      when(
        () => mockRepository.getProfileSettings(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer(
        (_) async => const DataSuccess<ProfileSettingsEntity>(_settings),
      );
      final GetSettingsUseCase useCase = GetSettingsUseCase(
        repository: mockRepository,
      );
      // Act
      final DataState<ProfileSettingsEntity> actualState = await useCase(
        params: 'profile-1',
      );
      // Assert
      expect(
        (actualState as DataSuccess<ProfileSettingsEntity>).data,
        _settings,
      );
      verify(
        () => mockRepository.getProfileSettings(profileId: 'profile-1'),
      ).called(1);
    });
  });

  group('UpdateSettingsUseCase', () {
    test('saves the given settings', () async {
      // Arrange
      when(
        () => mockRepository.updateProfileSettings(
          settings: any(named: 'settings'),
        ),
      ).thenAnswer((_) async => const DataSuccess<void>(null));
      final UpdateSettingsUseCase useCase = UpdateSettingsUseCase(
        repository: mockRepository,
      );
      // Act
      final DataState<void> actualState = await useCase(params: _settings);
      // Assert
      expect(actualState, isA<DataSuccess<void>>());
      verify(
        () => mockRepository.updateProfileSettings(settings: _settings),
      ).called(1);
    });
  });

  group('WatchProfileChangesUseCase', () {
    test('forwards the changes of the repository', () async {
      // Arrange
      when(
        mockRepository.watchProfileChanges,
      ).thenAnswer((_) => Stream<void>.value(null));
      final WatchProfileChangesUseCase useCase = WatchProfileChangesUseCase(
        repository: mockRepository,
      );
      // Act
      final List<void> actualEvents = await useCase().toList();
      // Assert
      expect(actualEvents, hasLength(1));
    });
  });
}
