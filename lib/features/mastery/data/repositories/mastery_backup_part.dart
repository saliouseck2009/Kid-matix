import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/backup_section_reader.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/features/mastery/data/datasources/mastery_tables.dart';
import 'package:kid_matix/features/mastery/data/models/item_progress_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// The mastery grid of a player in a backup file: the progress of every
/// item they met.
final class MasteryBackupPart implements ProfileBackupPart {
  /// Creates the part.
  const MasteryBackupPart();

  static const String _itemsKey = 'items';

  @override
  String get section => 'mastery';

  @override
  Future<Map<String, Object?>> exportSection(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    final List<Map<String, Object?>> items = await executor.query(
      MasteryTables.itemProgress,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
      orderBy: 'domain_id, item_key',
    );
    return <String, Object?>{_itemsKey: items};
  }

  @override
  Future<List<String>> importSection(
    Transaction transaction, {
    required Map<String, Object?> content,
    required BackupIdMap ids,
  }) async {
    final List<ItemProgressLocalModel> items = BackupSectionReader.readRows(
      content,
      key: _itemsKey,
      fromJson: ItemProgressLocalModel.fromJson,
    );
    final Batch batch = transaction.batch();
    for (final ItemProgressLocalModel item in items) {
      batch.insert(MasteryTables.itemProgress, <String, Object?>{
        ...item.toJson(),
        'profile_id': ids.profileId,
      });
    }
    await batch.commit(noResult: true);
    return const <String>[MasteryTables.itemProgress];
  }
}
