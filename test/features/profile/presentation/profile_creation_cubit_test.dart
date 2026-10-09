import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/nickname_error.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_creation_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_creation_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_creation_status.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/profile_fixtures.dart';

void main() {
  late MockCreateProfileUseCase mockCreateProfile;
  late MockSelectProfileUseCase mockSelectProfile;
  final ProfileEntity inputCreatedProfile = buildProfile(id: 'new-id');

  setUpAll(
    () => registerFallbackValue(
      const CreateProfileParams(
        nickname: '',
        avatar: ProfileAvatar.avatar1,
        color: ProfileColor.violet,
      ),
    ),
  );

  setUp(() {
    mockCreateProfile = MockCreateProfileUseCase();
    mockSelectProfile = MockSelectProfileUseCase();
    when(
      () => mockCreateProfile.call(params: any(named: 'params')),
    ).thenAnswer((_) async => DataSuccess<ProfileEntity>(inputCreatedProfile));
    when(
      () => mockSelectProfile.call(params: any(named: 'params')),
    ).thenAnswer((_) async => DataSuccess<ProfileEntity>(inputCreatedProfile));
  });

  ProfileCreationCubit buildCubit() => ProfileCreationCubit(
    createProfile: mockCreateProfile,
    selectProfile: mockSelectProfile,
  );

  ProfileCreationState filledState(String nickname) {
    return const ProfileCreationState.initial().copyWith(nickname: nickname);
  }

  group('ProfileCreationCubit', () {
    test('starts empty with the first avatar in violet', () {
      // Act
      final ProfileCreationState actualState = buildCubit().state;
      // Assert
      expect(actualState, const ProfileCreationState.initial());
      expect(actualState.canSubmit, isFalse);
    });
    blocTest<ProfileCreationCubit, ProfileCreationState>(
      'records the nickname, avatar and color',
      build: buildCubit,
      act: (ProfileCreationCubit cubit) => cubit
        ..changeNickname('Awa')
        ..pickAvatar(ProfileAvatar.avatar5)
        ..pickColor(ProfileColor.blue),
      skip: 2,
      expect: () => <ProfileCreationState>[
        filledState(
          'Awa',
        ).copyWith(avatar: ProfileAvatar.avatar5, color: ProfileColor.blue),
      ],
    );
    blocTest<ProfileCreationCubit, ProfileCreationState>(
      'shows the nickname error instead of saving a broken nickname',
      build: buildCubit,
      seed: () => filledState('A'),
      act: (ProfileCreationCubit cubit) => cubit.submit(),
      expect: () => <Matcher>[
        isA<ProfileCreationState>()
            .having(
              (ProfileCreationState state) => state.showsNicknameError,
              'showsNicknameError',
              isTrue,
            )
            .having(
              (ProfileCreationState state) => state.nicknameError,
              'nicknameError',
              NicknameError.tooShort,
            ),
      ],
      verify: (_) => verifyNever(
        () => mockCreateProfile.call(params: any(named: 'params')),
      ),
    );
    blocTest<ProfileCreationCubit, ProfileCreationState>(
      'creates the player and makes them the active one',
      build: buildCubit,
      seed: () => filledState('Awa').copyWith(color: ProfileColor.green),
      act: (ProfileCreationCubit cubit) => cubit.submit(),
      expect: () => <ProfileCreationState>[
        filledState('Awa').copyWith(
          color: ProfileColor.green,
          status: ProfileCreationStatus.submitting,
        ),
      ],
      verify: (_) {
        final CreateProfileParams actualParams =
            verify(
                  () => mockCreateProfile.call(
                    params: captureAny(named: 'params'),
                  ),
                ).captured.single
                as CreateProfileParams;
        expect(actualParams.nickname, 'Awa');
        expect(actualParams.color, ProfileColor.green);
        verify(() => mockSelectProfile.call(params: 'new-id')).called(1);
      },
    );
    blocTest<ProfileCreationCubit, ProfileCreationState>(
      'reports a taken nickname',
      setUp: () =>
          when(
            () => mockCreateProfile.call(params: any(named: 'params')),
          ).thenAnswer(
            (_) async => const DataFailed<ProfileEntity>(ConflictException()),
          ),
      build: buildCubit,
      seed: () => filledState('Awa'),
      act: (ProfileCreationCubit cubit) => cubit.submit(),
      skip: 1,
      expect: () => <ProfileCreationState>[
        filledState('Awa').copyWith(
          status: ProfileCreationStatus.failed,
          showsNicknameError: true,
          failureCode: AppErrorCode.conflict,
        ),
      ],
      verify: (_) => verifyNever(
        () => mockSelectProfile.call(params: any(named: 'params')),
      ),
    );
    blocTest<ProfileCreationCubit, ProfileCreationState>(
      'reports a failure to open the new player',
      setUp: () =>
          when(
            () => mockSelectProfile.call(params: any(named: 'params')),
          ).thenAnswer(
            (_) async => const DataFailed<ProfileEntity>(CacheException()),
          ),
      build: buildCubit,
      seed: () => filledState('Awa'),
      act: (ProfileCreationCubit cubit) => cubit.submit(),
      skip: 1,
      expect: () => <Matcher>[
        isA<ProfileCreationState>().having(
          (ProfileCreationState state) => state.failureCode,
          'failureCode',
          AppErrorCode.cache,
        ),
      ],
    );
    blocTest<ProfileCreationCubit, ProfileCreationState>(
      'clears the failure when the nickname changes',
      build: buildCubit,
      seed: () => filledState('Awa').copyWith(
        status: ProfileCreationStatus.failed,
        failureCode: AppErrorCode.conflict,
      ),
      act: (ProfileCreationCubit cubit) => cubit.changeNickname('Awa B'),
      expect: () => <ProfileCreationState>[filledState('Awa B')],
    );
    blocTest<ProfileCreationCubit, ProfileCreationState>(
      'does nothing while the nickname is empty',
      build: buildCubit,
      seed: () => filledState('   '),
      act: (ProfileCreationCubit cubit) => cubit.submit(),
      expect: () => <ProfileCreationState>[],
    );
  });
}
