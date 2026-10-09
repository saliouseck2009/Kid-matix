import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';

void main() {
  final DateTime inputCreatedAt = DateTime(2026, 10, 9, 8);
  ProfileEntity createProfile() => ProfileEntity.newPlayer(
    id: 'profile-1',
    nickname: 'Awa',
    avatar: ProfileAvatar.avatar1,
    color: ProfileColor.violet,
    createdAt: inputCreatedAt,
  );

  group('ProfileEntity', () {
    test('starts a new player at level 1 with no XP', () {
      // Arrange
      const int expectedLevel = 1;
      const int expectedTotalXp = 0;
      // Act
      final ProfileEntity actualProfile = createProfile();
      // Assert
      expect(actualProfile.level, expectedLevel);
      expect(actualProfile.totalXp, expectedTotalXp);
      expect(actualProfile.lastPlayedAt, isNull);
    });
    test('is equal to a profile with the same fields', () {
      // Arrange
      final ProfileEntity inputProfile = createProfile();
      // Act
      final ProfileEntity actualProfile = createProfile();
      // Assert
      expect(actualProfile, inputProfile);
      expect(actualProfile.hashCode, inputProfile.hashCode);
    });
    test('differs from a profile with another nickname', () {
      // Arrange
      final ProfileEntity inputProfile = createProfile();
      // Act
      final ProfileEntity actualProfile = inputProfile.copyWith(
        nickname: 'Lina',
      );
      // Assert
      expect(actualProfile, isNot(inputProfile));
    });
    test('copyWith replaces only the given fields', () {
      // Arrange
      final ProfileEntity inputProfile = createProfile();
      final DateTime inputPlayedAt = DateTime(2026, 10, 10, 18);
      // Act
      final ProfileEntity actualProfile = inputProfile.copyWith(
        color: ProfileColor.green,
        totalXp: 120,
        level: 2,
        lastPlayedAt: inputPlayedAt,
      );
      // Assert
      expect(actualProfile.id, inputProfile.id);
      expect(actualProfile.nickname, inputProfile.nickname);
      expect(actualProfile.avatar, inputProfile.avatar);
      expect(actualProfile.color, ProfileColor.green);
      expect(actualProfile.totalXp, 120);
      expect(actualProfile.level, 2);
      expect(actualProfile.createdAt, inputCreatedAt);
      expect(actualProfile.lastPlayedAt, inputPlayedAt);
    });
  });
}
