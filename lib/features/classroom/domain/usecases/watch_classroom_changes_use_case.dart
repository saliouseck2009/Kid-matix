import 'dart:async';

import 'package:kid_matix/core/services/pupil_roster_service.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/class_journal_repository.dart';
import 'package:kid_matix/features/classroom/domain/repositories/classroom_repository.dart';

/// Emits an event each time a class, one of its pupils, its assignments
/// or its results may have changed, so the screens of the class mode
/// read them again.
class WatchClassroomChangesUseCase {
  /// Creates the use case.
  const WatchClassroomChangesUseCase({
    required this._repository,
    required this._roster,
    required this._assignments,
    required this._journal,
  });

  final ClassroomRepository _repository;
  final PupilRosterService _roster;
  final AssignmentRepository _assignments;
  final ClassJournalRepository _journal;

  /// Starts watching; cancel the subscription to stop.
  Stream<void> call() {
    final List<Stream<void>> sources = <Stream<void>>[
      _repository.watchChanges(),
      _roster.watchChanges(),
      _assignments.watchChanges(),
      _journal.watchChanges(),
    ];
    return Stream<void>.multi((MultiStreamController<void> controller) {
      final List<StreamSubscription<void>> subscriptions =
          <StreamSubscription<void>>[
            for (final Stream<void> source in sources)
              source.listen(controller.add),
          ];
      controller.onCancel = () => Future.wait(
        subscriptions.map(
          (StreamSubscription<void> subscription) => subscription.cancel(),
        ),
      );
    });
  }
}
