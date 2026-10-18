import 'dart:async';

import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/core/services/player_avatar_service.dart';
import 'package:kid_matix/core/services/reward_service.dart';
import 'package:kid_matix/features/shop/domain/repositories/shop_repository.dart';

/// Emits an event each time the shop of a player may have changed: a
/// purchase, a theme, an avatar, new XP, a badge or a crown.
class WatchShopChangesUseCase {
  /// Creates the use case.
  const WatchShopChangesUseCase({
    required this._repository,
    required this._rewards,
    required this._crowns,
    required this._players,
  });

  final ShopRepository _repository;
  final RewardService _rewards;
  final CrownService _crowns;
  final PlayerAvatarService _players;

  /// Returns the stream of changes.
  Stream<void> call() {
    final List<StreamSubscription<void>> subscriptions =
        <StreamSubscription<void>>[];
    late final StreamController<void> controller;
    controller = StreamController<void>(
      onListen: () {
        for (final Stream<void> source in <Stream<void>>[
          _repository.watchChanges(),
          _rewards.watchChanges(),
          _crowns.watchChanges(),
          _players.watchChanges(),
        ]) {
          subscriptions.add(source.listen((_) => controller.add(null)));
        }
      },
      onCancel: () async {
        for (final StreamSubscription<void> subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }
}
