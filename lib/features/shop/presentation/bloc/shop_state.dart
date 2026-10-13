import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_entity.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:meta/meta.dart';

/// What the shop screen shows.
@immutable
sealed class ShopState {
  const ShopState();
}

/// The shop is being read.
final class ShopLoading extends ShopState {
  /// Creates the state.
  const ShopLoading();
}

/// The shop of the player, on the tab [tab].
final class ShopLoaded extends ShopState {
  /// Creates the state.
  const ShopLoaded({
    required this.shop,
    this.tab = ShopItemKind.avatar,
    this.isBusy = false,
    this.notice,
  });

  /// Coins and items.
  final ShopEntity shop;

  /// Tab shown: the avatars or the themes.
  final ShopItemKind tab;

  /// Whether a purchase or a choice is being saved.
  final bool isBusy;

  /// What to tell the player once, or `null`.
  final ShopNotice? notice;

  /// Returns a copy on [tab], or busy, without notice.
  ShopLoaded copyWith({ShopItemKind? tab, bool? isBusy, ShopNotice? notice}) {
    return ShopLoaded(
      shop: shop,
      tab: tab ?? this.tab,
      isBusy: isBusy ?? this.isBusy,
      notice: notice,
    );
  }
}

/// The shop could not be read.
final class ShopFailure extends ShopState {
  /// Creates the state.
  const ShopFailure({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}

/// Something to tell the player once, in a message under the screen.
///
/// Each notice is a new object: two equal messages in a row are both
/// shown.
@immutable
sealed class ShopNotice {
  const ShopNotice();
}

/// The player has just bought [item].
final class ShopPurchased extends ShopNotice {
  /// Creates the notice.
  const ShopPurchased({required this.item});

  /// Item bought.
  final ShopItem item;
}

/// A purchase or a choice failed.
final class ShopActionFailed extends ShopNotice {
  /// Creates the notice.
  const ShopActionFailed({required this.errorCode});

  /// Why it failed.
  final AppErrorCode errorCode;
}
