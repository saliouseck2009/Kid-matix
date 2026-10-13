import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_cubit.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_state.dart';
import 'package:kid_matix/features/shop/presentation/widgets/coin_balance.dart';
import 'package:kid_matix/features/shop/presentation/widgets/coin_icon.dart';

/// The card of the Profile tab that opens the shop, with the player's
/// coins.
class ShopEntryCard extends StatelessWidget {
  /// Creates the card; the coins come from the enclosing Cubit.
  const ShopEntryCard({required this.onOpen, super.key});

  static const double _radius = 20;
  static const double _iconBoxSize = 48;
  static const double _coinSize = 30;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppSizes.space16,
    vertical: 14,
  );

  /// Opens the shop.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int? balance = context.select(
      (ShopCubit cubit) => switch (cubit.state) {
        ShopLoaded(:final shop) => shop.balance,
        _ => null,
      },
    );
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(_radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: _padding,
              child: Row(
                spacing: AppSizes.space12,
                children: <Widget>[
                  Container(
                    width: _iconBoxSize,
                    height: _iconBoxSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.palette.warmTint,
                      shape: BoxShape.circle,
                    ),
                    child: const CoinIcon(size: _coinSize),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: <Widget>[
                        Row(
                          spacing: AppSizes.space8,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                context.l10n.shopTitle,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            if (balance != null)
                              CoinBalance(balance: balance, isLarge: false),
                          ],
                        ),
                        Text(
                          context.l10n.shopEntrySubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.palette.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ExcludeSemantics(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: context.palette.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
