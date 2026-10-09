import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_session_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/get_profile_session_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/watch_profile_changes_use_case.dart';
import 'package:kid_matix/features/profile/presentation/session/profile_session_service_impl.dart';
import 'package:mocktail/mocktail.dart';

final class _MockGetSession extends Mock implements GetProfileSessionUseCase {}

final class _MockWatchChanges extends Mock
    implements WatchProfileChangesUseCase {}

void main() {
  late _MockGetSession mockGetSession;
  late StreamController<void> changes;
  late ProfileSessionServiceImpl service;
  late int notificationCount;

  void stubSession(DataState<ProfileSessionEntity> state) {
    when(mockGetSession.call).thenAnswer((_) async => state);
  }

  setUp(() {
    mockGetSession = _MockGetSession();
    final _MockWatchChanges mockWatchChanges = _MockWatchChanges();
    changes = StreamController<void>.broadcast();
    when(mockWatchChanges.call).thenAnswer((_) => changes.stream);
    service = ProfileSessionServiceImpl(
      getSession: mockGetSession,
      watchChanges: mockWatchChanges,
    );
    notificationCount = 0;
    service.addListener(() => notificationCount++);
  });

  tearDown(() async {
    service.dispose();
    await changes.close();
  });

  group('ProfileSessionServiceImpl', () {
    test('is not restored before restore runs', () {
      // Assert
      expect(service.isRestored, isFalse);
      expect(service.activeProfileId, isNull);
    });
    test('exposes the stored session once restored', () async {
      // Arrange
      stubSession(
        const DataSuccess<ProfileSessionEntity>(
          ProfileSessionEntity(profileCount: 3, activeProfileId: 'p-1'),
        ),
      );
      // Act
      await service.restore();
      // Assert
      expect(service.isRestored, isTrue);
      expect(service.hasProfiles, isTrue);
      expect(service.activeProfileId, 'p-1');
      expect(notificationCount, 1);
    });
    test('reloads and notifies after a profile change', () async {
      // Arrange
      stubSession(
        const DataSuccess<ProfileSessionEntity>(
          ProfileSessionEntity(profileCount: 1),
        ),
      );
      await service.restore();
      stubSession(
        const DataSuccess<ProfileSessionEntity>(
          ProfileSessionEntity(profileCount: 1, activeProfileId: 'p-1'),
        ),
      );
      // Act
      changes.add(null);
      await pumpEventQueue();
      // Assert
      expect(service.activeProfileId, 'p-1');
      expect(notificationCount, 2);
    });
    test('does not notify when nothing changed', () async {
      // Arrange
      stubSession(
        const DataSuccess<ProfileSessionEntity>(
          ProfileSessionEntity(profileCount: 1),
        ),
      );
      await service.restore();
      // Act
      changes.add(null);
      await pumpEventQueue();
      // Assert
      expect(notificationCount, 1);
    });
    test('starts with no profile when the first read fails', () async {
      // Arrange
      stubSession(const DataFailed<ProfileSessionEntity>(CacheException()));
      // Act
      await service.restore();
      // Assert
      expect(service.isRestored, isTrue);
      expect(service.hasProfiles, isFalse);
    });
    test('keeps the last session when a reload fails', () async {
      // Arrange
      stubSession(
        const DataSuccess<ProfileSessionEntity>(
          ProfileSessionEntity(profileCount: 2, activeProfileId: 'p-2'),
        ),
      );
      await service.restore();
      stubSession(const DataFailed<ProfileSessionEntity>(CacheException()));
      // Act
      changes.add(null);
      await pumpEventQueue();
      // Assert
      expect(service.activeProfileId, 'p-2');
      expect(notificationCount, 1);
    });
  });
}
