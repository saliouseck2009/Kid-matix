import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/features/classroom/presentation/session/teacher_session_service_impl.dart';

import '../../../helpers/fake_profile_session_service.dart';
import '../helpers/classroom_device.dart';

void main() {
  late MovableClock clock;
  late TeacherSessionServiceImpl session;

  void goAwayFor(WidgetTester tester, Duration away) {
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
    clock.current = clock.current.add(away);
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  }

  setUp(() {
    clock = MovableClock(DateTime(2026, 10, 21, 9));
  });

  testWidgets('stays open through the file picker or a share target', (
    WidgetTester tester,
  ) async {
    // Arrange
    session = TeacherSessionServiceImpl(
      session: FakeProfileSessionService(),
      clock: clock,
    )..unlock();
    addTearDown(session.dispose);
    // Act
    goAwayFor(tester, const Duration(seconds: 40));
    // Assert
    expect(session.isUnlocked, isTrue);
  });

  testWidgets('closes after more than a minute in the background', (
    WidgetTester tester,
  ) async {
    // Arrange
    session = TeacherSessionServiceImpl(
      session: FakeProfileSessionService(),
      clock: clock,
    )..unlock();
    addTearDown(session.dispose);
    // Act
    goAwayFor(tester, const Duration(seconds: 61));
    // Assert
    expect(session.isUnlocked, isFalse);
  });

  testWidgets('closes at once when a player starts playing', (
    WidgetTester tester,
  ) async {
    // Arrange
    final FakeProfileSessionService players = FakeProfileSessionService();
    session = TeacherSessionServiceImpl(session: players, clock: clock)
      ..unlock();
    addTearDown(session.dispose);
    // Act
    players.update(hasProfiles: true, activeProfileId: 'pupil-1');
    // Assert
    expect(session.isUnlocked, isFalse);
  });
}
