import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_catalog.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_entity.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer_status.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_purchase.dart';
import 'package:kid_matix/features/shop/domain/services/coin_rules.dart';
import 'package:kid_matix/features/shop/domain/usecases/shop_item_params.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/shop_fakes.dart';

ShopPurchase _purchase(String itemId, int price) {
  return ShopPurchase(
    itemId: itemId,
    price: price,
    purchasedAt: DateTime(2026, 10, 12),
  );
}

ShopItemParams _params(String itemId) {
  return ShopItemParams(profileId: 'p1', itemId: itemId);
}

void main() {
  group('CoinRules', () {
    const CoinRules rules = CoinRules();

    test('gives one coin every 10 XP, the rest counting later', () {
      // Act and assert
      expect(rules.earnedFrom(totalXp: 0, crowns: 0, badges: 0), 0);
      expect(rules.earnedFrom(totalXp: 9, crowns: 0, badges: 0), 0);
      expect(rules.earnedFrom(totalXp: 59, crowns: 0, badges: 0), 5);
      expect(rules.earnedFrom(totalXp: 60, crowns: 0, badges: 0), 6);
    });

    test('gives 20 coins per crown and 10 per badge', () {
      // Act and assert
      expect(rules.earnedFrom(totalXp: 0, crowns: 1, badges: 0), 20);
      expect(rules.earnedFrom(totalXp: 0, crowns: 0, badges: 2), 20);
      expect(rules.earnedFrom(totalXp: 125, crowns: 3, badges: 4), 112);
    });
  });

  group('ShopCatalog', () {
    test('sells 8 avatars from 80 to 300 coins and keeps 12 free', () {
      // Arrange
      final Iterable<ShopItem> priced = ShopCatalog.avatars.where(
        (ShopItem item) => !item.isFree,
      );
      // Assert
      expect(priced, hasLength(8));
      expect(
        priced.map((ShopItem item) => item.price),
        everyElement(inInclusiveRange(80, 300)),
      );
      expect(
        ShopCatalog.avatars.where((ShopItem item) => item.isFree),
        hasLength(12),
      );
    });

    test('sells 4 themes from 150 to 250 coins, lavender free', () {
      // Arrange
      final Iterable<ShopItem> priced = ShopCatalog.themes.where(
        (ShopItem item) => !item.isFree,
      );
      // Assert
      expect(
        priced.map((ShopItem item) => item.key),
        <String>['ocean', 'forest', 'sunset', 'night'],
      );
      expect(
        priced.map((ShopItem item) => item.price),
        everyElement(inInclusiveRange(150, 250)),
      );
      expect(ShopCatalog.themeItemOf(AppColorTheme.lavender).isFree, isTrue);
      expect(
        ShopCatalog.themes.map((ShopItem item) => item.key),
        AppColorTheme.values.map((AppColorTheme theme) => theme.name),
      );
    });

    test('finds an item by its identifier', () {
      // Act and assert
      expect(ShopCatalog.findById('avatar:king')!.price, 300);
      expect(ShopCatalog.findById('theme:night')!.kind, ShopItemKind.theme);
      expect(ShopCatalog.findById('avatar:dinosaur'), isNull);
      expect(
        ShopCatalog.items.map((ShopItem item) => item.id).toSet(),
        hasLength(ShopCatalog.items.length),
      );
    });
  });

  group('GetShopUseCase', () {
    test('counts the coins earned minus the coins spent', () async {
      // Arrange
      final ShopWorld world = ShopWorld(
        totalXp: 1234,
        badges: <String>{'firstStep', 'regular'},
        crowns: 2,
        purchases: <ShopPurchase>[_purchase('avatar:fox', 80)],
      );
      // Act
      final ShopEntity actualShop = (await world.getShop(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actualShop.balance, 123 + 40 + 20 - 80);
      expect(actualShop.player.nickname, 'Awa');
      expect(actualShop.activeTheme, AppColorTheme.lavender);
    });

    test('tells what is worn, owned, affordable or too expensive', () async {
      // Arrange
      final ShopWorld world = ShopWorld(
        totalXp: 1500,
        purchases: <ShopPurchase>[_purchase('avatar:fox', 80)],
        avatarKey: 'avatar3',
      );
      // Act
      final ShopEntity actualShop = (await world.getShop(
        params: 'p1',
      )).requireData;
      // Assert: 150 earned, 70 left.
      expect(actualShop.balance, 70);
      expect(
        actualShop.findOffer('avatar:avatar3')!.status,
        ShopOfferStatus.inUse,
      );
      expect(
        actualShop.findOffer('avatar:avatar1')!.status,
        ShopOfferStatus.owned,
      );
      expect(actualShop.findOffer('avatar:fox')!.status, ShopOfferStatus.owned);
      expect(
        actualShop.findOffer('theme:lavender')!.status,
        ShopOfferStatus.inUse,
      );
      final ShopOffer actualPanda = actualShop.findOffer('avatar:panda')!;
      expect(actualPanda.status, ShopOfferStatus.tooExpensive);
      expect(actualPanda.missingCoins, 10);
      expect(actualPanda.isOwned, isFalse);
      expect(actualShop.offersOf(ShopItemKind.theme), hasLength(5));
      expect(actualShop.offersOf(ShopItemKind.avatar), hasLength(20));
      expect(actualShop.findOffer('avatar:dinosaur'), isNull);
    });

    test('offers what the coins can buy', () async {
      // Arrange
      final ShopWorld world = ShopWorld(totalXp: 800);
      // Act
      final ShopEntity actualShop = (await world.getShop(
        params: 'p1',
      )).requireData;
      // Assert
      expect(
        actualShop.findOffer('avatar:fox')!.status,
        ShopOfferStatus.affordable,
      );
      expect(actualShop.findOffer('avatar:fox')!.missingCoins, 0);
      expect(
        actualShop.findOffer('theme:ocean')!.status,
        ShopOfferStatus.tooExpensive,
      );
    });

    test('counts the avatar worn as owned after a reset', () async {
      // Arrange: no coins and no purchase, but the king is worn.
      final ShopWorld world = ShopWorld(avatarKey: 'king');
      // Act
      final ShopEntity actualShop = (await world.getShop(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actualShop.balance, 0);
      expect(
        actualShop.findOffer('avatar:king')!.status,
        ShopOfferStatus.inUse,
      );
    });

    test('never shows fewer than 0 coins', () async {
      // Arrange
      final ShopWorld world = ShopWorld(
        purchases: <ShopPurchase>[_purchase('avatar:fox', 80)],
      );
      // Act
      final ShopEntity actualShop = (await world.getShop(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actualShop.balance, 0);
    });

    test('fails when one of the reads fails', () async {
      // Arrange
      final ShopWorld world = ShopWorld()
        ..rewards.failure = const CacheException();
      // Act
      final DataState<ShopEntity> actualShop = await world.getShop(
        params: 'p1',
      );
      // Assert
      expect(actualShop.exceptionOrNull?.code, AppErrorCode.cache);
    });
  });

  group('BuyShopItemUseCase', () {
    test('spends the coins and owns the item', () async {
      // Arrange
      final ShopWorld world = ShopWorld(totalXp: 1500);
      // Act
      final DataState<void> actualResult = await world.buy(
        params: _params('avatar:robot'),
      );
      final ShopEntity actualShop = (await world.getShop(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actualResult, isA<DataSuccess<void>>());
      expect(
        world.repository.purchases.single,
        ShopPurchase(
          itemId: 'avatar:robot',
          price: 120,
          purchasedAt: ShopClock.instant,
        ),
      );
      expect(actualShop.balance, 150 - 120);
      expect(
        actualShop.findOffer('avatar:robot')!.status,
        ShopOfferStatus.owned,
      );
    });

    test('refuses an item the player cannot afford', () async {
      // Arrange
      final ShopWorld world = ShopWorld(totalXp: 790);
      // Act
      final DataState<void> actualResult = await world.buy(
        params: _params('avatar:fox'),
      );
      // Assert
      expect(actualResult.exceptionOrNull, isA<ValidationException>());
      expect(world.repository.purchases, isEmpty);
    });

    test('refuses an item owned or unknown', () async {
      // Arrange
      final ShopWorld world = ShopWorld(
        totalXp: 5000,
        purchases: <ShopPurchase>[_purchase('theme:night', 250)],
      );
      // Act
      final DataState<void> actualBought = await world.buy(
        params: _params('theme:night'),
      );
      final DataState<void> actualFree = await world.buy(
        params: _params('avatar:avatar2'),
      );
      final DataState<void> actualUnknown = await world.buy(
        params: _params('avatar:dinosaur'),
      );
      // Assert
      expect(actualBought.exceptionOrNull, isA<ConflictException>());
      expect(actualFree.exceptionOrNull, isA<ConflictException>());
      expect(actualUnknown.exceptionOrNull, isA<NotFoundException>());
      expect(world.repository.purchases, hasLength(1));
    });

    test('fails when the shop cannot be read', () async {
      // Arrange
      final ShopWorld world = ShopWorld()
        ..repository.failure = const CacheException();
      // Act
      final DataState<void> actualResult = await world.buy(
        params: _params('avatar:fox'),
      );
      // Assert
      expect(actualResult.exceptionOrNull, isA<CacheException>());
    });
  });

  group('UseShopItemUseCase', () {
    test('puts on an avatar the player owns', () async {
      // Arrange
      final ShopWorld world = ShopWorld(
        purchases: <ShopPurchase>[_purchase('avatar:ninja', 250)],
      );
      // Act
      final DataState<void> actualBought = await world.use(
        params: _params('avatar:ninja'),
      );
      final String actualAfterBought = world.players.avatarKey;
      final DataState<void> actualFree = await world.use(
        params: _params('avatar:avatar7'),
      );
      // Assert
      expect(actualBought, isA<DataSuccess<void>>());
      expect(actualAfterBought, 'ninja');
      expect(actualFree, isA<DataSuccess<void>>());
      expect(world.players.avatarKey, 'avatar7');
    });

    test('applies a theme the player owns', () async {
      // Arrange
      final ShopWorld world = ShopWorld(
        purchases: <ShopPurchase>[_purchase('theme:night', 250)],
      );
      // Act
      await world.use(params: _params('theme:night'));
      final AppColorTheme actualNight = world.repository.theme;
      await world.use(params: _params('theme:lavender'));
      // Assert
      expect(actualNight, AppColorTheme.night);
      expect(world.repository.theme, AppColorTheme.lavender);
    });

    test('refuses an item not owned or unknown', () async {
      // Arrange
      final ShopWorld world = ShopWorld(totalXp: 5000);
      // Act
      final DataState<void> actualNotOwned = await world.use(
        params: _params('theme:forest'),
      );
      final DataState<void> actualUnknown = await world.use(
        params: _params('theme:desert'),
      );
      // Assert
      expect(actualNotOwned.exceptionOrNull, isA<ValidationException>());
      expect(actualUnknown.exceptionOrNull, isA<NotFoundException>());
      expect(world.repository.theme, AppColorTheme.lavender);
    });

    test('fails when the shop cannot be read', () async {
      // Arrange
      final ShopWorld world = ShopWorld()
        ..players.failure = const CacheException();
      // Act
      final DataState<void> actualResult = await world.use(
        params: _params('avatar:avatar2'),
      );
      // Assert
      expect(actualResult.exceptionOrNull, isA<CacheException>());
    });
  });

  group('Watching', () {
    test('tells when the coins, the purchases or the avatar change', () async {
      // Arrange
      final ShopWorld world = ShopWorld();
      final List<void> actualEvents = <void>[];
      final subscription = world.useCases.watchChanges().listen(
        actualEvents.add,
      );
      // Act
      world.rewards.changes.add(null);
      world.repository.changes.add(null);
      world.players.changes.add(null);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      // Assert
      expect(actualEvents, hasLength(3));
    });

    test('reads the theme and tells when it changes', () async {
      // Arrange
      final ShopWorld world = ShopWorld();
      world.repository.theme = AppColorTheme.sunset;
      final Future<void> actualChange = world.useCases
          .watchThemeChanges()
          .first;
      // Act
      final AppColorTheme actualTheme = (await world.useCases.getActiveTheme(
        params: 'p1',
      )).requireData;
      world.repository.changes.add(null);
      // Assert
      expect(actualTheme, AppColorTheme.sunset);
      await expectLater(actualChange, completes);
    });
  });

  group('Entities', () {
    test('compare by value', () {
      // Arrange
      const ShopItem inputItem = ShopItem(
        kind: ShopItemKind.avatar,
        key: 'fox',
        price: 80,
      );
      const ShopOffer inputOffer = ShopOffer(
        item: inputItem,
        status: ShopOfferStatus.affordable,
      );
      final ShopPurchase inputPurchase = _purchase('avatar:fox', 80);
      // Assert
      expect(
        inputItem,
        const ShopItem(kind: ShopItemKind.avatar, key: 'fox', price: 80),
      );
      expect(inputItem.hashCode, ShopCatalog.avatars.first.hashCode);
      expect(inputItem.toString(), 'ShopItem(avatar:fox, 80)');
      expect(
        inputOffer,
        const ShopOffer(item: inputItem, status: ShopOfferStatus.affordable),
      );
      expect(inputOffer.hashCode, isNot(0));
      expect(inputOffer.toString(), 'ShopOffer(avatar:fox, affordable)');
      expect(inputPurchase, _purchase('avatar:fox', 80));
      expect(inputPurchase.hashCode, _purchase('avatar:fox', 80).hashCode);
      expect(inputPurchase.toString(), 'ShopPurchase(avatar:fox, 80)');
    });

    test('compare shops by value', () async {
      // Arrange
      final ShopWorld world = ShopWorld(totalXp: 900);
      final ShopEntity inputShop = (await world.getShop(
        params: 'p1',
      )).requireData;
      final ShopEntity inputSame = (await world.getShop(
        params: 'p1',
      )).requireData;
      world.rewards.totalXp = 2000;
      final ShopEntity inputOther = (await world.getShop(
        params: 'p1',
      )).requireData;
      // Assert
      expect(inputShop, inputSame);
      expect(inputShop.hashCode, inputSame.hashCode);
      expect(inputShop, isNot(inputOther));
      expect(inputShop.toString(), 'ShopEntity(p1, 90 coins)');
    });
  });
}
