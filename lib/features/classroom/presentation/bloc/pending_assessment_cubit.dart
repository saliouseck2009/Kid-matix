import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/classroom/domain/entities/class_assessment.dart';
import 'package:kid_matix/features/classroom/presentation/bloc/class_assessment_use_cases.dart';

/// Reads the assessment the player [profileId] still has to take, and
/// reads it again after each change: `null` for a free player or once it
/// is taken, a failure included (the home then shows nothing).
final class PendingAssessmentCubit extends Cubit<ClassAssessment?> {
  /// Creates the Cubit.
  PendingAssessmentCubit({
    required this._profileId,
    required this._useCases,
  }) : super(null);

  final String _profileId;
  final ClassAssessmentUseCases _useCases;
  StreamSubscription<void>? _changes;

  /// Reads the assessment and follows its changes.
  Future<void> load() async {
    _changes ??= _useCases.watchChanges().listen((_) => unawaited(_read()));
    await _read();
  }

  Future<void> _read() async {
    final DataState<ClassAssessment?> read = await _useCases.getPending(
      params: _profileId,
    );
    if (isClosed) return;
    emit(switch (read) {
      DataSuccess<ClassAssessment?>(:final data) => data,
      DataFailed<ClassAssessment?>() => null,
    });
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
