import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/id_generator.dart';
import 'package:kid_matix/core/usecases/usecase.dart';
import 'package:kid_matix/features/classroom/domain/entities/assignment_entity.dart';
import 'package:kid_matix/features/classroom/domain/repositories/assignment_repository.dart';
import 'package:kid_matix/features/classroom/domain/services/class_item_catalog.dart';
import 'package:kid_matix/features/classroom/domain/usecases/give_assignment_params.dart';

/// Gives a unit to a class: it becomes « Le devoir de la classe », in
/// place of the one before.
///
/// Fails with a `ValidationException` when no domain has the unit.
class GiveAssignmentUseCase
    implements UseCase<DataState<AssignmentEntity>, GiveAssignmentParams> {
  /// Creates the use case.
  const GiveAssignmentUseCase({
    required this._assignments,
    required this._catalog,
    required this._ids,
    required this._clock,
  });

  final AssignmentRepository _assignments;
  final ClassItemCatalog _catalog;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Future<DataState<AssignmentEntity>> call({
    required GiveAssignmentParams params,
  }) async {
    if (_catalog.unitItemKeys(params.unitKey).isEmpty) {
      return const DataFailed<AssignmentEntity>(
        ValidationException(message: 'Unknown unit.'),
      );
    }
    final DateTime now = _clock.now();
    final AssignmentEntity assignment = AssignmentEntity(
      id: _ids.generateId(),
      classroomId: params.classroomId,
      domainId: params.domainId,
      unitKey: params.unitKey,
      createdAt: now,
      updatedAt: now,
      dueAt: switch (params.dueInDays) {
        final int days => DateTime(now.year, now.month, now.day + days),
        null => null,
      },
    );
    return switch (await _assignments.saveAssignment(
      assignment: assignment,
    )) {
      DataSuccess<void>() => DataSuccess<AssignmentEntity>(assignment),
      DataFailed<void>(:final exception) => DataFailed<AssignmentEntity>(
        exception,
      ),
    };
  }
}
