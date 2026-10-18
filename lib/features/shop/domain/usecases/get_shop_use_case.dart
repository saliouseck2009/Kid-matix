import 'dart:math';

import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/core/services/player_avatar_service.dart';
import 'package:kid_matix/core/services/reward_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_catalog.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_entity.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer_status.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_purchase.dart';
import 'package:kid_matix/features/shop/domain/repositories/shop_repository.dart';
import 'package:kid_matix/features/shop/domain/services/coin_rules.dart';

/// Returns the shop of a player: their coins, the avatar worn, the theme
/// applied and every item; takes the profile id.
///
/// The coins are those earned (see [CoinRules]) minus those spent. The
/// avatar worn always counts as owned: a progress reset takes the
/// purchases back but leaves the player's avatar on.
class GetShopUseCase implements UseCase<DataState<ShopEntity>, String> {
  /// Creates the use case.
  const GetShopUseCase({
    required this._repository,
    required this._rewards,
    required this._crowns,
    required this._players,
    this._rules = const CoinRules(),
  });

  final ShopRepository _repository;
  final RewardService _rewards;
  final CrownService _crowns;
  final PlayerAvatarService _players;
  final CoinRules _rules;

  @override
  Future<DataState<ShopEntity>> call({required String params}) async {
    final DataState<PlayerIdentity> player = await _players.readPlayer(
      profileId: params,
    );
    final DataState<int> xp = await _rewards.readTotalXp(profileId: params);
    final DataState<Set<String>> badges = await _rewards.readBadgeKeys(
      profileId: params,
    );
    final DataState<int> crowns = await _crowns.readCrownCount(
      profileId: params,
    );
    final DataState<List<ShopPurchase>> purchases = await _repository
        .getPurchases(profileId: params);
    final DataState<AppColorTheme> theme = await _repository.getActiveTheme(
      profileId: params,
    );
    for (final DataState<Object?> read in <DataState<Object?>>[
      player,
      xp,
      badges,
      crowns,
      purchases,
      theme,
    ]) {
      if (read case DataFailed<Object?>(:final exception)) {
        return DataFailed<ShopEntity>(exception);
      }
    }
    final int earned = _rules.earnedFrom(
      totalXp: (xp as DataSuccess<int>).data,
      crowns: (crowns as DataSuccess<int>).data,
      badges: (badges as DataSuccess<Set<String>>).data.length,
    );
    return DataSuccess<ShopEntity>(
      _build(
        player: (player as DataSuccess<PlayerIdentity>).data,
        earned: earned,
        purchases: (purchases as DataSuccess<List<ShopPurchase>>).data,
        theme: (theme as DataSuccess<AppColorTheme>).data,
      ),
    );
  }

  ShopEntity _build({
    required PlayerIdentity player,
    required int earned,
    required List<ShopPurchase> purchases,
    required AppColorTheme theme,
  }) {
    final int spent = purchases.fold(
      0,
      (int total, ShopPurchase purchase) => total + purchase.price,
    );
    final int balance = max(0, earned - spent);
    final Set<String> bought = <String>{
      for (final ShopPurchase purchase in purchases) purchase.itemId,
    };
    return ShopEntity(
      player: player,
      balance: balance,
      activeTheme: theme,
      offers: <ShopOffer>[
        for (final ShopItem item in ShopCatalog.items)
          _offerOf(
            item,
            isInUse: _isInUse(item, player: player, theme: theme),
            isBought: bought.contains(item.id),
            balance: balance,
          ),
      ],
    );
  }

  static bool _isInUse(
    ShopItem item, {
    required PlayerIdentity player,
    required AppColorTheme theme,
  }) {
    return switch (item.kind) {
      ShopItemKind.avatar => item.key == player.avatarKey,
      ShopItemKind.theme => item.key == theme.name,
    };
  }

  static ShopOffer _offerOf(
    ShopItem item, {
    required bool isInUse,
    required bool isBought,
    required int balance,
  }) {
    if (isInUse) {
      return ShopOffer(item: item, status: ShopOfferStatus.inUse);
    }
    if (item.isFree || isBought) {
      return ShopOffer(item: item, status: ShopOfferStatus.owned);
    }
    if (item.price <= balance) {
      return ShopOffer(item: item, status: ShopOfferStatus.affordable);
    }
    return ShopOffer(
      item: item,
      status: ShopOfferStatus.tooExpensive,
      missingCoins: item.price - balance,
    );
  }
}
