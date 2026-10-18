import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/core/theme/app_theme_colors.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_purchase.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_cubit.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_state.dart';
import 'package:kid_matix/features/shop/presentation/shop_pages.dart';
import 'package:kid_matix/features/shop/presentation/widgets/coin_icon.dart';
import 'package:kid_matix/features/shop/presentation/widgets/theme_swatch.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

import '../../../helpers/pump_localized.dart';
import '../helpers/shop_fakes.dart';

Widget _avatarOf(PlayerIdentity player, double size) {
  return SizedBox.square(
    key: ValueKey<String>('avatar-${player.avatarKey}'),
    dimension: size,
  );
}

ShopPurchase _purchase(String itemId, int price) {
  return ShopPurchase(
    itemId: itemId,
    price: price,
    purchasedAt: DateTime(2026, 10, 12),
  );
}

Future<void> _pumpShop(WidgetTester tester, ShopWorld world) async {
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await pumpLocalized(
    tester,
    ShopPages(useCases: world.useCases).buildShopPage(
      profileId: 'p1',
      avatarOf: _avatarOf,
      onBack: () {},
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ShopPage', () {
    testWidgets('shows the coins, then the avatars two by two', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ShopWorld world = ShopWorld(
        totalXp: 2000,
        purchases: <ShopPurchase>[_purchase('avatar:panda', 80)],
        avatarKey: 'fox',
      );
      // Act
      await _pumpShop(tester, world);
      // Assert: 200 earned, 80 spent.
      expect(find.text('Boutique'), findsOneWidget);
      expect(find.bySemanticsLabel('120 pièces'), findsOneWidget);
      expect(find.text('Avatars'), findsOneWidget);
      expect(find.text('Thèmes'), findsOneWidget);
      expect(find.text('Porté'), findsOneWidget);
      expect(find.text('Choisir'), findsWidgets);
      expect(find.text('120'), findsNWidgets(2));
      expect(find.text('300'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('avatar-fox')), findsOneWidget);
    });

    testWidgets('buys an item after the confirmation', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ShopWorld world = ShopWorld(totalXp: 1000);
      await _pumpShop(tester, world);
      // Act
      await tester.tap(find.bySemanticsLabel('Acheter Renard pour 80 pièces'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Acheter Renard ?'), findsOneWidget);
      expect(
        find.text("Ça coûte 80 pièces. Il t'en restera 20."),
        findsOneWidget,
      );
      // Act
      await tester.tap(find.widgetWithText(TextButton, 'Acheter'));
      await tester.pumpAndSettle();
      // Assert
      expect(world.repository.purchases.single.itemId, 'avatar:fox');
      expect(find.textContaining('Renard est à toi'), findsOneWidget);
      expect(find.bySemanticsLabel('20 pièces'), findsOneWidget);
    });

    testWidgets('keeps the coins when the purchase is cancelled', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ShopWorld world = ShopWorld(totalXp: 1000);
      await _pumpShop(tester, world);
      // Act
      await tester.tap(find.bySemanticsLabel('Acheter Panda pour 80 pièces'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      // Assert
      expect(world.repository.purchases, isEmpty);
    });

    testWidgets('says how many coins are missing for a greyed price', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ShopWorld world = ShopWorld(totalXp: 500);
      await _pumpShop(tester, world);
      // Act
      await tester.tap(find.text('300'));
      await tester.pumpAndSettle();
      // Assert
      expect(
        find.text('Il te manque 250 pièces. Joue encore pour les gagner !'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      expect(world.repository.purchases, isEmpty);
    });

    testWidgets('wears an avatar the player owns', (WidgetTester tester) async {
      // Arrange
      final ShopWorld world = ShopWorld(
        purchases: <ShopPurchase>[_purchase('avatar:robot', 120)],
      );
      await _pumpShop(tester, world);
      // Act
      await tester.tap(find.bySemanticsLabel('Choisir Robot'));
      await tester.pumpAndSettle();
      // Assert
      expect(world.players.avatarKey, 'robot');
      expect(find.bySemanticsLabel('Robot, porté'), findsOneWidget);
    });

    testWidgets('lists the themes and applies one', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ShopWorld world = ShopWorld(
        totalXp: 1600,
        purchases: <ShopPurchase>[_purchase('theme:night', 250)],
      );
      await _pumpShop(tester, world);
      // Act
      await tester.tap(find.text('Thèmes'));
      await tester.pumpAndSettle();
      // Assert
      for (final String name in <String>[
        'Lavande',
        'Océan',
        'Forêt',
        'Coucher de soleil',
        'Nuit',
      ]) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('Actif'), findsOneWidget);
      expect(find.byType(ThemeSwatch), findsNWidgets(5));
      // Act
      await tester.ensureVisible(find.bySemanticsLabel('Choisir Nuit'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Choisir Nuit'));
      await tester.pumpAndSettle();
      // Assert
      expect(world.repository.theme, AppColorTheme.night);
      expect(find.bySemanticsLabel('Nuit, actif'), findsOneWidget);
    });

    testWidgets('shows the error, then the shop after a retry', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ShopWorld world = ShopWorld()
        ..repository.failure = const CacheException();
      await _pumpShop(tester, world);
      // Assert
      expect(
        find.text("Oups, on n'a pas pu lire ou enregistrer tes données."),
        findsOneWidget,
      );
      // Act
      world.repository.failure = null;
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('Avatars'), findsOneWidget);
    });
  });

  group('ShopCubit', () {
    test('tells when a purchase or a choice fails', () async {
      // Arrange
      final ShopWorld world = ShopWorld(totalXp: 2000);
      final ShopCubit cubit = ShopCubit(
        profileId: 'p1',
        useCases: world.useCases,
      );
      await cubit.load();
      cubit.selectTab(ShopItemKind.theme);
      final ShopLoaded loaded = cubit.state as ShopLoaded;
      world.repository.failure = const CacheException();
      // Act
      await cubit.buy(loaded.shop.findOffer('theme:ocean')!.item);
      final ShopState actualAfterBuy = cubit.state;
      await cubit.use(loaded.shop.findOffer('avatar:avatar2')!.item);
      final ShopState actualAfterUse = cubit.state;
      await cubit.close();
      // Assert
      expect((actualAfterBuy as ShopLoaded).tab, ShopItemKind.theme);
      expect(actualAfterBuy.isBusy, isFalse);
      expect(
        (actualAfterBuy.notice! as ShopActionFailed).errorCode,
        AppErrorCode.cache,
      );
      expect(actualAfterUse, isA<ShopLoaded>());
    });

    test('reads the shop again when the coins change', () async {
      // Arrange
      final ShopWorld world = ShopWorld();
      final ShopCubit cubit = ShopCubit(
        profileId: 'p1',
        useCases: world.useCases,
      );
      await cubit.load();
      final Future<ShopState> actualNext = cubit.stream.first;
      // Act
      world.rewards.totalXp = 400;
      world.rewards.changes.add(null);
      // Assert
      expect(((await actualNext) as ShopLoaded).shop.balance, 40);
      await cubit.close();
    });
  });

  group('Profile card', () {
    testWidgets('shows the coins and opens the shop', (
      WidgetTester tester,
    ) async {
      // Arrange
      int actualOpenings = 0;
      final ShopWorld world = ShopWorld(totalXp: 730);
      await pumpLocalized(
        tester,
        Scaffold(
          body: ShopPages(useCases: world.useCases).buildEntryCard(
            profileId: 'p1',
            onOpen: () => actualOpenings++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Act
      await tester.tap(find.text('Boutique'));
      // Assert
      expect(
        find.text('Avatars et thèmes à débloquer'),
        findsOneWidget,
      );
      expect(find.text('73'), findsOneWidget);
      expect(find.byType(CoinIcon), findsNWidgets(2));
      expect(actualOpenings, 1);
    });
  });

  group('Theme scope', () {
    late ThemeData seenTheme;

    Future<ThemeData> pumpScope(
      WidgetTester tester,
      ShopWorld world, {
      required bool isPlayerActive,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShopPages(useCases: world.useCases).buildThemeScope(
            profileId: 'p1',
            isPlayerActive: isPlayerActive,
            child: Builder(
              builder: (BuildContext context) {
                seenTheme = Theme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return seenTheme;
    }

    testWidgets('paints the app in the theme of the active player', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ShopWorld world = ShopWorld();
      world.repository.theme = AppColorTheme.night;
      // Act
      final ThemeData actualTheme = await pumpScope(
        tester,
        world,
        isPlayerActive: true,
      );
      // Assert
      expect(actualTheme.colorScheme.brightness, Brightness.dark);
      expect(
        actualTheme.scaffoldBackgroundColor,
        AppThemeColors.night.ground,
      );
      // Act: the player applies another theme.
      world.repository.theme = AppColorTheme.forest;
      world.repository.changes.add(null);
      await tester.pumpAndSettle();
      // Assert
      expect(seenTheme.scaffoldBackgroundColor, AppThemeColors.forest.ground);
    });

    testWidgets('keeps lavender once nobody plays', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ShopWorld world = ShopWorld();
      world.repository.theme = AppColorTheme.ocean;
      // Act
      final ThemeData actualTheme = await pumpScope(
        tester,
        world,
        isPlayerActive: false,
      );
      // Assert
      expect(
        actualTheme.scaffoldBackgroundColor,
        AppThemeColors.lavender.ground,
      );
    });
  });
}
