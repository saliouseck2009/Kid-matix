import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer_status.dart';
import 'package:kid_matix/features/shop/presentation/widgets/coin_icon.dart';

/// The button under an item of the shop (mockup 22): « Porté » or
/// « Actif » outlined in light violet, « Choisir », the price in violet,
/// or the price greyed when the player lacks coins.
class ShopActionButton extends StatelessWidget {
  /// Creates the button of [offer], named [name] for screen readers.
  const ShopActionButton({
    required this.offer,
    required this.name,
    required this.onPressed,
    super.key,
  });

  /// Item and where the player stands with it.
  final ShopOffer offer;

  /// Name of the item.
  final String name;

  /// Called on a tap; `null` for the item in use.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final (Color background, Color foreground) = _colorsOf(context);
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusSmall);
    final TextStyle? style = theme.textTheme.titleMedium?.copyWith(
      color: foreground,
    );
    return Semantics(
      container: true,
      button: offer.status != ShopOfferStatus.inUse,
      label: _spokenLabel(context),
      excludeSemantics: true,
      onTap: onPressed,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: <Widget>[
                  if (!offer.isOwned) const CoinIcon(),
                  Flexible(child: Text(_visibleLabel(context), style: style)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color) _colorsOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return switch (offer.status) {
      ShopOfferStatus.inUse => (
        context.palette.tint,
        context.palette.primaryText,
      ),
      ShopOfferStatus.owned => (
        theme.scaffoldBackgroundColor,
        theme.colorScheme.onSurface,
      ),
      ShopOfferStatus.affordable => (
        theme.colorScheme.primary,
        theme.colorScheme.onPrimary,
      ),
      ShopOfferStatus.tooExpensive => (
        context.palette.lockedSurface,
        context.palette.mutedText,
      ),
    };
  }

  String _visibleLabel(BuildContext context) {
    return switch (offer.status) {
      ShopOfferStatus.inUse => _inUseLabel(context),
      ShopOfferStatus.owned => context.l10n.shopChoose,
      ShopOfferStatus.affordable ||
      ShopOfferStatus.tooExpensive => '${offer.item.price}',
    };
  }

  String _inUseLabel(BuildContext context) {
    return switch (offer.item.kind) {
      ShopItemKind.avatar => context.l10n.shopWorn,
      ShopItemKind.theme => context.l10n.shopActive,
    };
  }

  String _spokenLabel(BuildContext context) {
    final int price = offer.item.price;
    return switch (offer.status) {
      ShopOfferStatus.inUse => switch (offer.item.kind) {
        ShopItemKind.avatar => context.l10n.shopWornLabel(name),
        ShopItemKind.theme => context.l10n.shopActiveLabel(name),
      },
      ShopOfferStatus.owned => context.l10n.shopChooseLabel(name),
      ShopOfferStatus.affordable => context.l10n.shopBuyLabel(name, price),
      ShopOfferStatus.tooExpensive => context.l10n.shopTooExpensiveLabel(
        name,
        price,
      ),
    };
  }
}
