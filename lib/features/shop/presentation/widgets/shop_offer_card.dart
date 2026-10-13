import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/entities/player_identity.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer_status.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_action_button.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_avatar_builder.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_item_preview.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_labels.dart';

/// One item of the shop grid (mockup 22): its picture, its name for a
/// theme, and its button; outlined while in use.
class ShopOfferCard extends StatelessWidget {
  /// Creates the card of [offer].
  const ShopOfferCard({
    required this.offer,
    required this.player,
    required this.avatarOf,
    required this.onPressed,
    super.key,
  });

  static const double _ringWidth = 3;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSizes.space12,
    AppSizes.space16,
    AppSizes.space12,
    AppSizes.space12,
  );

  /// Item and where the player stands with it.
  final ShopOffer offer;

  /// The player.
  final PlayerIdentity player;

  /// Draws an avatar.
  final ShopAvatarBuilder avatarOf;

  /// Called on a tap of the button; `null` while it does nothing.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String name = offer.item.toName(context.l10n);
    final bool isInUse = offer.status == ShopOfferStatus.inUse;
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(
          color: isInUse ? theme.colorScheme.primary : Colors.transparent,
          width: _ringWidth,
        ),
      ),
      child: Column(
        spacing: 10,
        children: <Widget>[
          ShopItemPreview(item: offer.item, player: player, avatarOf: avatarOf),
          if (offer.item.kind == ShopItemKind.theme)
            ExcludeSemantics(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ShopActionButton(
              offer: offer,
              name: name,
              onPressed: isInUse ? null : onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
