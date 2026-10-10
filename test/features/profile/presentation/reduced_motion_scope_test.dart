import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_settings_entity.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/profile_fixtures.dart';

void main() {
  Future<bool> pumpScope(WidgetTester tester, {required bool isReduced}) async {
    final MockGetSettingsUseCase mockGetSettings = MockGetSettingsUseCase();
    when(() => mockGetSettings.call(params: any(named: 'params'))).thenAnswer(
      (_) async => DataSuccess<ProfileSettingsEntity>(
        const ProfileSettingsEntity.defaults(
          profileId: 'p1',
        ).copyWith(isReducedMotionEnabled: isReduced),
      ),
    );
    bool isDisabled = false;
    await pumpLocalized(
      tester,
      buildProfilePages(
        settingsUseCases: buildSettingsUseCases(getSettings: mockGetSettings),
      ).buildSettingsScope(
        profileId: 'p1',
        child: Builder(
          builder: (BuildContext context) {
            isDisabled = MediaQuery.disableAnimationsOf(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return isDisabled;
  }

  testWidgets('turns the animations off when the player asked for it', (
    WidgetTester tester,
  ) async {
    // Act & Assert
    expect(await pumpScope(tester, isReduced: true), isTrue);
  });
  testWidgets('keeps the animations otherwise', (WidgetTester tester) async {
    // Act & Assert
    expect(await pumpScope(tester, isReduced: false), isFalse);
  });
}
