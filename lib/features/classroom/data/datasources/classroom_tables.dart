/// Names of the tables of the class mode (schema versions 15 and 17).
abstract final class ClassroomTables {
  /// The classes of the device.
  static const String classroom = 'classroom';

  /// The units given to the classes.
  static const String assignment = 'assignment';

  /// The sessions the pupils played, one row per quiz session.
  static const String session = 'class_session';

  /// The answers of those sessions.
  static const String answer = 'class_answer';

  /// The assessments opened for the classes (schema 17).
  static const String assessment = 'class_assessment';

  /// The result of each pupil in each assessment.
  static const String assessmentResult = 'assessment_result';

  /// The level of each result in each domain of the placement test.
  static const String assessmentLevel = 'assessment_level';

  /// The words of the word check of each result.
  static const String assessmentWord = 'assessment_word';

  /// Condition of the live rows.
  static const String isLive = 'deleted_at IS NULL';
}
