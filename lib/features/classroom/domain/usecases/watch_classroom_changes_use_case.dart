import 'dart:async';

import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';

/// Emits an event each time a class or one of its pupils may have
/// changed, so the screens of the class mode read them again.
class WatchClassroomChangesUseCase {
  /// Creates the use case.
  const WatchClassroomChangesUseCase({
    required this._repository,
    required this._roster,
  });

  final ClassroomRepository _repository;
  final PupilRosterService _roster;

  /// Starts watching; cancel the subscription to stop.
  Stream<void> call() {
    return Stream<void>.multi((MultiStreamController<void> controller) {
      final List<StreamSubscription<void>> subscriptions =
          <StreamSubscription<void>>[
            _repository.watchChanges().listen(controller.add),
            _roster.watchChanges().listen(controller.add),
          ];
      controller.onCancel = () => Future.wait(
        subscriptions.map(
          (StreamSubscription<void> subscription) => subscription.cancel(),
        ),
      );
    });
  }
}
