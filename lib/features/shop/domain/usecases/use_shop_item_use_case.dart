import 'package:kid_matix/core/entities/app_color_theme.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/player_avatar_service.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_entity.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_offer.dart';
import 'package:kid_matix/features/shop/domain/repositories/shop_repository.dart';
import 'package:kid_matix/features/shop/domain/usecases/get_shop_use_case.dart';
import 'package:kid_matix/features/shop/domain/usecases/shop_item_params.dart';

/// Puts on an avatar the player owns, or applies a theme they own.
///
/// Fails with a `NotFoundException` for an item the shop does not sell
/// and a `ValidationException` for an item not owned.
class UseShopItemUseCase implements UseCase<DataState<void>, ShopItemParams> {
  /// Creates the use case.
  const UseShopItemUseCase({
    required this._repository,
    required this._getShop,
    required this._players,
  });

  final ShopRepository _repository;
  final GetShopUseCase _getShop;
  final PlayerAvatarService _players;

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
    if (offer == null) {
      return DataFailed<void>(
        NotFoundException(message: 'No item ${params.itemId} in the shop.'),
      );
    }
    if (!offer.isOwned) {
      return DataFailed<void>(
        ValidationException(message: 'Item ${params.itemId} not owned.'),
      );
    }
    return _apply(offer.item, params.profileId);
  }

  Future<DataState<void>> _apply(ShopItem item, String profileId) {
    return switch (item.kind) {
      ShopItemKind.avatar => _players.wearAvatar(
        profileId: profileId,
        avatarKey: item.key,
      ),
      ShopItemKind.theme => _repository.saveActiveTheme(
        profileId: profileId,
        theme: AppColorTheme.values.byName(item.key),
      ),
    };
  }
}
