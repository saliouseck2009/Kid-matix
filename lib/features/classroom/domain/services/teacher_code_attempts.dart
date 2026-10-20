/// The wrong codes typed in a row at the door of the teacher area: after
/// [maxWrongCodes] of them, the door stays closed for [lockout], so the
/// 10 000 codes cannot be tried one after the other. The count is kept in
/// memory; the end of the lockout is kept in the preferences.
class TeacherCodeAttempts {
  /// Wrong codes in a row before the door closes for a while.
  static const int maxWrongCodes = 5;

  /// How long the door stays closed then.
  static const Duration lockout = Duration(seconds: 30);

  int _wrongCount = 0;

  /// Counts a wrong code; returns whether the door must now close for
  /// [lockout].
  bool recordWrongCode() {
    _wrongCount++;
    if (_wrongCount < maxWrongCodes) return false;
    _wrongCount = 0;
    return true;
  }

  /// Forgets the wrong codes, after the right one or a new code.
  void clear() => _wrongCount = 0;
}
