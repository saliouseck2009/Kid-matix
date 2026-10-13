import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Messages of the failures of the shop.
extension ShopErrorMessage on AppErrorCode {
  /// Returns the message shown to the player for this failure.
  String toShopMessage(AppLocalizations l10n) {
    return switch (this) {
      AppErrorCode.cache => l10n.errorStorage,
      AppErrorCode.validation => l10n.shopErrorNotEnoughCoins,
      AppErrorCode.conflict => l10n.shopErrorAlreadyOwned,
      _ => l10n.errorUnknown,
    };
  }
}
