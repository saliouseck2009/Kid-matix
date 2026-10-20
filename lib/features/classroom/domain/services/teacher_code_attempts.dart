/// The wrong codes typed at the door of the teacher area: after
/// [maxWrongCodes] of them, the door stays closed for [lockout], so the
/// 10 000 codes cannot be tried one after the other. Kept in memory.
class TeacherCodeAttempts {
  /// Wrong codes in a row before the door closes for a while.
  static const int maxWrongCodes = 5;

  /// How long the door stays closed then.
  static const Duration lockout = Duration(seconds: 30);

  int _wrongCount = 0;
  DateTime? _lockedUntil;

  /// Whether the door refuses every code at [now].
  bool isLockedAt(DateTime now) {
    final DateTime? until = _lockedUntil;
    return until != null && now.isBefore(until);
  }

  /// Counts a wrong code typed at [now]; returns whether the door is now
  /// closed for [lockout].
  bool recordWrongCode(DateTime now) {
    _wrongCount++;
    if (_wrongCount < maxWrongCodes) return false;
    _wrongCount = 0;
    _lockedUntil = now.add(lockout);
    return true;
  }

  /// Forgets the wrong codes, after the right one or a new code.
  void clear() {
    _wrongCount = 0;
    _lockedUntil = null;
  }
}
