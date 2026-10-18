import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/services/player_avatar_service_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/data_state_test_extension.dart';
import '../../helpers/profile_fixtures.dart';

void main() {
  late MockProfileRepository mockRepository;
  late PlayerAvatarServiceImpl service;

  setUpAll(() => registerFallbackValue(buildProfile()));

  setUp(() {
    mockRepository = MockProfileRepository();
    service = PlayerAvatarServiceImpl(repository: mockRepository);
  });

  group('PlayerAvatarServiceImpl', () {
    test('reads the nickname, avatar and color of a player', () async {
      // Arrange
      when(() => mockRepository.getProfile(profileId: 'p1')).thenAnswer(
        (_) async => DataSuccess<ProfileEntity>(
          buildProfile(id: 'p1', nickname: 'Awa'),
        ),
      );
      // Act
      final PlayerIdentity actualPlayer = (await service.readPlayer(
        profileId: 'p1',
      )).requireData;
      // Assert
      expect(
        actualPlayer,
        const PlayerIdentity(
          id: 'p1',
          nickname: 'Awa',
          avatarKey: 'avatar1',
          colorKey: 'violet',
        ),
      );
    });

    test('puts an avatar of the shop on the player', () async {
      // Arrange
      final ProfileEntity inputProfile = buildProfile(id: 'p1');
      when(
        () => mockRepository.getProfile(profileId: 'p1'),
      ).thenAnswer((_) async => DataSuccess<ProfileEntity>(inputProfile));
      when(
        () => mockRepository.updateProfile(profile: any(named: 'profile')),
      ).thenAnswer(
        (Invocation invocation) async => DataSuccess<ProfileEntity>(
          invocation.namedArguments[#profile]! as ProfileEntity,
        ),
      );
      // Act
      final DataState<void> actualResult = await service.wearAvatar(
        profileId: 'p1',
        avatarKey: 'dragon',
      );
      // Assert
      expect(actualResult, isA<DataSuccess<void>>());
      verify(
        () => mockRepository.updateProfile(
          profile: inputProfile.copyWith(avatar: ProfileAvatar.dragon),
        ),
      ).called(1);
    });

    test('refuses an unknown avatar and passes failures on', () async {
      // Arrange
      when(() => mockRepository.getProfile(profileId: 'p1')).thenAnswer(
        (_) async => const DataFailed<ProfileEntity>(NotFoundException()),
      );
      // Act
      final AppException? actualUnknown = (await service.wearAvatar(
        profileId: 'p1',
        avatarKey: 'dinosaur',
      )).exceptionOrNull;
      final AppException? actualMissing = (await service.wearAvatar(
        profileId: 'p1',
        avatarKey: 'fox',
      )).exceptionOrNull;
      final AppException? actualRead = (await service.readPlayer(
        profileId: 'p1',
      )).exceptionOrNull;
      // Assert
      expect(actualUnknown, isA<ValidationException>());
      expect(actualMissing, isA<NotFoundException>());
      expect(actualRead, isA<NotFoundException>());
    });

    test('passes a failed save on and follows the players', () async {
      // Arrange
      when(() => mockRepository.getProfile(profileId: 'p1')).thenAnswer(
        (_) async => DataSuccess<ProfileEntity>(buildProfile(id: 'p1')),
      );
      when(
        () => mockRepository.updateProfile(profile: any(named: 'profile')),
      ).thenAnswer(
        (_) async => const DataFailed<ProfileEntity>(CacheException()),
      );
      when(
        () => mockRepository.watchProfileChanges(),
      ).thenAnswer((_) => Stream<void>.value(null));
      // Act
      final AppException? actualException = (await service.wearAvatar(
        profileId: 'p1',
        avatarKey: 'fox',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
      await expectLater(service.watchChanges(), emits(null));
    });
  });
}
