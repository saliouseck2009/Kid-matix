import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/profile/presentation/profile_pages.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_settings.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';
import 'package:kid_matix/features/setting/presentation/bloc/reminder_cubit.dart';
import 'package:kid_matix/features/setting/presentation/bloc/reminder_state.dart';
import 'package:kid_matix/features/setting/presentation/reminder_pages.dart';

import '../../../helpers/pump_localized.dart';
import '../../profile/helpers/profile_fixtures.dart';
import '../helpers/reminder_fixtures.dart';

void main() {
  Future<void> pumpSettings(
    WidgetTester tester,
    ReminderTestBed bed, {
    bool hasReminder = true,
  }) async {
    tester.view.physicalSize = const Size(1080, 3000);
    addTearDown(tester.view.resetPhysicalSize);
    final ProfilePages pages = buildProfilePages();
    await pumpLocalized(
      tester,
      pages.buildSettingsPage(
        profileId: 'profile-1',
        onBack: () {},
        reminderRows: <Widget>[
          if (hasReminder)
            ReminderPages(useCases: bed.useCases).buildSettingsRows(),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  bool isSwitchOn(WidgetTester tester) {
    return tester
        .widget<SwitchListTile>(
          find.widgetWithText(SwitchListTile, 'Rappel quotidien'),
        )
        .value;
  }

  group('« Rappel » section of the settings', () {
    testWidgets('shows the reminder off at 17:00, the time greyed', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      // Act
      await pumpSettings(tester, bed);
      // Assert
      expect(find.text('Rappel'), findsOneWidget);
      expect(find.text('Heure du rappel'), findsOneWidget);
      expect(find.text('17:00'), findsOneWidget);
      expect(isSwitchOn(tester), isFalse);
      await tester.tap(find.text('17:00'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsNothing);
      expect(bed.notifications.permissionRequests, 0);
    });

    testWidgets('is hidden without reminder rows', (
      WidgetTester tester,
    ) async {
      // Act
      await pumpSettings(tester, ReminderTestBed(), hasReminder: false);
      // Assert
      expect(find.text('Rappel'), findsNothing);
      expect(find.text('Rappel quotidien'), findsNothing);
    });

    testWidgets('a refused permission puts the switch back off', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed(
        notifications: FakeNotificationScheduler(isGranted: false),
      );
      await pumpSettings(tester, bed);
      // Act
      await tester.tap(find.text('Rappel quotidien'));
      await tester.pumpAndSettle();
      // Assert
      expect(bed.notifications.permissionRequests, 1);
      expect(isSwitchOn(tester), isFalse);
      expect(
        find.text(
          'Les notifications sont bloquées. Autorise-les dans les réglages '
          'du téléphone pour recevoir le rappel.',
        ),
        findsOneWidget,
      );
      expect(bed.notifications.scheduled, isEmpty);
    });

    testWidgets('switched on, the time opens the picker', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      await pumpSettings(tester, bed);
      // Act
      await tester.tap(find.text('Rappel quotidien'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('17:00'));
      await tester.pumpAndSettle();
      // Assert
      expect(isSwitchOn(tester), isTrue);
      expect(find.byType(TimePickerDialog), findsOneWidget);
      bed.notifications.scheduled = <DateTime>[];
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsNothing);
      expect(bed.notifications.scheduled.first, DateTime(2026, 10, 12, 17));
    });
  });

  group('ReminderCubit', () {
    blocTest<ReminderCubit, ReminderState>(
      'loads the settings, then saves a change while waiting',
      build: () => ReminderCubit(useCases: ReminderTestBed().useCases),
      act: (ReminderCubit cubit) async {
        await cubit.load();
        await cubit.setEnabled(isEnabled: true);
      },
      expect: () => <Matcher>[
        isA<ReminderLoading>(),
        isA<ReminderLoaded>()
            .having(
              (ReminderLoaded state) => state.settings,
              'settings',
              ReminderSettings.initial,
            )
            .having((ReminderLoaded state) => state.isSaving, 'saving', false),
        isA<ReminderLoaded>().having(
          (ReminderLoaded state) => state.isSaving,
          'saving',
          true,
        ),
        isA<ReminderLoaded>().having(
          (ReminderLoaded state) => state.settings.isEnabled,
          'enabled',
          true,
        ),
      ],
    );

    blocTest<ReminderCubit, ReminderState>(
      'moves the reminder to another time',
      build: () => ReminderCubit(useCases: ReminderTestBed().useCases),
      seed: () => const ReminderLoaded(settings: ReminderSettings.initial),
      act: (ReminderCubit cubit) => cubit.setTime(
        time: const ReminderTime(hour: 8, minute: 15),
      ),
      skip: 1,
      expect: () => <Matcher>[
        isA<ReminderLoaded>().having(
          (ReminderLoaded state) => state.settings.time,
          'time',
          const ReminderTime(hour: 8, minute: 15),
        ),
      ],
    );

    blocTest<ReminderCubit, ReminderState>(
      'keeps the old time and tells why when saving fails',
      build: () {
        final ReminderTestBed bed = ReminderTestBed();
        bed.notifications.isBroken = true;
        return ReminderCubit(useCases: bed.useCases);
      },
      seed: () => const ReminderLoaded(settings: ReminderSettings.initial),
      act: (ReminderCubit cubit) => cubit.setTime(
        time: const ReminderTime(hour: 9, minute: 0),
      ),
      skip: 1,
      expect: () => <Matcher>[
        isA<ReminderLoaded>()
            .having(
              (ReminderLoaded state) => state.settings,
              'settings',
              ReminderSettings.initial,
            )
            .having(
              (ReminderLoaded state) => state.errorCode,
              'error',
              AppErrorCode.unknown,
            ),
      ],
    );

    blocTest<ReminderCubit, ReminderState>(
      'fails to load on broken preferences and ignores changes',
      build: () => ReminderCubit(
        useCases: ReminderTestBed(storage: BrokenLocalStorage()).useCases,
      ),
      act: (ReminderCubit cubit) async {
        await cubit.load();
        await cubit.setEnabled(isEnabled: true);
      },
      expect: () => <Matcher>[
        isA<ReminderLoading>(),
        isA<ReminderFailure>().having(
          (ReminderFailure state) => state.errorCode,
          'error',
          AppErrorCode.cache,
        ),
      ],
    );
  });
}
