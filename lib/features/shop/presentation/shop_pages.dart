import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/theme/app_theme.dart';
import 'package:kid_matix/features/shop/presentation/bloc/active_theme_cubit.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_cubit.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_use_cases.dart';
import 'package:kid_matix/features/shop/presentation/pages/shop_page.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_avatar_builder.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_entry_card.dart';

/// Builds the shop widgets for the app and the router.
///
/// Created at the composition root with the use cases resolved there, so
/// no widget ever reads the service locator.
final class ShopPages {
  /// Creates the factory.
  const ShopPages({required this._useCases});

  final ShopUseCases _useCases;

  /// The shop of [profileId]; [avatarOf] draws the avatars.
  Widget buildShopPage({
    required String profileId,
    required ShopAvatarBuilder avatarOf,
    required VoidCallback onBack,
  }) {
    return BlocProvider<ShopCubit>(
      create: (_) =>
          ShopCubit(profileId: profileId, useCases: _useCases)..load(),
      child: ShopPage(avatarOf: avatarOf, onBack: onBack),
    );
  }

  /// The card of the Profile tab that opens the shop, with the coins of
  /// [profileId].
  Widget buildEntryCard({
    required String profileId,
    required VoidCallback onOpen,
  }) {
    return BlocProvider<ShopCubit>(
      key: ValueKey<String>('shop-card-$profileId'),
      create: (_) =>
          ShopCubit(profileId: profileId, useCases: _useCases)..load(),
      child: ShopEntryCard(onOpen: onOpen),
    );
  }

  /// Paints [child] in the theme [profileId] applied, as long as
  /// [isPlayerActive]; in the lavender theme otherwise.
  Widget buildThemeScope({
    required String profileId,
    required Widget child,
    bool isPlayerActive = true,
  }) {
    return BlocProvider<ActiveThemeCubit>(
      key: ValueKey<String>('theme-$profileId'),
      create: (_) => ActiveThemeCubit(
        profileId: profileId,
        getActiveTheme: _useCases.getActiveTheme,
        watchChanges: _useCases.watchThemeChanges,
      )..load(),
      child: BlocBuilder<ActiveThemeCubit, AppColorTheme>(
        builder: (BuildContext context, AppColorTheme theme) => Theme(
          data: AppTheme.of(isPlayerActive ? theme : AppColorTheme.lavender),
          child: child,
        ),
      ),
    );
  }
}
