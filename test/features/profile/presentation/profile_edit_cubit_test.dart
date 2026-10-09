import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_edit_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_state.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_form_status.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/profile_fixtures.dart';

void main() {
  late MockGetProfileUseCase mockGetProfile;
  late MockUpdateProfileUseCase mockUpdateProfile;
  final ProfileEntity inputProfile = buildProfile();

  setUpAll(() => registerFallbackValue(buildProfile()));

  setUp(() {
    mockGetProfile = MockGetProfileUseCase();
    mockUpdateProfile = MockUpdateProfileUseCase();
    when(
      () => mockGetProfile.call(params: any(named: 'params')),
    ).thenAnswer((_) async => DataSuccess<ProfileEntity>(inputProfile));
    when(
      () => mockUpdateProfile.call(params: any(named: 'params')),
    ).thenAnswer((_) async => DataSuccess<ProfileEntity>(inputProfile));
  });

  ProfileEditCubit buildCubit() => ProfileEditCubit(
    profileId: 'profile-1',
    getProfile: mockGetProfile,
    updateProfile: mockUpdateProfile,
  );

  group('ProfileEditCubit', () {
    blocTest<ProfileEditCubit, ProfileFormState>(
      'fills the form with the stored player',
      build: buildCubit,
      act: (ProfileEditCubit cubit) => cubit.load(),
      expect: () => <ProfileFormState>[
        ProfileFormState.filled(
          nickname: inputProfile.nickname,
          avatar: inputProfile.avatar,
          color: inputProfile.color,
        ),
      ],
    );
    blocTest<ProfileEditCubit, ProfileFormState>(
      'saves the new nickname and avatar',
      build: buildCubit,
      act: (ProfileEditCubit cubit) async {
        await cubit.load();
        cubit
          ..changeNickname('Awa B')
          ..pickAvatar(ProfileAvatar.avatar9);
        await cubit.submit();
      },
      skip: 4,
      expect: () => <Matcher>[
        isA<ProfileFormState>().having(
          (ProfileFormState state) => state.status,
          'status',
          ProfileFormStatus.saved,
        ),
      ],
      verify: (_) => verify(
        () => mockUpdateProfile.call(
          params: inputProfile.copyWith(
            nickname: 'Awa B',
            avatar: ProfileAvatar.avatar9,
          ),
        ),
      ).called(1),
    );
    blocTest<ProfileEditCubit, ProfileFormState>(
      'reports a nickname another player uses',
      setUp: () =>
          when(
            () => mockUpdateProfile.call(params: any(named: 'params')),
          ).thenAnswer(
            (_) async => const DataFailed<ProfileEntity>(ConflictException()),
          ),
      build: buildCubit,
      act: (ProfileEditCubit cubit) async {
        await cubit.load();
        await cubit.submit();
      },
      skip: 2,
      expect: () => <Matcher>[
        isA<ProfileFormState>().having(
          (ProfileFormState state) => state.failureCode,
          'failureCode',
          AppErrorCode.conflict,
        ),
      ],
    );
    blocTest<ProfileEditCubit, ProfileFormState>(
      'reports a player that cannot be read',
      setUp: () =>
          when(
            () => mockGetProfile.call(params: any(named: 'params')),
          ).thenAnswer(
            (_) async => const DataFailed<ProfileEntity>(NotFoundException()),
          ),
      build: buildCubit,
      act: (ProfileEditCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<ProfileFormState>().having(
          (ProfileFormState state) => state.failureCode,
          'failureCode',
          AppErrorCode.notFound,
        ),
      ],
    );
    blocTest<ProfileEditCubit, ProfileFormState>(
      'saves nothing before the player is loaded',
      build: buildCubit,
      act: (ProfileEditCubit cubit) => cubit.submit(),
      expect: () => <ProfileFormState>[],
      verify: (_) => verifyNever(
        () => mockUpdateProfile.call(params: any(named: 'params')),
      ),
    );
  });
}
