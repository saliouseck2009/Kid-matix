/// The lock of the teacher area, as the use cases of the class mode see
/// it: pure Dart, with no listener.
///
/// The router listens to the same object through `TeacherSessionService`.
abstract interface class TeacherAreaLock {
  /// Whether the right code was typed and the area is open.
  bool get isUnlocked;

  /// Opens the area.
  void unlock();

  /// Closes the area.
  void lock();
}
