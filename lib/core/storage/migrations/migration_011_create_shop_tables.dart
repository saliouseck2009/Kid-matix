import 'package:kid_matix/core/storage/database_migration.dart';
import 'package:sqflite/sqflite.dart';

/// Schema version 11: the shop (lot F21).
///
/// `shop_purchase` keeps each item a player bought, once, with the coins
/// it cost; `shop_choice` keeps the color theme a player applied. The
/// coins earned are not stored: they follow from the XP, crowns and
/// badges. Deleting a profile deletes its rows. The SQL is written out
/// in full: a released migration never changes.
final class Migration011CreateShopTables implements DatabaseMigration {
  /// Creates the migration.
  const Migration011CreateShopTables();

  @override
  int get version => 11;

  @override
  Future<void> migrate(Database database) async {
    await database.execute('''
      CREATE TABLE shop_purchase (
        id TEXT PRIMARY KEY NOT NULL,
        profile_id TEXT NOT NULL
          REFERENCES profile (id) ON DELETE CASCADE,
        item_id TEXT NOT NULL,
        price INTEGER NOT NULL,
        purchased_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER,
        UNIQUE (profile_id, item_id)
      )
    ''');
    await database.execute('''
      CREATE TABLE shop_choice (
        profile_id TEXT PRIMARY KEY NOT NULL
          REFERENCES profile (id) ON DELETE CASCADE,
        theme_id TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        deleted_at INTEGER
      )
    ''');
  }
}
