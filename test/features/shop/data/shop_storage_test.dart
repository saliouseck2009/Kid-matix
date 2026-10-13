import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/services/uuid_id_generator.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/backup_id_map.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/shop/data/datasources/shop_local_data_source_impl.dart';
import 'package:kid_matix/features/shop/data/repositories/shop_backup_part.dart';
import 'package:kid_matix/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:kid_matix/features/shop/data/repositories/shop_reset_hook.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_purchase.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/shop_fakes.dart';

AppDatabase _open(int version, String path) {
  return AppDatabase(
    databaseFactory: databaseFactoryFfi,
    resolvePath: () async => path,
    migrationRunner: MigrationRunner(
      migrations: appMigrations.take(version).toList(),
    ),
  );
}

Map<String, Object?> _profileRow(String id) {
  return <String, Object?>{
    'id': id,
    'nickname': 'Player $id',
    'normalized_nickname': 'player $id',
    'avatar': 'avatar1',
    'color': 'violet',
    'created_at': 0,
    'updated_at': 0,
  };
}

ShopPurchase _purchase(String itemId, int price) {
  return ShopPurchase(
    itemId: itemId,
    price: price,
    purchasedAt: DateTime(2026, 10, 12, 9),
  );
}

void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late ShopRepositoryImpl repository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = _open(appMigrations.length, inMemoryDatabasePath);
    final Database database = await appDatabase.database;
    await database.insert('profile', _profileRow('p1'));
    await database.insert('profile', _profileRow('p2'));
    changeBus = TableChangeBus();
    repository = ShopRepositoryImpl(
      shop: ShopLocalDataSourceImpl(database: appDatabase),
      ids: const UuidIdGenerator(),
      clock: const ShopClock(),
      changeBus: changeBus,
    );
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  group('ShopRepositoryImpl', () {
    test('has no purchase and the lavender theme at first', () async {
      // Act
      final List<ShopPurchase> actualPurchases = (await repository.getPurchases(
        profileId: 'p1',
      )).requireData;
      final AppColorTheme actualTheme = (await repository.getActiveTheme(
        profileId: 'p1',
      )).requireData;
      // Assert
      expect(actualPurchases, isEmpty);
      expect(actualTheme, AppColorTheme.lavender);
    });

    test('saves purchases, oldest first, and tells it', () async {
      // Arrange
      final Future<void> actualChange = repository.watchChanges().first;
      // Act
      await repository.addPurchase(
        profileId: 'p1',
        purchase: _purchase('avatar:fox', 80),
      );
      await repository.addPurchase(
        profileId: 'p1',
        purchase: ShopPurchase(
          itemId: 'theme:night',
          price: 250,
          purchasedAt: DateTime(2026, 10, 13),
        ),
      );
      final List<ShopPurchase> actualPurchases = (await repository.getPurchases(
        profileId: 'p1',
      )).requireData;
      final List<ShopPurchase> actualOther = (await repository.getPurchases(
        profileId: 'p2',
      )).requireData;
      // Assert
      await expectLater(actualChange, completes);
      expect(
        actualPurchases.map((ShopPurchase purchase) => purchase.itemId),
        <String>['avatar:fox', 'theme:night'],
      );
      expect(actualPurchases.first, _purchase('avatar:fox', 80));
      expect(actualOther, isEmpty);
    });

    test('refuses to buy the same item twice', () async {
      // Arrange
      await repository.addPurchase(
        profileId: 'p1',
        purchase: _purchase('avatar:fox', 80),
      );
      // Act
      final AppException? actualException = (await repository.addPurchase(
        profileId: 'p1',
        purchase: _purchase('avatar:fox', 80),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ConflictException>());
    });

    test('applies a theme and reads it back', () async {
      // Arrange
      final Future<void> actualChange = repository.watchChanges().first;
      // Act
      await repository.saveActiveTheme(
        profileId: 'p1',
        theme: AppColorTheme.forest,
      );
      await repository.saveActiveTheme(
        profileId: 'p1',
        theme: AppColorTheme.night,
      );
      final AppColorTheme actualTheme = (await repository.getActiveTheme(
        profileId: 'p1',
      )).requireData;
      // Assert
      await expectLater(actualChange, completes);
      expect(actualTheme, AppColorTheme.night);
    });

    test('reads an unknown theme as lavender', () async {
      // Arrange
      await (await appDatabase.database).insert(
        'shop_choice',
        <String, Object?>{
          'profile_id': 'p1',
          'theme_id': 'rainbow',
          'updated_at': 0,
        },
      );
      // Act
      final AppColorTheme actualTheme = (await repository.getActiveTheme(
        profileId: 'p1',
      )).requireData;
      // Assert
      expect(actualTheme, AppColorTheme.lavender);
    });

    test('fails as a cache failure once the database is closed', () async {
      // Arrange
      await (await appDatabase.database).close();
      // Act
      final List<AppException?> actualExceptions = <AppException?>[
        (await repository.getPurchases(profileId: 'p1')).exceptionOrNull,
        (await repository.addPurchase(
          profileId: 'p1',
          purchase: _purchase('avatar:fox', 80),
        )).exceptionOrNull,
        (await repository.getActiveTheme(profileId: 'p1')).exceptionOrNull,
        (await repository.saveActiveTheme(
          profileId: 'p1',
          theme: AppColorTheme.ocean,
        )).exceptionOrNull,
      ];
      // Assert
      expect(actualExceptions, everyElement(isA<CacheException>()));
    });
  });

  group('Progress reset and deletion', () {
    test('takes back the purchases and the theme of one player', () async {
      // Arrange
      for (final String profileId in <String>['p1', 'p2']) {
        await repository.addPurchase(
          profileId: profileId,
          purchase: _purchase('theme:ocean', 150),
        );
        await repository.saveActiveTheme(
          profileId: profileId,
          theme: AppColorTheme.ocean,
        );
      }
      final Database database = await appDatabase.database;
      // Act
      final List<String> actualTables = await database.transaction(
        (Transaction transaction) =>
            const ShopResetHook().reset(transaction, profileId: 'p1'),
      );
      // Assert
      expect(actualTables, <String>['shop_purchase', 'shop_choice']);
      expect(
        (await repository.getPurchases(profileId: 'p1')).requireData,
        isEmpty,
      );
      expect(
        (await repository.getActiveTheme(profileId: 'p1')).requireData,
        AppColorTheme.lavender,
      );
      expect(
        (await repository.getPurchases(profileId: 'p2')).requireData,
        hasLength(1),
      );
      expect(
        (await repository.getActiveTheme(profileId: 'p2')).requireData,
        AppColorTheme.ocean,
      );
    });

    test('deletes the rows with the player', () async {
      // Arrange
      await repository.addPurchase(
        profileId: 'p1',
        purchase: _purchase('avatar:fox', 80),
      );
      await repository.saveActiveTheme(
        profileId: 'p1',
        theme: AppColorTheme.night,
      );
      final Database database = await appDatabase.database;
      // Act
      await database.delete(
        'profile',
        where: 'id = ?',
        whereArgs: <Object>['p1'],
      );
      // Assert
      expect(await database.query('shop_purchase'), isEmpty);
      expect(await database.query('shop_choice'), isEmpty);
    });
  });

  group('ShopBackupPart', () {
    test('exports the shop of a player and imports it for another', () async {
      // Arrange
      await repository.addPurchase(
        profileId: 'p1',
        purchase: _purchase('avatar:fox', 80),
      );
      await repository.addPurchase(
        profileId: 'p1',
        purchase: _purchase('theme:night', 250),
      );
      await repository.saveActiveTheme(
        profileId: 'p1',
        theme: AppColorTheme.night,
      );
      final Database database = await appDatabase.database;
      const ShopBackupPart part = ShopBackupPart();
      final Map<String, Object?> exported = await part.exportSection(
        database,
        profileId: 'p1',
      );
      final Map<String, Object?> duplicated = <String, Object?>{
        ...exported,
        'purchases': <Object?>[
          ...exported['purchases']! as List<Object?>,
          (exported['purchases']! as List<Object?>).first,
        ],
      };
      // Act
      final List<String> actualTables = await database.transaction(
        (Transaction transaction) => part.importSection(
          transaction,
          content: duplicated,
          ids: BackupIdMap(
            profileId: 'p2',
            idGenerator: const UuidIdGenerator(),
          ),
        ),
      );
      // Assert
      expect(part.section, 'shop');
      expect(actualTables, <String>['shop_purchase', 'shop_choice']);
      expect(
        (await repository.getPurchases(profileId: 'p2')).requireData,
        unorderedEquals(
          (await repository.getPurchases(profileId: 'p1')).requireData,
        ),
      );
      expect(
        (await repository.getActiveTheme(profileId: 'p2')).requireData,
        AppColorTheme.night,
      );
      expect(await database.query('shop_purchase'), hasLength(4));
    });

    test('reads a section without rows and refuses a malformed one', () async {
      // Arrange
      final Database database = await appDatabase.database;
      const ShopBackupPart part = ShopBackupPart();
      final BackupIdMap ids = BackupIdMap(
        profileId: 'p2',
        idGenerator: const UuidIdGenerator(),
      );
      // Act
      await database.transaction(
        (Transaction transaction) => part.importSection(
          transaction,
          content: const <String, Object?>{},
          ids: ids,
        ),
      );
      // Assert
      expect(await database.query('shop_purchase'), isEmpty);
      expect(
        () => database.transaction(
          (Transaction transaction) => part.importSection(
            transaction,
            content: const <String, Object?>{'purchases': 'none'},
            ids: ids,
          ),
        ),
        throwsFormatException,
      );
    });
  });
}
