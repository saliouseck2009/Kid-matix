import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/shop/data/datasources/shop_local_data_source.dart';
import 'package:kid_matix/features/shop/data/datasources/shop_tables.dart';
import 'package:kid_matix/features/shop/data/models/shop_choice_local_model.dart';
import 'package:kid_matix/features/shop/data/models/shop_purchase_local_model.dart';
import 'package:sqflite/sqflite.dart';

/// [ShopLocalDataSource] over the app database.
final class ShopLocalDataSourceImpl implements ShopLocalDataSource {
  /// Creates the data source over [database].
  const ShopLocalDataSourceImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<List<ShopPurchaseLocalModel>> getPurchases({
    required String profileId,
  }) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ShopTables.purchase,
      where: 'profile_id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[profileId],
      orderBy: 'purchased_at, id',
    );
    return rows.map(ShopPurchaseLocalModel.fromJson).toList();
  }

  @override
  Future<void> insertPurchase({
    required ShopPurchaseLocalModel purchase,
  }) async {
    final Database database = await _database.database;
    await database.insert(ShopTables.purchase, purchase.toJson());
  }

  @override
  Future<ShopChoiceLocalModel?> getChoice({required String profileId}) async {
    final Database database = await _database.database;
    final List<Map<String, Object?>> rows = await database.query(
      ShopTables.choice,
      where: 'profile_id = ? AND deleted_at IS NULL',
      whereArgs: <Object>[profileId],
    );
    return rows.isEmpty ? null : ShopChoiceLocalModel.fromJson(rows.single);
  }

  @override
  Future<void> upsertChoice({required ShopChoiceLocalModel choice}) async {
    final Database database = await _database.database;
    await database.insert(
      ShopTables.choice,
      choice.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
