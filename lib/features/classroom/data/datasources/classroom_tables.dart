/// Names of the tables of the class mode (schema version 15).
abstract final class ClassroomTables {
  /// The classes of the device.
  static const String classroom = 'classroom';

  /// The units given to the classes.
  static const String assignment = 'assignment';

  /// The sessions the pupils played, one row per quiz session.
  static const String session = 'class_session';

  /// The answers of those sessions.
  static const String answer = 'class_answer';

  /// Condition of the live rows.
  static const String isLive = 'deleted_at IS NULL';
}
