import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/router/profile_session_redirect.dart';
import 'package:kid_matix/core/services/teacher_session_service.dart';

import '../../helpers/fake_profile_session_service.dart';

void main() {
  String? redirect(FakeProfileSessionService session, String location) {
    return redirectForProfileSession(session: session, location: location);
  }

  group('redirectForProfileSession', () {
    test('opens the creation on the first launch', () {
      // Arrange
      final FakeProfileSessionService inputSession = FakeProfileSessionService(
        hasProfiles: false,
      );
      // Act
      final String? actualHome = redirect(inputSession, AppRoutes.learningPath);
      final String? actualSelection = redirect(
        inputSession,
        AppRoutes.whoIsPlaying,
      );
      final String? actualCreation = redirect(
        inputSession,
        AppRoutes.profileCreation,
      );
      // Assert
      expect(actualHome, AppRoutes.profileCreation);
      expect(actualSelection, AppRoutes.profileCreation);
      expect(actualCreation, isNull);
    });
    test('keeps the player selection while nobody plays', () {
      // Arrange
      final FakeProfileSessionService inputSession =
          FakeProfileSessionService();
      // Act
      final String? actualHome = redirect(inputSession, AppRoutes.learningPath);
      final String? actualTab = redirect(inputSession, AppRoutes.profile);
      final String? actualSelection = redirect(
        inputSession,
        AppRoutes.whoIsPlaying,
      );
      final String? actualCreation = redirect(
        inputSession,
        AppRoutes.profileCreation,
      );
      // Assert
      expect(actualHome, AppRoutes.whoIsPlaying);
      expect(actualTab, AppRoutes.whoIsPlaying);
      expect(actualSelection, isNull);
      expect(actualCreation, isNull);
    });
    test('sends an active player from the selection to the home and a '
        'player just created to the placement test', () {
      // Arrange
      final FakeProfileSessionService inputSession = FakeProfileSessionService(
        activeProfileId: 'p-1',
      );
      // Act
      final String? actualSelection = redirect(
        inputSession,
        AppRoutes.whoIsPlaying,
      );
      final String? actualCreation = redirect(
        inputSession,
        AppRoutes.profileCreation,
      );
      final String? actualTab = redirect(inputSession, AppRoutes.training);
      // Assert
      expect(actualSelection, AppRoutes.learningPath);
      expect(actualCreation, AppRoutes.placementTest);
      expect(actualTab, isNull);
    });

    test('opens the teacher area and the classes while nobody plays', () {
      // Arrange
      final FakeProfileSessionService inputSession =
          FakeProfileSessionService();
      final FakeProfileSessionService inputFirstLaunch =
          FakeProfileSessionService(hasProfiles: false);
      // Act
      final String? actualArea = redirect(inputSession, AppRoutes.teacherArea);
      final String? actualPicker = redirect(
        inputSession,
        AppRoutes.pupilPickerOf('c-1'),
      );
      final String? actualFirstArea = redirect(
        inputFirstLaunch,
        AppRoutes.teacherClassrooms,
      );
      // Assert
      expect(actualArea, isNull);
      expect(actualPicker, isNull);
      expect(actualFirstArea, isNull);
    });

    test('sends a player who plays away from the class mode', () {
      // Arrange
      final FakeProfileSessionService inputSession = FakeProfileSessionService(
        activeProfileId: 'p-1',
      );
      // Act
      final String? actualArea = redirect(
        inputSession,
        AppRoutes.teacherClassroomOf('c-1'),
      );
      final String? actualPicker = redirect(
        inputSession,
        AppRoutes.pupilPickerOf('c-1'),
      );
      // Assert
      expect(actualArea, AppRoutes.learningPath);
      expect(actualPicker, AppRoutes.learningPath);
    });
  });

  group('redirectForTeacherArea', () {
    test('keeps the area behind its door while it is closed', () {
      // Arrange
      final _Teacher inputTeacher = _Teacher();
      // Act
      final String? actualDoor = redirectForTeacherArea(
        teacher: inputTeacher,
        location: AppRoutes.teacherArea,
      );
      final String? actualClass = redirectForTeacherArea(
        teacher: inputTeacher,
        location: AppRoutes.teacherClassroomOf('c-1'),
      );
      final String? actualOther = redirectForTeacherArea(
        teacher: inputTeacher,
        location: AppRoutes.whoIsPlaying,
      );
      // Assert
      expect(actualDoor, isNull);
      expect(actualClass, AppRoutes.teacherArea);
      expect(actualOther, isNull);
    });

    test('leads from the door to the classes once open', () {
      // Arrange
      final _Teacher inputTeacher = _Teacher()..unlock();
      // Act
      final String? actualDoor = redirectForTeacherArea(
        teacher: inputTeacher,
        location: AppRoutes.teacherArea,
      );
      final String? actualClass = redirectForTeacherArea(
        teacher: inputTeacher,
        location: AppRoutes.classroomCreation,
      );
      // Assert
      expect(actualDoor, AppRoutes.teacherClassrooms);
      expect(actualClass, isNull);
    });
  });
}

final class _Teacher extends ChangeNotifier implements TeacherSessionService {
  @override
  bool isUnlocked = false;

  @override
  void lock() => isUnlocked = false;

  @override
  void unlock() => isUnlocked = true;
}
