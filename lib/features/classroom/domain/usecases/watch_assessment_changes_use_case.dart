import 'dart:async';

import 'package:kid_matix/features/classroom/domain/repositories/assessment_repository.dart';
import 'package:kid_matix/features/classroom/domain/usecases/watch_classroom_changes_use_case.dart';

/// Emits an event each time a class, its pupils, its results, its
/// assessments or their results may have changed.
class WatchAssessmentChangesUseCase {
  /// Creates the use case.
  const WatchAssessmentChangesUseCase({
    required this._classroom,
    required this._assessments,
  });

  final WatchClassroomChangesUseCase _classroom;
  final AssessmentRepository _assessments;

  /// Starts watching; cancel the subscription to stop.
  Stream<void> call() {
    final List<Stream<void>> sources = <Stream<void>>[
      _classroom(),
      _assessments.watchChanges(),
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
