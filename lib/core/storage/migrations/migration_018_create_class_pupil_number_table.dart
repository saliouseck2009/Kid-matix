import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 18: the number of each pupil in their class (F31-04).
///
/// `class_pupil_number` gives each pupil, at enrolment, the next number
/// of the class: the anonymous reports show « Élève 7 » by it, so a
/// pupil keeps their number from one report to the next. A number is
/// never given again: the row stays when the pupil is removed (no foreign
/// key on the profile), and goes only with the class.
///
/// The pupils already in a class are numbered here in the order of the
/// class list (creation date, then identifier). The SQL is written out in
/// full: a released migration never changes.
final class Migration018CreateClassPupilNumberTable
    implements DatabaseMigration {
  /// Creates the migration.
  const Migration018CreateClassPupilNumberTable();

  @override
  int get version => 18;

  @override
  Future<void> migrate(Database database) async {
    await database.execute('''
      CREATE TABLE class_pupil_number (
        classroom_id TEXT NOT NULL
          REFERENCES classroom (id) ON DELETE CASCADE,
        profile_id TEXT NOT NULL,
        number INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        PRIMARY KEY (classroom_id, profile_id),
        UNIQUE (classroom_id, number)
      )
    ''');
    final List<Map<String, Object?>> pupils = await database.rawQuery(
      'SELECT id, classroom_id, updated_at FROM profile '
      'WHERE classroom_id IS NOT NULL AND deleted_at IS NULL '
      'ORDER BY classroom_id, created_at, id',
    );
    final Map<String, int> counts = <String, int>{};
    final Batch batch = database.batch();
    for (final Map<String, Object?> pupil in pupils) {
      final String classroomId = pupil['classroom_id']! as String;
      final int number = (counts[classroomId] ?? 0) + 1;
      counts[classroomId] = number;
      batch.insert('class_pupil_number', <String, Object?>{
        'classroom_id': classroomId,
        'profile_id': pupil['id'],
        'number': number,
        'updated_at': pupil['updated_at'],
      });
    }
    await batch.commit(noResult: true);
  }
}
