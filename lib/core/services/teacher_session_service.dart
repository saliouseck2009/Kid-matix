import 'package:flutter/foundation.dart';
import 'package:kid_matix/core/services/teacher_area_lock.dart';

/// Whether the teacher area is open, as the router guards it.
///
/// The router listens to it (`refreshListenable`) and sends every page of
/// the teacher area but its door back to the door while it is closed.
/// Implemented by the class mode; the area closes when the teacher
/// leaves it, when a player starts playing, when the app goes to the
/// background, and at each launch.
abstract interface class TeacherSessionService
    implements TeacherAreaLock, Listenable {}
