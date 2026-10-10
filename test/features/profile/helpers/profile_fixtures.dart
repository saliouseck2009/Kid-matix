import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/presentation/bloc/settings_use_cases.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/reset_progress_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_settings_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_settings_use_case.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:kid_matix/features/profile/domain/usecases/clear_active_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/delete_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_stats_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_profile_changes_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_progress_changes_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_use_cases.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixed_progress_services.dart';

export '../../../helpers/fixed_progress_services.dart';

/// Test double of [ProfileRepository].
final class MockProfileRepository extends Mock implements ProfileRepository {}

/// Test double of [GetProfilesUseCase].
final class MockGetProfilesUseCase extends Mock implements GetProfilesUseCase {}

/// Test double of [CreateProfileUseCase].
final class MockCreateProfileUseCase extends Mock
    implements CreateProfileUseCase {}

/// Test double of [SelectProfileUseCase].
final class MockSelectProfileUseCase extends Mock
    implements SelectProfileUseCase {}

/// Test double of [GetProfileUseCase].
final class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

/// Test double of [UpdateProfileUseCase].
final class MockUpdateProfileUseCase extends Mock
    implements UpdateProfileUseCase {}

/// Test double of [WatchProfileChangesUseCase].
final class MockWatchProfileChangesUseCase extends Mock
    implements WatchProfileChangesUseCase {}

/// Test double of [ClearActiveProfileUseCase].
final class MockClearActiveProfileUseCase extends Mock
    implements ClearActiveProfileUseCase {}

/// Test double of [DeleteProfileUseCase].
final class MockDeleteProfileUseCase extends Mock
    implements DeleteProfileUseCase {}

/// Test double of [GetSettingsUseCase].
final class MockGetSettingsUseCase extends Mock implements GetSettingsUseCase {}

/// Test double of [UpdateSettingsUseCase].
final class MockUpdateSettingsUseCase extends Mock
    implements UpdateSettingsUseCase {}

/// Test double of [ResetProgressUseCase].
final class MockResetProgressUseCase extends Mock
    implements ResetProgressUseCase {}

/// Doubles of every use case of the settings screen: the player of
/// [buildProfile] with the default settings, every write succeeding.
SettingsUseCases buildSettingsUseCases({
  GetSettingsUseCase? getSettings,
  UpdateSettingsUseCase? updateSettings,
  ResetProgressUseCase? resetProgress,
  DeleteProfileUseCase? deleteProfile,
}) {
  registerFallbackValue(const ProfileSettingsEntity.defaults(profileId: ''));
  final MockGetSettingsUseCase quietSettings = MockGetSettingsUseCase();
  when(() => quietSettings.call(params: any(named: 'params'))).thenAnswer(
    (Invocation invocation) async => DataSuccess<ProfileSettingsEntity>(
      ProfileSettingsEntity.defaults(
        profileId: invocation.namedArguments[#params] as String,
      ),
    ),
  );
  final MockUpdateSettingsUseCase quietUpdate = MockUpdateSettingsUseCase();
  when(
    () => quietUpdate.call(params: any(named: 'params')),
  ).thenAnswer((_) async => const DataSuccess<void>(null));
  final MockResetProgressUseCase quietReset = MockResetProgressUseCase();
  when(
    () => quietReset.call(params: any(named: 'params')),
  ).thenAnswer((_) async => const DataSuccess<void>(null));
  final MockDeleteProfileUseCase quietDelete = MockDeleteProfileUseCase();
  when(
    () => quietDelete.call(params: any(named: 'params')),
  ).thenAnswer((_) async => const DataSuccess<void>(null));
  return SettingsUseCases(
    getProfile: _quietGetProfile(),
    getSettings: getSettings ?? quietSettings,
    updateSettings: updateSettings ?? quietUpdate,
    resetProgress: resetProgress ?? quietReset,
    deleteProfile: deleteProfile ?? quietDelete,
  );
}

/// Doubles of every use case of the Profile tab.
ProfileTabUseCases buildTabUseCases({
  GetProfileUseCase? getProfile,
  WatchProfileChangesUseCase? watchChanges,
  ClearActiveProfileUseCase? clearActiveProfile,
  FixedRewardService? rewards,
  FixedCrownService? crowns,
}) {
  final FixedRewardService rewardService = rewards ?? FixedRewardService();
  final FixedCrownService crownService = crowns ?? FixedCrownService();
  return ProfileTabUseCases(
    getProfile: getProfile ?? _quietGetProfile(),
    watchChanges: watchChanges ?? _quietWatch(),
    clearActiveProfile: clearActiveProfile ?? MockClearActiveProfileUseCase(),
    getStats: GetProfileStatsUseCase(
      rewards: rewardService,
      crowns: crownService,
    ),
    watchProgress: WatchProgressChangesUseCase(
      rewards: rewardService,
      crowns: crownService,
    ),
  );
}

/// A [GetProfileUseCase] double that returns [buildProfile].
GetProfileUseCase _quietGetProfile() {
  final MockGetProfileUseCase mock = MockGetProfileUseCase();
  when(
    () => mock.call(params: any(named: 'params')),
  ).thenAnswer((_) async => DataSuccess<ProfileEntity>(buildProfile()));
  return mock;
}

/// A [WatchProfileChangesUseCase] double that never emits.
WatchProfileChangesUseCase _quietWatch() {
  final MockWatchProfileChangesUseCase mock = MockWatchProfileChangesUseCase();
  when(mock.call).thenAnswer((_) => const Stream<void>.empty());
  return mock;
}

/// Profile pages over doubles; pass the ones a test drives.
ProfilePages buildProfilePages({
  GetProfilesUseCase? getProfiles,
  GetProfileUseCase? getProfile,
  CreateProfileUseCase? createProfile,
  UpdateProfileUseCase? updateProfile,
  SelectProfileUseCase? selectProfile,
  ProfileTabUseCases? tabUseCases,
  SettingsUseCases? settingsUseCases,
}) {
  return ProfilePages(
    getProfiles: getProfiles ?? MockGetProfilesUseCase(),
    getProfile: getProfile ?? MockGetProfileUseCase(),
    createProfile: createProfile ?? MockCreateProfileUseCase(),
    updateProfile: updateProfile ?? MockUpdateProfileUseCase(),
    selectProfile: selectProfile ?? MockSelectProfileUseCase(),
    tabUseCases: tabUseCases ?? buildTabUseCases(),
    settingsUseCases: settingsUseCases ?? buildSettingsUseCases(),
  );
}

/// Returns a new player named [nickname], created on 9 October 2026.
ProfileEntity buildProfile({
  String id = 'profile-1',
  String nickname = 'Awa',
}) {
  return ProfileEntity.newPlayer(
    id: id,
    nickname: nickname,
    avatar: ProfileAvatar.avatar1,
    color: ProfileColor.violet,
    createdAt: DateTime(2026, 10, 9, 8),
  );
}
