import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profiles_bloc.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profiles_event.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profiles_state.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/profile_fixtures.dart';

final class _MockGetProfiles extends Mock implements GetProfilesUseCase {}

final class _MockSelectProfile extends Mock implements SelectProfileUseCase {}

List<ProfileEntity> _buildProfiles(int count) {
  return List<ProfileEntity>.generate(
    count,
    (int index) => buildProfile(id: 'p-$index', nickname: 'Joueur $index'),
  );
}

void main() {
  late _MockGetProfiles mockGetProfiles;
  late _MockSelectProfile mockSelectProfile;

  setUp(() {
    mockGetProfiles = _MockGetProfiles();
    mockSelectProfile = _MockSelectProfile();
  });

  ProfilesBloc buildBloc() => ProfilesBloc(
    getProfiles: mockGetProfiles,
    selectProfile: mockSelectProfile,
  );

  void stubProfiles(List<ProfileEntity> profiles) {
    when(mockGetProfiles.call).thenAnswer(
      (_) async => DataSuccess<List<ProfileEntity>>(profiles),
    );
  }

  group('ProfilesBloc', () {
    blocTest<ProfilesBloc, ProfilesState>(
      'loads the players and allows one more below ten',
      setUp: () => stubProfiles(_buildProfiles(3)),
      build: buildBloc,
      act: (ProfilesBloc bloc) => bloc.add(const ProfilesRequested()),
      expect: () => <Matcher>[
        isA<ProfilesLoading>(),
        isA<ProfilesLoaded>()
            .having(
              (ProfilesLoaded state) => state.profiles.length,
              'profiles',
              3,
            )
            .having(
              (ProfilesLoaded state) => state.canAddProfile,
              'canAddProfile',
              isTrue,
            ),
      ],
    );
    blocTest<ProfilesBloc, ProfilesState>(
      'forbids an eleventh player',
      setUp: () => stubProfiles(_buildProfiles(10)),
      build: buildBloc,
      act: (ProfilesBloc bloc) => bloc.add(const ProfilesRequested()),
      expect: () => <Matcher>[
        isA<ProfilesLoading>(),
        isA<ProfilesLoaded>().having(
          (ProfilesLoaded state) => state.canAddProfile,
          'canAddProfile',
          isFalse,
        ),
      ],
    );
    blocTest<ProfilesBloc, ProfilesState>(
      'reports a loading failure with its code',
      setUp: () => when(mockGetProfiles.call).thenAnswer(
        (_) async => const DataFailed<List<ProfileEntity>>(CacheException()),
      ),
      build: buildBloc,
      act: (ProfilesBloc bloc) => bloc.add(const ProfilesRequested()),
      expect: () => <Matcher>[
        isA<ProfilesLoading>(),
        isA<ProfilesFailure>().having(
          (ProfilesFailure state) => state.errorCode,
          'errorCode',
          AppErrorCode.cache,
        ),
      ],
    );
    blocTest<ProfilesBloc, ProfilesState>(
      'selects the tapped player and waits for the router',
      setUp: () => when(
        () => mockSelectProfile.call(params: any(named: 'params')),
      ).thenAnswer((_) async => DataSuccess<ProfileEntity>(buildProfile())),
      build: buildBloc,
      act: (ProfilesBloc bloc) =>
          bloc.add(const ProfileSelected(profileId: 'profile-1')),
      expect: () => <Matcher>[isA<ProfilesLoading>()],
      verify: (_) => verify(
        () => mockSelectProfile.call(params: 'profile-1'),
      ).called(1),
    );
    blocTest<ProfilesBloc, ProfilesState>(
      'reports a selection failure with its code',
      setUp: () =>
          when(
            () => mockSelectProfile.call(params: any(named: 'params')),
          ).thenAnswer(
            (_) async => const DataFailed<ProfileEntity>(NotFoundException()),
          ),
      build: buildBloc,
      act: (ProfilesBloc bloc) =>
          bloc.add(const ProfileSelected(profileId: 'missing')),
      expect: () => <Matcher>[
        isA<ProfilesLoading>(),
        isA<ProfilesFailure>().having(
          (ProfilesFailure state) => state.errorCode,
          'errorCode',
          AppErrorCode.notFound,
        ),
      ],
    );
  });
}
