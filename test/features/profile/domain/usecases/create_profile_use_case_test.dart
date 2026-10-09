import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_limits.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/nickname_checker.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/profile_fixtures.dart';

final class _MockIdGenerator extends Mock implements IdGenerator {}

final class _MockClock extends Mock implements Clock {}

void main() {
  late MockProfileRepository mockRepository;
  late CreateProfileUseCase useCase;
  final DateTime inputNow = DateTime(2026, 10, 9, 8);
  const CreateProfileParams inputParams = CreateProfileParams(
    nickname: '  Awa  ',
    avatar: ProfileAvatar.avatar3,
    color: ProfileColor.green,
  );

  setUpAll(() => registerFallbackValue(buildProfile()));

  setUp(() {
    mockRepository = MockProfileRepository();
    final _MockIdGenerator mockIdGenerator = _MockIdGenerator();
    final _MockClock mockClock = _MockClock();
    when(mockIdGenerator.generateId).thenReturn('new-id');
    when(mockClock.now).thenReturn(inputNow);
    when(mockRepository.countProfiles).thenAnswer(
      (_) async => const DataSuccess<int>(3),
    );
    when(
      () => mockRepository.isNicknameTaken(
        nickname: any(named: 'nickname'),
        excludedProfileId: any(named: 'excludedProfileId'),
      ),
    ).thenAnswer((_) async => const DataSuccess<bool>(false));
    when(
      () => mockRepository.createProfile(profile: any(named: 'profile')),
    ).thenAnswer(
      (Invocation invocation) async => DataSuccess<ProfileEntity>(
        invocation.namedArguments[#profile] as ProfileEntity,
      ),
    );
    useCase = CreateProfileUseCase(
      repository: mockRepository,
      nicknameChecker: NicknameChecker(repository: mockRepository),
      idGenerator: mockIdGenerator,
      clock: mockClock,
    );
  });

  group('CreateProfileUseCase', () {
    test('stores a new player with a cleaned nickname', () async {
      // Arrange
      final ProfileEntity expectedProfile = ProfileEntity.newPlayer(
        id: 'new-id',
        nickname: 'Awa',
        avatar: ProfileAvatar.avatar3,
        color: ProfileColor.green,
        createdAt: inputNow,
      );
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: inputParams,
      );
      // Assert
      expect(actualState, isA<DataSuccess<ProfileEntity>>());
      verify(
        () => mockRepository.createProfile(profile: expectedProfile),
      ).called(1);
    });
    test('refuses an eleventh profile', () async {
      // Arrange
      when(mockRepository.countProfiles).thenAnswer(
        (_) async => const DataSuccess<int>(ProfileLimits.maxProfiles),
      );
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: inputParams,
      );
      // Assert
      expect(
        (actualState as DataFailed<ProfileEntity>).exception,
        isA<LimitReachedException>(),
      );
      verifyNever(
        () => mockRepository.createProfile(profile: any(named: 'profile')),
      );
    });
    test('accepts the tenth profile', () async {
      // Arrange
      when(mockRepository.countProfiles).thenAnswer(
        (_) async => const DataSuccess<int>(ProfileLimits.maxProfiles - 1),
      );
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: inputParams,
      );
      // Assert
      expect(actualState, isA<DataSuccess<ProfileEntity>>());
    });
    test('refuses a taken nickname without storing anything', () async {
      // Arrange
      when(
        () => mockRepository.isNicknameTaken(
          nickname: any(named: 'nickname'),
          excludedProfileId: any(named: 'excludedProfileId'),
        ),
      ).thenAnswer((_) async => const DataSuccess<bool>(true));
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: inputParams,
      );
      // Assert
      expect(
        (actualState as DataFailed<ProfileEntity>).exception,
        isA<ConflictException>(),
      );
      verifyNever(
        () => mockRepository.createProfile(profile: any(named: 'profile')),
      );
    });
    test('refuses a nickname that breaks the rules', () async {
      // Arrange
      const CreateProfileParams inputInvalidParams = CreateProfileParams(
        nickname: 'A!',
        avatar: ProfileAvatar.avatar1,
        color: ProfileColor.violet,
      );
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: inputInvalidParams,
      );
      // Assert
      expect(
        (actualState as DataFailed<ProfileEntity>).exception,
        isA<ValidationException>(),
      );
    });
    test('forwards a failure to count the profiles', () async {
      // Arrange
      const CacheException expectedException = CacheException();
      when(mockRepository.countProfiles).thenAnswer(
        (_) async => const DataFailed<int>(expectedException),
      );
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: inputParams,
      );
      // Assert
      expect(
        (actualState as DataFailed<ProfileEntity>).exception,
        expectedException,
      );
    });
  });
}
