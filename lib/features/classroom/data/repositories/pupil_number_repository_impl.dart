import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/classroom/data/repositories/classroom_storage_guard.dart';
import 'package:kid_matix/features/classroom/domain/repositories/pupil_number_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [PupilNumberRepository] over the `class_pupil_number` table (schema
/// 18), in one transaction so two enrolments never share a number.
final class PupilNumberRepositoryImpl implements PupilNumberRepository {
  /// Creates the repository over [database].
  const PupilNumberRepositoryImpl({
    required this._database,
    required this._clock,
  });

  static const String _table = 'class_pupil_number';

  final AppDatabase _database;
  final Clock _clock;

  @override
  Future<DataState<Map<String, int>>> assign({
    required String classroomId,
    required List<String> pupilIds,
  }) {
    return guardClassroomStorage(() async {
      final Database database = await _database.database;
      return database.transaction(
        (Transaction transaction) => _assignWith(
          transaction,
          classroomId,
          pupilIds,
        ),
      );
    });
  }

  Future<Map<String, int>> _assignWith(
    Transaction transaction,
    String classroomId,
    List<String> pupilIds,
  ) async {
    final List<Map<String, Object?>> rows = await transaction.query(
      _table,
      columns: <String>['profile_id', 'number'],
      where: 'classroom_id = ?',
      whereArgs: <Object>[classroomId],
    );
    final Map<String, int> numbers = <String, int>{
      for (final Map<String, Object?> row in rows)
        row['profile_id']! as String: row['number']! as int,
    };
    // Removed pupils keep their rows: the last number is never reused.
    int last = numbers.values.fold(0, (int a, int b) => a > b ? a : b);
    final int now = _clock.now().millisecondsSinceEpoch;
    for (final String pupilId in pupilIds) {
      if (numbers.containsKey(pupilId)) continue;
      numbers[pupilId] = ++last;
      await transaction.insert(_table, <String, Object?>{
        'classroom_id': classroomId,
        'profile_id': pupilId,
        'number': last,
        'updated_at': now,
      });
    }
    return numbers;
  }
}
