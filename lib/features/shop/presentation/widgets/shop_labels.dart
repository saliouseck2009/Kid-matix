import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Names of the items of the shop, as the player reads and hears them.
extension ShopItemLabel on ShopItem {
  /// Returns the name of the avatar or the theme, such as « Renard ».
  String toName(AppLocalizations l10n) {
    return switch (kind) {
      ShopItemKind.avatar => _avatarName(l10n),
      ShopItemKind.theme => _themeName(l10n),
    };
  }

  String _avatarName(AppLocalizations l10n) {
    return switch (key) {
      'fox' => l10n.shopAvatarFox,
      'panda' => l10n.shopAvatarPanda,
      'robot' => l10n.shopAvatarRobot,
      'alien' => l10n.shopAvatarAlien,
      'unicorn' => l10n.shopAvatarUnicorn,
      'dragon' => l10n.shopAvatarDragon,
      'ninja' => l10n.shopAvatarNinja,
      'king' => l10n.shopAvatarKing,
      _ => l10n.avatarOptionLabel(_freeAvatarNumber),
    };
  }

  // The free avatars are named `avatar1` to `avatar12`.
  int get _freeAvatarNumber {
    return int.tryParse(key.replaceFirst(_freeAvatarPrefix, '')) ?? 1;
  }

  String _themeName(AppLocalizations l10n) {
    return switch (AppColorTheme.values.asNameMap()[key]) {
      AppColorTheme.ocean => l10n.shopThemeOcean,
      AppColorTheme.forest => l10n.shopThemeForest,
      AppColorTheme.sunset => l10n.shopThemeSunset,
      AppColorTheme.night => l10n.shopThemeNight,
      AppColorTheme.lavender || null => l10n.shopThemeLavender,
    };
  }
}

const String _freeAvatarPrefix = 'avatar';
