import 'dart:async';

import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/core/services/reward_service.dart';

/// Emits an event each time the progress figures of a player may have
/// changed: a quiz rewarded, a table crowned.
class WatchProgressChangesUseCase {
  /// Creates the use case.
  const WatchProgressChangesUseCase({
    required this._rewards,
    required this._crowns,
  });

  final RewardService _rewards;
  final CrownService _crowns;

  /// Returns the stream of changes.
  Stream<void> call() {
    final List<StreamSubscription<void>> subscriptions =
        <StreamSubscription<void>>[];
    late final StreamController<void> controller;
    controller = StreamController<void>(
      onListen: () {
        for (final Stream<void> source in <Stream<void>>[
          _rewards.watchChanges(),
          _crowns.watchChanges(),
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
