import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/settings_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/settings_state.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/profile_fixtures.dart';

void main() {
  late MockUpdateSettingsUseCase mockUpdate;
  late MockResetProgressUseCase mockReset;
  late MockDeleteProfileUseCase mockDelete;

  setUp(() {
    mockUpdate = MockUpdateSettingsUseCase();
    mockReset = MockResetProgressUseCase();
    mockDelete = MockDeleteProfileUseCase();
    registerFallbackValue(const ProfileSettingsEntity.defaults(profileId: ''));
    when(
      () => mockUpdate.call(params: any(named: 'params')),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
    when(
      () => mockReset.call(params: any(named: 'params')),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
    when(
      () => mockDelete.call(params: any(named: 'params')),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
  });

  Future<SettingsCubit> loadedCubit() async {
    final SettingsCubit cubit = SettingsCubit(
      profileId: 'profile-1',
      useCases: buildSettingsUseCases(
        updateSettings: mockUpdate,
        resetProgress: mockReset,
        deleteProfile: mockDelete,
      ),
    );
    await cubit.load();
    return cubit;
  }

  group('SettingsCubit', () {
    test('reads the player and the settings', () async {
      // Act
      final SettingsCubit cubit = await loadedCubit();
      // Assert
      final SettingsLoaded actualState = cubit.state as SettingsLoaded;
      expect(actualState.nickname, 'Awa');
      expect(actualState.settings.timerMode, TimerMode.normal);
      await cubit.close();
    });
    test('saves a change and shows it', () async {
      // Arrange
      final SettingsCubit cubit = await loadedCubit();
      // Act
      await cubit.update(
        (ProfileSettingsEntity old) => old.copyWith(timerMode: TimerMode.off),
      );
      // Assert
      final ProfileSettingsEntity actualSettings =
          (cubit.state as SettingsLoaded).settings;
      expect(actualSettings.timerMode, TimerMode.off);
      verify(() => mockUpdate.call(params: actualSettings)).called(1);
      await cubit.close();
    });
    test('puts the settings back when the save fails', () async {
      // Arrange
      when(
        () => mockUpdate.call(params: any(named: 'params')),
      ).thenAnswer((_) async => const DataFailed<void>(CacheException()));
      final SettingsCubit cubit = await loadedCubit();
      // Act
      await cubit.update(
        (ProfileSettingsEntity old) => old.copyWith(isSoundEnabled: false),
      );
      // Assert
      final SettingsLoaded actualState = cubit.state as SettingsLoaded;
      expect(actualState.settings.isSoundEnabled, isTrue);
      expect(actualState.errorCode, AppErrorCode.cache);
      await cubit.close();
    });
    test('erases the progress and says so', () async {
      // Arrange
      final SettingsCubit cubit = await loadedCubit();
      // Act
      await cubit.resetProgress();
      // Assert
      expect((cubit.state as SettingsLoaded).wasReset, isTrue);
      verify(() => mockReset.call(params: 'profile-1')).called(1);
      await cubit.close();
    });
    test('deletes the player', () async {
      // Arrange
      final SettingsCubit cubit = await loadedCubit();
      // Act
      await cubit.deleteProfile();
      // Assert
      expect(cubit.state, isA<SettingsLoading>());
      verify(() => mockDelete.call(params: 'profile-1')).called(1);
      await cubit.close();
    });
    test('reports a failed deletion', () async {
      // Arrange
      when(
        () => mockDelete.call(params: any(named: 'params')),
      ).thenAnswer((_) async => const DataFailed<void>(CacheException()));
      final SettingsCubit cubit = await loadedCubit();
      // Act
      await cubit.deleteProfile();
      // Assert
      expect(
        (cubit.state as SettingsLoaded).errorCode,
        AppErrorCode.cache,
      );
      await cubit.close();
    });
  });
}
