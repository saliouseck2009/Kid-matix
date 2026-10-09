import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:kid_matix/features/profile/domain/usecases/clear_active_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/delete_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_profile_changes_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_use_cases.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:mocktail/mocktail.dart';

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

/// Doubles of every use case of the Profile tab.
ProfileTabUseCases buildTabUseCases({
  GetProfileUseCase? getProfile,
  WatchProfileChangesUseCase? watchChanges,
  ClearActiveProfileUseCase? clearActiveProfile,
  DeleteProfileUseCase? deleteProfile,
}) {
  return ProfileTabUseCases(
    getProfile: getProfile ?? MockGetProfileUseCase(),
    watchChanges: watchChanges ?? MockWatchProfileChangesUseCase(),
    clearActiveProfile: clearActiveProfile ?? MockClearActiveProfileUseCase(),
    deleteProfile: deleteProfile ?? MockDeleteProfileUseCase(),
  );
}

/// Profile pages over doubles; pass the ones a test drives.
ProfilePages buildProfilePages({
  GetProfilesUseCase? getProfiles,
  GetProfileUseCase? getProfile,
  CreateProfileUseCase? createProfile,
  UpdateProfileUseCase? updateProfile,
  SelectProfileUseCase? selectProfile,
  ProfileTabUseCases? tabUseCases,
}) {
  return ProfilePages(
    getProfiles: getProfiles ?? MockGetProfilesUseCase(),
    getProfile: getProfile ?? MockGetProfileUseCase(),
    createProfile: createProfile ?? MockCreateProfileUseCase(),
    updateProfile: updateProfile ?? MockUpdateProfileUseCase(),
    selectProfile: selectProfile ?? MockSelectProfileUseCase(),
    tabUseCases: tabUseCases ?? buildTabUseCases(),
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
