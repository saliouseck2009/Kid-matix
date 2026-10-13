import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/shop/data/datasources/shop_tables.dart';
import 'package:sqflite/sqflite.dart';

/// Takes back the purchases of a player and their theme: the coins go
/// back to zero with the XP, crowns and badges they come from. The
/// avatar worn stays, like the rest of the player's identity.
final class ShopResetHook implements ProgressResetHook {
  /// Creates the hook.
  const ShopResetHook();

  @override
  Future<List<String>> reset(
    Transaction transaction, {
    required String profileId,
  }) async {
    for (final String table in <String>[
      ShopTables.purchase,
      ShopTables.choice,
    ]) {
      await transaction.delete(
        table,
        where: 'profile_id = ?',
        whereArgs: <Object>[profileId],
      );
    }
    return const <String>[ShopTables.purchase, ShopTables.choice];
  }
}
