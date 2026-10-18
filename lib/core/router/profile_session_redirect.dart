import 'package:kid_matix/core/router/app_routes.dart';
import 'package:kid_matix/core/services/profile_session_service.dart';

/// Where the router must go for [session] when [location] is asked, or
/// `null` to stay.
///
/// - Nobody playing and no profile: the profile creation (first launch).
/// - Nobody playing: "Qui joue ?" or the creation, nothing else.
/// - Somebody playing: anywhere but "Qui joue ?" and the creation; a
///   player just created leaves the creation for the placement test.
String? redirectForProfileSession({
  required ProfileSessionService session,
  required String location,
}) {
  if (!session.isRestored) return null;
  final bool isPlayerSelection =
      location == AppRoutes.whoIsPlaying ||
      location == AppRoutes.profileCreation;
  if (session.activeProfileId != null) {
    // The creation is open with an active player only when that player
    // was just created: the session left the selection for it.
    if (location == AppRoutes.profileCreation) return AppRoutes.placementTest;
    return isPlayerSelection ? AppRoutes.learningPath : null;
  }
  if (!session.hasProfiles) {
    return location == AppRoutes.profileCreation
        ? null
        : AppRoutes.profileCreation;
  }
  return isPlayerSelection ? null : AppRoutes.whoIsPlaying;
}
