import 'package:flutter/material.dart';
import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_avatar_builder.dart';
import 'package:kid_matix/features/shop/presentation/widgets/theme_swatch.dart';

/// The picture of an item of the shop: the avatar on [player], or the
/// colors of the theme, [size] high.
class ShopItemPreview extends StatelessWidget {
  /// Creates the picture of [item].
  const ShopItemPreview({
    required this.item,
    required this.player,
    required this.avatarOf,
    this.size = 76,
    super.key,
  });

  /// Item drawn.
  final ShopItem item;

  /// The player, whose color the free avatars take.
  final PlayerIdentity player;

  /// Draws an avatar.
  final ShopAvatarBuilder avatarOf;

  /// Height of the picture.
  final double size;

  @override
  Widget build(BuildContext context) {
    return switch (item.kind) {
      ShopItemKind.avatar => avatarOf(
        player.copyWith(avatarKey: item.key),
        size,
      ),
      ShopItemKind.theme => ThemeSwatch(
        theme:
            AppColorTheme.values.asNameMap()[item.key] ??
            AppColorTheme.lavender,
        height: size,
      ),
    };
  }
}
