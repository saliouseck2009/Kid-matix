import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_entity.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item.dart';
import 'package:kid_matix/features/shop/domain/entities/shop_item_kind.dart';
import 'package:kid_matix/features/shop/domain/usecases/shop_item_params.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_state.dart';
import 'package:kid_matix/features/shop/presentation/bloc/shop_use_cases.dart';

/// Reads the shop of a player, follows its changes, and buys, wears or
/// applies its items.
final class ShopCubit extends Cubit<ShopState> {
  /// Creates the Cubit of the shop of [profileId].
  ShopCubit({required this._profileId, required this._useCases})
    : super(const ShopLoading());

  final String _profileId;
  final ShopUseCases _useCases;
  StreamSubscription<void>? _changes;

  /// Reads the shop and follows its changes.
  Future<void> load() async {
    _changes ??= _useCases.watchChanges().listen((_) => unawaited(_reload()));
    if (state is! ShopLoaded) emit(const ShopLoading());
    await _reload();
  }

  /// Shows the items of [tab].
  void selectTab(ShopItemKind tab) {
    if (state case final ShopLoaded loaded) emit(loaded.copyWith(tab: tab));
  }

  /// Buys [item] with the player's coins.
  Future<void> buy(ShopItem item) async {
    final ShopState current = state;
    if (current is! ShopLoaded || current.isBusy) return;
    emit(current.copyWith(isBusy: true));
    final DataState<void> result = await _useCases.buy(
      params: ShopItemParams(profileId: _profileId, itemId: item.id),
    );
    await _finish(result, ShopPurchased(item: item));
  }

  /// Wears [item], an avatar, or applies it, a theme.
  Future<void> use(ShopItem item) async {
    final ShopState current = state;
    if (current is! ShopLoaded || current.isBusy) return;
    emit(current.copyWith(isBusy: true));
    final DataState<void> result = await _useCases.use(
      params: ShopItemParams(profileId: _profileId, itemId: item.id),
    );
    await _finish(result, null);
  }

  Future<void> _finish(DataState<void> result, ShopNotice? success) async {
    switch (result) {
      case DataSuccess<void>():
        await _reload(notice: success);
      case DataFailed<void>(:final exception):
        if (isClosed) return;
        if (state case final ShopLoaded loaded) {
          emit(
            loaded.copyWith(
              isBusy: false,
              notice: ShopActionFailed(errorCode: exception.code),
            ),
          );
        }
    }
  }

  Future<void> _reload({ShopNotice? notice}) async {
    final DataState<ShopEntity> read = await _useCases.getShop(
      params: _profileId,
    );
    if (isClosed) return;
    final ShopState current = state;
    emit(switch (read) {
      DataSuccess<ShopEntity>(:final data) => ShopLoaded(
        shop: data,
        tab: current is ShopLoaded ? current.tab : ShopItemKind.avatar,
        notice: notice,
      ),
      DataFailed<ShopEntity>(:final exception) => ShopFailure(
        errorCode: exception.code,
      ),
    });
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
