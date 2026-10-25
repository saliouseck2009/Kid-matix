/// Where the teacher stands at the door of the teacher area.
enum TeacherAccess {
  /// No code chosen yet on this device: the first visit chooses one.
  noCode,

  /// A code exists and the area is closed.
  locked,

  /// The right code was typed: the area is open until the teacher leaves
  /// it or a pupil starts playing.
  unlocked,
}
