import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_entity.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer_status.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_purchase.dart';
import 'package:kid_matix/features/shop/domain/repositories/shop_repository.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_shop_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/shop_item_params.dart';

/// Buys an item of the shop with the player's coins; no real money.
///
/// Fails with a `NotFoundException` for an item the shop does not sell,
/// a `ConflictException` for an item already owned and a
/// `ValidationException` when the player lacks coins.
class BuyShopItemUseCase implements UseCase<DataState<void>, ShopItemParams> {
  /// Creates the use case.
  const BuyShopItemUseCase({
    required this._repository,
    required this._getShop,
    required this._clock,
  });

  final ShopRepository _repository;
  final GetShopUseCase _getShop;
  final Clock _clock;

  @override
  Future<DataState<void>> call({required ShopItemParams params}) async {
    final DataState<ShopEntity> shop = await _getShop(
      params: params.profileId,
    );
    if (shop case DataFailed<ShopEntity>(:final exception)) {
      return DataFailed<void>(exception);
    }
    final ShopOffer? offer = (shop as DataSuccess<ShopEntity>).data.findOffer(
      params.itemId,
    );
    final AppException? problem = _findProblem(offer, params.itemId);
    if (problem != null) return DataFailed<void>(problem);
    return _repository.addPurchase(
      profileId: params.profileId,
      purchase: ShopPurchase(
        itemId: params.itemId,
        price: offer!.item.price,
        purchasedAt: _clock.now(),
      ),
    );
  }

  static AppException? _findProblem(ShopOffer? offer, String itemId) {
    if (offer == null) {
      return NotFoundException(message: 'No item $itemId in the shop.');
    }
    if (offer.isOwned) {
      return ConflictException(message: 'Item $itemId already owned.');
    }
    if (offer.status == ShopOfferStatus.tooExpensive) {
      return ValidationException(message: 'Not enough coins for $itemId.');
    }
    return null;
  }
}
