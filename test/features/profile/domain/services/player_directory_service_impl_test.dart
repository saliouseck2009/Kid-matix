import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/services/player_directory_service_impl.dart';
import 'package:kid_matix/features/profile/presentation/widgets/profile_avatar_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/data_state_test_extension.dart';
import '../../helpers/profile_fixtures.dart';

void main() {
  late MockGetProfilesUseCase mockGetProfiles;

  setUp(() => mockGetProfiles = MockGetProfilesUseCase());

  group('PlayerDirectoryServiceImpl', () {
    test('lists the players with their avatar and color names', () async {
      // Arrange
      when(() => mockGetProfiles()).thenAnswer(
        (_) async => DataSuccess<List<ProfileEntity>>(<ProfileEntity>[
          buildProfile(id: 'p1', nickname: 'Awa'),
        ]),
      );
      // Act
      final List<PlayerIdentity> actualPlayers =
          (await PlayerDirectoryServiceImpl(
            getProfiles: mockGetProfiles,
          ).readPlayers()).requireData;
      // Assert
      expect(actualPlayers, const <PlayerIdentity>[
        PlayerIdentity(
          id: 'p1',
          nickname: 'Awa',
          avatarKey: 'avatar1',
          colorKey: 'violet',
        ),
      ]);
    });
    test('passes a failure on', () async {
      // Arrange
      when(() => mockGetProfiles()).thenAnswer(
        (_) async => const DataFailed<List<ProfileEntity>>(CacheException()),
      );
      // Act
      final AppException? actualException = (await PlayerDirectoryServiceImpl(
        getProfiles: mockGetProfiles,
      ).readPlayers()).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  group('ProfilePages.buildAvatar', () {
    testWidgets('draws the avatar named, the first one for an unknown name', (
      WidgetTester tester,
    ) async {
      // Arrange
      const PlayerIdentity inputPlayer = PlayerIdentity(
        id: 'p1',
        nickname: 'Awa',
        avatarKey: 'avatar4',
        colorKey: 'unknown',
      );
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: buildProfilePages().buildAvatar(player: inputPlayer, size: 40),
        ),
      );
      // Assert
      final ProfileAvatarView actualView = tester.widget<ProfileAvatarView>(
        find.byType(ProfileAvatarView),
      );
      expect(actualView.avatar, ProfileAvatar.avatar4);
      expect(actualView.color, ProfileColor.values.first);
    });
  });

  test('PlayerIdentity compares by value', () {
    // Arrange
    const PlayerIdentity inputPlayer = PlayerIdentity(
      id: 'p1',
      nickname: 'Awa',
      avatarKey: 'avatar1',
      colorKey: 'violet',
    );
    // Act
    final PlayerIdentity actualCopy = inputPlayer.copyWith(nickname: 'Ali');
    // Assert
    expect(actualCopy, isNot(inputPlayer));
    expect(actualCopy.copyWith(nickname: 'Awa'), inputPlayer);
    expect(actualCopy.copyWith(nickname: 'Awa').hashCode, inputPlayer.hashCode);
    expect(inputPlayer.toString(), contains('Awa'));
  });
}
