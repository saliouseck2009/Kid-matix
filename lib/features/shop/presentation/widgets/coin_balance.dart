import 'package:flutter/material.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/shop/presentation/widgets/coin_icon.dart';

/// The coins of the player in a white pill: the coin, then the number.
class CoinBalance extends StatelessWidget {
  /// Creates the pill of [balance] coins.
  const CoinBalance({required this.balance, this.isLarge = true, super.key});

  static const double _largeCoin = 28;
  static const double _smallCoin = 22;

  /// Coins of the player.
  final int balance;

  /// Whether the pill is the large one of the shop header.
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Semantics(
      label: context.l10n.shopCoinBalance(balance),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.space8,
          AppSizes.space8,
          14,
          AppSizes.space8,
        ),
        decoration: BoxDecoration(
          color: isLarge ? theme.colorScheme.surface : context.palette.tint,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: <Widget>[
            CoinIcon(size: isLarge ? _largeCoin : _smallCoin),
            Text(
              '$balance',
              style: isLarge
                  ? theme.textTheme.titleLarge
                  : theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
