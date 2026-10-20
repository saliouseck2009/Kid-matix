import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';
import 'package:kid_matix/core/services/teacher_session_service.dart';

/// Where the router must go for [session] when [location] is asked, or
/// `null` to stay.
///
/// - Nobody playing and no profile: the profile creation (first launch),
///   or the teacher area, which creates classes.
/// - Nobody playing: "Qui joue ?", the creation, « Qui es-tu ? » of a
///   class and the teacher area, nothing else.
/// - Somebody playing: anywhere but those; a player just created leaves
///   the creation for the placement test.
String? redirectForProfileSession({
  required ProfileSessionService session,
  required String location,
}) {
  if (!session.isRestored) return null;
  final bool isPlayerSelection =
      location == AppRoutes.whoIsPlaying ||
      location == AppRoutes.profileCreation ||
      AppRoutes.isPupilPicker(location) ||
      AppRoutes.isTeacherArea(location);
  if (session.activeProfileId != null) {
    // The creation is open with an active player only when that player
    // was just created: the session left the selection for it.
    if (location == AppRoutes.profileCreation) return AppRoutes.placementTest;
    return isPlayerSelection ? AppRoutes.learningPath : null;
  }
  if (!session.hasProfiles) {
    return location == AppRoutes.profileCreation ||
            AppRoutes.isTeacherArea(location)
        ? null
        : AppRoutes.profileCreation;
  }
  return isPlayerSelection ? null : AppRoutes.whoIsPlaying;
}

/// Where the router must go for the [teacher] area when [location] is
/// asked, or `null` to stay: its pages need the area open, and its door
/// leads to « Mes classes » once it is.
String? redirectForTeacherArea({
  required TeacherSessionService teacher,
  required String location,
}) {
  if (!AppRoutes.isTeacherArea(location)) return null;
  if (location == AppRoutes.teacherArea) {
    return teacher.isUnlocked ? AppRoutes.teacherClassrooms : null;
  }
  return teacher.isUnlocked ? null : AppRoutes.teacherArea;
}
