import 'package:kid_matix/core/services/pupil_roster_service.dart';

/// Rules of the class mode (lot F29, owner's answers of 2026-10-20).
abstract final class ClassroomRules {
  /// Most pupils one class holds.
  static const int maxPupils = PupilRosterService.maxPupilsPerClass;

  /// Most characters of a class name.
  static const int maxNameLength = 24;

  /// Digits of the teacher's code.
  static const int teacherCodeLength = 4;

  /// Right answers a new class aims at each week.
  static const int defaultWeeklyGoal = 1000;

  /// Weekly goals the teacher can choose from.
  static const List<int> weeklyGoalChoices = <int>[250, 500, 1000, 2000];

  /// Digits of a pupil number, « 01 » to « 60 »: a nickname has at least
  /// two characters.
  static const int pupilNumberWidth = 2;

  static final RegExp _teacherCode = RegExp(
    '^[0-9]{$teacherCodeLength}\$',
  );
  static final RegExp _lineBreaks = RegExp(r'[\r\n]+');

  /// Whether [code] is a teacher's code: exactly 4 digits.
  static bool isTeacherCode(String code) => _teacherCode.hasMatch(code);

  /// Returns [name] without stray spaces, or `null` when it is empty or
  /// longer than [maxNameLength].
  static String? cleanName(String name) {
    final String cleaned = name.trim();
    if (cleaned.isEmpty || cleaned.runes.length > maxNameLength) return null;
    return cleaned;
  }

  /// The nicknames of [text], one per line; empty lines are skipped.
  static List<String> parseNicknames(String text) {
    return text
        .split(_lineBreaks)
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();
  }

  /// [count] pupil numbers following the [existingCount] pupils of a
  /// class: « 01 », « 02 »... for a new class.
  static List<String> numberNicknames({
    required int count,
    int existingCount = 0,
  }) {
    return List<String>.generate(
      count,
      (int index) => '${existingCount + index + 1}'.padLeft(
        pupilNumberWidth,
        '0',
      ),
    );
  }
}
