import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_cubit.dart';
import 'package:kid_matix/features/profile/presentation/bloc/profile_tab_state.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/profile_fixtures.dart';

void main() {
  late MockGetProfileUseCase mockGetProfile;
  late MockClearActiveProfileUseCase mockClearActive;
  late MockDeleteProfileUseCase mockDelete;
  late StreamController<void> changes;

  setUp(() {
    mockGetProfile = MockGetProfileUseCase();
    mockClearActive = MockClearActiveProfileUseCase();
    mockDelete = MockDeleteProfileUseCase();
    changes = StreamController<void>.broadcast();
    when(
      () => mockGetProfile.call(params: any(named: 'params')),
    ).thenAnswer((_) async => DataSuccess<ProfileEntity>(buildProfile()));
    when(
      mockClearActive.call,
    ).thenAnswer((_) async => const DataSuccess<void>(null));
    when(
      () => mockDelete.call(params: any(named: 'params')),
    ).thenAnswer((_) async => const DataSuccess<void>(null));
  });

  tearDown(() => changes.close());

  ProfileTabCubit buildCubit() {
    final MockWatchProfileChangesUseCase mockWatch =
        MockWatchProfileChangesUseCase();
    when(mockWatch.call).thenAnswer((_) => changes.stream);
    return ProfileTabCubit(
      profileId: 'profile-1',
      useCases: buildTabUseCases(
        getProfile: mockGetProfile,
        watchChanges: mockWatch,
        clearActiveProfile: mockClearActive,
        deleteProfile: mockDelete,
      ),
    );
  }

  group('ProfileTabCubit', () {
    blocTest<ProfileTabCubit, ProfileTabState>(
      'shows the active player',
      build: buildCubit,
      act: (ProfileTabCubit cubit) => cubit.load(),
      expect: () => <Matcher>[
        isA<ProfileTabLoading>(),
        isA<ProfileTabLoaded>().having(
          (ProfileTabLoaded state) => state.profile.nickname,
          'nickname',
          'Awa',
        ),
      ],
    );
    blocTest<ProfileTabCubit, ProfileTabState>(
      'shows the new nickname after an edit',
      build: buildCubit,
      act: (ProfileTabCubit cubit) async {
        await cubit.load();
        when(() => mockGetProfile.call(params: any(named: 'params')))
            .thenAnswer(
              (_) async =>
                  DataSuccess<ProfileEntity>(buildProfile(nickname: 'Awa B')),
            );
        changes.add(null);
        await pumpEventQueue();
      },
      skip: 2,
      expect: () => <Matcher>[
        isA<ProfileTabLoaded>().having(
          (ProfileTabLoaded state) => state.profile.nickname,
          'nickname',
          'Awa B',
        ),
      ],
    );
    blocTest<ProfileTabCubit, ProfileTabState>(
      'lets another child play without reloading the player',
      build: buildCubit,
      act: (ProfileTabCubit cubit) async {
        await cubit.load();
        await cubit.switchPlayer();
        changes.add(null);
        await pumpEventQueue();
      },
      skip: 2,
      expect: () => <Matcher>[isA<ProfileTabLoading>()],
      verify: (_) => verify(mockClearActive.call).called(1),
    );
    blocTest<ProfileTabCubit, ProfileTabState>(
      'deletes the player',
      build: buildCubit,
      act: (ProfileTabCubit cubit) async {
        await cubit.load();
        await cubit.deleteProfile();
      },
      skip: 2,
      expect: () => <Matcher>[isA<ProfileTabLoading>()],
      verify: (_) =>
          verify(() => mockDelete.call(params: 'profile-1')).called(1),
    );
    blocTest<ProfileTabCubit, ProfileTabState>(
      'reports a failed deletion',
      setUp: () => when(
        () => mockDelete.call(params: any(named: 'params')),
      ).thenAnswer((_) async => const DataFailed<void>(CacheException())),
      build: buildCubit,
      act: (ProfileTabCubit cubit) => cubit.deleteProfile(),
      expect: () => <Matcher>[
        isA<ProfileTabLoading>(),
        isA<ProfileTabFailure>().having(
          (ProfileTabFailure state) => state.errorCode,
          'errorCode',
          AppErrorCode.cache,
        ),
      ],
    );
  });
}
