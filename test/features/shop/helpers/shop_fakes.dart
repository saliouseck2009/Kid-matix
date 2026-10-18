import 'dart:async';

import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/player_avatar_service.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_purchase.dart';
import 'package:kid_matix/features/shop/domain/repositories/shop_repository.dart';
import 'package:kid_matix/features/shop/domain/usecases/buy_shop_item_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_active_theme_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_shop_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/use_shop_item_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/watch_shop_changes_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/watch_theme_changes_use_case.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_use_cases.dart';

import '../../../helpers/fixed_progress_services.dart';

/// A clock stopped on [instant].
final class ShopClock implements Clock {
  /// Creates the clock.
  const ShopClock();

  /// Moment returned.
  static final DateTime instant = DateTime(2026, 10, 13, 17);

  @override
  DateTime now() => instant;
}

/// [ShopRepository] in memory.
final class InMemoryShopRepository implements ShopRepository {
  /// Creates the repository with [purchases] and [theme].
  InMemoryShopRepository({
    List<ShopPurchase>? purchases,
    this.theme = AppColorTheme.lavender,
  }) : purchases = purchases ?? <ShopPurchase>[];

  /// Purchases saved.
  final List<ShopPurchase> purchases;

  /// Theme applied.
  AppColorTheme theme;

  /// Failure of every call, or `null`.
  AppException? failure;

  /// Changes sent to the watchers.
  final StreamController<void> changes = StreamController<void>.broadcast();

  @override
  Future<DataState<List<ShopPurchase>>> getPurchases({
    required String profileId,
  }) async {
    final AppException? error = failure;
    if (error != null) return DataFailed<List<ShopPurchase>>(error);
    return DataSuccess<List<ShopPurchase>>(List<ShopPurchase>.of(purchases));
  }

  @override
  Future<DataState<void>> addPurchase({
    required String profileId,
    required ShopPurchase purchase,
  }) async {
    final AppException? error = failure;
    if (error != null) return DataFailed<void>(error);
    purchases.add(purchase);
    changes.add(null);
    return const DataSuccess<void>(null);
  }

  @override
  Future<DataState<AppColorTheme>> getActiveTheme({
    required String profileId,
  }) async {
    final AppException? error = failure;
    if (error != null) return DataFailed<AppColorTheme>(error);
    return DataSuccess<AppColorTheme>(theme);
  }

  @override
  Future<DataState<void>> saveActiveTheme({
    required String profileId,
    required AppColorTheme theme,
  }) async {
    final AppException? error = failure;
    if (error != null) return DataFailed<void>(error);
    this.theme = theme;
    changes.add(null);
    return const DataSuccess<void>(null);
  }

  @override
  Stream<void> watchChanges() => changes.stream;
}

/// [PlayerAvatarService] over one player in memory.
final class FakePlayerAvatarService implements PlayerAvatarService {
  /// Creates the service of a player wearing [avatarKey].
  FakePlayerAvatarService({this.avatarKey = 'avatar1'});

  /// Avatar worn.
  String avatarKey;

  /// Failure of every call, or `null`.
  AppException? failure;

  /// Changes sent to the watchers.
  final StreamController<void> changes = StreamController<void>.broadcast();

  @override
  Future<DataState<PlayerIdentity>> readPlayer({
    required String profileId,
  }) async {
    final AppException? error = failure;
    if (error != null) return DataFailed<PlayerIdentity>(error);
    return DataSuccess<PlayerIdentity>(
      PlayerIdentity(
        id: profileId,
        nickname: 'Awa',
        avatarKey: avatarKey,
        colorKey: 'green',
      ),
    );
  }

  @override
  Future<DataState<void>> wearAvatar({
    required String profileId,
    required String avatarKey,
  }) async {
    final AppException? error = failure;
    if (error != null) return DataFailed<void>(error);
    this.avatarKey = avatarKey;
    changes.add(null);
    return const DataSuccess<void>(null);
  }

  @override
  Stream<void> watchChanges() => changes.stream;
}

/// The shop of one player over fakes: XP, badges and crowns, purchases
/// and the avatar worn.
final class ShopWorld {
  /// Creates the world.
  ShopWorld({
    int totalXp = 0,
    Set<String> badges = const <String>{},
    int crowns = 0,
    List<ShopPurchase>? purchases,
    String avatarKey = 'avatar1',
  }) : rewards = FixedRewardService(totalXp: totalXp, badges: badges),
       crowns = FixedCrownService(crowns: crowns),
       repository = InMemoryShopRepository(purchases: purchases),
       players = FakePlayerAvatarService(avatarKey: avatarKey);

  /// XP and badges.
  final FixedRewardService rewards;

  /// Crowns.
  final FixedCrownService crowns;

  /// Purchases and theme.
  final InMemoryShopRepository repository;

  /// Avatar worn.
  final FakePlayerAvatarService players;

  /// Reads the shop.
  GetShopUseCase get getShop => GetShopUseCase(
    repository: repository,
    rewards: rewards,
    crowns: crowns,
    players: players,
  );

  /// Buys an item.
  BuyShopItemUseCase get buy => BuyShopItemUseCase(
    repository: repository,
    getShop: getShop,
    clock: const ShopClock(),
  );

  /// Wears or applies an item.
  UseShopItemUseCase get use => UseShopItemUseCase(
    repository: repository,
    getShop: getShop,
    players: players,
  );

  /// The use cases of the screens.
  ShopUseCases get useCases => ShopUseCases(
    getShop: getShop,
    buy: buy,
    use: use,
    watchChanges: WatchShopChangesUseCase(
      repository: repository,
      rewards: rewards,
      crowns: crowns,
      players: players,
    ),
    getActiveTheme: GetActiveThemeUseCase(repository: repository),
    watchThemeChanges: WatchThemeChangesUseCase(repository: repository),
  );
}
