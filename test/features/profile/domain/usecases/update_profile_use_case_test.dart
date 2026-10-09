import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/nickname_checker.dart';
import 'package:kid_matix/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/profile_fixtures.dart';

void main() {
  late MockProfileRepository mockRepository;
  late UpdateProfileUseCase useCase;

  setUpAll(() => registerFallbackValue(buildProfile()));

  setUp(() {
    mockRepository = MockProfileRepository();
    when(
      () => mockRepository.isNicknameTaken(
        nickname: any(named: 'nickname'),
        excludedProfileId: any(named: 'excludedProfileId'),
      ),
    ).thenAnswer((_) async => const DataSuccess<bool>(false));
    when(
      () => mockRepository.updateProfile(profile: any(named: 'profile')),
    ).thenAnswer(
      (Invocation invocation) async => DataSuccess<ProfileEntity>(
        invocation.namedArguments[#profile] as ProfileEntity,
      ),
    );
    useCase = UpdateProfileUseCase(
      repository: mockRepository,
      nicknameChecker: NicknameChecker(repository: mockRepository),
    );
  });

  group('UpdateProfileUseCase', () {
    test('saves the renamed player with a cleaned nickname', () async {
      // Arrange
      final ProfileEntity inputProfile = buildProfile(nickname: ' Lina  B ');
      final ProfileEntity expectedProfile = buildProfile(nickname: 'Lina B');
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: inputProfile,
      );
      // Assert
      expect(actualState, isA<DataSuccess<ProfileEntity>>());
      verify(
        () => mockRepository.updateProfile(profile: expectedProfile),
      ).called(1);
    });
    test("ignores the player's own nickname in the uniqueness check", () async {
      // Arrange
      final ProfileEntity inputProfile = buildProfile(id: 'profile-7');
      // Act
      await useCase(params: inputProfile);
      // Assert
      verify(
        () => mockRepository.isNicknameTaken(
          nickname: inputProfile.nickname,
          excludedProfileId: 'profile-7',
        ),
      ).called(1);
    });
    test('refuses a nickname another player uses, without saving', () async {
      // Arrange
      when(
        () => mockRepository.isNicknameTaken(
          nickname: any(named: 'nickname'),
          excludedProfileId: any(named: 'excludedProfileId'),
        ),
      ).thenAnswer((_) async => const DataSuccess<bool>(true));
      // Act
      final DataState<ProfileEntity> actualState = await useCase(
        params: buildProfile(),
      );
      // Assert
      expect(
        (actualState as DataFailed<ProfileEntity>).exception,
        isA<ConflictException>(),
      );
      verifyNever(
        () => mockRepository.updateProfile(profile: any(named: 'profile')),
      );
    });
  });
}
