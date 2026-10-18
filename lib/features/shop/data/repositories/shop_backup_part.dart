import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/backup_section_reader.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/features/shop/data/datasources/shop_tables.dart';
import 'package:kid_matix/features/shop/data/models/shop_choice_local_model.dart';
import 'package:kid_matix/features/shop/data/models/shop_purchase_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// The shop of a player in a backup file: the items bought and the theme
/// applied. The coins follow from the XP, crowns and badges of the file.
final class ShopBackupPart implements ProfileBackupPart {
  /// Creates the part.
  const ShopBackupPart();

  static const String _purchasesKey = 'purchases';
  static const String _choiceKey = 'choice';

  @override
  String get section => 'shop';

  @override
  Future<Map<String, Object?>> exportSection(
    DatabaseExecutor executor, {
    required String profileId,
  }) async {
    final List<Map<String, Object?>> purchases = await executor.query(
      ShopTables.purchase,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
      orderBy: 'purchased_at, id',
    );
    final List<Map<String, Object?>> choices = await executor.query(
      ShopTables.choice,
      where: 'profile_id = ?',
      whereArgs: <Object>[profileId],
    );
    return <String, Object?>{
      _purchasesKey: purchases,
      _choiceKey: choices.firstOrNull,
    };
  }

  @override
  Future<List<String>> importSection(
    Transaction transaction, {
    required Map<String, Object?> content,
    required BackupIdMap ids,
  }) async {
    final List<ShopPurchaseLocalModel> purchases = BackupSectionReader.readRows(
      content,
      key: _purchasesKey,
      fromJson: ShopPurchaseLocalModel.fromJson,
    );
    final ShopChoiceLocalModel? choice = BackupSectionReader.readRow(
      content,
      key: _choiceKey,
      fromJson: ShopChoiceLocalModel.fromJson,
    );
    for (final ShopPurchaseLocalModel purchase in purchases) {
      // An item listed twice in a file is bought once.
      await transaction.insert(
        ShopTables.purchase,
        <String, Object?>{
          ...purchase.toJson(),
          'id': ids.remap(purchase.id),
          'profile_id': ids.profileId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    if (choice != null) {
      await transaction.insert(ShopTables.choice, <String, Object?>{
        ...choice.toJson(),
        'profile_id': ids.profileId,
      });
    }
    return const <String>[ShopTables.purchase, ShopTables.choice];
  }
}
