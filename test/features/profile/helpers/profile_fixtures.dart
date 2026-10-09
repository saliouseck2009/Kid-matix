import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/repositories/profile_repository.dart';
import 'package:mocktail/mocktail.dart';

/// Test double of [ProfileRepository].
final class MockProfileRepository extends Mock implements ProfileRepository {}

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
