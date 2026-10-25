import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessments_overview.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_assessment_use_cases.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_assessments_state.dart';

/// The assessments of the class [classroomId] in the teacher area: reads
/// them, follows their changes, opens and closes them.
final class ClassAssessmentsCubit extends Cubit<ClassAssessmentsState> {
  /// Creates the Cubit.
  ClassAssessmentsCubit({
    required this._classroomId,
    required this._useCases,
  }) : super(const ClassAssessmentsLoading());

  final String _classroomId;
  final ClassAssessmentUseCases _useCases;
  StreamSubscription<void>? _changes;

  /// Reads the assessments and follows their changes.
  Future<void> load() async {
    _changes ??= _useCases.watchChanges().listen((_) => unawaited(_read()));
    await _read();
  }

  /// Opens an assessment of the period [label].
  Future<void> openAssessment(String label) async {
    final DataState<ClassAssessment> opened = await _useCases.open(
      params: (classroomId: _classroomId, periodLabel: label),
    );
    if (opened case DataFailed<ClassAssessment>(:final exception)) {
      _fail(exception);
      return;
    }
    await _read();
  }

  /// Closes the assessment [assessmentId].
  Future<void> closeAssessment(String assessmentId) async {
    final DataState<void> closed = await _useCases.close(params: assessmentId);
    if (closed case DataFailed<void>(:final exception)) {
      _fail(exception);
      return;
    }
    await _read();
  }

  Future<void> _read() async {
    final DataState<ClassAssessmentsOverview> read = await _useCases
        .getAssessments(params: _classroomId);
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<ClassAssessmentsOverview>(:final data) =>
        ClassAssessmentsLoaded(overview: data),
      DataFailed<ClassAssessmentsOverview>(:final exception) =>
        ClassAssessmentsFailure(errorCode: exception.code),
    });
  }

  void _fail(AppException exception) {
    final ClassAssessmentsState current = state;
    if (isClosed || current is! ClassAssessmentsLoaded) return;
    emit(
      ClassAssessmentsLoaded(
        overview: current.overview,
        failure: exception.code,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
