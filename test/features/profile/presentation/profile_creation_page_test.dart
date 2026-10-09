import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/presentation/pages/profile_creation_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/profile_fixtures.dart';

void main() {
  late MockCreateProfileUseCase mockCreateProfile;
  late MockSelectProfileUseCase mockSelectProfile;

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
    ).thenAnswer((_) async => DataSuccess<ProfileEntity>(buildProfile()));
    when(
      () => mockSelectProfile.call(params: any(named: 'params')),
    ).thenAnswer((_) async => DataSuccess<ProfileEntity>(buildProfile()));
  });

  Future<void> pumpPage(WidgetTester tester, {bool canGoBack = true}) async {
    tester.view.physicalSize = const Size(1170, 3000);
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      ProfileCreationPage(
        createProfile: mockCreateProfile,
        selectProfile: mockSelectProfile,
        canGoBack: canGoBack,
      ),
    );
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    await tester.pump();
    await tester.tap(find.text("C'est parti !"));
    await tester.pumpAndSettle();
  }

  group('ProfileCreationPage', () {
    testWidgets('creates the player with the chosen avatar and color', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpPage(tester);
      await tester.enterText(find.byType(TextField), 'Awa');
      await tester.tap(find.bySemanticsLabel('Avatar 3'));
      await tester.tap(find.bySemanticsLabel('Vert'));
      await tester.pump();
      // Act
      await tapSubmit(tester);
      // Assert
      final CreateProfileParams actualParams =
          verify(
                () => mockCreateProfile.call(
                  params: captureAny(named: 'params'),
                ),
              ).captured.single
              as CreateProfileParams;
      expect(actualParams.nickname, 'Awa');
      expect(actualParams.avatar, ProfileAvatar.avatar3);
      expect(actualParams.color, ProfileColor.green);
    });
    testWidgets('explains a nickname that is too short', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpPage(tester);
      await tester.enterText(find.byType(TextField), 'A');
      // Act
      await tapSubmit(tester);
      // Assert
      expect(
        find.text('Il faut au moins 2 lettres ou chiffres.'),
        findsOneWidget,
      );
      verifyNever(() => mockCreateProfile.call(params: any(named: 'params')));
    });
    testWidgets('says when the nickname is already taken', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockCreateProfile.call(params: any(named: 'params')),
      ).thenAnswer(
        (_) async => const DataFailed<ProfileEntity>(ConflictException()),
      );
      await pumpPage(tester);
      await tester.enterText(find.byType(TextField), 'awa');
      // Act
      await tapSubmit(tester);
      // Assert
      expect(
        find.text('Ce nom est déjà pris sur ce téléphone.'),
        findsOneWidget,
      );
    });
    testWidgets('says when the phone already holds ten players', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockCreateProfile.call(params: any(named: 'params')),
      ).thenAnswer(
        (_) async => const DataFailed<ProfileEntity>(LimitReachedException()),
      );
      await pumpPage(tester);
      await tester.enterText(find.byType(TextField), 'Lina');
      // Act
      await tapSubmit(tester);
      // Assert
      expect(
        find.text('Il y a déjà 10 joueurs sur ce téléphone.'),
        findsOneWidget,
      );
    });
    testWidgets('has no way back on the first launch', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpPage(tester, canGoBack: false);
      // Assert
      expect(find.byTooltip('Retour'), findsNothing);
    });
  });
}
