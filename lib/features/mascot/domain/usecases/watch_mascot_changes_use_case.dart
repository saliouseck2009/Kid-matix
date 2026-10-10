import 'dart:async';

import 'package:kid_matix/core/services/crown_service.dart';
import 'package:kid_matix/core/services/reward_service.dart';
import 'package:kid_matix/features/mascot/domain/repositories/mascot_repository.dart';

/// Emits an event each time the mascot may have changed: a choice of the
/// child, a new level, badge or crown.
class WatchMascotChangesUseCase {
  /// Creates the use case.
  const WatchMascotChangesUseCase({
    required this._repository,
    required this._rewards,
    required this._crowns,
  });

  final MascotRepository _repository;
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
          _repository.watchChanges(),
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
