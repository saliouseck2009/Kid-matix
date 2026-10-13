import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';

/// Asks the player to confirm they buy [name] for [price] coins, keeping
/// [left]; resolves to `true` once confirmed.
Future<bool> confirmPurchase(
  BuildContext context, {
  required String name,
  required int price,
  required int left,
  required Widget preview,
}) async {
  final bool? isConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => ShopPurchaseDialog(
      name: name,
      price: price,
      left: left,
      preview: preview,
    ),
  );
  return isConfirmed ?? false;
}

/// « Acheter Renard ? »: the item, its price and the coins left.
class ShopPurchaseDialog extends StatelessWidget {
  /// Creates the dialog.
  const ShopPurchaseDialog({
    required this.name,
    required this.price,
    required this.left,
    required this.preview,
    super.key,
  });

  /// Name of the item.
  final String name;

  /// Price in coins.
  final int price;

  /// Coins left after the purchase.
  final int left;

  /// Picture of the item.
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.shopBuyTitle(name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSizes.space16,
        children: <Widget>[
          preview,
          Text(context.l10n.shopBuyMessage(price, left)),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.shopBuyConfirm),
        ),
      ],
    );
  }
}
