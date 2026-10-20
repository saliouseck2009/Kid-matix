import 'package:flutter/foundation.dart';

/// Whether the teacher area is open, as the router guards it.
///
/// The router listens to it (`refreshListenable`) and sends every page of
/// the teacher area but its door back to the door while it is closed.
/// Implemented by the class mode; the area closes when the teacher
/// leaves it, when a player starts playing, and at each launch.
abstract interface class TeacherSessionService implements Listenable {
  /// Whether the right code was typed and the area is open.
  bool get isUnlocked;

  /// Opens the area.
  void unlock();

  /// Closes the area.
  void lock();
}
