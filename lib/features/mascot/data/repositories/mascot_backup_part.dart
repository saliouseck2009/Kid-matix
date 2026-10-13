import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/backup_section_reader.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/features/mascot/data/datasources/mascot_tables.dart';
import 'package:kid_matix/features/mascot/data/models/mascot_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// The mascot of a player in a backup file: its name, the accessories
/// worn and the stage already celebrated.
final class MascotBackupPart implements ProfileBackupPart {
  /// Creates the part.
  const MascotBackupPart();

  static const String _mascotKey = 'mascot';

  @override
  String get section => 'mascot';

  @override
  Future<Map<String, Object?>> exportSection(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    final List<Map<String, Object?>> rows = await executor.query(
      MascotTables.mascot,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
    );
    return <String, Object?>{_mascotKey: rows.firstOrNull};
  }

  @override
  Future<List<String>> importSection(
    Transaction transaction, {
    required Map<String, Object?> content,
    required BackupIdMap ids,
  }) async {
    final MascotLocalModel? mascot = BackupSectionReader.readRow(
      content,
      key: _mascotKey,
      fromJson: MascotLocalModel.fromJson,
    );
    if (mascot == null) return const <String>[];
    await transaction.insert(MascotTables.mascot, <String, Object?>{
      ...mascot.toJson(),
      'profile_id': ids.profileId,
    });
    return const <String>[MascotTables.mascot];
  }
}
