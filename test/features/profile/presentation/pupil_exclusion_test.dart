import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/services/player_directory_service_impl.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profiles_use_case.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/pump_localized.dart';
import '../helpers/profile_fixtures.dart';

final class _MockGetProfiles extends Mock implements GetProfilesUseCase {}

void main() {
  final ProfileEntity pupil = buildProfile(
    id: 'pupil',
    nickname: '01',
  ).copyWith(classroomId: 'class-1');

  test('the duel and the leaderboard list the free players only', () async {
    // Arrange
    final _MockGetProfiles mockGetProfiles = _MockGetProfiles();
    when(mockGetProfiles.call).thenAnswer(
      (_) async => DataSuccess<List<ProfileEntity>>(<ProfileEntity>[
        buildProfile(),
        pupil,
      ]),
    );
    // Act
    final List<PlayerIdentity> actual = (await PlayerDirectoryServiceImpl(
      getProfiles: mockGetProfiles,
    ).readPlayers()).requireData;
    // Assert
    expect(actual.map((PlayerIdentity p) => p.id), <String>['profile-1']);
  });

  Future<void> pumpCard(WidgetTester tester, ProfileEntity player) async {
    final MockGetProfileUseCase mockGetProfile = MockGetProfileUseCase();
    when(() => mockGetProfile.call(params: any(named: 'params'))).thenAnswer(
      (_) async => DataSuccess<ProfileEntity>(player),
    );
    final ProfilePages pages = buildProfilePages(
      tabUseCases: buildTabUseCases(getProfile: mockGetProfile),
    );
    await pumpLocalized(
      tester,
      Scaffold(
        body: pages.buildForFreePlayer(
          profileId: player.id,
          child: const Text('Classement'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('hides the « Classement » card from a pupil', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpCard(tester, pupil);
    // Assert
    expect(find.text('Classement'), findsNothing);
  });

  testWidgets('shows the « Classement » card to a free player', (
    WidgetTester tester,
  ) async {
    // Act
    await pumpCard(tester, buildProfile());
    // Assert
    expect(find.text('Classement'), findsOneWidget);
  });
}
