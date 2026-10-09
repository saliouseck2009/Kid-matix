import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
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
