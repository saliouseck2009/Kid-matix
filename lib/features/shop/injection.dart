import 'package:get_it/get_it.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/features/shop/data/datasources/shop_local_data_source.dart';
import 'package:kid_matix/features/shop/data/datasources/shop_local_data_source_impl.dart';
import 'package:kid_matix/features/shop/data/repositories/shop_backup_part.dart';
import 'package:kid_matix/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:kid_matix/features/shop/data/repositories/shop_reset_hook.dart';
import 'package:kid_matix/features/shop/domain/repositories/shop_repository.dart';
import 'package:kid_matix/features/shop/domain/usecases/buy_shop_item_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_active_theme_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_shop_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/use_shop_item_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/watch_shop_changes_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/watch_theme_changes_use_case.dart';

/// Registers the shop feature in [sl], with its reset hook and backup
/// part; Blocs are never registered.
void registerShopFeature(GetIt sl) {
  sl.registerLazySingleton<ShopLocalDataSource>(
    () => ShopLocalDataSourceImpl(database: sl()),
  );
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(
      shop: sl(),
      ids: sl(),
      clock: sl(),
      changeBus: sl(),
    ),
  );
  sl.registerLazySingleton<GetShopUseCase>(
    () => GetShopUseCase(
      repository: sl(),
      rewards: sl(),
      crowns: sl(),
      players: sl(),
    ),
  );
  sl.registerLazySingleton<BuyShopItemUseCase>(
    () => BuyShopItemUseCase(repository: sl(), getShop: sl(), clock: sl()),
  );
  sl.registerLazySingleton<UseShopItemUseCase>(
    () => UseShopItemUseCase(repository: sl(), getShop: sl(), players: sl()),
  );
  sl.registerLazySingleton<WatchShopChangesUseCase>(
    () => WatchShopChangesUseCase(
      repository: sl(),
      rewards: sl(),
      crowns: sl(),
      players: sl(),
    ),
  );
  sl.registerLazySingleton<GetActiveThemeUseCase>(
    () => GetActiveThemeUseCase(repository: sl()),
  );
  sl.registerLazySingleton<WatchThemeChangesUseCase>(
    () => WatchThemeChangesUseCase(repository: sl()),
  );
  sl<ProgressResetHooks>().add(const ShopResetHook());
  sl<ProfileBackupParts>().add(const ShopBackupPart());
}
