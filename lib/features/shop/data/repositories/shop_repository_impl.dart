import 'dart:developer';

import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/shop/data/datasources/shop_local_data_source.dart';
import 'package:kid_matix/features/shop/data/datasources/shop_tables.dart';
import 'package:kid_matix/features/shop/data/models/shop_choice_local_model.dart';
import 'package:kid_matix/features/shop/data/models/shop_purchase_local_model.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_purchase.dart';
import 'package:kid_matix/features/shop/domain/repositories/shop_repository.dart';
import 'package:sqflite/sqflite.dart';

/// [ShopRepository] over the local database.
final class ShopRepositoryImpl implements ShopRepository {
  /// Creates the repository.
  const ShopRepositoryImpl({
    required this._shop,
    required this._ids,
    required this._clock,
    required this._changeBus,
  });

  static const String _logName = 'shop';

  final ShopLocalDataSource _shop;
  final IdGenerator _ids;
  final Clock _clock;
  final TableChangeBus _changeBus;

  @override
  Future<DataState<List<ShopPurchase>>> getPurchases({
    required String profileId,
  }) async {
    try {
      final List<ShopPurchaseLocalModel> rows = await _shop.getPurchases(
        profileId: profileId,
      );
      return DataSuccess<List<ShopPurchase>>(
        rows.map((ShopPurchaseLocalModel row) => row.toEntity()).toList(),
      );
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Purchases not read', error, stackTrace);
    }
  }

  @override
  Future<DataState<void>> addPurchase({
    required String profileId,
    required ShopPurchase purchase,
  }) async {
    try {
      await _shop.insertPurchase(
        purchase: ShopPurchaseLocalModel.fromEntity(
          id: _ids.generateId(),
          profileId: profileId,
          purchase: purchase,
        ),
      );
      _changeBus.notifyChanged(table: ShopTables.purchase);
      return const DataSuccess<void>(null);
    } on DatabaseException catch (error, stackTrace) {
      if (error.isUniqueConstraintError()) {
        log('Item already bought', name: _logName, error: error);
        return DataFailed<void>(ConflictException(message: error.toString()));
      }
      return _fail('Purchase not saved', error, stackTrace);
    }
  }

  @override
  Future<DataState<AppColorTheme>> getActiveTheme({
    required String profileId,
  }) async {
    try {
      final ShopChoiceLocalModel? row = await _shop.getChoice(
        profileId: profileId,
      );
      return DataSuccess<AppColorTheme>(
        row?.toTheme() ?? AppColorTheme.lavender,
      );
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Theme not read', error, stackTrace);
    }
  }

  @override
  Future<DataState<void>> saveActiveTheme({
    required String profileId,
    required AppColorTheme theme,
  }) async {
    try {
      await _shop.upsertChoice(
        choice: ShopChoiceLocalModel(
          profileId: profileId,
          themeId: theme.name,
          updatedAt: _clock.now().millisecondsSinceEpoch,
        ),
      );
      _changeBus.notifyChanged(table: ShopTables.choice);
      return const DataSuccess<void>(null);
    } on DatabaseException catch (error, stackTrace) {
      return _fail('Theme not saved', error, stackTrace);
    }
  }

  @override
  Stream<void> watchChanges() {
    return _changeBus.watchTables(
      tables: const <String>{ShopTables.purchase, ShopTables.choice},
    );
  }

  DataFailed<T> _fail<T>(
    String message,
    DatabaseException error,
    StackTrace stackTrace,
  ) {
    log(message, name: _logName, error: error, stackTrace: stackTrace);
    return DataFailed<T>(CacheException(message: error.toString()));
  }
}
