import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/setting/data/datasources/reminder_local_data_source_impl.dart';
import 'package:kid_matix/features/setting/data/repositories/reminder_session_hook.dart';
import 'package:kid_matix/features/setting/domain/entities/reminder_time.dart';
import 'package:kid_matix/features/setting/domain/repositories/reminder_repository.dart';
import 'package:sqflite/sqflite.dart';

import '../../../helpers/in_memory_local_storage.dart';
import '../helpers/reminder_fixtures.dart';

SavedQuizSession _session({required bool isCompleted}) {
  return SavedQuizSession(
    id: 's-1',
    profileId: 'p-2',
    domainId: 'mul',
    mode: QuizMode.freeTraining,
    isCompleted: isCompleted,
    questionCount: 10,
    correctCount: 8,
    endedAt: DateTime(2026, 10, 12, 11, 30),
  );
}

void main() {
  group('ReminderLocalDataSourceImpl', () {
    test('keeps the switch, the time and the day in the preferences', () async {
      // Arrange
      final InMemoryLocalStorage storage = InMemoryLocalStorage();
      final ReminderLocalDataSourceImpl source = ReminderLocalDataSourceImpl(
        storage: storage,
      );
      // Act
      await source.writeEnabled(isEnabled: true);
      await source.writeTime(time: const ReminderTime(hour: 7, minute: 5));
      await source.writeLastSessionDay(day: DateTime(2026, 3, 9));
      // Assert
      expect(await source.readEnabled(), isTrue);
      expect(await source.readTime(), const ReminderTime(hour: 7, minute: 5));
      expect(await source.readLastSessionDay(), DateTime(2026, 3, 9));
      expect(
        await storage.readString(key: ReminderLocalDataSourceImpl.timeKey),
        '07:05',
      );
      expect(
        await storage.readString(
          key: ReminderLocalDataSourceImpl.lastSessionDayKey,
        ),
        '2026-03-09',
      );
    });

    test('reads nothing on a new phone', () async {
      // Arrange
      final ReminderLocalDataSourceImpl source = ReminderLocalDataSourceImpl(
        storage: InMemoryLocalStorage(),
      );
      // Act & Assert
      expect(await source.readEnabled(), isNull);
      expect(await source.readTime(), isNull);
      expect(await source.readLastSessionDay(), isNull);
    });

    test('ignores values of another shape', () async {
      // Arrange
      final InMemoryLocalStorage storage = InMemoryLocalStorage();
      final ReminderLocalDataSourceImpl source = ReminderLocalDataSourceImpl(
        storage: storage,
      );
      // Act
      await storage.writeString(
        key: ReminderLocalDataSourceImpl.enabledKey,
        value: 'yes',
      );
      await storage.writeString(
        key: ReminderLocalDataSourceImpl.timeKey,
        value: '25:00',
      );
      await storage.writeString(
        key: ReminderLocalDataSourceImpl.lastSessionDayKey,
        value: '2026-10',
      );
      // Assert
      expect(await source.readEnabled(), isNull);
      expect(await source.readTime(), isNull);
      expect(await source.readLastSessionDay(), isNull);
      await storage.writeString(
        key: ReminderLocalDataSourceImpl.timeKey,
        value: '-1:30',
      );
      expect(await source.readTime(), isNull);
    });
  });

  group('ReminderRepositoryImpl', () {
    test('turns a broken plugin into a typed failure', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      bed.notifications.isBroken = true;
      final ReminderRepository repository = bed.repository;
      // Act
      final DataState<bool> actual = await repository.requestPermission();
      // Assert
      expect(
        (actual as DataFailed<bool>).exception.code,
        AppErrorCode.unknown,
      );
      expect(await repository.cancelReminders(), isA<DataFailed<void>>());
    });

    test('turns broken preferences into a storage failure', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed(
        storage: BrokenLocalStorage(),
      );
      // Act
      final DataState<DateTime?> actual = await bed.repository
          .getLastSessionDay();
      // Assert
      expect(
        (actual as DataFailed<DateTime?>).exception.code,
        AppErrorCode.cache,
      );
    });
  });

  group('ReminderSessionHook', () {
    test('a completed session leaves out the reminder of today', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      await bed.setEnabled(params: true);
      final ReminderSessionHook hook = ReminderSessionHook(
        recordFinishedSession: () => bed.recordFinishedSession,
      );
      // Act
      final SessionWrite write = await hook.prepare(
        session: _session(isCompleted: true),
      );
      final List<String> actual = await write(_NoTransaction());
      await pumpEventQueue();
      // Assert
      expect(actual, isEmpty);
      expect(bed.notifications.scheduled.first, DateTime(2026, 10, 13, 17));
    });

    test('an abandoned session changes nothing', () async {
      // Arrange
      final ReminderTestBed bed = ReminderTestBed();
      await bed.setEnabled(params: true);
      final ReminderSessionHook hook = ReminderSessionHook(
        recordFinishedSession: () => bed.recordFinishedSession,
      );
      // Act
      final SessionWrite write = await hook.prepare(
        session: _session(isCompleted: false),
      );
      await write(_NoTransaction());
      await pumpEventQueue();
      // Assert
      expect(bed.notifications.scheduled.first, DateTime(2026, 10, 12, 17));
    });
  });
}

/// The hook never touches the transaction.
final class _NoTransaction implements Transaction {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}
