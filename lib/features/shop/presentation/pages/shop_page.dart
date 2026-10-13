import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/constants/app_sizes.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_icon_button.dart';
import 'package:kid_matix/core/widgets/back_to_parent.dart';
import 'package:kid_matix/core/widgets/choice_segments.dart';
import 'package:kid_matix/core/widgets/depth_button.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer_status.dart';
import 'package:kid_matix/features/shop/domain/services/coin_rules.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_cubit.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_state.dart';
import 'package:kid_matix/features/shop/presentation/widgets/coin_balance.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_avatar_builder.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_dialogs.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_error_message.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_item_preview.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_labels.dart';
import 'package:kid_matix/features/shop/presentation/widgets/shop_offer_card.dart';

/// The shop (mockup 22): the player's coins, then the avatars or the
/// themes, two by two, to buy, wear or apply. Coins only, no real money.
class ShopPage extends StatelessWidget {
  /// Creates the page; the shop comes from the enclosing Cubit.
  const ShopPage({required this.avatarOf, required this.onBack, super.key});

  /// Draws the avatars.
  final ShopAvatarBuilder avatarOf;

  /// Goes back to the Profile tab.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return BackToParent(
      onBack: onBack,
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<ShopCubit, ShopState>(
            listenWhen: (ShopState previous, ShopState current) =>
                current is ShopLoaded && current.notice != null,
            listener: _showNotice,
            builder: (BuildContext context, ShopState state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ShopHeader(
                    onBack: onBack,
                    balance: state is ShopLoaded ? state.shop.balance : null,
                  ),
                  Expanded(
                    child: switch (state) {
                      ShopLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      ShopFailure() => _ShopFailureView(state: state),
                      ShopLoaded() => _ShopView(
                        state: state,
                        avatarOf: avatarOf,
                      ),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showNotice(BuildContext context, ShopState state) {
    final ShopNotice? notice = state is ShopLoaded ? state.notice : null;
    final String? message = switch (notice) {
      ShopPurchased(:final item) => context.l10n.shopPurchased(
        item.toName(context.l10n),
      ),
      ShopActionFailed(:final errorCode) => errorCode.toShopMessage(
        context.l10n,
      ),
      null => null,
    };
    if (message != null) showShopMessage(context, message);
  }
}

/// Shows [message] under the shop screen.
void showShopMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.onBack, required this.balance});

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSizes.space24,
    20,
    AppSizes.space24,
    AppSizes.space16,
  );

  final VoidCallback onBack;
  final int? balance;

  @override
  Widget build(BuildContext context) {
    final int? coins = balance;
    return Padding(
      padding: _padding,
      child: Row(
        spacing: AppSizes.space12,
        children: <Widget>[
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: context.l10n.commonBack,
            onPressed: onBack,
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                context.l10n.shopTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          if (coins != null) CoinBalance(balance: coins),
        ],
      ),
    );
  }
}

class _ShopView extends StatelessWidget {
  const _ShopView({required this.state, required this.avatarOf});

  static const int _columnCount = 2;
  static const double _gap = AppSizes.space12;
  static const EdgeInsets _sides = EdgeInsets.symmetric(
    horizontal: AppSizes.space24,
  );

  final ShopLoaded state;
  final ShopAvatarBuilder avatarOf;

  @override
  Widget build(BuildContext context) {
    final List<ShopOffer> offers = state.shop.offersOf(state.tab);
    final int rowCount = (offers.length + _columnCount - 1) ~/ _columnCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: _sides,
          child: ChoiceSegments<ShopItemKind>(
            choices: ShopItemKind.values,
            selected: state.tab,
            labelOf: (ShopItemKind kind) => switch (kind) {
              ShopItemKind.avatar => context.l10n.shopTabAvatars,
              ShopItemKind.theme => context.l10n.shopTabThemes,
            },
            onSelected: context.read<ShopCubit>().selectTab,
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: PageStorageKey<ShopItemKind>(state.tab),
            padding: _sides.copyWith(top: AppSizes.space16, bottom: 20),
            itemCount: rowCount + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == rowCount) return const _EarnHint();
              final int start = index * _columnCount;
              return _ShopRow(
                key: ValueKey<String>(offers[start].item.id),
                offers: offers.sublist(
                  start,
                  (start + _columnCount).clamp(0, offers.length),
                ),
                state: state,
                avatarOf: avatarOf,
                gap: _gap,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShopRow extends StatelessWidget {
  const _ShopRow({
    required this.offers,
    required this.state,
    required this.avatarOf,
    required this.gap,
    super.key,
  });

  final List<ShopOffer> offers;
  final ShopLoaded state;
  final ShopAvatarBuilder avatarOf;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: gap,
        children: <Widget>[
          for (final ShopOffer offer in offers)
            Expanded(
              child: ShopOfferCard(
                offer: offer,
                player: state.shop.player,
                avatarOf: avatarOf,
                onPressed: state.isBusy
                    ? null
                    : () => _onPressed(context, offer),
              ),
            ),
          if (offers.length == 1) const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Future<void> _onPressed(BuildContext context, ShopOffer offer) async {
    final ShopCubit cubit = context.read<ShopCubit>();
    switch (offer.status) {
      case ShopOfferStatus.inUse:
        return;
      case ShopOfferStatus.owned:
        await cubit.use(offer.item);
      case ShopOfferStatus.tooExpensive:
        showShopMessage(
          context,
          context.l10n.shopNotEnoughCoins(offer.missingCoins),
        );
      case ShopOfferStatus.affordable:
        final bool isConfirmed = await confirmPurchase(
          context,
          name: offer.item.toName(context.l10n),
          price: offer.item.price,
          left: state.shop.balance - offer.item.price,
          preview: ShopItemPreview(
            item: offer.item,
            player: state.shop.player,
            avatarOf: avatarOf,
            size: 64,
          ),
        );
        if (isConfirmed) await cubit.buy(offer.item);
    }
  }
}

class _EarnHint extends StatelessWidget {
  const _EarnHint();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.space4),
      child: Text(
        context.l10n.shopEarnHint(
          CoinRules.xpPerCoin,
          CoinRules.coinsPerCrown,
          CoinRules.coinsPerBadge,
        ),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: context.palette.mutedText,
        ),
      ),
    );
  }
}

class _ShopFailureView extends StatelessWidget {
  const _ShopFailureView({required this.state});

  final ShopFailure state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.space24,
          children: <Widget>[
            Semantics(
              liveRegion: true,
              child: Text(
                state.errorCode.toShopMessage(context.l10n),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            DepthButton(
              label: context.l10n.commonRetry,
              onPressed: context.read<ShopCubit>().load,
            ),
          ],
        ),
      ),
    );
  }
}
